class RegisterResponse {
  final bool? success;
  final String? message;
  final LoginData? data;

  RegisterResponse({this.success, this.message, this.data});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class LoginData {
  final String? token;
  final String? id;
  final bool? verify;
  final String? userType;
  final int? lastQuestionNumber;
  final bool? answerCompleted;
  final String? name;

  LoginData({
    this.token,
    this.id,
    this.verify,
    this.userType,
    this.lastQuestionNumber,
    this.answerCompleted,
    this.name,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'] as String?,
      id: json['id'] as String?,
      verify: json['verify'] as bool?,
      userType: json['userType'] as String?,
      lastQuestionNumber: json['lastQuestionNumber'] as int?,
      answerCompleted: json['answerCompleted'] as bool?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'id': id,
      'verify': verify,
      'userType': userType,
      'lastQuestionNumber': lastQuestionNumber,
      'answerCompleted': answerCompleted,
      'name': name,
    };
  }
}
