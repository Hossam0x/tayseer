import 'package:flutter/material.dart';

Future<DateTime?> pickDate(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final now = DateTime.now();
  // Default to today as the earliest selectable date, and allow up to 10 years ahead
  final _first = firstDate ?? DateTime(now.year, now.month, now.day);
  final _last = lastDate ?? now.add(const Duration(days: 3650));

  // Ensure initialDate falls within the allowed range
  DateTime init = initialDate ?? now;
  if (init.isBefore(_first)) init = _first;
  if (init.isAfter(_last)) init = _last;

  return await showDatePicker(
    context: context,
    locale: Localizations.localeOf(context),
    initialDate: init,
    firstDate: _first,
    lastDate: _last,
  );
}
