// lib/features/user/my_space/data/model/create_session.dart

class AvailableSlotsResponseModel {
  final bool success;
  final String message;
  final AvailableSlotsData data;

  AvailableSlotsResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AvailableSlotsResponseModel.fromJson(Map<String, dynamic> json) {
    return AvailableSlotsResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: AvailableSlotsData.fromJson(json['data'] ?? {}),
    );
  }
}

class AvailableSlotsData {
  final int month;
  final int year;
  final List<CalendarDay> calendarDays;
  final List<DurationOption> duration;

  AvailableSlotsData({
    required this.month,
    required this.year,
    required this.calendarDays,
    required this.duration,
  });

  factory AvailableSlotsData.fromJson(Map<String, dynamic> json) {
    return AvailableSlotsData(
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      calendarDays:
          (json['calendarDays'] as List<dynamic>?)
              ?.map((e) => CalendarDay.fromJson(e))
              .toList() ??
          [],
      duration:
          (json['duration'] as List<dynamic>?)
              ?.map((e) => DurationOption.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CalendarDay {
  final String date;
  final int dayOfWeek;
  final bool isAvailable;
  final List<TimeSlot> timeSlots30;
  final List<TimeSlot> timeSlots60;

  CalendarDay({
    required this.date,
    required this.dayOfWeek,
    required this.isAvailable,
    required this.timeSlots30,
    required this.timeSlots60,
  });

  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    return CalendarDay(
      date: json['date'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
      timeSlots30:
          (json['timeSlots30'] as List<dynamic>?)
              ?.map((e) => TimeSlot.fromJson(e))
              .toList() ??
          [],
      timeSlots60:
          (json['timeSlots60'] as List<dynamic>?)
              ?.map((e) => TimeSlot.fromJson(e))
              .toList() ??
          [],
    );
  }

  // استخراج رقم اليوم من التاريخ
  int get dayNumber {
    try {
      return int.parse(date.split('-').last);
    } catch (e) {
      return 0;
    }
  }

  // الحصول على الأوقات المتاحة حسب المدة
  List<TimeSlot> getAvailableSlots(int durationMinutes) {
    if (durationMinutes == 30) {
      return timeSlots30.where((slot) => slot.isAvailable).toList();
    } else if (durationMinutes == 60) {
      return timeSlots60.where((slot) => slot.isAvailable).toList();
    }
    return [];
  }
}

class TimeSlot {
  final String time;
  final String endTime;
  final bool isAvailable;

  TimeSlot({
    required this.time,
    required this.endTime,
    required this.isAvailable,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      time: json['time'] ?? '',
      endTime: json['endTime'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
    );
  }

  // تحويل الوقت لصيغة عربية
  String get timeInArabic {
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      String period = hour >= 12 ? 'م' : 'ص';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '${hour.toString().padLeft(2, '0')}:${parts[1]} $period';
    } catch (e) {
      return time;
    }
  }
}

class DurationOption {
  final String type;
  final int duration;
  final int price;
  final String currency;
  final bool isEnabled;

  DurationOption({
    required this.type,
    required this.duration,
    required this.price,
    required this.currency,
    required this.isEnabled,
  });

  factory DurationOption.fromJson(Map<String, dynamic> json) {
    final docData = json['_doc'] as Map<String, dynamic>? ?? {};

    return DurationOption(
      type: json['type'] ?? '',
      duration: docData['duration'] ?? json['duration'] ?? 0,
      price: docData['price'] ?? json['price'] ?? 0,
      currency: docData['currency'] ?? json['currency'] ?? 'SAR',
      isEnabled: docData['isEnabled'] ?? json['isEnabled'] ?? false,
    );
  }

  // الحصول على اسم المدة بالعربي
  String get durationInArabic {
    return '$duration دقيقة';
  }

  // الحصول على السعر مع العملة
  String get priceWithCurrency {
    return '$price $currency';
  }
}
