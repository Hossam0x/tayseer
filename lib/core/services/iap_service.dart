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

  // Set during restoreAndCollect to intercept restored transactions
  void Function(PurchaseDetails)? _restoreCollector;

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

    // Only clear pending transactions when NOT in restore mode.
    // During restore, we want to receive the restored transactions.
    if (_restoreCollector == null) {
      await _clearPendingTransactions();
    }
  }

  Future<void> _clearPendingTransactions() async {
    if (!Platform.isIOS) return;
    try {
      final txns = await SKPaymentQueueWrapper().transactions();
      log('[IAP] Pending iOS transactions: ${txns.length}');
      for (final t in txns) {
        // ✅ لا تـ finish الـ purchasing state — Apple مش بتسمح بده
        // فقط finished/failed/restored/deferred
        final shouldFinish =
            t.transactionState == SKPaymentTransactionStateWrapper.purchased ||
            t.transactionState == SKPaymentTransactionStateWrapper.restored ||
            t.transactionState == SKPaymentTransactionStateWrapper.failed ||
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

  /// Purchases a subscription product.
  ///
  /// Uses [buyNonConsumable] for subscriptions — this is the correct API for
  /// Auto-Renewable Subscriptions on iOS. The purchase will appear in
  /// Apple's Subscriptions settings and can be restored.
  ///
  /// Note: If the user already has an active subscription, Apple will return
  /// [PurchaseStatus.restored] instead of [purchased] — both are treated as
  /// success.
  Future<PurchaseDetails> buyProduct(
    String productId, {
    required String uniqueNumber,
  }) async {
    if (!_initialized) await init();

    if (!_storeAvailable) throw Exception('المتجر غير متوفر');
    if (!_initialized) throw Exception('فشل تهيئة خدمة الشراء');
    if (_isPurchasing) throw Exception('يوجد عملية شراء جارية بالفعل');

    log('[IAP] ════════════════════════════════════════');
    log('[IAP] 🛒 SENDING TO APPLE');
    log('[IAP]   productId        : $productId');
    log('[IAP]   applicationUserName (pendingId): $uniqueNumber');
    log('[IAP] ════════════════════════════════════════');

    final product = await _fetchProduct(productId);

    log('[IAP] 📦 Product details from Apple:');
    log('[IAP]   id          : ${product.id}');
    log('[IAP]   title       : ${product.title}');
    log('[IAP]   description : ${product.description}');
    log('[IAP]   price       : ${product.price}');
    log('[IAP]   currencyCode: ${product.currencyCode}');
    log('[IAP]   rawPrice    : ${product.rawPrice}');

    _completers.clear();
    final completer = Completer<PurchaseDetails>();
    _completers[uniqueNumber] = completer;
    _pendingUniqueNumber = uniqueNumber;
    _pendingProductId = productId;
    _isPurchasing = true;

    // Clear stale pending transactions before starting
    // ثم نستنى لحد ما الـ queue تبقى فاضية (max 3 ثواني)
    await _clearPendingTransactions();
    if (Platform.isIOS) {
      const maxWait = Duration(seconds: 3);
      const checkInterval = Duration(milliseconds: 300);
      final deadline = DateTime.now().add(maxWait);
      while (DateTime.now().isBefore(deadline)) {
        await Future.delayed(checkInterval);
        final remaining = await SKPaymentQueueWrapper().transactions();
        final hasPending = remaining.any(
          (t) =>
              t.transactionState ==
                  SKPaymentTransactionStateWrapper.purchased ||
              t.transactionState == SKPaymentTransactionStateWrapper.restored,
        );
        if (!hasPending) {
          log('[IAP] ✅ Queue is clear — proceeding with purchase');
          break;
        }
        log(
          '[IAP] ⏳ Waiting for queue to clear... (${remaining.length} remaining)',
        );
      }
    }

    bool buyStarted = false;
    try {
      log(
        '[IAP] ▶ Calling buyNonConsumable with applicationUserName=$uniqueNumber',
      );
      buyStarted = await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(
          productDetails: product,
          applicationUserName: uniqueNumber,
        ),
      );
      log('[IAP] buyNonConsumable returned: $buyStarted');
    } catch (e, st) {
      log('[IAP] ❌ buyNonConsumable threw: $e\n$st');
      if (!completer.isCompleted) {
        _completers.remove(uniqueNumber);
        _clearPendingState();
        throw Exception('فشل بدء عملية الشراء: $e');
      }
    }

    if (!buyStarted && !completer.isCompleted) {
      _completers.remove(uniqueNumber);
      _clearPendingState();
      throw Exception('فشل إضافة عملية الشراء إلى قائمة الانتظار');
    }

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
    // ── Full debug dump of everything Apple returned ──────────────────────
    log('[IAP] ════════════════════════════════════════');
    log('[IAP] 📩 RECEIVED FROM APPLE');
    log('[IAP]   status          : ${purchase.status}');
    log('[IAP]   productID       : ${purchase.productID}');
    log('[IAP]   purchaseID      : ${purchase.purchaseID}');
    log('[IAP]   transactionDate : ${purchase.transactionDate}');
    log('[IAP]   pendingComplete : ${purchase.pendingCompletePurchase}');
    log(
      '[IAP]   verificationData.source          : ${purchase.verificationData.source}',
    );
    log(
      '[IAP]   verificationData.localVerificationData (length): ${purchase.verificationData.localVerificationData.length}',
    );
    log(
      '[IAP]   verificationData.serverVerificationData (length): ${purchase.verificationData.serverVerificationData.length}',
    );

    if (Platform.isIOS && purchase is AppStorePurchaseDetails) {
      final txn = purchase.skPaymentTransaction;
      final payment = txn.payment;
      log(
        '[IAP]   [iOS] transactionIdentifier  : ${txn.transactionIdentifier}',
      );
      log('[IAP]   [iOS] transactionState       : ${txn.transactionState}');
      log('[IAP]   [iOS] transactionTimeStamp   : ${txn.transactionTimeStamp}');
      log(
        '[IAP]   [iOS] payment.productIdentifier   : ${payment.productIdentifier}',
      );
      log(
        '[IAP]   [iOS] payment.applicationUsername : ${payment.applicationUsername}',
      );
      log('[IAP]   [iOS] payment.quantity            : ${payment.quantity}');
      if (txn.originalTransaction != null) {
        log(
          '[IAP]   [iOS] originalTransaction.identifier: ${txn.originalTransaction!.transactionIdentifier}',
        );
      }
    }
    log('[IAP] ════════════════════════════════════════');
    // ─────────────────────────────────────────────────────────────────────

    final now = DateTime.now();
    _processedIds.removeWhere((_, t) => now.difference(t).inSeconds > 5);

    final pid = purchase.purchaseID;

    // Already processed recently
    if (pid != null && _processedIds.containsKey(pid)) {
      log('[IAP] Already processed, skipping');
      await _completePurchase(purchase);
      return;
    }

    // No active purchase session — forward to restore collector if active
    if (!_isPurchasing && _completers.isEmpty) {
      if (purchase.status == PurchaseStatus.restored &&
          _restoreCollector != null) {
        log('[IAP] Forwarding to restore collector: ${purchase.productID}');
        _restoreCollector!(purchase);
      } else {
        log('[IAP] No active session, completing and ignoring');
      }
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

    // Resolve using applicationUserName (pendingId) first, then fallback
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
        // Both purchased and restored are treated as success.
        // iOS returns "restored" when the user already has an active
        // subscription and tries to purchase again — this is expected.
        log('[IAP] ✅ Purchased/Restored!');
        if (pid != null) _processedIds[pid] = now;
        _lastSuccessTime = now;
        await _completePurchase(purchase);
        _resolve(key, purchase);

      case PurchaseStatus.error:
        log(
          '[IAP] ❌ Error: ${purchase.error?.message} | code: ${purchase.error?.code}',
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
        log('[IAP] ✅ completePurchase sent to Apple for: ${p.purchaseID}');
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

  /// Triggers Apple restore and collects all restored transactions.
  ///
  /// Sets [_restoreCollector] BEFORE [init] so transactions arriving during
  /// initialization are captured. Also skips [_clearPendingTransactions]
  /// during restore to avoid finishing restored transactions prematurely.
  Future<List<PurchaseDetails>> restoreAndCollect({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final List<PurchaseDetails> collected = [];
    final completer = Completer<List<PurchaseDetails>>();
    Timer? idleTimer;

    void scheduleComplete() {
      idleTimer?.cancel();
      idleTimer = Timer(const Duration(seconds: 3), () {
        if (!completer.isCompleted) {
          _restoreCollector = null;
          completer.complete(List.unmodifiable(collected));
        }
      });
    }

    // Set collector BEFORE init — this also prevents _clearPendingTransactions
    _restoreCollector = (purchase) {
      collected.add(purchase);
      scheduleComplete();
    };

    final safetyTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        _restoreCollector = null;
        idleTimer?.cancel();
        completer.complete(List.unmodifiable(collected));
      }
    });

    try {
      await init();
      if (!_storeAvailable) {
        _restoreCollector = null;
        idleTimer?.cancel();
        safetyTimer.cancel();
        throw Exception('store_unavailable');
      }

      await _iap.restorePurchases();

      // Start idle timer — fires if Apple delivers 0 transactions
      scheduleComplete();

      return await completer.future;
    } finally {
      safetyTimer.cancel();
      idleTimer?.cancel();
      _restoreCollector = null;
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
    _completers.clear();
    _processedIds.clear();
    _initialized = false;
    _clearPendingState();
    _lastSuccessTime = null;
    _restoreCollector = null;
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
  final String messageKey; // localization key
  final bool isCanceled;
  const IAPErrorResult({required this.messageKey, this.isCanceled = false});
}

class IAPErrorHandler {
  static IAPErrorResult handle(dynamic error) {
    final s = error.toString().toLowerCase();
    log('[IAP] IAPErrorHandler: $error');

    // ── إلغاء من المستخدم ──────────────────────────────────────────────────
    if (s.contains('user_canceled') ||
        s.contains('canceled') ||
        s.contains('cancelled') ||
        s.contains('تم إلغاء') ||
        s.contains('إلغاء')) {
      return const IAPErrorResult(
        messageKey: 'purchase_cancelled',
        isCanceled: true,
      );
    }

    // ── transaction مكررة (pending لنفس المنتج) ───────────────────────────
    if (s.contains('duplicate_product') ||
        s.contains('storekit_duplicate') ||
        s.contains('pending transaction')) {
      return const IAPErrorResult(messageKey: 'purchase_duplicate');
    }

    // ── عملية شراء جارية بالفعل ───────────────────────────────────────────
    if (s.contains('already in progress') || s.contains('جارية')) {
      return const IAPErrorResult(messageKey: 'purchase_in_progress');
    }

    // ── الشراء غير مسموح (parental controls, etc.) ────────────────────────
    if (s.contains('not_allowed') ||
        s.contains('payment_not_allowed') ||
        s.contains('purchases are not allowed')) {
      return const IAPErrorResult(messageKey: 'purchase_not_allowed');
    }

    // ── مشكلة شبكة ────────────────────────────────────────────────────────
    if (s.contains('network') ||
        s.contains('connection') ||
        s.contains('internet') ||
        s.contains('storekitd') || // NSCocoaErrorDomain Code=4097 (Simulator)
        s.contains('nscocoaerrordomain')) {
      return const IAPErrorResult(messageKey: 'check_internet_connection');
    }

    // ── timeout ───────────────────────────────────────────────────────────
    if (s.contains('timeout') ||
        s.contains('مهلة') ||
        s.contains('timed out')) {
      return const IAPErrorResult(messageKey: 'operation_timeout');
    }

    // ── المنتج غير موجود ──────────────────────────────────────────────────
    if (s.contains('غير موجود') ||
        s.contains('not found') ||
        s.contains('invalid product')) {
      return const IAPErrorResult(messageKey: 'purchase_invalid_product');
    }

    // ── المتجر غير متوفر ──────────────────────────────────────────────────
    if (s.contains('store_unavailable') || s.contains('unavailable')) {
      return const IAPErrorResult(messageKey: 'store_unavailable');
    }

    // ── بيانات المستخدم مش موجودة ─────────────────────────────────────────
    if (s.contains('uuid') || s.contains('user data')) {
      return const IAPErrorResult(messageKey: 'purchase_user_data_missing');
    }

    return const IAPErrorResult(messageKey: 'unexpected_error');
  }
}
