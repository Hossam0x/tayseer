import 'package:tayseer/my_import.dart';

class CustomErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  final double? verticalPadding;
  final double? width;
  final double? height;

  const CustomErrorView({
    super.key,
    this.message,
    required this.onRetry,
    this.verticalPadding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: verticalPadding ?? 30.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppImage(
                AssetsData.appErrorIcon,
                width: 120.w,
                height: 120.w,
                fit: BoxFit.contain,
              ),
              Gap(10.h),
              Text(
                message ?? context.tr('error_loading_data'),
                style: Styles.textStyle16Meduim.copyWith(
                  color: AppColors.secondary800,
                ),
                textAlign: TextAlign.center,
              ),
              Gap(10.h),
              SizedBox(
                width: 160.w,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kprimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  onPressed: onRetry,
                  child: Text(
                    context.tr('retry'),
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.kWhiteColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
