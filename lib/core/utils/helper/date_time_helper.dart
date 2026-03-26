import 'package:intl/intl.dart';

class DateTimeHelper {
  /// Format a rating date string (e.g. "3/15/2025, 10:30:00 AM") to a readable date.
  static String formatRatingDate(String dateString, String langCode) {
    try {
      final parsed = DateFormat('M/d/yyyy, hh:mm:ss a', 'en').parse(dateString);
      return DateFormat('dd MMMM yyyy', langCode).format(parsed);
    } catch (_) {
      return dateString;
    }
  }
}
