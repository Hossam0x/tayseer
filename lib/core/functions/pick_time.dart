import 'package:flutter/material.dart';

Future<TimeOfDay?> pickTime(
  BuildContext context, {
  DateTime? minDate,
}) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          alwaysUse24HourFormat: false, // غيرها true لو عاوز 24 ساعة
        ),
        child: child!,
      );
    },
  );

  if (picked == null) return null;

  // If a minimum date is provided and it's today, disallow selecting a past time
  if (minDate != null) {
    final now = DateTime.now();
    if (minDate.year == now.year &&
        minDate.month == now.month &&
        minDate.day == now.day) {
      final nowTime = TimeOfDay.fromDateTime(now);
      final pickedMinutes = picked.hour * 60 + picked.minute;
      final nowMinutes = nowTime.hour * 60 + nowTime.minute;
      if (pickedMinutes < nowMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('الرجاء اختيار وقت لاحق من الوقت الحالي'),
          ),
        );
        return null;
      }
    }
  }

  return picked;
}
