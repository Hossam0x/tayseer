// lib/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart

import 'package:tayseer/features/user/my_space/data/model/advisorprofile/advisor_model.dart';

class SessionDetailsModelResponse {
  final bool success;
  final String message;
  final SessionDetailsDataResponse data;

  SessionDetailsModelResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SessionDetailsModelResponse.fromJson(Map<String, dynamic> json) {
    return SessionDetailsModelResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: SessionDetailsDataResponse.fromJson(json['data'] ?? {}),
    );
  }
}

/* ===================== DATA ===================== */

class SessionDetailsDataResponse {
  final String sessionId;
  final String type;
  final AdvisorModel advisor;
  final String status;
  final DateTime date;
  final TimeRangeModel timeRange;
  final int duration;
  final bool isAnonymous;
  final PricingModelResponse pricing;
  final String paymentMethods;
  final SessionCreditModel? sessionCredit;

  SessionDetailsDataResponse({
    required this.sessionId,
    required this.type,
    required this.advisor,
    required this.status,
    required this.date,
    required this.timeRange,
    required this.duration,
    required this.isAnonymous,
    required this.pricing,
    required this.paymentMethods,
    this.sessionCredit,
  });

  // ============ HELPER GETTERS للـ Type ============

  bool get isPackage => type.toLowerCase() == 'package';

  bool get isSingle => type.toLowerCase() == 'single';

  String get typeDisplayNameAr {
    switch (type.toLowerCase()) {
      case 'package':
        return 'باقة';
      case 'single':
        return 'جلسة فردية';
      default:
        return type;
    }
  }

  String get typeDisplayNameEn {
    switch (type.toLowerCase()) {
      case 'package':
        return 'Package';
      case 'single':
        return 'Single Session';
      default:
        return type;
    }
  }

  // ============ HELPER GETTERS للـ Session Credit ============

  bool get hasSessionCredit => sessionCredit != null;

  int get creditLeft => sessionCredit?.creditLeft ?? 0;

  String get offerName => sessionCredit?.offerName ?? '';

  // ============ HELPER GETTERS للـ Date ============

  int get dayOfMonth => date.day;

  int get month => date.month;

  int get year => date.year;

  String get dateString {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String get displayDate {
    final months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  // ============ HELPER GETTERS للـ Time ============

  bool get hasTimeInfo => timeRange.hasValidTime;

  String get startTime => timeRange.from;

  String get endTime => timeRange.to;

  String get displayStartTime {
    if (timeRange.from.isNotEmpty) return timeRange.from;
    return '--:--';
  }

  String get displayEndTime {
    if (timeRange.to.isNotEmpty) return timeRange.to;
    return '--:--';
  }

  String get displayTime {
    if (timeRange.hasValidTime) return '${timeRange.from} - ${timeRange.to}';
    return 'الوقت غير متاح';
  }

  String get displayTimeWithDuration {
    if (timeRange.hasValidTime) {
      return '${timeRange.from} - ${timeRange.to} ($duration دقيقة)';
    }
    return '$duration دقيقة (الوقت غير محدد)';
  }

  // ============ HELPER GETTERS للـ Payment ============

  int get paymentMethodIndex {
    switch (paymentMethods.toLowerCase()) {
      case 'bank':
        return 0;
      case 'wallet':
        return 1;
      case 'vodafone':
        return 2;
      default:
        return 1;
    }
  }

  String get paymentMethodDisplayName {
    switch (paymentMethods.toLowerCase()) {
      case 'bank':
        return 'تحويل بنكي';
      case 'wallet':
        return 'محفظة إلكترونية';
      case 'vodafone':
        return 'فودافون كاش';
      default:
        return paymentMethods;
    }
  }

  // ============ FACTORY ============

  factory SessionDetailsDataResponse.fromJson(Map<String, dynamic> json) {
    return SessionDetailsDataResponse(
      sessionId: json['sessionId'] ?? '',
      type: json['type'] ?? 'single',
      advisor: AdvisorModel.fromJson(json['advisor'] ?? {}),
      status: json['status'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      timeRange: TimeRangeModel.fromJson(json['timeRange'] ?? {}),
      duration: json['duration'] ?? 0,
      isAnonymous: json['isAnonymous'] ?? false,
      pricing: PricingModelResponse.fromJson(json['pricing'] ?? {}),
      paymentMethods: json['paymentMethods'] ?? '',
      sessionCredit: json['sessionCredit'] != null
          ? SessionCreditModel.fromJson(json['sessionCredit'])
          : null,
    );
  }

  SessionDetailsDataResponse copyWith({
    String? sessionId,
    String? type,
    AdvisorModel? advisor,
    String? status,
    DateTime? date,
    TimeRangeModel? timeRange,
    int? duration,
    bool? isAnonymous,
    PricingModelResponse? pricing,
    String? paymentMethods,
    SessionCreditModel? sessionCredit,
  }) {
    return SessionDetailsDataResponse(
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      advisor: advisor ?? this.advisor,
      status: status ?? this.status,
      date: date ?? this.date,
      timeRange: timeRange ?? this.timeRange,
      duration: duration ?? this.duration,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      pricing: pricing ?? this.pricing,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      sessionCredit: sessionCredit ?? this.sessionCredit,
    );
  }
}

/* ===================== SESSION CREDIT ===================== */

class SessionCreditModel {
  final int creditLeft;
  final String offerId;
  final String offerName;

  SessionCreditModel({
    required this.creditLeft,
    required this.offerId,
    required this.offerName,
  });

  bool get hasCredit => creditLeft > 0;

  String get displayCreditAr => 'متبقي $creditLeft جلسات';

  String get displayCreditEn => '$creditLeft sessions left';

  factory SessionCreditModel.fromJson(Map<String, dynamic> json) {
    return SessionCreditModel(
      creditLeft: json['creditLeft'] ?? 0,
      offerId: json['offerId'] ?? '',
      offerName: json['offerName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creditLeft': creditLeft,
      'offerId': offerId,
      'offerName': offerName,
    };
  }
}

/* ===================== TIME RANGE ===================== */

class TimeRangeModel {
  final String from;
  final String to;

  TimeRangeModel({required this.from, required this.to});

  bool get hasValidTime => from.isNotEmpty && to.isNotEmpty;

  bool get hasFromTime => from.isNotEmpty;

  bool get hasToTime => to.isNotEmpty;

  String get displayTime {
    if (hasValidTime) {
      return '$from - $to';
    } else if (hasFromTime) {
      return '$from - ؟؟';
    } else if (hasToTime) {
      return '؟؟ - $to';
    }
    return 'غير محدد';
  }

  factory TimeRangeModel.fromJson(Map<String, dynamic> json) {
    return TimeRangeModel(from: json['from'] ?? '', to: json['to'] ?? '');
  }

  factory TimeRangeModel.empty() {
    return TimeRangeModel(from: '', to: '');
  }

  Map<String, dynamic> toJson() {
    return {'from': from, 'to': to};
  }
}

/* ===================== PRICING ===================== */

class PricingModelResponse {
  final num sessionPrice;
  final num taxes;
  final num fees;
  final num discount;
  final num total;

  PricingModelResponse({
    required this.sessionPrice,
    required this.taxes,
    required this.fees,
    required this.discount,
    required this.total,
  });

  int get totalAsInt => total.toInt();

  double get totalAsDouble => total.toDouble();

  String get displayTotal =>
      '${total.toStringAsFixed(total % 1 == 0 ? 0 : 2)} ر.س';

  String get displaySessionPrice =>
      '${sessionPrice.toStringAsFixed(sessionPrice % 1 == 0 ? 0 : 2)} ر.س';

  factory PricingModelResponse.fromJson(Map<String, dynamic> json) {
    return PricingModelResponse(
      sessionPrice: (json['sessionPrice'] ?? 0) as num,
      taxes: (json['taxes'] ?? 0) as num,
      fees: (json['fees'] ?? 0) as num,
      discount: (json['discount'] ?? 0) as num,
      total: (json['total'] ?? 0) as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionPrice': sessionPrice,
      'taxes': taxes,
      'fees': fees,
      'discount': discount,
      'total': total,
    };
  }
}
