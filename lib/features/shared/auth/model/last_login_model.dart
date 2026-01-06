class LastLoginResponse {
  final bool? success;
  final String? message;
  final LastLoginData? data;

  LastLoginResponse({this.success, this.message, this.data});

  factory LastLoginResponse.fromJson(Map<String, dynamic> json) {
    return LastLoginResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? LastLoginData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class LastLoginData {
  final String? lastLoginBY;
  final String? email;

  LastLoginData({this.lastLoginBY, this.email});

  factory LastLoginData.fromJson(Map<String, dynamic> json) {
    return LastLoginData(
      lastLoginBY: json['lastLoginBY'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'lastLoginBY': lastLoginBY, 'email': email};
  }
}
