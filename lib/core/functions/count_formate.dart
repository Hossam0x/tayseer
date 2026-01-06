import 'package:tayseer/core/constant/constans.dart';

String formatCount(int count) {
  if (count < 1000) {
    return count.toString();
  } else if (count < 1000000) {
    // التحويل للآلاف
    double value = count / 1000.0;
    String formattedNumber = value
        .toStringAsFixed(1)
        .replaceAll(RegExp(r'\.0$'), '');

    // لو عربي: "1.5 ألف" (مسافة ثم الكلمة)
    // لو انجليزي: "1.5k" (بدون مسافة والرمز k)
    return "$formattedNumber${isArabic ? ' ألف' : 'k'}";
  } else {
    // التحويل للملايين
    double value = count / 1000000.0;
    String formattedNumber = value
        .toStringAsFixed(1)
        .replaceAll(RegExp(r'\.0$'), '');

    return "$formattedNumber${isArabic ? ' مليون' : 'M'}";
  }
}
