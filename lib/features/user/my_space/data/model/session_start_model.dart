class SessionStartModel {
  final String sessionId;
  final String message;
  final DateTime fromTimeUTC;
  final DateTime toTimeUTC;

  SessionStartModel({
    required this.sessionId,
    required this.message,
    required this.fromTimeUTC,
    required this.toTimeUTC,
  });

  factory SessionStartModel.fromJson(Map<String, dynamic> json) {
    return SessionStartModel(
      sessionId: json['sessionId'],
      message: json['message'],
      fromTimeUTC: DateTime.parse(json['fromTimeUTC']),
      toTimeUTC: DateTime.parse(json['toTimeUTC']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'message': message,
      'fromTimeUTC': fromTimeUTC.toIso8601String(),
      'toTimeUTC': toTimeUTC.toIso8601String(),
    };
  }
}
