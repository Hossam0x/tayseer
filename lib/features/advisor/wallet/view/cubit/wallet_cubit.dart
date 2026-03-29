import 'package:tayseer/features/advisor/wallet/view/cubit/wallet_state.dart';
import 'package:tayseer/features/advisor/wallet/data/repos/wallet_repo.dart';
import 'package:tayseer/my_import.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepo _walletRepo;

  WalletCubit(this._walletRepo) : super(const WalletState());

  Future<void> loadInitialData() async {
    await Future.wait([
      fetchWallet(),
      fetchTransactions(refresh: true, limit: 5),
      fetchEarnings(refresh: true, limit: 9),
    ]);
  }

  Future<void> fetchWallet() async {
    emit(state.copyWith(walletStatus: WalletStatus.loading));
    final result = await _walletRepo.getWallet();
    result.fold(
      (f) => emit(
        state.copyWith(
          walletStatus: WalletStatus.error,
          walletError: f.message,
        ),
      ),
      (data) => emit(
        state.copyWith(walletStatus: WalletStatus.loaded, walletData: data),
      ),
    );
  }

  Future<void> fetchTransactions({bool refresh = false, int limit = 15}) async {
    if (!refresh && state.transactionsStatus == ListStatus.loadingMore) return;

    final isFirstPage =
        refresh || state.transactionsStatus == ListStatus.initial;
    final nextPage = isFirstPage
        ? 1
        : (state.transactionsPagination?.currentPage ?? 0) + 1;

    if (!isFirstPage && state.transactionsPagination?.hasNextPage == false) {
      return;
    }

    emit(
      state.copyWith(
        transactionsStatus: isFirstPage
            ? ListStatus.loading
            : ListStatus.loadingMore,
      ),
    );

    final result = await _walletRepo.getTransactions(
      page: nextPage,
      limit: limit,
    );
    result.fold(
      (f) => emit(
        state.copyWith(
          transactionsStatus: ListStatus.error,
          transactionsError: f.message,
        ),
      ),
      (paginated) => emit(
        state.copyWith(
          transactionsStatus: ListStatus.loaded,
          transactions: isFirstPage
              ? paginated.data
              : [...state.transactions, ...paginated.data],
          transactionsPagination: paginated.pagination,
        ),
      ),
    );
  }

  Future<void> fetchEarnings({bool refresh = false, int limit = 15}) async {
    if (!refresh && state.earningsStatus == ListStatus.loadingMore) return;

    final isFirstPage = refresh || state.earningsStatus == ListStatus.initial;
    final nextPage = isFirstPage
        ? 1
        : (state.earningsPagination?.currentPage ?? 0) + 1;

    if (!isFirstPage && state.earningsPagination?.hasNextPage == false) {
      return;
    }

    emit(
      state.copyWith(
        earningsStatus: isFirstPage
            ? ListStatus.loading
            : ListStatus.loadingMore,
      ),
    );

    final result = await _walletRepo.getEarnings(page: nextPage, limit: limit);
    result.fold(
      (f) => emit(
        state.copyWith(
          earningsStatus: ListStatus.error,
          earningsError: f.message,
        ),
      ),
      (paginated) => emit(
        state.copyWith(
          earningsStatus: ListStatus.loaded,
          earnings: isFirstPage
              ? paginated.data
              : [...state.earnings, ...paginated.data],
          earningsPagination: paginated.pagination,
        ),
      ),
    );
  }

  // Legacy compat used by withdraw_cubit etc.
  Future<void> getWallet() => fetchWallet();
  Future<void> getAllTransactions({int page = 1}) =>
      fetchTransactions(refresh: page == 1);
  Future<void> loadAllData() => loadInitialData();
}
