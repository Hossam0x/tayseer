import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/utils/styles.dart';
import 'package:tayseer/core/widgets/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget موحد لعرض حالة الخطأ
class ErrorStateWidget extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;
  final String? title;
  final String? retryButtonText;

  const ErrorStateWidget({
    super.key,
    this.errorMessage,
    required this.onRetry,
    this.title,
    this.retryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AssetsData.errorIcon,
              width: 150.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16.h),
            Text(
              title ?? 'حدث خطأ ما',
              style: Styles.textStyle18,
              textAlign: TextAlign.center,
            ),
            if (errorMessage != null && errorMessage!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                errorMessage!,
                style: Styles.textStyle14.copyWith(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: 16.h),
            CustomBotton(
              width: 200.w,
              title: retryButtonText ?? "إعادة المحاولة",
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
