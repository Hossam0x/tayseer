import 'dart:developer';
import 'dart:io';

import 'package:tayseer/core/services/iap_service.dart';
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

  Future<void> purchasePackage(RegardsPackageModel package) async {
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

    final platform = Platform.isIOS ? 'ios' : 'android';

    try {
      log('[RegardsPurchase] ════════════════════════════════════════');
      log('[RegardsPurchase] 🛒 PURCHASE FLOW START');
      log('[RegardsPurchase]   productId : $productId');
      log('[RegardsPurchase]   packageId : ${package.id}');
      log('[RegardsPurchase]   platform  : $platform');
      log('[RegardsPurchase] ────────────────────────────────────────');

      // 1️⃣ Initiate purchase on backend → get pendingId
      log('[RegardsPurchase] 📤 Calling /iap/initiate-purchase...');
      Map<String, dynamic> initiateResponse;
      try {
        initiateResponse = await _apiService.post(
          endPoint: '/iap/initiate-purchase',
          data: {'productId': productId, 'platform': platform},
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
