class WalletModel {
  final String id;
  final String advisorId;
  final num balance;
  final String currency;

  const WalletModel({
    required this.id,
    required this.advisorId,
    required this.balance,
    required this.currency,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? '',
      advisorId: json['advisorId'] ?? '',
      balance: json['balance'] ?? 0,
      currency: json['currency'] ?? 'USD',
    );
  }
}
