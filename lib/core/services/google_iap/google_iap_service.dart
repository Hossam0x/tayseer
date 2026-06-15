import 'dart:async';
import 'dart:developer';

import 'package:in_app_purchase/in_app_purchase.dart';

typedef GooglePurchaseResult = ({String productId, String purchaseToken});

class GoogleIAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  final Map<String, Completer<PurchaseDetails>> _completers = {};
  bool _initialized = false;
  bool _storeAvailable = false;
  bool _isPurchasing = false;
  String? _pendingKey;

  bool get isAvailable => _storeAvailable;

  Future<void> init() async {
    if (_initialized) return;
    _storeAvailable = await _iap.isAvailable();
    if (!_storeAvailable) return;
    await _sub?.cancel();
    _sub = _iap.purchaseStream.listen(
      _onUpdate,
      onDone: () => _sub?.cancel(),
      onError: _onStreamError,
    );
    _initialized = true;
    log('[GoogleIAP] ✅ Initialized');
  }

  Future<ProductDetails> _fetchProduct(String productId) async {
    log('[GoogleIAP] Querying product: $productId');
    final response = await _iap.queryProductDetails({productId});
    if (response.error != null) {
      throw Exception('فشل تحميل المنتج: ${response.error!.message}');
    }
    if (response.productDetails.isEmpty) {
      throw Exception('المنتج غير موجود في المتجر: $productId');
    }
    return response.productDetails.first;
  }

  /// Android subscription purchase.
  /// [pendingId] is sent as applicationUserName → obfuscatedAccountId in Google Play.
  /// Backend receives it via S2S notification to link the purchase.
  Future<PurchaseDetails> buySubscription(
    String productId, {
    required String pendingId,
  }) async {
    await init();
    if (!_storeAvailable) throw Exception('store_unavailable');
    if (_isPurchasing) throw Exception('purchase_in_progress');

    log('[GoogleIAP] 🛒 SUBSCRIPTION: $productId | pendingId: $pendingId');

    final product = await _fetchProduct(productId);
    _isPurchasing = true;
    _pendingKey = pendingId;
    final completer = Completer<PurchaseDetails>();
    _completers[pendingId] = completer;

    final started = await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: product,
        applicationUserName: pendingId,
      ),
    );

    if (!started && !completer.isCompleted) {
      _clear(pendingId);
      throw Exception('purchase_start_failed');
    }

    return completer.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () {
        _clear(pendingId);
        throw TimeoutException('operation_timeout');
      },
    );
  }

  /// Android consumable purchase.
  /// Returns [GooglePurchaseResult] with productId and purchaseToken for backend verification.
  Future<GooglePurchaseResult> buyConsumable(String productId) async {
    await init();
    if (!_storeAvailable) throw Exception('store_unavailable');
    if (_isPurchasing) throw Exception('purchase_in_progress');

    log('[GoogleIAP] 🛒 CONSUMABLE: $productId');

    final product = await _fetchProduct(productId);
    _isPurchasing = true;
    _pendingKey = productId;
    final completer = Completer<PurchaseDetails>();
    _completers[productId] = completer;

    final started = await _iap.buyConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );

    if (!started && !completer.isCompleted) {
      _clear(productId);
      throw Exception('purchase_start_failed');
    }

    final purchase = await completer.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () {
        _clear(productId);
        throw TimeoutException('operation_timeout');
      },
    );

    final token = purchase.verificationData.serverVerificationData;
    log('[GoogleIAP] ✅ Consumable token length: ${token.length}');
    return (productId: purchase.productID, purchaseToken: token);
  }

  void _onUpdate(List<PurchaseDetails> list) {
    for (final p in list) {
      _handlePurchase(p);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    log('[GoogleIAP] 📩 status=${purchase.status} productId=${purchase.productID}');

    if (purchase.pendingCompletePurchase) {
      try {
        await _iap.completePurchase(purchase);
        log('[GoogleIAP] ✅ completePurchase sent');
      } catch (e) {
        log('[GoogleIAP] completePurchase error: $e');
      }
    }

    if (!_isPurchasing && _completers.isEmpty) return;

    final key = _pendingKey ?? '';

    switch (purchase.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        log('[GoogleIAP] ✅ Purchased: ${purchase.productID}');
        _resolve(key, purchase);

      case PurchaseStatus.error:
        log('[GoogleIAP] ❌ Error: ${purchase.error?.message}');
        _reject(key, purchase.error?.message ?? 'purchase_error');

      case PurchaseStatus.canceled:
        log('[GoogleIAP] ⚠️ Canceled');
        _reject(key, 'تم إلغاء عملية الشراء');

      case PurchaseStatus.pending:
        log('[GoogleIAP] ⏳ Pending...');
    }
  }

  void _resolve(String key, PurchaseDetails purchase) {
    final completer = _completers[key] ?? _completers.values.firstOrNull;
    if (completer != null && !completer.isCompleted) {
      completer.complete(purchase);
    }
    _clear(key);
  }

  void _reject(String key, String message) {
    final completer = _completers[key] ?? _completers.values.firstOrNull;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(Exception(message));
    }
    _clear(key);
  }

  void _clear(String key) {
    _completers.remove(key);
    _isPurchasing = false;
    _pendingKey = null;
  }

  void _onStreamError(dynamic error) {
    log('[GoogleIAP] Stream error: $error');
    _reject(_pendingKey ?? '', 'purchase_stream_error');
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
    _completers.clear();
    _isPurchasing = false;
    _pendingKey = null;
    _initialized = false;
  }
}
