import 'dart:async';

import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/features/user/marriage/model/regards_package_model.dart';
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
      // 1. Initiate purchase on backend to get pendingId
      final response = await _apiService.post(
        endPoint: ApiEndPoint.initiatePurchase,
        data: {
          'productId': productId,
          'platform': platform,
          'packageId': package.id,
        },
      );

      if (response['success'] != true) {
        emit(
          state.copyWith(
            status: RegardsPackagePurchaseStatus.error,
            error: response['message']?.toString() ?? 'فشل بدء عملية الشراء',
          ),
        );
        return;
      }

      final pendingId = response['data']?['pendingId'] as String? ?? '';

      // 2. Trigger IAP flow
      await _iapService.buyProduct(productId, uniqueNumber: pendingId);

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
