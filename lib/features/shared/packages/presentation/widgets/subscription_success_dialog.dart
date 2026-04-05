import 'package:tayseer/my_import.dart';

class SubscriptionSuccessDialog extends StatelessWidget {
  const SubscriptionSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.kWhiteColor,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                gradient: AppColors.backgroundGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28.r),
                  topRight: Radius.circular(28.r),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 120.w,
                    child: Lottie.asset(
                      AssetsData.kSuccessMarriageAnimationsLottie,
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Gap(14.h),
                  Text(
                    context.tr('subscription_success_title'),
                    style: Styles.textStyle20Bold.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 24.h),
              child: Column(
                children: [
                  Text(
                    context.tr('subscription_success_subtitle'),
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.secondaryText,
                      height: 1.7,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(16.h),
                  CustomBotton(
                    height: 52.h,
                    width: double.infinity,
                    title: context.tr('done'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    useGradient: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showSubscriptionSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (_) => const SubscriptionSuccessDialog(),
  );
}
