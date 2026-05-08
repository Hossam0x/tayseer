import 'package:tayseer/my_import.dart';

// ── ألوان Gold ──
const _goldGradient1 = Color(0xFFD4A017);
const _goldGradient2 = Color(0xFF8B6914);
const _goldAccent = Color(0xFFF5C842);

// ── ألوان Elite ──
const _eliteGradient1 = Color(0xFF6A1FC2);
const _eliteGradient2 = Color(0xFF4A1A8C);
const _eliteAccent = Color(0xFFB57BFF);

class SubscriptionSuccessDialog extends StatelessWidget {
  /// true → Gold theme | false → Elite theme
  final bool isGold;

  const SubscriptionSuccessDialog({super.key, this.isGold = true});

  @override
  Widget build(BuildContext context) {
    final gradientColors = isGold
        ? [_goldGradient1, _goldGradient2]
        : [_eliteGradient1, _eliteGradient2];

    final accentColor = isGold ? _goldAccent : _eliteAccent;
    final packageIcon = isGold ? AssetsData.goldIcon : AssetsData.eliteIcon;
    final packageName = isGold ? 'Gold' : 'Elite';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.kWhiteColor,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header مع gradient ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28.r),
                  topRight: Radius.circular(28.r),
                ),
              ),
              child: Column(
                children: [
                  // ── Lottie animation ──────────────────────────────────
                  SizedBox(
                    height: 110.w,
                    child: Lottie.asset(
                      AssetsData.kSuccessMarriageAnimationsLottie,
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Gap(12.h),

                  // ── Package badge ─────────────────────────────────────
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: accentColor.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppImage(packageIcon, width: 22.w, height: 22.w),
                        Gap(8.w),
                        Text(
                          packageName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(14.h),

                  // ── Title ─────────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      context.tr('subscription_success_title'),
                      style: Styles.textStyle20Bold.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ───────────────────────────────────────────────────
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
                  Gap(20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // dialog
                        Navigator.pop(context); // subscription view
                        Navigator.pop(context); // packages view
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gradientColors.last,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        context.tr('done'),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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

void showSubscriptionSuccessDialog(BuildContext context, {bool isGold = true}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (_) => SubscriptionSuccessDialog(isGold: isGold),
  );
}
