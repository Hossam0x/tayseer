import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/wallet/data/models/transaction_model.dart';
import 'package:tayseer/features/advisor/wallet/data/models/wallet_model.dart';

enum WalletStatus { initial, loading, loaded, error }

enum ListStatus { initial, loading, loaded, loadingMore, error }

class WalletState extends Equatable {
  final WalletStatus walletStatus;
  final WalletModel? walletData;
  final String? walletError;

  // Transactions tab
  final ListStatus transactionsStatus;
  final List<TransactionModel> transactions;
  final PaginationModel? transactionsPagination;
  final String? transactionsError;

  // Earnings tab
  final ListStatus earningsStatus;
  final List<TransactionModel> earnings;
  final PaginationModel? earningsPagination;
  final String? earningsError;

  const WalletState({
    this.walletStatus = WalletStatus.initial,
    this.walletData,
    this.walletError,
    this.transactionsStatus = ListStatus.initial,
    this.transactions = const [],
    this.transactionsPagination,
    this.transactionsError,
    this.earningsStatus = ListStatus.initial,
    this.earnings = const [],
    this.earningsPagination,
    this.earningsError,
  });

  // Convenience getters for wallet_view preview (limit 10)
  List<TransactionModel> get previewTransactions =>
      transactions.take(10).toList();
  List<TransactionModel> get previewEarnings => earnings.take(10).toList();

  // Legacy compat
  WalletStatus get status => walletStatus;

  @override
  List<Object?> get props => [
    walletStatus,
    walletData,
    walletError,
    transactionsStatus,
    transactions,
    transactionsPagination,
    transactionsError,
    earningsStatus,
    earnings,
    earningsPagination,
    earningsError,
  ];

  WalletState copyWith({
    WalletStatus? walletStatus,
    WalletModel? walletData,
    String? walletError,
    ListStatus? transactionsStatus,
    List<TransactionModel>? transactions,
    PaginationModel? transactionsPagination,
    String? transactionsError,
    ListStatus? earningsStatus,
    List<TransactionModel>? earnings,
    PaginationModel? earningsPagination,
    String? earningsError,
  }) {
    return WalletState(
      walletStatus: walletStatus ?? this.walletStatus,
      walletData: walletData ?? this.walletData,
      walletError: walletError ?? this.walletError,
      transactionsStatus: transactionsStatus ?? this.transactionsStatus,
      transactions: transactions ?? this.transactions,
      transactionsPagination:
          transactionsPagination ?? this.transactionsPagination,
      transactionsError: transactionsError ?? this.transactionsError,
      earningsStatus: earningsStatus ?? this.earningsStatus,
      earnings: earnings ?? this.earnings,
      earningsPagination: earningsPagination ?? this.earningsPagination,
      earningsError: earningsError ?? this.earningsError,
    );
  }
}
