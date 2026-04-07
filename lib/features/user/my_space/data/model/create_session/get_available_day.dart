// lib/features/user/my_space/data/model/create_session/get_available_day.dart

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
  final String dayNameFromApi;
  final bool isAvailable;
  final List<TimeSlot> timeSlots45; // ★ كان timeSlots30
  final List<TimeSlot> timeSlots90; // ★ زي ما هو

  CalendarDay({
    required this.date,
    required this.dayOfWeek,
    required this.dayNameFromApi,
    required this.isAvailable,
    required this.timeSlots45,
    required this.timeSlots90,
  });

  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    return CalendarDay(
      date: json['date'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? 0,
      dayNameFromApi: json['dayName'] ?? '', // ★ من الـ API
      isAvailable: json['isAvailable'] ?? false,
      // ★★★ هنا التعديل الأساسي ★★★
      timeSlots45:
          (json['timeSlots45'] as List<dynamic>?)
              ?.map((e) => TimeSlot.fromJson(e))
              .toList() ??
          [],
      timeSlots90:
          (json['timeSlots90'] as List<dynamic>?)
              ?.map((e) => TimeSlot.fromJson(e))
              .toList() ??
          [],
    );
  }

  int get dayNumber {
    try {
      return int.parse(date.split('-').last);
    } catch (e) {
      return 0;
    }
  }

  int get monthNumber {
    try {
      return int.parse(date.split('-')[1]);
    } catch (e) {
      return 0;
    }
  }

  int get yearNumber {
    try {
      return int.parse(date.split('-').first);
    } catch (e) {
      return 0;
    }
  }

  // ★ اسم اليوم بالعربي - من الـ API
  String get dayName {
    const arabicDays = {
      'Saturday': 'السبت',
      'Sunday': 'الاحد',
      'Monday': 'الاثنين',
      'Tuesday': 'الثلاثاء',
      'Wednesday': 'الاربعاء',
      'Thursday': 'الخميس',
      'Friday': 'الجمعة',
    };
    return arabicDays[dayNameFromApi] ?? dayNameFromApi;
  }

  String get dayNameEn => dayNameFromApi;

  String get monthName {
    const months = [
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
    final num = monthNumber;
    if (num >= 1 && num <= 12) return months[num];
    return '';
  }

  String get monthNameEn {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final num = monthNumber;
    if (num >= 1 && num <= 12) return months[num];
    return '';
  }

  String get fullDayTextAr => '$dayName, $dayNumber $monthName';
  String get fullDayTextEn => '$dayNameEn, $dayNumber $monthNameEn';

  // ★ أول وقت متاح
  String get firstAvailableTime {
    final slots45 = timeSlots45.where((s) => s.isAvailable).toList();
    if (slots45.isNotEmpty) return slots45.first.time;

    final slots90 = timeSlots90.where((s) => s.isAvailable).toList();
    if (slots90.isNotEmpty) return slots90.first.time;

    return '--:--';
  }

  String get firstAvailableTimeArabic {
    final slots45 = timeSlots45.where((s) => s.isAvailable).toList();
    if (slots45.isNotEmpty) return slots45.first.timeInArabic;

    final slots90 = timeSlots90.where((s) => s.isAvailable).toList();
    if (slots90.isNotEmpty) return slots90.first.timeInArabic;

    return '--:--';
  }

  int get availableSlots45Count =>
      timeSlots45.where((s) => s.isAvailable).length;

  int get availableSlots90Count =>
      timeSlots90.where((s) => s.isAvailable).length;

  int get totalAvailableSlotsCount =>
      availableSlots45Count + availableSlots90Count;

  bool get hasAvailableSlots => totalAvailableSlotsCount > 0;
  bool get hasAvailable45Slots => availableSlots45Count > 0;
  bool get hasAvailable90Slots => availableSlots90Count > 0;

  List<TimeSlot> getAvailableSlots(int durationMinutes) {
    if (durationMinutes == 45) {
      return timeSlots45.where((slot) => slot.isAvailable).toList();
    } else if (durationMinutes == 90) {
      return timeSlots90.where((slot) => slot.isAvailable).toList();
    }
    return [];
  }

  List<TimeSlot> getAllSlots(int durationMinutes) {
    if (durationMinutes == 45) return timeSlots45;
    if (durationMinutes == 90) return timeSlots90;
    return [];
  }

  DateTime? get dateTime {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }

  bool get isToday {
    final now = DateTime.now();
    return dateTime?.year == now.year &&
        dateTime?.month == now.month &&
        dateTime?.day == now.day;
  }

  bool get isPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dateTime?.isBefore(today) ?? false;
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

  // ════════════════════════════════════════
  // ★ الوقت بصيغة عربية (07:00 → 07:00 ص)
  // ════════════════════════════════════════
  String get timeInArabic {
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      String minute = parts[1];
      String period = hour >= 12 ? 'م' : 'ص';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    } catch (e) {
      return time;
    }
  }

  // ════════════════════════════════════════
  // ★ وقت النهاية بصيغة عربية
  // ════════════════════════════════════════
  String get endTimeInArabic {
    try {
      final parts = endTime.split(':');
      int hour = int.parse(parts[0]);
      String minute = parts[1];
      String period = hour >= 12 ? 'م' : 'ص';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    } catch (e) {
      return endTime;
    }
  }

  // ════════════════════════════════════════
  // ★ الوقت بصيغة إنجليزية (07:00 → 07:00 AM)
  // ════════════════════════════════════════
  String get timeInEnglish {
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      String minute = parts[1];
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    } catch (e) {
      return time;
    }
  }

  // ════════════════════════════════════════
  // ★ النطاق الزمني بالعربي (07:00 ص - 07:30 ص)
  // ════════════════════════════════════════
  String get timeRangeArabic {
    return '$timeInArabic - $endTimeInArabic';
  }

  // ════════════════════════════════════════
  // ★ الساعة فقط (07:00 → 7)
  // ════════════════════════════════════════
  int get hourNumber {
    try {
      return int.parse(time.split(':').first);
    } catch (e) {
      return 0;
    }
  }

  // ════════════════════════════════════════
  // ★ الدقائق فقط (07:30 → 30)
  // ════════════════════════════════════════
  int get minuteNumber {
    try {
      return int.parse(time.split(':').last);
    } catch (e) {
      return 0;
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

  // ════════════════════════════════════════
  // ★ المدة بالعربي
  // ════════════════════════════════════════
  String get durationInArabic {
    return '$duration دقيقة';
  }

  // ════════════════════════════════════════
  // ★ المدة بالإنجليزي
  // ════════════════════════════════════════
  String get durationInEnglish {
    return '$duration minutes';
  }

  // ════════════════════════════════════════
  // ★ السعر مع العملة بالعربي
  // ════════════════════════════════════════
  String get priceWithCurrency {
    return '$price ${_getCurrencyArabic()}';
  }

  // ════════════════════════════════════════
  // ★ السعر مع العملة بالإنجليزي
  // ════════════════════════════════════════
  String get priceWithCurrencyEn {
    return '$price $currency';
  }

  // ════════════════════════════════════════
  // ★ رمز العملة بالعربي
  // ════════════════════════════════════════
  String _getCurrencyArabic() {
    switch (currency.toUpperCase()) {
      case 'SAR':
        return 'ر.س';
      case 'EGP':
        return 'ج.م';
      case 'AED':
        return 'د.إ';
      case 'KWD':
        return 'د.ك';
      case 'QAR':
        return 'ر.ق';
      case 'BHD':
        return 'د.ب';
      case 'JOD':
        return 'د.أ';
      case 'MAD':
        return 'د.م';
      case 'TND':
        return 'د.ت';
      default:
        return currency;
    }
  }

  // ════════════════════════════════════════
  // ★ هل هي 30 دقيقة؟
  // ════════════════════════════════════════
  bool get is30Min => duration == 30;

  // ════════════════════════════════════════
  // ★ هل هي 60 دقيقة؟
  // ════════════════════════════════════════
  bool get is60Min => duration == 60;

  // ════════════════════════════════════════
  // ★ النوع بالعربي
  // ════════════════════════════════════════
  String get typeInArabic {
    switch (type.toLowerCase()) {
      case 'session':
        return 'جلسة فردية';
      case 'package':
        return 'باقة';
      default:
        return type;
    }
  }

  // ════════════════════════════════════════
  // ★ النوع بالإنجليزي
  // ════════════════════════════════════════
  String get typeInEnglish {
    switch (type.toLowerCase()) {
      case 'session':
        return 'Individual Session';
      case 'package':
        return 'Package';
      default:
        return type;
    }
  }
}
