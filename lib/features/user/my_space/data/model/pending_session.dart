class PendingSessionResponse {
  bool? success;
  String? message;
  PendingSessionData? data;

  PendingSessionResponse({this.success, this.message, this.data});

  factory PendingSessionResponse.fromJson(Map<String, dynamic> json) {
    return PendingSessionResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? PendingSessionData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    jsonData['success'] = success;
    jsonData['message'] = message;
    if (data != null) {
      jsonData['data'] = data!.toJson();
    }
    return jsonData;
  }
}

class PendingSessionData {
  List<PendingSession>? pendingSessions;
  int? count;
  String? advisorTimezone;

  PendingSessionData({this.pendingSessions, this.count, this.advisorTimezone});

  factory PendingSessionData.fromJson(Map<String, dynamic> json) {
    return PendingSessionData(
      pendingSessions: json['pendingSessions'] != null
          ? List<PendingSession>.from(
              json['pendingSessions'].map((x) => PendingSession.fromJson(x)),
            )
          : null,
      count: json['count'],
      advisorTimezone: json['advisorTimezone'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    if (pendingSessions != null) {
      jsonData['pendingSessions'] = pendingSessions!
          .map((x) => x.toJson())
          .toList();
    }
    jsonData['count'] = count;
    jsonData['advisorTimezone'] = advisorTimezone;
    return jsonData;
  }

  PendingSessionData copyWith({
    List<PendingSession>? pendingSessions,
    int? count,
    String? advisorTimezone,
  }) {
    return PendingSessionData(
      pendingSessions: pendingSessions ?? this.pendingSessions,
      count: count ?? this.count,
      advisorTimezone: advisorTimezone ?? this.advisorTimezone,
    );
  }
}

class PendingSession {
  String? sessionId;
  String? status;
  bool? isNow;
  bool? isUpcoming;
  bool? isDone;
  String? date;
  Advisor? advisor;
  TimeRange? timeRange;

  PendingSession({
    this.sessionId,
    this.status,
    this.isNow,
    this.isUpcoming,
    this.isDone,
    this.date,
    this.advisor,
    this.timeRange,
  });

  factory PendingSession.fromJson(Map<String, dynamic> json) {
    return PendingSession(
      sessionId: json['sessionId'],
      status: json['status'],
      isNow: json['isNow'],
      isUpcoming: json['isUpcoming'],
      isDone: json['isDone'],
      date: json['date'],
      advisor: json['advisor'] != null
          ? Advisor.fromJson(json['advisor'])
          : null,
      timeRange: json['timeRange'] != null
          ? TimeRange.fromJson(json['timeRange'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    jsonData['sessionId'] = sessionId;
    jsonData['status'] = status;
    jsonData['isNow'] = isNow;
    jsonData['isUpcoming'] = isUpcoming;
    jsonData['isDone'] = isDone;
    jsonData['date'] = date;
    if (advisor != null) {
      jsonData['advisor'] = advisor!.toJson();
    }
    if (timeRange != null) {
      jsonData['timeRange'] = timeRange!.toJson();
    }
    return jsonData;
  }
}

class Advisor {
  String? id;
  String? name;
  String? userName;
  String? image;

  Advisor({this.id, this.name, this.userName, this.image});

  factory Advisor.fromJson(Map<String, dynamic> json) {
    return Advisor(
      id: json['id'],
      name: json['name'],
      userName: json['userName'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    jsonData['id'] = id;
    jsonData['name'] = name;
    jsonData['userName'] = userName;
    jsonData['image'] = image;
    return jsonData;
  }
}

class TimeRange {
  String? fromTimeUTC;
  String? toTimeUTC;
  String? from;
  String? to;

  TimeRange({this.fromTimeUTC, this.toTimeUTC, this.from, this.to});

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      fromTimeUTC: json['fromTimeUTC'],
      toTimeUTC: json['toTimeUTC'],
      from: json['from'],
      to: json['to'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    jsonData['fromTimeUTC'] = fromTimeUTC;
    jsonData['toTimeUTC'] = toTimeUTC;
    jsonData['from'] = from;
    jsonData['to'] = to;
    return jsonData;
  }
}
