import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/wallet/data/models/transaction_model.dart';

enum WalletStatus { initial, loading, loaded, error }

class WalletState extends Equatable {
  final WalletStatus status;
  final List<TransactionModel> walletTransactions;
  final List<TransactionModel> bookingTransactions;
  final String? errorMessage;

  const WalletState({
    this.status = WalletStatus.initial,
    this.walletTransactions = const [],
    this.bookingTransactions = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    status,
    walletTransactions,
    bookingTransactions,
    errorMessage,
  ];

  WalletState copyWith({
    WalletStatus? status,
    List<TransactionModel>? walletTransactions,
    List<TransactionModel>? bookingTransactions,
    String? errorMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      walletTransactions: walletTransactions ?? this.walletTransactions,
      bookingTransactions: bookingTransactions ?? this.bookingTransactions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
