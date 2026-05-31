class ChatDurationPackageModel {
  final String id;
  final String appleProductId;
  final String androidProductId;
  final int durationInDays;
  final num price;
  final String currency;
  final int? savePercentage;

  const ChatDurationPackageModel({
    required this.id,
    required this.appleProductId,
    this.androidProductId = '',
    required this.durationInDays,
    required this.price,
    required this.currency,
    this.savePercentage,
  });

  factory ChatDurationPackageModel.fromJson(Map<String, dynamic> json) {
    return ChatDurationPackageModel(
      id: json['id'] as String? ?? '',
      appleProductId: json['appleProductId'] as String? ?? '',
      androidProductId: json['androidProductId'] as String? ?? '',
      durationInDays: (json['durationInDays'] as num?)?.toInt() ?? 0,
      price: json['price'] as num? ?? 0,
      currency: json['currency'] as String? ?? 'EGP',
      savePercentage: (json['savePercentage'] as num?)?.toInt(),
    );
  }
}

class ChatDurationPackagesResponse {
  final List<ChatDurationPackageModel> packages;

  const ChatDurationPackagesResponse({required this.packages});

  factory ChatDurationPackagesResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return ChatDurationPackagesResponse(
      packages: list
          .map(
            (e) => ChatDurationPackageModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
