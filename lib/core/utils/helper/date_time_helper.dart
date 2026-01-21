// import 'package:flutter_timezone/flutter_timezone.dart';
// import 'package:intl/intl.dart';

// class DateTimeHelper {
//   /// الحصول على التايم زون (مثل: Africa/Cairo)
//   static Future<String> getTimezone() async {
//     try {
//       return await FlutterTimezone.getLocalTimezone();
//     } catch (e) {
//       return 'UTC';
//     }
//   }

//   /// الحصول على الوقت بصيغة 12 ساعة (مثل: 10:50 am)
//   static String getCurrentTime12Hour() {
//     final now = DateTime.now();
//     return DateFormat('hh:mm a').format(now); // 10:50 AM
//   }

//   /// الحصول على الوقت بصيغة 12 ساعة بحروف صغيرة (مثل: 10:50 am)
//   static String getCurrentTime12HourLower() {
//     final now = DateTime.now();
//     return DateFormat('hh:mm a').format(now).toLowerCase(); // 10:50 am
//   }

//   /// الحصول على الوقت بصيغة 24 ساعة (مثل: 22:50)
//   static String getCurrentTime24Hour() {
//     final now = DateTime.now();
//     return DateFormat('HH:mm').format(now); // 22:50
//   }

//   /// الحصول على التاريخ (مثل: 20 January 2026)
//   static String getCurrentDate() {
//     final now = DateTime.now();
//     return DateFormat('dd MMMM yyyy').format(now);
//   }

//   /// الحصول على التاريخ والوقت معًا
//   static String getFullDateTime() {
//     final now = DateTime.now();
//     return DateFormat('dd MMMM yyyy, hh:mm a').format(now);
//   }
// }
