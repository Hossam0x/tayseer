// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
// ignore: unused_import
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  final Map<String, Completer<PurchaseDetails>> _completers = {};
  final Map<String, DateTime> _processedIds = {};

  bool _initialized = false;
  bool _isPurchasing = false;
  bool _storeAvailable = false;

  String? _pendingUniqueNumber;
  String? _pendingProductId;
  DateTime? _lastSuccessTime;

  bool get isPurchasing => _isPurchasing;
  bool get isInitialized => _initialized;
  bool get storeAvailable => _storeAvailable;

  Future<void> init() async {
    if (_initialized) return;

    _storeAvailable = await _iap.isAvailable();
    log('[IAP] Store available: $_storeAvailable');
    if (!_storeAvailable) return;

    if (Platform.isIOS) {
      final iosAddition = _iap
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosAddition.setDelegate(PaymentQueueDelegate());
    }

    await _sub?.cancel();
    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _sub?.cancel(),
      onError: _onStreamError,
    );
    _initialized = true;
    log('[IAP] ✅ Initialized');

    await _clearPendingTransactions();
  }

  Future<void> _clearPendingTransactions() async {
    if (!Platform.isIOS) return;
    try {
      final txns = await SKPaymentQueueWrapper().transactions();
      log('[IAP] Pending iOS transactions: ${txns.length}');
      for (final t in txns) {
        // Clear ALL non-purchasing states + any purchasing for same product
        final shouldFinish =
            t.transactionState == SKPaymentTransactionStateWrapper.purchased ||
            t.transactionState == SKPaymentTransactionStateWrapper.restored ||
            t.transactionState == SKPaymentTransactionStateWrapper.failed ||
            t.transactionState == SKPaymentTransactionStateWrapper.purchasing ||
            t.transactionState == SKPaymentTransactionStateWrapper.deferred;
        if (shouldFinish) {
          try {
            await SKPaymentQueueWrapper().finishTransaction(t);
            log(
              '[IAP] Finished pending: ${t.transactionIdentifier} state=${t.transactionState}',
            );
          } catch (e) {
            log('[IAP] Could not finish ${t.transactionIdentifier}: $e');
          }
        }
      }
    } catch (e) {
      log('[IAP] Error clearing pending: $e');
    }
  }

  Future<ProductDetails> _fetchProduct(String productId) async {
    log('[IAP] Querying product: $productId');
    final response = await _iap.queryProductDetails({productId});

    if (response.error != null) {
      log('[IAP] ❌ Query error: ${response.error!.message}');
      throw Exception('فشل تحميل المنتج: ${response.error!.message}');
    }

    log('[IAP] notFoundIDs: ${response.notFoundIDs}');
    log('[IAP] found: ${response.productDetails.map((p) => p.id).toList()}');

    if (response.productDetails.isEmpty) {
      throw Exception('المنتج غير موجود في المتجر: $productId');
    }

    return response.productDetails.first;
  }

  Future<PurchaseDetails> buyProduct(
    String productId, {
    required String uniqueNumber,
  }) async {
    if (!_initialized) await init();

    if (!_storeAvailable) throw Exception('المتجر غير متوفر');
    if (!_initialized) throw Exception('فشل تهيئة خدمة الشراء');
    if (_isPurchasing) throw Exception('يوجد عملية شراء جارية بالفعل');

    log('[IAP] 🛒 buyProduct: $productId | pendingId: $uniqueNumber');

    final product = await _fetchProduct(productId);

    // Setup state BEFORE calling buyConsumable
    _completers.clear();
    final completer = Completer<PurchaseDetails>();
    _completers[uniqueNumber] = completer;
    _pendingUniqueNumber = uniqueNumber;
    _pendingProductId = productId;
    _isPurchasing = true;

    // Clear any stale pending transactions before starting a new purchase
    await _clearPendingTransactions();

    // Call buyConsumable — on iOS this just enqueues the payment,
    // the actual result comes via purchaseStream, NOT as a return value.
    // Any exception here is a setup error (not a payment error).
    bool buyStarted = false;
    try {
      buyStarted = await _iap.buyConsumable(
        purchaseParam: PurchaseParam(
          productDetails: product,
          applicationUserName: uniqueNumber,
        ),
        autoConsume: true,
      );
      log('[IAP] buyConsumable returned: $buyStarted');
    } catch (e, st) {
      log('[IAP] ❌ buyConsumable threw: $e\n$st');
      // If completer already resolved by stream (race condition), ignore
      if (!completer.isCompleted) {
        _completers.remove(uniqueNumber);
        _clearPendingState();
        throw Exception('فشل بدء عملية الشراء: $e');
      }
    }

    // buyConsumable returning false means payment couldn't be queued
    if (!buyStarted && !completer.isCompleted) {
      _completers.remove(uniqueNumber);
      _clearPendingState();
      throw Exception('فشل إضافة عملية الشراء إلى قائمة الانتظار');
    }

    // Wait for purchaseStream to deliver the result (up to 5 min)
    return completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () {
        log('[IAP] ⏰ Purchase timed out');
        _completers.remove(uniqueNumber);
        _clearPendingState();
        throw TimeoutException('انتهت مهلة عملية الشراء');
      },
    );
  }

  void _onPurchaseUpdate(List<PurchaseDetails> list) {
    log('[IAP] 📥 ${list.length} purchase update(s)');
    for (final p in list) {
      _handlePurchase(p);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    log(
      '[IAP] ▶ status=${purchase.status} | product=${purchase.productID} | purchaseID=${purchase.purchaseID}',
    );

    final now = DateTime.now();
    _processedIds.removeWhere((_, t) => now.difference(t).inSeconds > 5);

    final pid = purchase.purchaseID;

    // Already processed recently
    if (pid != null && _processedIds.containsKey(pid)) {
      log('[IAP] Already processed, skipping');
      await _completePurchase(purchase);
      return;
    }

    // No active session
    if (!_isPurchasing && _completers.isEmpty) {
      log('[IAP] No active session, completing and ignoring');
      await _completePurchase(purchase);
      return;
    }

    // Product mismatch
    if (_pendingProductId != null && purchase.productID != _pendingProductId) {
      log('[IAP] Product mismatch, ignoring');
      await _completePurchase(purchase);
      return;
    }

    // Duplicate success within 3s
    if (_lastSuccessTime != null &&
        now.difference(_lastSuccessTime!).inSeconds < 3) {
      log('[IAP] Duplicate success, ignoring');
      await _completePurchase(purchase);
      return;
    }

    // Use applicationUserName (pendingId sent to Apple) as key first,
    // fallback to _pendingUniqueNumber
    String? appUserName;
    if (Platform.isIOS && purchase is AppStorePurchaseDetails) {
      appUserName = purchase.skPaymentTransaction.payment.applicationUsername;
    }
    final key = (appUserName?.isNotEmpty == true)
        ? appUserName!
        : (_pendingUniqueNumber ?? '');

    log('[IAP] Using key: $key | completers: ${_completers.keys.toList()}');

    switch (purchase.status) {
      case PurchaseStatus.pending:
        log('[IAP] ⏳ Pending...');

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        log('[IAP] ✅ Purchased!');
        if (pid != null) _processedIds[pid] = now;
        _lastSuccessTime = now;
        await _completePurchase(purchase);
        _resolve(key, purchase);

      case PurchaseStatus.error:
        log(
          '[IAP] ❌ Error: ${purchase.error?.message} | code: ${purchase.error?.code} | details: ${purchase.error?.details}',
        );
        if (pid != null) _processedIds[pid] = now;
        await _completePurchase(purchase);
        _reject(key, purchase.error?.message ?? 'حدث خطأ أثناء الشراء');

      case PurchaseStatus.canceled:
        log('[IAP] ⚠️ Canceled by user');
        if (pid != null) _processedIds[pid] = now;
        await _completePurchase(purchase);
        _reject(key, 'تم إلغاء عملية الشراء');
    }
  }

  Future<void> _completePurchase(PurchaseDetails p) async {
    if (p.pendingCompletePurchase) {
      try {
        await _iap.completePurchase(p);
      } catch (e) {
        log('[IAP] Error completing purchase: $e');
      }
    }
  }

  void _resolve(String key, PurchaseDetails purchase) {
    final completer = _completers[key] ?? _completers.values.firstOrNull;
    if (completer != null && !completer.isCompleted) {
      completer.complete(purchase);
    }
    _completers.remove(key);
    _clearPendingState();
  }

  void _reject(String key, String message) {
    final completer = _completers[key] ?? _completers.values.firstOrNull;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(Exception(message));
    }
    _completers.remove(key);
    _clearPendingState();
  }

  void _onStreamError(dynamic error) {
    log('[IAP] Stream error: $error');
    _reject(_pendingUniqueNumber ?? '', 'خطأ في عملية الشراء: $error');
  }

  void _clearPendingState() {
    _isPurchasing = false;
    _pendingUniqueNumber = null;
    _pendingProductId = null;
  }

  void cancelCurrentPurchase() {
    if (_pendingUniqueNumber != null) {
      _reject(_pendingUniqueNumber!, 'تم إلغاء عملية الشراء');
    }
    _completers.clear();
    _clearPendingState();
  }

  Future<void> restorePurchases() => _iap.restorePurchases();

  void dispose() {
    _sub?.cancel();
    _sub = null;
    _completers.clear();
    _processedIds.clear();
    _initialized = false;
    _clearPendingState();
    _lastSuccessTime = null;
  }
}

class PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) => true;

  @override
  bool shouldShowPriceConsent() => false;
}

class IAPErrorResult {
  final String message;
  final bool isCanceled;
  const IAPErrorResult({required this.message, this.isCanceled = false});
}

class IAPErrorHandler {
  static IAPErrorResult handle(dynamic error) {
    final s = error.toString().toLowerCase();
    log('[IAP] IAPErrorHandler: $error');
    if (s.contains('user_canceled') ||
        s.contains('canceled') ||
        s.contains('cancelled') ||
        s.contains('تم إلغاء') ||
        s.contains('إلغاء')) {
      return const IAPErrorResult(
        message: 'تم إلغاء عملية الشراء',
        isCanceled: true,
      );
    }
    if (s.contains('network') ||
        s.contains('connection') ||
        s.contains('internet')) {
      return const IAPErrorResult(
        message: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
      );
    }
    if (s.contains('timeout') ||
        s.contains('مهلة') ||
        s.contains('timed out')) {
      return const IAPErrorResult(message: 'انتهت مهلة العملية. حاول مرة أخرى');
    }
    if (s.contains('already in progress') || s.contains('جارية')) {
      return const IAPErrorResult(message: 'يوجد عملية شراء جارية بالفعل');
    }
    if (s.contains('غير موجود') || s.contains('not found')) {
      return const IAPErrorResult(message: 'المنتج غير متوفر في المتجر حالياً');
    }
    return const IAPErrorResult(message: 'حدث خطأ غير متوقع. حاول مرة أخرى');
  }
}
