import 'dart:developer';

import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/core/shared/network/local_network.dart';
import 'package:tayseer/features/user/marriage/model/regards_package_model.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_event_bus.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/regards_package_cubit/regards_package_state.dart';
import 'package:tayseer/my_import.dart';

class RegardsPackagePurchaseCubit extends Cubit<RegardsPackagePurchaseState> {
  final IAPService _iapService;

  RegardsPackagePurchaseCubit(this._iapService)
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

    try {
      // قراءة الـ uuid من الكاش — نفس الطريقة المستخدمة في باقات الاشتراك
      final uuid = CachNetwork.getStringData(key: kUuid);

      log('[RegardsPurchase] ════════════════════════════════════════');
      log('[RegardsPurchase] 🛒 PURCHASE FLOW START');
      log('[RegardsPurchase]   productId : $productId');
      log('[RegardsPurchase]   packageId : ${package.id}');
      log(
        '[RegardsPurchase]   uuid      : ${uuid.isNotEmpty ? uuid : "⚠️ EMPTY"}',
      );
      log('[RegardsPurchase] ════════════════════════════════════════');

      if (uuid.isEmpty) {
        emit(
          state.copyWith(
            status: RegardsPackagePurchaseStatus.error,
            error: 'purchase_user_data_missing',
          ),
        );
        return;
      }

      // Trigger IAP flow مباشرة بالـ uuid من الكاش
      // نستخدم native SK2 channel عشان appAccountToken يتبعت صح في الـ webhook
      await _iapService.buyConsumableNative(
        productId: productId,
        appAccountToken: uuid,
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
