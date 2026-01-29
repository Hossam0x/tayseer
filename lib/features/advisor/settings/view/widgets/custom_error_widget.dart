import 'package:tayseer/my_import.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String? buttonText;

  const CustomErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.buttonText,
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
              Icons.error_outline_rounded,
              size: 64.w,
              color: AppColors.kRedColor,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: Styles.textStyle16.copyWith(color: AppColors.secondary600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: Text(
                buttonText ?? 'إعادة المحاولة',
                style: Styles.textStyle16Meduim.copyWith(
                  color: AppColors.kWhiteColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
