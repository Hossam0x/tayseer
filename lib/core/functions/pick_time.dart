import 'package:flutter/material.dart';

Future<TimeOfDay?> pickTime(BuildContext context) async {
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

  return picked;
}
