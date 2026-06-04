import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';

class ErrorStateWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;
  final String? retryButtonText;
  final IconData? icon;

  const ErrorStateWidget({
    super.key,
    this.errorMessage,
    required this.onRetry,
    this.retryButtonText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 60.sp,
              color: Colors.red[300],
            ),
            SizedBox(height: 16.h),
            Text(
              errorMessage ?? context.tr('error_loading_session'),
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryButtonText ?? context.tr('try_again')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD65A73),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
