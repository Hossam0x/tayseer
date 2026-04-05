import 'package:tayseer/features/advisor/wallet/data/models/transaction_model.dart';

/// Base class for wallet socket events
abstract class WalletSocketEvent {
  const WalletSocketEvent();
}

/// Event: advisorWalletUpdate
/// Fired when balance/points change — includes the new transaction
class AdvisorWalletUpdateEvent extends WalletSocketEvent {
  final int points;
  final int balance;
  final String? currency;
  final TransactionModel? transaction;

  const AdvisorWalletUpdateEvent({
    required this.points,
    required this.balance,
    this.currency,
    this.transaction,
  });

  factory AdvisorWalletUpdateEvent.fromJson(Map<String, dynamic> json) {
    final txJson = json['transaction'];
    return AdvisorWalletUpdateEvent(
      points: (json['points'] as num?)?.toInt() ?? 0,
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String?,
      transaction: txJson != null
          ? TransactionModel.fromJson(Map<String, dynamic>.from(txJson as Map))
          : null,
    );
  }
}
