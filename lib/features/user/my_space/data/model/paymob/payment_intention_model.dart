class PaymentIntentionModel {
  final bool success;
  final String message;
  final PaymentIntentionData data;

  PaymentIntentionModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PaymentIntentionModel.fromJson(Map<String, dynamic> json) {
    return PaymentIntentionModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: PaymentIntentionData.fromJson(json['data']),
    );
  }
}

class PaymentIntentionData {
  final String clientSecret;
  final String paymentKey;
  final int orderId;
  final String publicKey;
  final String webviewUrl;

  PaymentIntentionData({
    required this.clientSecret,
    required this.paymentKey,
    required this.orderId,
    required this.publicKey,
    this.webviewUrl = '',
  });

  factory PaymentIntentionData.fromJson(Map<String, dynamic> json) {
    return PaymentIntentionData(
      clientSecret: json['clientSecret'] ?? '',
      paymentKey: json['paymentKey'] ?? '',
      orderId: json['orderId'] ?? 0,
      publicKey: json['publicKey'] ?? '',
      webviewUrl: json['webviewUrl'] ?? '',
    );
  }
}
