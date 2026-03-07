import 'package:tayseer/my_import.dart';

class AccountReviewContent extends StatelessWidget {
  final VoidCallback? onButtonPressed;
  final bool isDialog;
  final bool showButton;

  const AccountReviewContent({
    super.key,
    this.onButtonPressed,
    this.isDialog = false,
    this.showButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final double imageHeight = isDialog
        ? context.height * .25
        : context.height * .35;
    final double imageWidth = isDialog
        ? context.width * .4
        : context.width * .65;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDialog) SizedBox(height: context.height * .03),
        Text(
          context.tr('accountReviewTitle'),
          textAlign: TextAlign.center,
          style: Styles.textStyle18.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.kscandryTextColor,
          ),
        ),
        const SizedBox(height: 16),
        AppImage(
          AssetsData.kAccountReviewImage,
          height: imageHeight,
          width: imageWidth,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            context.tr('accountReviewSubtitle'),
            textAlign: TextAlign.center,
            style: Styles.textStyle14,
          ),
        ),
        if (showButton) ...[
          if (!isDialog) ...[
            Gap(context.height * 0.1),
            CustomBotton(
              useGradient: true,
              title: context.tr('continuation'),
              onPressed:
                  onButtonPressed ??
                  () {
                    // pop
                    context.pop();
                  },
            ),
          ] else ...[
            Gap(24.h),
            CustomBotton(
              width: context.width * .5,
              useGradient: true,
              title: context.tr('ok'),
              onPressed: () => Navigator.pop(context),
            ),
            if (isDialog) SizedBox(height: context.height * .03),
          ],
        ],
      ],
    );
  }
}
