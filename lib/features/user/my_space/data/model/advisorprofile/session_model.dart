import 'package:tayseer/features/user/my_space/data/model/advisorprofile/session_advisor_model.dart';
import 'package:tayseer/features/user/my_space/data/model/advisorprofile/time_range_model.dart';
import 'package:tayseer/features/user/my_space/data/model/session_start_model.dart'; // ⬅️ لازم تعمل الموديل ده

class SessionModel {
  final String sessionId;
  final String message; // ⬅️ ده الناقص
  final String status;
  final bool isNow;
  final bool isUpcoming;
  final bool isDone;
  final DateTime date;
  final DateTime fromTimeUTC; // ⬅️ ده الناقص
  final DateTime toTimeUTC; // ⬅️ ده الناقص
  final String displayDate; // ⬅️ ده الناقص
  final String displayTimeRange; // ⬅️ ده الناقص
  final int duration; // ⬅️ ده الناقص (بالدقائق)
  final SessionAdvisorModel advisor;
  final TimeRangeModel timeRange;
  final OtherUserModel? otherUser; // ⬅️ ده الناقص (nullable لو مش موجود)

  SessionModel({
    required this.sessionId,
    required this.message,
    required this.status,
    required this.isNow,
    required this.isUpcoming,
    required this.isDone,
    required this.date,
    required this.fromTimeUTC,
    required this.toTimeUTC,
    required this.displayDate,
    required this.displayTimeRange,
    required this.duration,
    required this.advisor,
    required this.timeRange,
    this.otherUser,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    // Handling flattened advisor data
    final advisorData = (json['advisor'] != null && json['advisor'] is Map)
        ? json['advisor']
        : json;

    // Handling flattened timeRange data
    final timeRangeData =
        (json['timeRange'] != null && json['timeRange'] is Map)
        ? json['timeRange']
        : {'from': json['displayFromTime'], 'to': json['displayToTime']};

    return SessionModel(
      sessionId: json['sessionId'] ?? '',
      message: json['message'] ?? '', // ⬅️ ده الناقص
      status: json['status'] ?? '',
      isNow: json['isNow'] ?? false,
      isUpcoming: json['isUpcoming'] ?? false,
      isDone: json['isDone'] ?? false,
      date:
          DateTime.tryParse(json['displayDate'] ?? json['fromTimeUTC'] ?? '') ??
          DateTime.now(),
      fromTimeUTC:
          DateTime.tryParse(json['fromTimeUTC'] ?? '') ??
          DateTime.now(), // ⬅️ ده الناقص
      toTimeUTC:
          DateTime.tryParse(json['toTimeUTC'] ?? '') ??
          DateTime.now(), // ⬅️ ده الناقص
      displayDate: json['displayDate'] ?? '', // ⬅️ ده الناقص
      displayTimeRange: json['displayTimeRange'] ?? '', // ⬅️ ده الناقص
      duration: json['duration'] ?? 0, // ⬅️ ده الناقص
      advisor: SessionAdvisorModel.fromJson(advisorData),
      timeRange: TimeRangeModel.fromJson(timeRangeData),
      otherUser: json['otherUser'] != null
          ? OtherUserModel.fromJson(json['otherUser'])
          : null, // ⬅️ ده الناقص
    );
  }

  // ✅ copyWith محدث
  SessionModel copyWith({
    String? sessionId,
    String? message,
    String? status,
    bool? isNow,
    bool? isUpcoming,
    bool? isDone,
    DateTime? date,
    DateTime? fromTimeUTC,
    DateTime? toTimeUTC,
    String? displayDate,
    String? displayTimeRange,
    int? duration,
    SessionAdvisorModel? advisor,
    TimeRangeModel? timeRange,
    OtherUserModel? otherUser,
  }) {
    return SessionModel(
      sessionId: sessionId ?? this.sessionId,
      message: message ?? this.message,
      status: status ?? this.status,
      isNow: isNow ?? this.isNow,
      isUpcoming: isUpcoming ?? this.isUpcoming,
      isDone: isDone ?? this.isDone,
      date: date ?? this.date,
      fromTimeUTC: fromTimeUTC ?? this.fromTimeUTC,
      toTimeUTC: toTimeUTC ?? this.toTimeUTC,
      displayDate: displayDate ?? this.displayDate,
      displayTimeRange: displayTimeRange ?? this.displayTimeRange,
      duration: duration ?? this.duration,
      advisor: advisor ?? this.advisor,
      timeRange: timeRange ?? this.timeRange,
      otherUser: otherUser ?? this.otherUser,
    );
  }

  // ✅ toJson (اختياري)
}
