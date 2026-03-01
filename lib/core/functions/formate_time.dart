import 'package:intl/intl.dart';

String formatTime(DateTime dateTime) {
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
    return DateFormat('h:mm a', 'ar').format(localDateTime);
  } else if (differenceInDays == 1) {
    return 'أمس';
  } else if (differenceInDays < 7) {
    return DateFormat('EEEE', 'ar').format(localDateTime);
  } else {
    return DateFormat('d/M/yyyy', 'ar').format(localDateTime);
  }
}
