class BalancePackageModel {
  final String id;
  final num balance;
  final String appleProductId;
  final String androidProductId;
  final num price;
  final String currency;

  const BalancePackageModel({
    required this.id,
    required this.balance,
    required this.appleProductId,
    this.androidProductId = '',
    required this.price,
    required this.currency,
  });

  factory BalancePackageModel.fromJson(Map<String, dynamic> json) {
    return BalancePackageModel(
      id: json['id'] ?? '',
      balance: json['balance'] ?? 0,
      appleProductId: json['appleProductId'] ?? '',
      androidProductId: json['googleProductId'] as String? ?? json['androidProductId'] as String? ?? '',
      price: json['price'] ?? 0,
      currency: json['currency'] ?? 'USD',
    );
  }
}
