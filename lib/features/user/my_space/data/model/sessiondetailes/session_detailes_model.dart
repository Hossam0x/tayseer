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
  final AdvisorModel advisor;
  final String status;
  final DateTime date;
  final TimeRangeModel timeRange;
  final int duration;
  final bool isAnonymous;
  final PricingModelResponse pricing;
  final String paymentMethods;

  SessionDetailsDataResponse({
    required this.sessionId,
    required this.advisor,
    required this.status,
    required this.date,
    required this.timeRange,
    required this.duration,
    required this.isAnonymous,
    required this.pricing,
    required this.paymentMethods,
  });

  // ============ HELPER GETTERS للـ Date ============

  /// اليوم في الشهر (1-31)
  int get dayOfMonth => date.day;

  /// الشهر (1-12)
  int get month => date.month;

  /// السنة
  int get year => date.year;

  /// التاريخ كـ String بصيغة "yyyy-MM-dd"
  String get dateString {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// التاريخ للعرض بصيغة حلوة
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

  /// هل الوقت متاح/موجود؟
  bool get hasTimeInfo => timeRange.hasValidTime;

  /// وقت البداية (raw)
  String get startTime => timeRange.from;

  /// وقت النهاية (raw)
  String get endTime => timeRange.to;

  /// وقت البداية للعرض (مع fallback)
  String get displayStartTime {
    if (timeRange.from.isNotEmpty) {
      return timeRange.from;
    }
    return '--:--';
  }

  /// وقت النهاية للعرض (مع fallback)
  String get displayEndTime {
    if (timeRange.to.isNotEmpty) {
      return timeRange.to;
    }
    return '--:--';
  }

  /// وقت الجلسة كامل للعرض
  String get displayTime {
    if (timeRange.hasValidTime) {
      return '${timeRange.from} - ${timeRange.to}';
    }
    return 'الوقت غير متاح';
  }

  /// وقت الجلسة مع المدة
  String get displayTimeWithDuration {
    if (timeRange.hasValidTime) {
      return '${timeRange.from} - ${timeRange.to} ($duration دقيقة)';
    }
    return '$duration دقيقة (الوقت غير محدد)';
  }

  // ============ HELPER GETTERS للـ Payment ============

  /// index طريقة الدفع
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

  /// اسم طريقة الدفع بالعربي
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
      advisor: AdvisorModel.fromJson(json['advisor'] ?? {}),
      status: json['status'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      timeRange: TimeRangeModel.fromJson(json['timeRange'] ?? {}),
      duration: json['duration'] ?? 0,
      isAnonymous: json['isAnonymous'] ?? false,
      pricing: PricingModelResponse.fromJson(json['pricing'] ?? {}),
      paymentMethods: json['paymentMethods'] ?? '',
    );
  }

  /// Copy with للتعديل
  SessionDetailsDataResponse copyWith({
    String? sessionId,
    AdvisorModel? advisor,
    String? status,
    DateTime? date,
    TimeRangeModel? timeRange,
    int? duration,
    bool? isAnonymous,
    PricingModelResponse? pricing,
    String? paymentMethods,
  }) {
    return SessionDetailsDataResponse(
      sessionId: sessionId ?? this.sessionId,
      advisor: advisor ?? this.advisor,
      status: status ?? this.status,
      date: date ?? this.date,
      timeRange: timeRange ?? this.timeRange,
      duration: duration ?? this.duration,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      pricing: pricing ?? this.pricing,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}

/* ===================== TIME RANGE ===================== */

class TimeRangeModel {
  final String from;
  final String to;

  TimeRangeModel({required this.from, required this.to});

  /// هل الوقت صالح ومتاح؟
  bool get hasValidTime => from.isNotEmpty && to.isNotEmpty;

  /// هل وقت البداية متاح؟
  bool get hasFromTime => from.isNotEmpty;

  /// هل وقت النهاية متاح؟
  bool get hasToTime => to.isNotEmpty;

  /// الوقت للعرض
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

  /// Empty constructor
  factory TimeRangeModel.empty() {
    return TimeRangeModel(from: '', to: '');
  }

  Map<String, dynamic> toJson() {
    return {'from': from, 'to': to};
  }
}

/* ===================== PRICING ===================== */

class PricingModelResponse {
  final int sessionPrice;
  final int taxes;
  final int fees;
  final int discount;
  final dynamic total;

  PricingModelResponse({
    required this.sessionPrice,
    required this.taxes,
    required this.fees,
    required this.discount,
    required this.total,
  });

  /// الإجمالي كـ int
  int get totalAsInt {
    if (total is int) return total;
    if (total is double) return total.toInt();
    if (total is String) return int.tryParse(total) ?? 0;
    return 0;
  }

  /// الإجمالي كـ double
  double get totalAsDouble {
    if (total is double) return total;
    if (total is int) return total.toDouble();
    if (total is String) return double.tryParse(total) ?? 0.0;
    return 0.0;
  }

  /// السعر للعرض
  String get displayTotal => '$totalAsInt ر.س';

  /// سعر الجلسة للعرض
  String get displaySessionPrice => '$sessionPrice ر.س';

  factory PricingModelResponse.fromJson(Map<String, dynamic> json) {
    return PricingModelResponse(
      sessionPrice: json['sessionPrice'] ?? 0,
      taxes: json['taxes'] ?? 0,
      fees: json['fees'] ?? 0,
      discount: json['discount'] ?? 0,
      total: json['total'] ?? 0,
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
