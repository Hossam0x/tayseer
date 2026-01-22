// lib/models/advisor_sessions_model.dart

class AdvisorSessionsModel {
  final bool advisorSuccess;
  final String advisorMessage;
  final AdvisorData advisorData;

  AdvisorSessionsModel({
    required this.advisorSuccess,
    required this.advisorMessage,
    required this.advisorData,
  });

  factory AdvisorSessionsModel.fromJson(Map<String, dynamic> json) {
    return AdvisorSessionsModel(
      advisorSuccess: json['success'] ?? false,
      advisorMessage: json['message'] ?? '',
      advisorData: AdvisorData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': advisorSuccess,
    'message': advisorMessage,
    'data': advisorData.toJson(),
  };
}

class AdvisorData {
  final List<AdvisorSession> advisorSessionExpired;
  final List<AdvisorSession> advisorSessionNotExpired;
  final String advisorTimezone;

  AdvisorData({
    required this.advisorSessionExpired,
    required this.advisorSessionNotExpired,
    required this.advisorTimezone,
  });

  factory AdvisorData.fromJson(Map<String, dynamic> json) {
    return AdvisorData(
      advisorSessionExpired: (json['sessionExpired'] as List<dynamic>? ?? [])
          .map((e) => AdvisorSession.fromJson(e))
          .toList(),
      advisorSessionNotExpired:
          (json['sessionNotExpired'] as List<dynamic>? ?? [])
              .map((e) => AdvisorSession.fromJson(e))
              .toList(),
      advisorTimezone: json['advisorTimezone'] ?? 'UTC',
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionExpired': advisorSessionExpired.map((e) => e.toJson()).toList(),
    'sessionNotExpired': advisorSessionNotExpired
        .map((e) => e.toJson())
        .toList(),
    'advisorTimezone': advisorTimezone,
  };
}

class AdvisorSession {
  final String advisorSessionId;
  final String advisorMessage;
  final String advisorStatus;
  final bool advisorIsNow;
  final bool advisorIsUpcoming;
  final bool advisorIsDone;
  final String advisorDate;
  final String advisorDisplayTimeRange;
  final int advisorDuration;
  final AdvisorAdvisor advisorAdvisor;
  final AdvisorTimeRange advisorTimeRange;
  final OtherUser? otherUser;

  AdvisorSession({
    required this.advisorSessionId,
    required this.advisorMessage,
    required this.advisorStatus,
    required this.advisorIsNow,
    required this.advisorIsUpcoming,
    required this.advisorIsDone,
    required this.advisorDate,
    required this.advisorDisplayTimeRange,
    required this.advisorDuration,
    required this.advisorAdvisor,
    required this.advisorTimeRange,
    this.otherUser,
  });

  factory AdvisorSession.fromJson(Map<String, dynamic> json) {
    return AdvisorSession(
      advisorSessionId: json['sessionId'] ?? '',
      advisorMessage: json['message'] ?? '',
      advisorStatus: json['status'] ?? '',
      advisorIsNow: json['isNow'] ?? false,
      advisorIsUpcoming: json['isUpcoming'] ?? false,
      advisorIsDone: json['isDone'] ?? false,
      // ✅ تصحيح: استخدام displayDate
      advisorDate: json['displayDate'] ?? '',
      // ✅ إضافة displayTimeRange
      advisorDisplayTimeRange: json['displayTimeRange'] ?? '',
      advisorDuration: json['duration'] ?? 0,
      // ✅ تصحيح: بناء AdvisorAdvisor من الحقول المباشرة
      advisorAdvisor: AdvisorAdvisor.fromJson({
        'id': json['id'] ?? '',
        'name': json['name'] ?? '',
        'userName': json['name'] ?? '', // غير موجود في API، نستخدم name
        'image': json['image'] ?? '',
      }),
      // ✅ تصحيح: بناء TimeRange من الحقول المباشرة
      advisorTimeRange: AdvisorTimeRange.fromJson({
        'fromTimeUTC': json['fromTimeUTC'],
        'toTimeUTC': json['toTimeUTC'],
        'from': json['displayFromTime'] ?? '',
        'to': json['displayToTime'] ?? '',
      }),
      // ✅ إضافة otherUser
      otherUser: json['otherUser'] != null
          ? OtherUser.fromJson(json['otherUser'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionId': advisorSessionId,
    'message': advisorMessage,
    'status': advisorStatus,
    'isNow': advisorIsNow,
    'isUpcoming': advisorIsUpcoming,
    'isDone': advisorIsDone,
    'displayDate': advisorDate,
    'displayTimeRange': advisorDisplayTimeRange,
    'duration': advisorDuration,
    'advisor': advisorAdvisor.toJson(),
    'timeRange': advisorTimeRange.toJson(),
    'otherUser': otherUser?.toJson(),
  };
}

class AdvisorAdvisor {
  final String advisorId;
  final String advisorName;
  final String advisorUserName;
  final String advisorImage;

  AdvisorAdvisor({
    required this.advisorId,
    required this.advisorName,
    required this.advisorUserName,
    required this.advisorImage,
  });

  factory AdvisorAdvisor.fromJson(Map<String, dynamic> json) {
    return AdvisorAdvisor(
      advisorId: json['id'] ?? '',
      advisorName: json['name'] ?? '',
      advisorUserName: json['userName'] ?? json['name'] ?? '',
      advisorImage: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': advisorId,
    'name': advisorName,
    'userName': advisorUserName,
    'image': advisorImage,
  };
}

class AdvisorTimeRange {
  final String? advisorFromTimeUTC;
  final String? advisorToTimeUTC;
  final String advisorFrom;
  final String advisorTo;

  AdvisorTimeRange({
    this.advisorFromTimeUTC,
    this.advisorToTimeUTC,
    required this.advisorFrom,
    required this.advisorTo,
  });

  factory AdvisorTimeRange.fromJson(Map<String, dynamic> json) {
    return AdvisorTimeRange(
      advisorFromTimeUTC: json['fromTimeUTC'],
      advisorToTimeUTC: json['toTimeUTC'],
      advisorFrom: json['from'] ?? '',
      advisorTo: json['to'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    if (advisorFromTimeUTC != null) 'fromTimeUTC': advisorFromTimeUTC,
    if (advisorToTimeUTC != null) 'toTimeUTC': advisorToTimeUTC,
    'from': advisorFrom,
    'to': advisorTo,
  };
}

// ✅ إضافة class جديد لـ otherUser
class OtherUser {
  final String id;
  final String name;
  final String image;
  final bool isAnonymous;

  OtherUser({
    required this.id,
    required this.name,
    required this.image,
    required this.isAnonymous,
  });

  factory OtherUser.fromJson(Map<String, dynamic> json) {
    return OtherUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      isAnonymous: json['Anonymous'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'Anonymous': isAnonymous,
  };
}
