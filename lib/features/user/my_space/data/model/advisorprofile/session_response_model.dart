import 'package:tayseer/features/user/my_space/data/model/advisorprofile/session_data.dart';

class SessionsResponseModel {
  final bool success;
  final String message;
  final SessionsData data;

  SessionsResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SessionsResponseModel.fromJson(Map<String, dynamic> json) {
    return SessionsResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: SessionsData.fromJson(json['data'] ?? {}),
    );
  }
}
