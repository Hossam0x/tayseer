class SessionStartModel {
  final String sessionId;
  final String message;
  final DateTime fromTimeUTC;
  final DateTime toTimeUTC;
  final String id;
  final String? name;
  final String imageUrl;
  final OtherUserModel otherUser;

  SessionStartModel({
    required this.sessionId,
    required this.message,
    required this.fromTimeUTC,
    required this.toTimeUTC,
    required this.id,
    this.name,
    required this.imageUrl,
    required this.otherUser,
  });

  factory SessionStartModel.fromJson(Map<String, dynamic> json) {
    return SessionStartModel(
      sessionId: json['sessionId'] as String? ?? '',
      message: json['message'] as String? ?? '',
      fromTimeUTC:
          DateTime.tryParse(json['fromTimeUTC']?.toString() ?? '') ??
          DateTime.now(),
      toTimeUTC:
          DateTime.tryParse(json['toTimeUTC']?.toString() ?? '') ??
          DateTime.now(),
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      imageUrl: json['image'] as String? ?? '',
      otherUser: OtherUserModel.fromJson(
        json['otherUser'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'message': message,
      'fromTimeUTC': fromTimeUTC.toIso8601String(),
      'toTimeUTC': toTimeUTC.toIso8601String(),
      'id': id,
      'name': name,
      'image': imageUrl,
      'otherUser': otherUser.toJson(),
    };
  }
}

class OtherUserModel {
  final String id;
  final String? name;
  final String imageUrl;

  OtherUserModel({required this.id, this.name, required this.imageUrl});

  factory OtherUserModel.fromJson(Map<String, dynamic> json) {
    return OtherUserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      imageUrl: json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'image': imageUrl};
  }
}
