import 'dart:ui';

import 'package:tayseer/my_import.dart';

class CusttomGlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool showIcon;
  final double? width;
  final double height;

  const CusttomGlassButton({
    super.key,
    required this.text,
    required this.onTap,
    this.showIcon = false,
    this.width,
    this.height = 55,
  });

  @override
  Widget build(BuildContext context) {
    // استخدمنا ClipRRect عشان الـ Blur ما يخرجش بره حدود الزر
    return ClipRRect(
      borderRadius: BorderRadius.circular(15), // حواف دائرية ناعمة
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10.0,
          sigmaY: 10.0,
        ), // قوة التغبيش (Blur)
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: width ?? double.infinity,
            height: height,
            decoration: BoxDecoration(
              // ✅ تأثير الزجاج (لون أبيض شفاف متدرج)
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.5), // أبيض فاتح شوية
                  Colors.white.withOpacity(0.2), // أبيض شفاف أكتر
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              // ✅ حدود بيضاء رفيعة لإبراز الحواف
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1.5,
              ),
              // ✅ ظل خفيف جداً
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ اللوجيك الخاص بظهور الأيقونة
                if (showIcon) ...[
                  AppImage(
                    AssetsData.kLoadingAiAnimationLottie,
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(width: 8), // مسافة بين الأيقونة والنص
                ],

                Text(
                  text,
                  style: Styles.textStyle16Bold.copyWith(
                    color: AppColors
                        .kprimaryColor, // اللون الأحمر الغامق زي الصورة
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
