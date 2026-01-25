class SessionCancelledModel {
  final String sessionId;
  final String reason;
  final String advisorName;

  SessionCancelledModel({
    required this.sessionId,
    required this.reason,
    required this.advisorName,
  });

  factory SessionCancelledModel.fromJson(Map<String, dynamic> json) {
    return SessionCancelledModel(
      sessionId: json['sessionId'] as String,
      reason: json['reason'] as String,
      advisorName: json['advisorName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'reason': reason,
      'advisorName': advisorName,
    };
  }
}
