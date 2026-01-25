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
  final int discount;

  DiscountData({required this.discount});

  factory DiscountData.fromJson(Map<String, dynamic> json) {
    return DiscountData(discount: json['discount'] ?? 0);
  }
}
