import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';

class PickTimeResult {
  final TimeOfDay? time;
  final bool wasInvalid; // true if user picked a past time (invalid)

  PickTimeResult({this.time, this.wasInvalid = false});
}

Future<PickTimeResult> pickTime(
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

  if (picked == null) return PickTimeResult(time: null, wasInvalid: false);

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
          SnackBar(content: Text(context.tr('select_time_after_current'))),
        );
        return PickTimeResult(time: null, wasInvalid: true);
      }
    }
  }

  return PickTimeResult(time: picked, wasInvalid: false);
}
