// lib/core/widgets/empty_sessions_state.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/my_import.dart';

class EmptySessionsState extends StatelessWidget {
  const EmptySessionsState({
    super.key,
    required this.title,
    required this.subtitle,
    this.showAnimation = true,
    this.isCompact = false, // ✅ للحجم الصغير داخل القسم
  });

  final String title;
  final String subtitle;
  final bool showAnimation;
  final bool isCompact; // ✅ جديد

  @override
  Widget build(BuildContext context) {
    final content = isCompact ? _buildCompactContent() : _buildFullContent();

    if (showAnimation) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: content,
      );
    }

    return content;
  }

  // ✅ المحتوى الكامل (للصفحة الفارغة بالكامل)
  Widget _buildFullContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppImage(AssetsData.noSessionHistoryIcon, width: 268.w),
        SizedBox(height: 20.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
        ),
      ],
    );
  }

  // ✅ المحتوى المضغوط (لقسم داخل الصفحة)
  Widget _buildCompactContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImage(AssetsData.noSessionHistoryIcon, width: 120.w),
            SizedBox(height: 15.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
