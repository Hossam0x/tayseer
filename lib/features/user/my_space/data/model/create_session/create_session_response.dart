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
  final String offeringId;
  final String userId;
  final Advisor advisor;
  final DateTime date;
  final String duration;
  final String time;
  final String fromTime;
  final String toTime;
  final DateTime fromTimeUTC;
  final DateTime toTimeUTC;
  final String advisorTimezone;
  final bool am;
  final bool pm;
  final bool isAnonymous;
  final double price;
  final double tax;
  final double fees;
  final double total;
  final String currency;
  final String displayTime;

  SessionData({
    required this.id,
    required this.offeringId,
    required this.userId,
    required this.advisor,
    required this.date,
    required this.duration,
    required this.time,
    required this.fromTime,
    required this.toTime,
    required this.fromTimeUTC,
    required this.toTimeUTC,
    required this.advisorTimezone,
    required this.am,
    required this.pm,
    required this.isAnonymous,
    required this.price,
    required this.tax,
    required this.fees,
    required this.total,
    required this.currency,
    required this.displayTime,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      id: json['id'] ?? '',
      offeringId: json['offeringId'] ?? '',
      userId: json['userId'] ?? '',
      advisor: Advisor.fromJson(json['advisor'] ?? {}),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      duration: json['duration']?.toString() ?? '',
      time: json['time'] ?? '',
      fromTime: json['fromTime'] ?? '',
      toTime: json['toTime'] ?? '',
      fromTimeUTC:
          DateTime.tryParse(json['fromTimeUTC'] ?? '') ?? DateTime.now(),
      toTimeUTC: DateTime.tryParse(json['toTimeUTC'] ?? '') ?? DateTime.now(),
      advisorTimezone: json['advisorTimezone'] ?? '',
      am: json['am'] ?? false,
      pm: json['pm'] ?? false,
      isAnonymous: json['isAnonymous'] ?? false,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      fees: (json['fees'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? '',
      displayTime: json['displayTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offeringId': offeringId,
      'userId': userId,
      'advisor': advisor.toJson(),
      'date': date.toIso8601String(),
      'duration': duration,
      'time': time,
      'fromTime': fromTime,
      'toTime': toTime,
      'fromTimeUTC': fromTimeUTC.toIso8601String(),
      'toTimeUTC': toTimeUTC.toIso8601String(),
      'advisorTimezone': advisorTimezone,
      'am': am,
      'pm': pm,
      'isAnonymous': isAnonymous,
      'price': price,
      'tax': tax,
      'fees': fees,
      'total': total,
      'currency': currency,
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
