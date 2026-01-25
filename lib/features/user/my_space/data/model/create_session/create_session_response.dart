class SessionBookingModel {
  final bool success;
  final String message;
  final SessionData data;

  SessionBookingModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SessionBookingModel.fromJson(Map<String, dynamic> json) {
    return SessionBookingModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: SessionData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class SessionData {
  final String id;
  final String userId;
  final Advisor advisor;
  final DateTime date;
  final String duration;
  final String time;
  final String fromTime;
  final String toTime;
  final bool am;
  final bool pm;
  final bool anonymous;
  final int price;
  final int tax;
  final int fees;
  final int total;
  final String displayTime;

  SessionData({
    required this.id,
    required this.userId,
    required this.advisor,
    required this.date,
    required this.duration,
    required this.time,
    required this.fromTime,
    required this.toTime,
    required this.am,
    required this.pm,
    required this.anonymous,
    required this.price,
    required this.tax,
    required this.fees,
    required this.total,
    required this.displayTime,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      advisor: Advisor.fromJson(json['advisor'] ?? {}),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      duration: json['duration'] ?? '',
      time: json['time'] ?? '',
      fromTime: json['fromTime'] ?? '',
      toTime: json['toTime'] ?? '',
      am: json['am'] ?? false,
      pm: json['pm'] ?? false,
      anonymous: json['anonymous'] ?? false,
      price: json['price'] ?? 0,
      tax: json['tax'] ?? 0,
      fees: json['fees'] ?? 0,
      total: json['total'] ?? 0,
      displayTime: json['displayTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'advisor': advisor.toJson(),
      'date': date.toIso8601String(),
      'duration': duration,
      'time': time,
      'fromTime': fromTime,
      'toTime': toTime,
      'am': am,
      'pm': pm,
      'anonymous': anonymous,
      'price': price,
      'tax': tax,
      'fees': fees,
      'total': total,
      'displayTime': displayTime,
    };
  }
}

class Advisor {
  final String id;
  final String name;
  final String image;

  Advisor({required this.id, required this.name, required this.image});

  factory Advisor.fromJson(Map<String, dynamic> json) {
    return Advisor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'image': image};
  }
}
