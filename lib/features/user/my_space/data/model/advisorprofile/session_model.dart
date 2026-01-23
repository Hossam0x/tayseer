import 'package:tayseer/features/user/my_space/data/model/advisorprofile/session_advisor_model.dart';
import 'package:tayseer/features/user/my_space/data/model/advisorprofile/time_range_model.dart';

class SessionModel {
  final String sessionId;
  final String status;
  final bool isNow;
  final bool isUpcoming;
  final bool isDone;
  final DateTime date;
  final SessionAdvisorModel advisor;
  final TimeRangeModel timeRange;

  SessionModel({
    required this.sessionId,
    required this.status,
    required this.isNow,
    required this.isUpcoming,
    required this.isDone,
    required this.date,
    required this.advisor,
    required this.timeRange,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      sessionId: json['sessionId'] ?? '',
      status: json['status'] ?? '',
      isNow: json['isNow'] ?? false,
      isUpcoming: json['isUpcoming'] ?? false,
      isDone: json['isDone'] ?? false,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      advisor: SessionAdvisorModel.fromJson(json['advisor'] ?? {}),
      timeRange: TimeRangeModel.fromJson(json['timeRange'] ?? {}),
    );
  }

  // ✅ أضف copyWith
  SessionModel copyWith({
    String? sessionId,
    String? status,
    bool? isNow,
    bool? isUpcoming,
    bool? isDone,
    DateTime? date,
    SessionAdvisorModel? advisor,
    TimeRangeModel? timeRange,
  }) {
    return SessionModel(
      sessionId: sessionId ?? this.sessionId,
      status: status ?? this.status,
      isNow: isNow ?? this.isNow,
      isUpcoming: isUpcoming ?? this.isUpcoming,
      isDone: isDone ?? this.isDone,
      date: date ?? this.date,
      advisor: advisor ?? this.advisor,
      timeRange: timeRange ?? this.timeRange,
    );
  }
}
