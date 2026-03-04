import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/styles.dart';

/// ويدجت نهاية البوستات المحفوظة — تظهر في آخر القائمة أثناء الأوفلاين
class EndOfCachedPosts extends StatelessWidget {
  const EndOfCachedPosts({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 36.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 12.h),
          Text(
            'أنت تشاهد منشورات محفوظة',
            style: Styles.textStyle14.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            'اتصل بالإنترنت لتحميل المزيد',
            style: Styles.textStyle12.copyWith(color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Container(
            width: 4.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}
