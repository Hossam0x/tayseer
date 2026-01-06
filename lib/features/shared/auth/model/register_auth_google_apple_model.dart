class AccountResponse {
  final bool? success;
  final String? message;
  final VerifyAccountData? data;

  AccountResponse({
    this.success,
    this.message,
    this.data,
  });

  factory AccountResponse.fromJson(Map<String, dynamic> json) {
    return AccountResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? VerifyAccountData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class VerifyAccountData {
  final bool? verify;
  final String? token;

  VerifyAccountData({
    this.verify,
    this.token,
  });

  factory VerifyAccountData.fromJson(Map<String, dynamic> json) {
    return VerifyAccountData(
      verify: json['verify'] as bool?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verify': verify,
      'token': token,
    };
  }
}
