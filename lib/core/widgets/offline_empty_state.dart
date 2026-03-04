import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/styles.dart';

/// شاشة فارغة ودودة عند عدم وجود إنترنت وبدون كاش
class OfflineEmptyState extends StatelessWidget {
  const OfflineEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 64.sp,
                  color: Colors.grey.shade400,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'أنت غير متصل بالإنترنت',
                style: Styles.textStyle16.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'اتصل بالإنترنت لعرض المنشورات',
                style: Styles.textStyle14.copyWith(color: Colors.grey.shade400),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
