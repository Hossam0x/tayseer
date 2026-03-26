import 'package:tayseer/my_import.dart';

class AccountConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;

  const AccountConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink.shade50, Colors.blue.shade50],
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImage(AssetsData.kWoriningImage, height: 100.h),
            Gap(20.h),
            Text(
              title,
              style: Styles.textStyle18Meduim.copyWith(
                color: AppColors.secondary800,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(12.h),
            Text(
              message,
              style: Styles.textStyle14.copyWith(color: AppColors.secondary600),
              textAlign: TextAlign.center,
            ),
            Gap(24.h),
            Row(
              children: [
                Expanded(
                  child: CustomBotton(
                    title: confirmText,
                    onPressed: onConfirm,
                    backGroundcolor: Colors.red,
                    titleColor: Colors.white,
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: CustomBotton(
                    title: cancelText,
                    onPressed: () => Navigator.pop(context),
                    backGroundcolor: Colors.green,
                    titleColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
