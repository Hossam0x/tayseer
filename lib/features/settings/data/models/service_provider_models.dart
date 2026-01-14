import 'package:equatable/equatable.dart';

// ============================================
// 📌 TIME SLOT MODEL
// ============================================
class TimeSlotModel extends Equatable {
  final String start;
  final String end;

  const TimeSlotModel({required this.start, required this.end});

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      start: json['start'] as String,
      end: json['end'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'start': start, 'end': end};
  }

  @override
  List<Object?> get props => [start, end];
}

// ============================================
// 📌 WEEKLY AVAILABILITY MODEL
// ============================================
class WeeklyAvailabilityModel extends Equatable {
  final int dayOfWeek; // 0 = Saturday, 6 = Friday
  final bool isEnabled;
  final List<TimeSlotModel> timeSlots;

  const WeeklyAvailabilityModel({
    required this.dayOfWeek,
    required this.isEnabled,
    required this.timeSlots,
  });

  factory WeeklyAvailabilityModel.fromJson(Map<String, dynamic> json) {
    final timeSlotsList = (json['timeSlots'] as List)
        .map((slot) => TimeSlotModel.fromJson(slot as Map<String, dynamic>))
        .toList();

    return WeeklyAvailabilityModel(
      dayOfWeek: json['dayOfWeek'] as int,
      isEnabled: json['isEnabled'] as bool,
      timeSlots: timeSlotsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'isEnabled': isEnabled,
      'timeSlots': timeSlots.map((slot) => slot.toJson()).toList(),
    };
  }

  // الحصول على اسم اليوم العربي
  String get dayName {
    switch (dayOfWeek) {
      case 0:
        return 'السبت';
      case 1:
        return 'الأحد';
      case 2:
        return 'الاثنين';
      case 3:
        return 'الثلاثاء';
      case 4:
        return 'الأربعاء';
      case 5:
        return 'الخميس';
      case 6:
        return 'الجمعة';
      default:
        return '';
    }
  }

  @override
  List<Object?> get props => [dayOfWeek, isEnabled, timeSlots];
}

// ============================================
// 📌 SESSION TYPE MODEL
// ============================================
class SessionTypeModel extends Equatable {
  final int duration; // بالدقائق
  final int price;
  final String currency;
  final bool isEnabled;

  const SessionTypeModel({
    required this.duration,
    required this.price,
    required this.currency,
    required this.isEnabled,
  });

  factory SessionTypeModel.fromJson(Map<String, dynamic> json) {
    return SessionTypeModel(
      duration: json['duration'] as int,
      price: json['price'] as int,
      currency: json['currency'] as String,
      isEnabled: json['isEnabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
      'price': price,
      'currency': currency,
      'isEnabled': isEnabled,
    };
  }

  // الحصول على المدة بشكل نصي
  String get durationText {
    if (duration == 30) return '30 دقيقة';
    if (duration == 60) return '60 دقيقة';
    return '$duration دقيقة';
  }

  @override
  List<Object?> get props => [duration, price, currency, isEnabled];
}

// ============================================
// 📌 SERVICE PROVIDER REQUEST MODEL
// ============================================
class ServiceProviderRequest extends Equatable {
  final Map<String, SessionTypeModel> sessionTypes;
  final List<WeeklyAvailabilityModel> weeklyAvailability;
  final String timezone;

  const ServiceProviderRequest({
    required this.sessionTypes,
    required this.weeklyAvailability,
    required this.timezone,
  });

  factory ServiceProviderRequest.fromJson(Map<String, dynamic> json) {
    // تحويل sessionTypes
    final sessionTypesMap = Map<String, dynamic>.from(json['sessionTypes']);
    final sessionTypes = sessionTypesMap.map(
      (key, value) => MapEntry(
        key,
        SessionTypeModel.fromJson(value as Map<String, dynamic>),
      ),
    );

    // تحويل weeklyAvailability
    final weeklyAvailabilityList = (json['weeklyAvailability'] as List)
        .map(
          (day) =>
              WeeklyAvailabilityModel.fromJson(day as Map<String, dynamic>),
        )
        .toList();

    return ServiceProviderRequest(
      sessionTypes: sessionTypes,
      weeklyAvailability: weeklyAvailabilityList,
      timezone: json['timezone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionTypes': sessionTypes.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'weeklyAvailability': weeklyAvailability
          .map((day) => day.toJson())
          .toList(),
      'timezone': timezone,
    };
  }

  // إنشاء request افتراضي
  factory ServiceProviderRequest.defaultRequest() {
    return ServiceProviderRequest(
      sessionTypes: {
        '30min': SessionTypeModel(
          duration: 30,
          price: 100,
          currency: 'SAR',
          isEnabled: true,
        ),
        '60min': SessionTypeModel(
          duration: 60,
          price: 180,
          currency: 'SAR',
          isEnabled: true,
        ),
      },
      weeklyAvailability: List.generate(7, (index) {
        return WeeklyAvailabilityModel(
          dayOfWeek: index,
          isEnabled:
              index == 0 ||
              index == 1, // Saturday and Sunday enabled by default
          timeSlots: index == 0 || index == 1
              ? [TimeSlotModel(start: '09:00', end: '17:00')]
              : [],
        );
      }),
      timezone: 'Asia/Riyadh',
    );
  }

  @override
  List<Object?> get props => [sessionTypes, weeklyAvailability, timezone];
}

// ============================================
// 📌 SERVICE PROVIDER RESPONSE MODEL
// ============================================
class ServiceProviderResponse extends Equatable {
  final bool success;
  final String message;
  final ServiceProviderRequest? data;

  const ServiceProviderResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ServiceProviderResponse.fromJson(Map<String, dynamic> json) {
    ServiceProviderRequest? data;
    if (json['data'] != null) {
      data = ServiceProviderRequest.fromJson(
        json['data'] as Map<String, dynamic>,
      );
    }

    return ServiceProviderResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: data,
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}
