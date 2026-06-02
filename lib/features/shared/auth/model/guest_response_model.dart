class GuestResponseModel {
  final bool success;
  final String message;
  final GuestData? data;

  GuestResponseModel({required this.success, required this.message, this.data});

  factory GuestResponseModel.fromJson(Map<String, dynamic> json) {
    return GuestResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? GuestData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class GuestData {
  /// The access token — the server may return it as 'accessToken' or legacy 'token'.
  final String accessToken;

  /// The refresh token — may be absent for legacy guest sessions.
  final String? refreshToken;

  final String id;
  final String name;
  final String userType;
  final String image;

  GuestData({
    required this.accessToken,
    this.refreshToken,
    required this.id,
    required this.name,
    required this.userType,
    required this.image,
  });

  /// Convenience getter for code that still references `.token`
  String get token => accessToken;

  factory GuestData.fromJson(Map<String, dynamic> json) {
    // Support both 'accessToken' (new) and 'token' (legacy) field names
    final accessToken =
        json['accessToken']?.toString() ?? json['token']?.toString() ?? '';

    return GuestData(
      accessToken: accessToken,
      refreshToken: json['refreshToken']?.toString(),
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      userType: json['userType']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
      'id': id,
      'name': name,
      'userType': userType,
      'image': image,
    };
  }
}
