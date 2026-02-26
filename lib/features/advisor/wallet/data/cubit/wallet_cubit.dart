import 'package:tayseer/features/advisor/wallet/data/cubit/wallet_state.dart';
import 'package:tayseer/features/advisor/wallet/data/repos/wallet_repo.dart';
import 'package:tayseer/my_import.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepo _walletRepo;

  WalletCubit(this._walletRepo) : super(const WalletState());

  Future<void> getWallet() async {
    emit(state.copyWith(status: WalletStatus.loading));
    final result = await _walletRepo.getWallet();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: WalletStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (walletData) => emit(
        state.copyWith(status: WalletStatus.loaded, walletData: walletData),
      ),
    );
  }

  Future<void> getAllTransactions({int page = 1}) async {
    // If it's the first page, we might want to show a loading state
    if (page == 1) {
      emit(state.copyWith(status: WalletStatus.loading));
    }

    final result = await _walletRepo.getTransactions(page: page);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: WalletStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (transactions) {
        if (page == 1) {
          emit(
            state.copyWith(
              status: WalletStatus.loaded,
              allTransactions: transactions,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: WalletStatus.loaded,
              allTransactions: [...state.allTransactions, ...transactions],
            ),
          );
        }
      },
    );
  }

  Future<void> loadAllData() async {
    emit(state.copyWith(status: WalletStatus.loading));

    // We can run them in parallel
    await Future.wait([getWallet(), getAllTransactions()]);
  }
}
