import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:tayseer/core/utils/assets.dart';

class SuccessRatingDialog extends StatelessWidget {
  const SuccessRatingDialog({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "SuccessDialog",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (context, __, ___) {
        return const Center(
          child: Material(
            type: MaterialType.transparency,
            child: SuccessRatingDialog(),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        );
        return ScaleTransition(
          scale: curve,
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w), // مارجن جانبي
      padding: EdgeInsets.all(20.r), // بادينج داخلي
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF2E7FF), Colors.white, Color(0xFFFFF0F5)],
          stops: [0.0, 0.4, 1.0],
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- زر الإغلاق ---
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.close,
                color: const Color(0xFF530D1D),
                size: 30.sp,
              ),
            ),
          ),

          // --- النص ---
          Text(
            "! تم ارسال تقييمك بنجاح",
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFA8364B),
              fontFamily: 'Arial',
            ),
          ),
          SizedBox(height: 20.h),

          // --- الصورة ---
          Image.asset(
            AssetsData.ratingSuccessIcon,
            height: 180.h, // ارتفاع الصورة
            fit: BoxFit.contain,
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
