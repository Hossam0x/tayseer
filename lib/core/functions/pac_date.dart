import 'package:flutter/material.dart';

Future<DateTime?> pickDate(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  return await showDatePicker(
    context: context,
    locale: Localizations.localeOf(context),
    initialDate: initialDate ?? DateTime(2000),
    firstDate: firstDate ?? DateTime(1950),
    lastDate: lastDate ?? DateTime.now(),
  );
}
