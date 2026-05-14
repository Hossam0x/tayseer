class ChatDurationPackageModel {
  final String id;
  final String appleProductId;
  final int durationInDays;
  final num price;
  final String currency;
  final int? savePercentage;

  const ChatDurationPackageModel({
    required this.id,
    required this.appleProductId,
    required this.durationInDays,
    required this.price,
    required this.currency,
    this.savePercentage,
  });

  factory ChatDurationPackageModel.fromJson(Map<String, dynamic> json) {
    return ChatDurationPackageModel(
      id: json['id'] as String? ?? '',
      appleProductId: json['appleProductId'] as String? ?? '',
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
          .map((e) => ChatDurationPackageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
