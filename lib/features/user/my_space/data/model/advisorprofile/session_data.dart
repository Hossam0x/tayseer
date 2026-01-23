import 'package:tayseer/features/user/my_space/data/model/advisorprofile/advisor_model.dart';
import 'package:tayseer/features/user/my_space/data/model/advisorprofile/session_model.dart';

class SessionsData {
  final AdvisorModel advisor;
  final List<SessionModel> sessionExpired;
  final List<SessionModel> sessionNotExpired;

  SessionsData({
    required this.advisor,
    required this.sessionExpired,
    required this.sessionNotExpired,
  });

  factory SessionsData.fromJson(Map<String, dynamic> json) {
    return SessionsData(
      advisor: AdvisorModel.fromJson(json['advisor'] ?? {}),
      sessionExpired: (json['sessionExpired'] as List? ?? [])
          .map((e) => SessionModel.fromJson(e))
          .toList(),
      sessionNotExpired: (json['sessionNotExpired'] as List? ?? [])
          .map((e) => SessionModel.fromJson(e))
          .toList(),
    );
  }
}
