/// Response model for advisor session details API
/// Endpoint: /session/advisor-session-details/{sessionId}
class AdvisorDetailesSessionResponseModel {
  final bool success;
  final String message;
  final AdvisorSessionDetailesData data;

  const AdvisorDetailesSessionResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AdvisorDetailesSessionResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdvisorDetailesSessionResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: AdvisorSessionDetailesData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data.toJson(),
  };
}

/// Data container for session details
class AdvisorSessionDetailesData {
  final String sessionId;
  final SessionUserInfo user;
  final SessionDetailesInfo sessionDetails;
  final SessionPricingInfo pricing;

  const AdvisorSessionDetailesData({
    required this.sessionId,
    required this.user,
    required this.sessionDetails,
    required this.pricing,
  });

  factory AdvisorSessionDetailesData.fromJson(Map<String, dynamic> json) {
    return AdvisorSessionDetailesData(
      sessionId: json['sessionId'] ?? '',
      user: SessionUserInfo.fromJson(json['user'] ?? {}),
      sessionDetails: SessionDetailesInfo.fromJson(
        json['sessionDetails'] ?? {},
      ),
      pricing: SessionPricingInfo.fromJson(json['pricing'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'user': user.toJson(),
    'sessionDetails': sessionDetails.toJson(),
    'pricing': pricing.toJson(),
  };
}

/// User information in session details
class SessionUserInfo {
  final String id;
  final String name;
  final String userName;
  final String image;

  const SessionUserInfo({
    required this.id,
    required this.name,
    required this.userName,
    required this.image,
  });

  factory SessionUserInfo.fromJson(Map<String, dynamic> json) {
    return SessionUserInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      userName: json['userName'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'userName': userName,
    'image': image,
  };
}

/// Session details information
class SessionDetailesInfo {
  final String date;
  final String fromTime;
  final String toTime;
  final int duration;
  final String status;

  const SessionDetailesInfo({
    required this.date,
    required this.fromTime,
    required this.toTime,
    required this.duration,
    required this.status,
  });

  factory SessionDetailesInfo.fromJson(Map<String, dynamic> json) {
    return SessionDetailesInfo(
      date: json['date'] ?? '',
      fromTime: json['fromTime'] ?? '',
      toTime: json['toTime'] ?? '',
      duration: json['duration'] ?? 0,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'fromTime': fromTime,
    'toTime': toTime,
    'duration': duration,
    'status': status,
  };

  /// Returns formatted time range
  String get timeRange => '$fromTime - $toTime';

  /// Returns formatted date for display
  String getFormattedDate() {
    if (date.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }
}

/// Pricing information for the session
class SessionPricingInfo {
  final num sessionPrice;
  final num fees;
  final num vat;
  final num appFees;
  final num discount;
  final num total;

  const SessionPricingInfo({
    required this.sessionPrice,
    required this.fees,
    required this.vat,
    required this.appFees,
    required this.discount,
    required this.total,
  });

  factory SessionPricingInfo.fromJson(Map<String, dynamic> json) {
    return SessionPricingInfo(
      sessionPrice: json['sessionPrice'] ?? 0,
      fees: json['fees'] ?? 0,
      vat: json['vat'] ?? 0,
      appFees: json['appFees'] ?? 0,
      discount: json['discount'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionPrice': sessionPrice,
    'fees': fees,
    'vat': vat,
    'appFees': appFees,
    'discount': discount,
    'total': total,
  };
}
