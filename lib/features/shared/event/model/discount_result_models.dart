class DiscountResultModel {
  final String id;
  final int percentage;
  final bool isActive;

  DiscountResultModel({
    required this.id,
    required this.percentage,
    required this.isActive,
  });

  factory DiscountResultModel.fromJson(Map<String, dynamic> json) {
    return DiscountResultModel(
      id: json['id'] ?? '',
      percentage: json['percentage'] ?? 0,
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'percentage': percentage, 'isActive': isActive};
  }
}
