import 'package:intl/intl.dart';
import 'package:tayseer/core/constant/constans.dart';

String formatTime(DateTime dateTime) {
  final locale = isArabic ? 'ar' : 'en';
  final localDateTime = dateTime.toLocal();
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final dateToCompare = DateTime(
    localDateTime.year,
    localDateTime.month,
    localDateTime.day,
  );
  final differenceInDays = today.difference(dateToCompare).inDays;

  if (differenceInDays == 0) {
    return DateFormat('h:mm a', locale).format(localDateTime);
  } else if (differenceInDays == 1) {
    return isArabic ? 'أمس' : 'Yesterday';
  } else if (differenceInDays < 7) {
    return DateFormat('EEEE', locale).format(localDateTime);
  } else {
    return DateFormat('d/M/yyyy').format(localDateTime);
  }
}
