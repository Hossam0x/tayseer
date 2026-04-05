import 'package:tayseer/my_import.dart';

void showMembershipSuccessDialog(
  BuildContext context, {
  required String messageKey,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => _MembershipSuccessDialog(messageKey: messageKey),
  );
}

class _MembershipSuccessDialog extends StatelessWidget {
  final String messageKey;
  const _MembershipSuccessDialog({required this.messageKey});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h),
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
                    height: 110.w,
                    child: Lottie.asset(
                      AssetsData.kSuccessMarriageAnimationsLottie,
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Gap(12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      context.tr(messageKey),
                      style: Styles.textStyle18Bold.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // Action button
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
              child: CustomBotton(
                height: 50.h,
                width: double.infinity,
                title: context.tr('done'),
                onPressed: () => Navigator.of(context).pop(),
                useGradient: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
