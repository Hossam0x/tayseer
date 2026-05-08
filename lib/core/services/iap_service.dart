// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:in_app_purchase_storekit/src/sk2_pigeon.g.dart';
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

    // StoreKit 1 only: set payment queue delegate
    // مع StoreKit 2 ده مش مطلوب لكن مش بيضر
    if (Platform.isIOS) {
      try {
        final iosAddition = _iap
            .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await iosAddition.setDelegate(PaymentQueueDelegate());
      } catch (e) {
        // StoreKit 2 قد لا يدعم setDelegate — نتجاهل الخطأ
        log('[IAP] setDelegate skipped (StoreKit 2 mode): $e');
      }
    }

    await _sub?.cancel();
    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _sub?.cancel(),
      onError: _onStreamError,
    );
    _initialized = true;
    log('[IAP] ✅ Initialized');

    // StoreKit 1 only: clear pending transactions
    // مع StoreKit 2 ده مش مطلوب — Apple بتتعامل مع الـ queue تلقائياً
    if (_restoreCollector == null) {
      await _clearPendingTransactions();
    }
  }

  /// StoreKit 1 only — مع StoreKit 2 ده no-op
  Future<void> _clearPendingTransactions() async {
    if (!Platform.isIOS) return;
    try {
      final txns = await SKPaymentQueueWrapper().transactions();
      log('[IAP] Pending iOS transactions: ${txns.length}');
      for (final t in txns) {
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
      // StoreKit 2 بيرمي exception هنا — نتجاهله
      log('[IAP] _clearPendingTransactions skipped: $e');
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
  /// مع StoreKit 2: [uniqueNumber] بيتحط كـ applicationUserName
  /// وبيرجع في الـ JWS payload كـ appAccountToken (UUID format).
  ///
  /// ملاحظة: Apple بتطلب الـ applicationUserName يكون UUID v4 مع StoreKit 2.
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

    // ✅ Set _isPurchasing BEFORE clearing completers to prevent race condition
    // لو double-tap حصل، الـ check فوق هيمنع الثاني من الوصول لهنا
    _isPurchasing = true;
    _completers.clear();
    final completer = Completer<PurchaseDetails>();
    _completers[uniqueNumber] = completer;
    _pendingUniqueNumber = uniqueNumber;
    _pendingProductId = productId;

    // StoreKit 1 only: clear pending queue before purchase
    await _clearPendingTransactions();

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
        // ✅ لو الـ error هو cancelled، نرمي exception بالاسم الصح
        final errStr = e.toString().toLowerCase();
        if (errStr.contains('cancelled') ||
            errStr.contains('canceled') ||
            errStr.contains('storekit2_purchase_cancelled')) {
          throw Exception('تم إلغاء عملية الشراء');
        }
        throw Exception('فشل بدء عملية الشراء: $e');
      }
    }

    if (!buyStarted && !completer.isCompleted) {
      _completers.remove(uniqueNumber);
      _clearPendingState();
      throw Exception('فشل إضافة عملية الشراء إلى قائمة الانتظار');
    }

    return completer.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () {
        log('[IAP] ⏰ Purchase timed out after 2 minutes');
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
    // ── Full debug dump ───────────────────────────────────────────────────
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
      '[IAP]   verificationData.serverVerificationData (length): ${purchase.verificationData.serverVerificationData.length}',
    );

    // StoreKit 1 details (مش موجودة مع StoreKit 2)
    if (Platform.isIOS && purchase is AppStorePurchaseDetails) {
      final txn = purchase.skPaymentTransaction;
      final payment = txn.payment;
      log(
        '[IAP]   [SK1] transactionIdentifier  : ${txn.transactionIdentifier}',
      );
      log('[IAP]   [SK1] transactionState       : ${txn.transactionState}');
      log(
        '[IAP]   [SK1] payment.applicationUsername : ${payment.applicationUsername}',
      );
      if (txn.originalTransaction != null) {
        log(
          '[IAP]   [SK1] originalTransaction.identifier: ${txn.originalTransaction!.transactionIdentifier}',
        );
      }
    }

    // StoreKit 2 details
    if (Platform.isIOS && purchase is SK2PurchaseDetails) {
      log('[IAP]   [SK2] purchaseID: ${purchase.purchaseID}');
      // الـ serverVerificationData هو الـ JWS (JWT) — ده اللي بنبعته للباك-إند
      final jws = purchase.verificationData.serverVerificationData;
      log('[IAP]   [SK2] JWS length: ${jws.length}');
      log(
        '[IAP]   [SK2] JWS preview: ${jws.length > 50 ? '${jws.substring(0, 50)}...' : jws}',
      );
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
      log(
        '[IAP] Product mismatch (got ${purchase.productID}, expected $_pendingProductId)',
      );

      // ── StoreKit 2 behavior ───────────────────────────────────────────────
      // مع StoreKit 2، لما تشتري subscription جديدة وعندك existing subscription
      // في نفس الـ Apple account، Apple بتبعت الـ existing subscription كـ
      // purchased event أولاً. ده سلوك Apple الطبيعي مش bug.
      //
      // الحل: لو الـ status هو purchased/restored وعندنا pending purchase،
      // نعتبره success — Apple بتعمل الـ switch تلقائياً من جهتها،
      // والـ backend بيعرف عن طريق server-to-server notifications.
      if (Platform.isIOS &&
          purchase is SK2PurchaseDetails &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored)) {
        log(
          '[IAP] SK2 cross-subscription event — treating as success for pending purchase',
        );
        final now2 = DateTime.now();
        if (pid != null) _processedIds[pid] = now2;
        _lastSuccessTime = now2;
        await _completePurchase(purchase);
        final key2 = _pendingUniqueNumber ?? '';
        _resolve(key2, purchase);
        return;
      }

      // StoreKit 1 أو non-purchased status → تجاهل
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

    // Resolve key:
    // StoreKit 1: applicationUserName من الـ payment
    // StoreKit 2: purchaseID أو _pendingUniqueNumber
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
  /// مع StoreKit 2: بعد الـ restore، بنجيب الـ JWS مباشرة من
  /// [InAppPurchase2API.transactions()] لأن الـ Flutter package
  /// مش بيملأ [serverVerificationData] في الـ SK2 transactions.
  ///
  /// الـ JWS هو [SK2TransactionMessage.jsonRepresentation] — JWT موقع من Apple.
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

      scheduleComplete();

      final purchases = await completer.future;

      // ── StoreKit 2: جيب الـ JWS من native layer ──────────────────────────
      // الـ Flutter package بيحط serverVerificationData فاضي في SK2
      // لكن الـ JWS موجود في SK2TransactionMessage.jsonRepresentation
      if (Platform.isIOS && purchases.any((p) => p is SK2PurchaseDetails)) {
        return await _enrichSK2WithJWS(purchases);
      }

      return purchases;
    } finally {
      safetyTimer.cancel();
      idleTimer?.cancel();
      _restoreCollector = null;
    }
  }

  /// يجيب الـ JWS لكل SK2 transaction من الـ native layer
  /// عن طريق method channel مخصص يستخدم Transaction.currentEntitlements
  Future<List<PurchaseDetails>> _enrichSK2WithJWS(
    List<PurchaseDetails> purchases,
  ) async {
    try {
      log('[IAP] 🔍 Fetching JWS via native method channel...');

      const channel = MethodChannel('com.athr.tayser/iap_jws');
      final List<dynamic> rawList = await channel.invokeMethod(
        'getCurrentEntitlementsJWS',
      );

      log('[IAP] Native entitlements count: ${rawList.length}');

      // Map: transactionId → JWS
      final jwsMap = <String, String>{};
      for (final item in rawList) {
        if (item is Map) {
          final txnId = item['transactionId']?.toString() ?? '';
          final jws = item['jws']?.toString() ?? '';
          if (txnId.isNotEmpty && jws.isNotEmpty) {
            jwsMap[txnId] = jws;
            log('[IAP] Entitlement $txnId → JWS length: ${jws.length}');
            log(
              '[IAP] JWS preview: ${jws.length > 30 ? '${jws.substring(0, 30)}...' : jws}',
            );
          }
        }
      }

      // أضف الـ JWS لكل SK2PurchaseDetails
      return purchases.map((p) {
        if (p is SK2PurchaseDetails) {
          final jws = jwsMap[p.purchaseID];
          if (jws != null && jws.isNotEmpty) {
            log('[IAP] ✅ Enriched SK2 purchase ${p.purchaseID} with JWS');
            return SK2PurchaseDetails(
              productID: p.productID,
              purchaseID: p.purchaseID,
              verificationData: PurchaseVerificationData(
                localVerificationData: jws,
                serverVerificationData: jws,
                source: 'app_store',
              ),
              transactionDate: p.transactionDate,
              status: p.status,
            );
          }
          log('[IAP] ⚠️ No JWS found for SK2 purchase ${p.purchaseID}');
        }
        return p;
      }).toList();
    } catch (e) {
      log('[IAP] ❌ Failed to enrich SK2 with JWS: $e');
      return purchases;
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

    if (s.contains('user_canceled') ||
        s.contains('canceled') ||
        s.contains('cancelled') ||
        s.contains('storekit2_purchase_cancelled') ||
        s.contains('تم إلغاء') ||
        s.contains('إلغاء')) {
      return const IAPErrorResult(
        messageKey: 'purchase_cancelled',
        isCanceled: true,
      );
    }

    if (s.contains('duplicate_product') ||
        s.contains('storekit_duplicate') ||
        s.contains('pending transaction')) {
      return const IAPErrorResult(messageKey: 'purchase_duplicate');
    }

    if (s.contains('already in progress') || s.contains('جارية')) {
      return const IAPErrorResult(messageKey: 'purchase_in_progress');
    }

    if (s.contains('not_allowed') ||
        s.contains('payment_not_allowed') ||
        s.contains('purchases are not allowed')) {
      return const IAPErrorResult(messageKey: 'purchase_not_allowed');
    }

    if (s.contains('network') ||
        s.contains('connection') ||
        s.contains('internet') ||
        s.contains('storekitd') ||
        s.contains('nscocoaerrordomain')) {
      return const IAPErrorResult(messageKey: 'check_internet_connection');
    }

    if (s.contains('timeout') ||
        s.contains('مهلة') ||
        s.contains('timed out')) {
      return const IAPErrorResult(messageKey: 'operation_timeout');
    }

    if (s.contains('غير موجود') ||
        s.contains('not found') ||
        s.contains('invalid product')) {
      return const IAPErrorResult(messageKey: 'purchase_invalid_product');
    }

    if (s.contains('store_unavailable') || s.contains('unavailable')) {
      return const IAPErrorResult(messageKey: 'store_unavailable');
    }

    if (s.contains('uuid') || s.contains('user data')) {
      return const IAPErrorResult(messageKey: 'purchase_user_data_missing');
    }

    return const IAPErrorResult(messageKey: 'unexpected_error');
  }
}
