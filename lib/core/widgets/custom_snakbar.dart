import '../../my_import.dart';

SnackBar CustomSnackBar(
  BuildContext context, {
  required String text,
  bool? isError,
  bool? isSuccess,
}) {
  return SnackBar(
    behavior: SnackBarBehavior.floating, // ⭐ يخليه طاير
    elevation: 8, // ⭐ ظل أعلى
    margin: const EdgeInsets.only(
      bottom: 40, // ⭐ يرفعه لفوق
      right: 20,
      left: 20,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18), // ⭐ مستدير
    ),
    duration: const Duration(milliseconds: 1800), // زمن الظهور
    backgroundColor:
        isError == true
            ? AppColors.kRedColor
            : isSuccess == true
            ? AppColors.kgreen
            : AppColors.kRedColor,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),

    // ⭐ Animation جميل بشكل تلقائي من Flutter
    content: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
