// lib/features/user/my_space/data/model/discount/discount_response_model.dart

class DiscountResponseModel {
  final bool success;
  final String message;
  final DiscountData data;

  DiscountResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DiscountResponseModel.fromJson(Map<String, dynamic> json) {
    return DiscountResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: DiscountData.fromJson(json['data'] ?? {}),
    );
  }
}

class DiscountData {
  final double discountPercentage;
  final double newPrice;
  final double newTotalPrice;
  final double discountAmount;

  DiscountData({
    required this.discountPercentage,
    required this.newPrice,
    required this.newTotalPrice,
    required this.discountAmount,
  });

  factory DiscountData.fromJson(Map<String, dynamic> json) {
    return DiscountData(
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      newPrice: (json['newPrice'] as num?)?.toDouble() ?? 0.0,
      newTotalPrice: (json['newTotalPrice'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
