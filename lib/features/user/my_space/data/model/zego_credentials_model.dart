class ZegoCredentialsResponse {
  final bool success;
  final String message;
  final ZegoCredentialsData data;

  const ZegoCredentialsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ZegoCredentialsResponse.fromJson(Map<String, dynamic> json) {
    return ZegoCredentialsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ZegoCredentialsData.fromJson(json['data'] ?? {}),
    );
  }
}

class ZegoCredentialsData {
  final String zegoAppId;
  final String zegoAppSign;

  const ZegoCredentialsData({
    required this.zegoAppId,
    required this.zegoAppSign,
  });

  factory ZegoCredentialsData.fromJson(Map<String, dynamic> json) {
    return ZegoCredentialsData(
      zegoAppId: json['zegoAppId'] ?? '',
      zegoAppSign: json['zegoAppSign'] ?? '',
    );
  }

  /// Parse zegoAppId as int for Zego SDK
  int get appIdAsInt {
    try {
      return int.parse(zegoAppId);
    } catch (e) {
      return 0;
    }
  }
}
