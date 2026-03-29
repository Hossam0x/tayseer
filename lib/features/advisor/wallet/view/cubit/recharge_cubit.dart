import 'package:tayseer/features/advisor/wallet/data/repos/wallet_repo.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/recharge_state.dart';
import 'package:tayseer/my_import.dart';

class RechargeCubit extends Cubit<RechargeState> {
  final WalletRepo _walletRepo;

  RechargeCubit(this._walletRepo) : super(const RechargeState());

  Future<void> fetchPackages() async {
    emit(state.copyWith(status: RechargeStatus.loading));
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
}
