class RegardsPackageModel {
  final String id;
  final String appleProductId;
  final int amount;
  final double price;
  final String currency;
  final double priceForOne;
  final int? savePercentage;

  const RegardsPackageModel({
    required this.id,
    required this.appleProductId,
    required this.amount,
    required this.price,
    required this.currency,
    required this.priceForOne,
    this.savePercentage,
  });

  factory RegardsPackageModel.fromJson(Map<String, dynamic> json) {
    return RegardsPackageModel(
      id: json['id'] as String? ?? '',
      appleProductId: json['appleProductId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'EGP',
      priceForOne: double.tryParse(json['priceForOne']?.toString() ?? '0') ?? 0,
      savePercentage: json['savePercentage'] as int?,
    );
  }
}

class RegardsPackagesResponse {
  final List<RegardsPackageModel> packages;
  final DateTime? regardsIncrementAt;

  const RegardsPackagesResponse({
    required this.packages,
    this.regardsIncrementAt,
  });

  factory RegardsPackagesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final list = data['packages'] as List<dynamic>? ?? [];
    return RegardsPackagesResponse(
      packages: list
          .map((e) => RegardsPackageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      regardsIncrementAt: data['regardsIncrementAt'] != null
          ? DateTime.tryParse(data['regardsIncrementAt'] as String)
          : null,
    );
  }
}
