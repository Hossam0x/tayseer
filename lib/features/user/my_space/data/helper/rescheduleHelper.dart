// lib/features/user/my_space/presentation/widget/reschedule/reschedule_helper.dart

import 'package:tayseer/features/user/my_space/data/model/create_session/get_available_day.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';

class RescheduleHelper {
  RescheduleHelper._();

  // ============ PAYMENT METHODS ============

  /// تحويل index الدفع لـ String
  static String getPaymentMethodString(int index) {
    switch (index) {
      case 0:
        return 'bank';
      case 1:
        return 'wallet';
      case 2:
        return 'vodafone';
      default:
        return 'wallet';
    }
  }

  /// تحويل String الدفع لـ index
  static int getPaymentMethodIndex(String method) {
    switch (method.toLowerCase()) {
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

  // ============ DURATION MATCHING ============

  /// البحث عن Duration مطابقة من الـ old data
  static DurationOption? findMatchingDuration({
    required List<DurationOption> availableDurations,
    required int oldDuration,
  }) {
    if (availableDurations.isEmpty) return null;
    if (oldDuration <= 0) return null;

    try {
      return availableDurations.firstWhere((d) => d.duration == oldDuration);
    } catch (e) {
      // لو مش موجود، حاول تلاقي أقرب واحد
      return _findClosestDuration(availableDurations, oldDuration);
    }
  }

  /// البحث عن أقرب Duration
  static DurationOption? _findClosestDuration(
    List<DurationOption> durations,
    int targetDuration,
  ) {
    if (durations.isEmpty) return null;

    DurationOption? closest;
    int minDiff = 999999;

    for (var duration in durations) {
      int diff = (duration.duration - targetDuration).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = duration;
      }
    }

    return closest;
  }

  // ============ TIME SLOT MATCHING ============

  /// البحث عن TimeSlot مطابق من الـ old data
  static TimeSlot? findMatchingTimeSlot({
    required List<TimeSlot> availableTimeSlots,
    required String oldStartTime,
  }) {
    // لو الوقت القديم فاضي، ما نحاولش نطابق
    if (availableTimeSlots.isEmpty || oldStartTime.isEmpty) {
      return null;
    }

    try {
      // محاولة مطابقة مباشرة
      return availableTimeSlots.firstWhere((slot) => slot.time == oldStartTime);
    } catch (e) {
      // لو مش موجود بالظبط، حاول تطابق بتنسيق مختلف
      return _findTimeSlotFlexible(availableTimeSlots, oldStartTime);
    }
  }

  /// مطابقة مرنة للوقت (يتعامل مع اختلافات التنسيق)
  static TimeSlot? _findTimeSlotFlexible(
    List<TimeSlot> slots,
    String targetTime,
  ) {
    if (slots.isEmpty || targetTime.isEmpty) return null;

    // تنظيف الوقت المستهدف
    String cleanTarget = _normalizeTime(targetTime);

    try {
      return slots.firstWhere(
        (slot) => _normalizeTime(slot.time) == cleanTarget,
      );
    } catch (e) {
      return null;
    }
  }

  /// تنظيف تنسيق الوقت
  static String _normalizeTime(String time) {
    // إزالة المسافات
    String normalized = time.trim();

    // لو الوقت بصيغة "9:00" حوله لـ "09:00"
    if (normalized.length == 4 && normalized.contains(':')) {
      normalized = '0$normalized';
    }

    return normalized;
  }

  // ============ OLD SESSION VALIDATION ============

  /// التأكد إن الـ old session فيها معلومات وقت صالحة
  static bool hasValidOldTimeInfo(SessionDetailsDataResponse? oldSession) {
    if (oldSession == null) return false;
    return oldSession.hasTimeInfo;
  }

  /// التأكد إن الـ old session فيها معلومات duration صالحة
  static bool hasValidOldDuration(SessionDetailsDataResponse? oldSession) {
    if (oldSession == null) return false;
    return oldSession.duration > 0;
  }

  /// التأكد إن الـ old session فيها معلومات تاريخ صالحة
  static bool hasValidOldDate(SessionDetailsDataResponse? oldSession) {
    if (oldSession == null) return false;
    // التاريخ مش النهارده أو قبله
    return oldSession.date.isAfter(
      DateTime.now().subtract(Duration(days: 365)),
    );
  }

  /// الحصول على ملخص بيانات الـ old session
  static OldSessionSummary getOldSessionSummary(
    SessionDetailsDataResponse? oldSession,
  ) {
    return OldSessionSummary(
      hasDate: hasValidOldDate(oldSession),
      hasTime: hasValidOldTimeInfo(oldSession),
      hasDuration: hasValidOldDuration(oldSession),
      date: oldSession?.displayDate ?? 'غير محدد',
      time: oldSession?.displayTime ?? 'غير محدد',
      duration: oldSession?.duration ?? 0,
    );
  }

  // ============ DATE & TIME FORMATTING ============

  /// تحويل التاريخ والوقت للصيغة المطلوبة للـ API
  static String formatDateTimeForApi(String date, String time) {
    return '${date}T$time:00Z';
  }

  /// تحويل DateTime لـ String للـ API
  static String formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ============ PREFILL DATA ============

  /// الحصول على بيانات الـ prefill من الـ old session
  static PrefillData getPrefillData({
    required SessionDetailsDataResponse oldSession,
    required List<DurationOption> availableDurations,
    required List<TimeSlot> availableTimeSlots,
  }) {
    // Duration
    DurationOption? matchedDuration;
    if (hasValidOldDuration(oldSession)) {
      matchedDuration = findMatchingDuration(
        availableDurations: availableDurations,
        oldDuration: oldSession.duration,
      );
    }

    // Time Slot
    TimeSlot? matchedTimeSlot;
    if (hasValidOldTimeInfo(oldSession)) {
      matchedTimeSlot = findMatchingTimeSlot(
        availableTimeSlots: availableTimeSlots,
        oldStartTime: oldSession.startTime,
      );
    }

    return PrefillData(
      duration: matchedDuration,
      timeSlot: matchedTimeSlot,
      paymentMethodIndex: oldSession.paymentMethodIndex,
      isAnonymous: oldSession.isAnonymous,
      // Info about what was matched
      durationMatched: matchedDuration != null,
      timeSlotMatched: matchedTimeSlot != null,
      originalDuration: oldSession.duration,
      originalTime: oldSession.startTime,
    );
  }
}

// ============ HELPER CLASSES ============

/// ملخص بيانات الجلسة القديمة
class OldSessionSummary {
  final bool hasDate;
  final bool hasTime;
  final bool hasDuration;
  final String date;
  final String time;
  final int duration;

  OldSessionSummary({
    required this.hasDate,
    required this.hasTime,
    required this.hasDuration,
    required this.date,
    required this.time,
    required this.duration,
  });

  bool get hasAllInfo => hasDate && hasTime && hasDuration;
  bool get hasPartialInfo => hasDate || hasTime || hasDuration;
}

/// بيانات الـ Prefill
class PrefillData {
  final DurationOption? duration;
  final TimeSlot? timeSlot;
  final int paymentMethodIndex;
  final bool isAnonymous;

  // معلومات عن المطابقة
  final bool durationMatched;
  final bool timeSlotMatched;
  final int originalDuration;
  final String originalTime;

  PrefillData({
    this.duration,
    this.timeSlot,
    required this.paymentMethodIndex,
    required this.isAnonymous,
    required this.durationMatched,
    required this.timeSlotMatched,
    required this.originalDuration,
    required this.originalTime,
  });

  /// هل كل البيانات اتطابقت؟
  bool get allMatched => durationMatched && timeSlotMatched;

  /// هل فيه بيانات اتطابقت؟
  bool get anyMatched => durationMatched || timeSlotMatched;

  /// رسالة للمستخدم عن اللي مش اتطابق
  String get mismatchMessage {
    List<String> issues = [];

    if (!durationMatched && originalDuration > 0) {
      issues.add('المدة ($originalDuration دقيقة) غير متاحة');
    }

    if (!timeSlotMatched && originalTime.isNotEmpty) {
      issues.add('الوقت ($originalTime) غير متاح');
    }

    if (issues.isEmpty) return '';
    return issues.join('\n');
  }
}
