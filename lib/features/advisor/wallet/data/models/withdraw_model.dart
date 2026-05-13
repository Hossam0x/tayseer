class WithdrawModel {
  final String id;
  final double amount;
  final String currency;
  final WithdrawStatus status;
  final DateTime createdAt;

  WithdrawModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  factory WithdrawModel.fromJson(Map<String, dynamic> json) {
    return WithdrawModel(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      status: WithdrawStatus.fromApiValue(json['status'] ?? 'pending'),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

enum WithdrawMethod {
  bankAccount,
  stcPay,
  urPay,
  instaPay,
  vodafoneCash,
  etisalatCash,
  orangeCash;

  /// Maps the API string value to the enum
  static WithdrawMethod fromApiValue(String value) {
    switch (value.toUpperCase()) {
      case 'BANK_TRANSFER':
        return WithdrawMethod.bankAccount;
      case 'STC_PAY':
        return WithdrawMethod.stcPay;
      case 'UR_PAY':
        return WithdrawMethod.urPay;
      case 'INSTAPAY':
        return WithdrawMethod.instaPay;
      case 'VODAFONE_CASH':
        return WithdrawMethod.vodafoneCash;
      case 'ETISALAT_CASH':
        return WithdrawMethod.etisalatCash;
      case 'ORANGE_CASH':
        return WithdrawMethod.orangeCash;
      default:
        return WithdrawMethod.bankAccount;
    }
  }

  /// Maps the enum back to the API string value
  String toApiValue() {
    switch (this) {
      case WithdrawMethod.bankAccount:
        return 'BANK_TRANSFER';
      case WithdrawMethod.stcPay:
        return 'STC_PAY';
      case WithdrawMethod.urPay:
        return 'UR_PAY';
      case WithdrawMethod.instaPay:
        return 'INSTAPAY';
      case WithdrawMethod.vodafoneCash:
        return 'VODAFONE_CASH';
      case WithdrawMethod.etisalatCash:
        return 'ETISALAT_CASH';
      case WithdrawMethod.orangeCash:
        return 'ORANGE_CASH';
    }
  }
}

enum WithdrawStatus {
  pending,
  completed,
  failed;

  static WithdrawStatus fromApiValue(String value) {
    switch (value.toLowerCase()) {
      case 'completed':
        return WithdrawStatus.completed;
      case 'failed':
        return WithdrawStatus.failed;
      default:
        return WithdrawStatus.pending;
    }
  }
}
