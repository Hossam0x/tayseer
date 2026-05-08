import 'dart:async';
import 'dart:io';

import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/features/advisor/wallet/data/repos/wallet_repo.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/recharge_state.dart';
import 'package:tayseer/my_import.dart';

class RechargeCubit extends Cubit<RechargeState> {
  final WalletRepo _walletRepo;
  final IAPService _iapService;

  RechargeCubit(this._walletRepo, this._iapService)
    : super(const RechargeState());

  Future<void> fetchPackages() async {
    emit(state.copyWith(status: RechargeStatus.loading));
    // Init IAP early so the purchase stream is ready before user taps buy
    unawaited(_iapService.init());
    final result = await _walletRepo.getBalancePackages();
    result.fold(
      (f) =>
          emit(state.copyWith(status: RechargeStatus.error, error: f.message)),
      (packages) => emit(
        state.copyWith(status: RechargeStatus.loaded, packages: packages),
      ),
    );
  }

  void selectPackage(int index) {
    emit(state.copyWith(selectedIndex: index));
  }

  Future<void> purchaseSelectedPackage() async {
    final index = state.selectedIndex;
    if (index == null || index >= state.packages.length) return;

    final package = state.packages[index];
    // appleProductId holds the store product ID e.g. "com.app.balance.100"
    final productId = package.appleProductId;

    if (productId.isEmpty) {
      emit(
        state.copyWith(
          status: RechargeStatus.error,
          error: 'معرف المنتج غير متوفر',
        ),
      );
      return;
    }

    emit(state.copyWith(status: RechargeStatus.purchasing));

    final platform = Platform.isIOS ? 'ios' : 'android';

    // Step 1: Initiate purchase on backend → get pendingId
    final initiateResult = await _walletRepo.initiatePurchase(
      productId: productId,
      platform: platform,
    );

    if (initiateResult.isLeft()) {
      initiateResult.fold(
        (f) => emit(
          state.copyWith(status: RechargeStatus.error, error: f.message),
        ),
        (_) {},
      );
      return;
    }

    final pendingId = initiateResult.getOrElse(() => '');

    // Step 2: Send pendingId to Apple/Google as applicationUserName
    try {
      await _iapService.buyProduct(productId, uniqueNumber: pendingId);
      // Purchase confirmed by Apple — success
      emit(state.copyWith(status: RechargeStatus.success, clearSelected: true));
    } catch (e) {
      final err = IAPErrorHandler.handle(e);
      emit(
        state.copyWith(
          status: err.isCanceled
              ? RechargeStatus.canceled
              : RechargeStatus.error,
          error: err.isCanceled ? null : err.messageKey,
        ),
      );
    }
  }

  void resetStatus() {
    emit(state.copyWith(status: RechargeStatus.loaded));
  }
}
