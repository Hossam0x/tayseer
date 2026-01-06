// دالة لحساب الوقت المنقضي (مثل: 3h, 5m)
import 'package:tayseer/my_import.dart';

String getTimeAgo(BuildContext context, DateTime? dateTime) {
  if (dateTime == null) return '';
  final difference = DateTime.now().difference(dateTime);
  if (difference.inDays > 0) {
    return '${difference.inDays}${context.tr(AppStrings.day)}'; // يوم
  } else if (difference.inHours > 0) {
    return '${difference.inHours}${context.tr(AppStrings.h)}'; // ساعة
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}${context.tr(AppStrings.m)}'; // دقيقة
  } else if (difference.inSeconds > 0) {
    return '${difference.inSeconds}${context.tr(AppStrings.s)}'; // ثانية
  } else {
    return '0${context.tr(AppStrings.now)}'; // ثانية
  }
}
