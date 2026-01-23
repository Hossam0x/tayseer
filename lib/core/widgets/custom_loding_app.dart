import 'package:tayseer/my_import.dart';

class CustomloadingApp extends StatelessWidget {
  const CustomloadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppImage(
      width: context.width * 0.1,
      height: context.height * 0.1,
      AssetsData.kloadingAnimationsLottie,
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // مينفعش يقفله بالضغط برا
      barrierColor: Colors.black.withOpacity(0.3), // خلفية شفافة
      builder: (_) => PopScope(
        canPop: false, // مينفعش يقفله بزرار الرجوع
        child: const Center(
          child: CustomloadingApp(),
        ),
      ),
    );
  }

  /// إغلاق الـ Loading Dialog
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}