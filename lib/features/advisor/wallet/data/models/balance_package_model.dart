class BalancePackageModel {
  final String id;
  final num balance;
  final String appleProductId;
  final num price;
  final String currency;

  const BalancePackageModel({
    required this.id,
    required this.balance,
    required this.appleProductId,
    required this.price,
    required this.currency,
  });

  factory BalancePackageModel.fromJson(Map<String, dynamic> json) {
    return BalancePackageModel(
      id: json['id'] ?? '',
      balance: json['balance'] ?? 0,
      appleProductId: json['appleProductId'] ?? '',
      price: json['price'] ?? 0,
      currency: json['currency'] ?? 'USD',
    );
  }
}
