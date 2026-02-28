import 'package:tayseer/my_import.dart';

class SnackBarService {
  static final SnackBarService _instance = SnackBarService._internal();
  factory SnackBarService() => _instance;
  SnackBarService._internal();

  // Track current SnackBar
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _currentController;
  bool _isShowing = false;

  /// عرض SnackBar بشكل آمن مع إدارة الحالة
  void showSnackBar({
    required BuildContext context,
    required String text,
    bool? isError,
    bool? isSuccess,
    Duration? duration,
  }) {
    // إغلاق أي SnackBar سابق أولاً بشكل فوري
    clearAll(context);

    // التحقق من أن context لا يزال صالحاً
    if (!context.mounted) {
      debugPrint('⚠️ Context is not mounted, cannot show snackbar');
      return;
    }

    // التحقق من أن ScaffoldMessenger موجود
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger == null) {
      debugPrint('⚠️ ScaffoldMessenger not found');
      return;
    }

    try {
      final snackBar = _createSnackBar(
        context: context,
        text: text,
        isError: isError,
        isSuccess: isSuccess,
        duration: duration ?? const Duration(milliseconds: 1800),
      );

      _currentController = scaffoldMessenger.showSnackBar(snackBar);
      _isShowing = true;

      // تتبع حالة الإغلاق
      _currentController?.closed.then((reason) {
        _isShowing = false;
        _currentController = null;
      });
    } catch (e) {
      debugPrint('❌ Error showing snackbar: $e');
    }
  }

  /// إنشاء SnackBar مخصص
  SnackBar _createSnackBar({
    required BuildContext context,
    required String text,
    bool? isError,
    bool? isSuccess,
    required Duration duration,
  }) {
    Color backgroundColor;
    Color textColor = Colors.white;

    if (isError == true) {
      backgroundColor = AppColors.kRedColor;
    } else if (isSuccess == true) {
      backgroundColor = AppColors.kgreen;
    } else {
      backgroundColor = AppColors.secondary800;
    }

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      margin: EdgeInsets.only(bottom: 40.h, right: 20.w, left: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      duration: duration,
      backgroundColor: backgroundColor,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      content: Text(
        text,
        textAlign: TextAlign.center,
        style: Styles.textStyle14SemiBold.copyWith(color: textColor),
      ),
    );
  }

  /// إغلاق جميع الـ SnackBars بشكل فوري
  void clearAll(BuildContext context) {
    if (context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    }
    _currentController = null;
    _isShowing = false;
  }

  /// التحقق مما إذا كان هناك SnackBar معروض حالياً
  bool get isShowing => _isShowing;
}

// دالة مساعدة للاستخدام السريع
void showSafeSnackBar({
  required BuildContext context,
  required String text,
  bool? isError,
  bool? isSuccess,
  Duration? duration,
}) {
  SnackBarService().showSnackBar(
    context: context,
    text: text,
    isError: isError,
    isSuccess: isSuccess,
    duration: duration,
  );
}
