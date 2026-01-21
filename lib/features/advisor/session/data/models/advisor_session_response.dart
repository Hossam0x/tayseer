// lib/models/advisor_sessions_model.dart

import 'dart:convert';

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
      advisorTimezone: json['advisorTimezone'] ?? '',
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
  final String advisorStatus;
  final bool advisorIsNow;
  final bool advisorIsUpcoming;
  final bool advisorIsDone;
  final String advisorDate;
  final AdvisorAdvisor advisorAdvisor;
  final AdvisorTimeRange advisorTimeRange;

  AdvisorSession({
    required this.advisorSessionId,
    required this.advisorStatus,
    required this.advisorIsNow,
    required this.advisorIsUpcoming,
    required this.advisorIsDone,
    required this.advisorDate,
    required this.advisorAdvisor,
    required this.advisorTimeRange,
  });

  factory AdvisorSession.fromJson(Map<String, dynamic> json) {
    return AdvisorSession(
      advisorSessionId: json['sessionId'] ?? '',
      advisorStatus: json['status'] ?? '',
      advisorIsNow: json['isNow'] ?? false,
      advisorIsUpcoming: json['isUpcoming'] ?? false,
      advisorIsDone: json['isDone'] ?? false,
      advisorDate: json['date'] ?? '',
      advisorAdvisor: AdvisorAdvisor.fromJson(json['advisor'] ?? {}),
      advisorTimeRange: AdvisorTimeRange.fromJson(json['timeRange'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionId': advisorSessionId,
    'status': advisorStatus,
    'isNow': advisorIsNow,
    'isUpcoming': advisorIsUpcoming,
    'isDone': advisorIsDone,
    'date': advisorDate,
    'advisor': advisorAdvisor.toJson(),
    'timeRange': advisorTimeRange.toJson(),
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
      advisorUserName: json['userName'] ?? '',
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
