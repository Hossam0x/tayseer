class WithdrawModel {
  final String id;
  final double amount;
  final double fees;
  final double netAmount;
  final WithdrawMethod method;
  final String accountNumber;
  final DateTime date;
  final WithdrawStatus status;

  WithdrawModel({
    required this.id,
    required this.amount,
    required this.fees,
    required this.netAmount,
    required this.method,
    required this.accountNumber,
    required this.date,
    required this.status,
  });

  factory WithdrawModel.fromJson(Map<String, dynamic> json) {
    return WithdrawModel(
      id: json['id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      fees: (json['fees'] ?? 0).toDouble(),
      netAmount: (json['netAmount'] ?? 0).toDouble(),
      method: WithdrawMethod.values[json['method'] ?? 0],
      accountNumber: json['accountNumber'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toString()),
      status: WithdrawStatus.values[json['status'] ?? 0],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'fees': fees,
      'netAmount': netAmount,
      'method': method.index,
      'accountNumber': accountNumber,
      'date': date.toIso8601String(),
      'status': status.index,
    };
  }
}

enum WithdrawMethod { bankAccount, stcPay, instaPay, vodafoneCash }

enum WithdrawStatus { pending, completed, failed }
