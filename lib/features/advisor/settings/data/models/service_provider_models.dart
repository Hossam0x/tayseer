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
      start: json['start']?.toString() ?? '09:00',
      end: json['end']?.toString() ?? '17:00',
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
    List<TimeSlotModel> timeSlotsList = [];

    try {
      if (json['timeSlots'] is List) {
        timeSlotsList = (json['timeSlots'] as List)
            .where((slot) => slot != null)
            .map((slot) => TimeSlotModel.fromJson(slot as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('⚠️ Error parsing timeSlots: $e');
    }

    return WeeklyAvailabilityModel(
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 0,
      isEnabled: json['isEnabled'] as bool? ?? false,
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
        return 'saturday';
      case 1:
        return 'sunday';
      case 2:
        return 'monday';
      case 3:
        return 'tuesday';
      case 4:
        return 'wednesday';
      case 5:
        return 'thursday';
      case 6:
        return 'friday';
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
      duration: (json['duration'] as num?)?.toInt() ?? 30,
      price: (json['price'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'SAR',
      isEnabled: json['isEnabled'] as bool? ?? true,
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
    if (duration == 30) return 'thirtyMinutes';
    if (duration == 60) return 'sixtyMinutes';
    return '$duration';
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
    print('📦 Parsing ServiceProviderRequest from JSON');

    // تحويل sessionTypes
    Map<String, SessionTypeModel> sessionTypesMap = {};
    try {
      if (json['sessionTypes'] is Map) {
        final sessionTypesData = json['sessionTypes'] as Map<String, dynamic>;
        sessionTypesData.forEach((key, value) {
          try {
            sessionTypesMap[key] = SessionTypeModel.fromJson(
              value as Map<String, dynamic>,
            );
          } catch (e) {
            print('⚠️ Error parsing session type $key: $e');
          }
        });
      }
    } catch (e) {
      print('⚠️ Error parsing sessionTypes: $e');
    }

    // تحويل weeklyAvailability
    List<WeeklyAvailabilityModel> weeklyAvailabilityList = [];
    try {
      if (json['weeklyAvailability'] is List) {
        weeklyAvailabilityList = (json['weeklyAvailability'] as List)
            .where((day) => day != null)
            .map(
              (day) =>
                  WeeklyAvailabilityModel.fromJson(day as Map<String, dynamic>),
            )
            .toList();
      }
    } catch (e) {
      print('⚠️ Error parsing weeklyAvailability: $e');
    }

    // إذا كانت القائمة فارغة، نملأها بأيام الأسبوع السبعة
    if (weeklyAvailabilityList.length != 7) {
      print('📝 Creating default weekly availability (7 days)');
      weeklyAvailabilityList = List.generate(7, (index) {
        return WeeklyAvailabilityModel(
          dayOfWeek: index,
          isEnabled:
              index == 0 ||
              index == 1, // Saturday and Sunday enabled by default
          timeSlots: index == 0
              ? [
                  TimeSlotModel(start: '10:00', end: '12:00'),
                  TimeSlotModel(start: '14:00', end: '17:00'),
                ]
              : index == 1
              ? [TimeSlotModel(start: '09:00', end: '17:00')]
              : [],
        );
      });
    }

    return ServiceProviderRequest(
      sessionTypes: sessionTypesMap.isNotEmpty
          ? sessionTypesMap
          : ServiceProviderRequest.defaultRequest().sessionTypes,
      weeklyAvailability: weeklyAvailabilityList,
      timezone: json['timezone']?.toString() ?? 'Asia/Riyadh',
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
          timeSlots: index == 0
              ? [
                  TimeSlotModel(start: '10:00', end: '12:00'),
                  TimeSlotModel(start: '14:00', end: '17:00'),
                ]
              : index == 1
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

  @override
  List<Object?> get props => [success, message, data];
}
