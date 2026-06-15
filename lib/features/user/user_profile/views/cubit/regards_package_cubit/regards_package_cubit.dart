import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/core/services/one_time_payment/one_time_payment_cubit.dart';
import 'package:tayseer/features/user/marriage/model/regards_package_model.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_event_bus.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/regards_package_cubit/regards_package_state.dart';
import 'package:tayseer/my_import.dart';

class RegardsPackagePurchaseCubit extends Cubit<RegardsPackagePurchaseState> {
  final IAPService _iapService;
  final ApiService _apiService;

  RegardsPackagePurchaseCubit(this._iapService, this._apiService)
    : super(const RegardsPackagePurchaseState());

  void resetStatus() => emit(const RegardsPackagePurchaseState());

  Future<void> purchasePackage(
    RegardsPackageModel package, {
    BuildContext? context,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    if (Platform.isAndroid) {
      await _purchaseAndroid(
        package,
        context: context,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
    } else {
      await _purchaseIOS(package);
    }
  }

  // ── Android: Paymob WebView ───────────────────────────────────────────────

  Future<void> _purchaseAndroid(
    RegardsPackageModel package, {
    BuildContext? context,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    if (context == null || !context.mounted) {
      emit(
        state.copyWith(
          status: RegardsPackagePurchaseStatus.error,
          error: 'unexpected_error',
        ),
      );
      return;
    }

    emit(state.copyWith(status: RegardsPackagePurchaseStatus.purchasing));

    log('[RegardsPurchase-Android] ════════════════════════════════════════');
    log('[RegardsPurchase-Android] 🌐 ANDROID PAYMOB FLOW');
    log('[RegardsPurchase-Android]   packageId : ${package.id}');
    log('[RegardsPurchase-Android] ════════════════════════════════════════');

    final oneTimeCubit = OneTimePaymentCubit(_apiService);

    await oneTimeCubit.pay(
      context: context,
      productId: package.id,
      productType: OneTimeProductType.regardsPackage,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );

    if (isClosed) {
      oneTimeCubit.close();
      return;
    }

    final result = oneTimeCubit.state;
    oneTimeCubit.close();

    switch (result.status) {
      case OneTimePaymentStatus.success:
        MarriageEventBus.instance.refreshRegards();
        emit(state.copyWith(status: RegardsPackagePurchaseStatus.success));

      case OneTimePaymentStatus.canceled:
        emit(state.copyWith(status: RegardsPackagePurchaseStatus.canceled));

      case OneTimePaymentStatus.profileIncomplete:
        emit(
          state.copyWith(
            status: RegardsPackagePurchaseStatus.profileIncomplete,
          ),
        );

      case OneTimePaymentStatus.error:
        emit(
          state.copyWith(
            status: RegardsPackagePurchaseStatus.error,
            error: result.error ?? 'unexpected_error',
          ),
        );

      case OneTimePaymentStatus.initial:
      case OneTimePaymentStatus.loading:
        emit(
          state.copyWith(
            status: RegardsPackagePurchaseStatus.error,
            error: 'unexpected_error',
          ),
        );
    }
  }

  // ── iOS: Apple IAP (SK2 native consumable) ────────────────────────────────

  Future<void> _purchaseIOS(RegardsPackageModel package) async {
    final productId = package.appleProductId;
    if (productId.isEmpty) {
      emit(
        state.copyWith(
          status: RegardsPackagePurchaseStatus.error,
          error: 'معرف المنتج غير متوفر',
        ),
      );
      return;
    }

    emit(state.copyWith(status: RegardsPackagePurchaseStatus.purchasing));

    // تهيئة الـ IAP service قبل الشراء
    try {
      await _iapService.init();
    } catch (e) {
      log('[RegardsPurchase] ❌ IAP init failed: $e');
      emit(
        state.copyWith(
          status: RegardsPackagePurchaseStatus.error,
          error: 'store_unavailable',
        ),
      );
      return;
    }

    try {
      log('[RegardsPurchase] ════════════════════════════════════════');
      log('[RegardsPurchase] 🛒 iOS PURCHASE FLOW START');
      log('[RegardsPurchase]   productId : $productId');
      log('[RegardsPurchase]   packageId : ${package.id}');
      log('[RegardsPurchase] ────────────────────────────────────────');

      // 1️⃣ Initiate purchase on backend → get pendingId
      log('[RegardsPurchase] 📤 Calling /iap/initiate-purchase...');
      Map<String, dynamic> initiateResponse;
      try {
        initiateResponse = await _apiService.post(
          endPoint: '/iap/initiate-purchase',
          data: {'productId': productId, 'platform': 'ios'},
        );
      } catch (e) {
        log('[RegardsPurchase] ❌ initiate-purchase failed: $e');
        emit(
          state.copyWith(
            status: RegardsPackagePurchaseStatus.error,
            error: 'فشل تسجيل عملية الشراء',
          ),
        );
        return;
      }

      if (initiateResponse['success'] != true) {
        log(
          '[RegardsPurchase] ❌ initiate-purchase error: ${initiateResponse['message']}',
        );
        emit(
          state.copyWith(
            status: RegardsPackagePurchaseStatus.error,
            error: 'فشل تسجيل عملية الشراء',
          ),
        );
        return;
      }

      final pendingId = initiateResponse['data']?['pendingId'] as String? ?? '';
      if (pendingId.isEmpty) {
        log('[RegardsPurchase] ❌ pendingId is empty');
        emit(
          state.copyWith(
            status: RegardsPackagePurchaseStatus.error,
            error: 'فشل تسجيل عملية الشراء',
          ),
        );
        return;
      }

      log('[RegardsPurchase] ✅ pendingId: $pendingId');
      log('[RegardsPurchase] 📲 appAccountToken → Apple: $pendingId');
      log('[RegardsPurchase] ════════════════════════════════════════');

      // 2️⃣ نستخدم native SK2 channel عشان appAccountToken يتبعت صح في الـ webhook
      await _iapService.buyConsumableNative(
        productId: productId,
        appAccountToken: pendingId,
      );

      // أطلق event عشان الـ MarriageProfileCubit يعمل silent reload ويحدث الـ regardsLeft
      MarriageEventBus.instance.refreshRegards();

      emit(state.copyWith(status: RegardsPackagePurchaseStatus.success));
    } catch (e) {
      final err = IAPErrorHandler.handle(e);
      emit(
        state.copyWith(
          status: err.isCanceled
              ? RegardsPackagePurchaseStatus.canceled
              : RegardsPackagePurchaseStatus.error,
          error: err.isCanceled ? null : err.messageKey,
        ),
      );
    }
  }
}
