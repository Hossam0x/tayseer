import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/wallet/data/models/transaction_model.dart';
import 'package:tayseer/features/advisor/wallet/data/models/wallet_model.dart';

enum WalletStatus { initial, loading, loaded, error }

class WalletState extends Equatable {
  final WalletStatus status;
  final WalletModel? walletData;
  final List<TransactionModel> allTransactions;
  final String? errorMessage;

  const WalletState({
    this.status = WalletStatus.initial,
    this.walletData,
    this.allTransactions = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    status,
    walletData,
    allTransactions,
    errorMessage,
  ];

  WalletState copyWith({
    WalletStatus? status,
    WalletModel? walletData,
    List<TransactionModel>? allTransactions,
    String? errorMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      walletData: walletData ?? this.walletData,
      allTransactions: allTransactions ?? this.allTransactions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Helper getters to keep UI working if it expects these
  List<TransactionModel> get walletTransactions =>
      walletData?.transactions ?? [];
  List<TransactionModel> get bookingTransactions => allTransactions;
}
