import 'package:tayseer/my_import.dart';

// ════════════════════════════════════════════════════════════════
// ✅ Shared Widget — يتستخدم في Exploration و History
// ════════════════════════════════════════════════════════════════
class SubscriptionButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SubscriptionButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ??
          () => context.pushNamed(AppRouter.kinteractionSubscriptionView),
      child: Container(
        width: double.infinity,
        height: 55.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              Color(0xFFEB7A91),
              Color.fromRGBO(245, 192, 3, 1),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEB7A91).withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(AssetsData.diamondIcon, width: 24.w, height: 24.h),
            SizedBox(width: 12.w),
            Text(
              context.tr("subscribe_to_see_likes"),
              style: Styles.textStyle20SemiBold.copyWith(
                fontSize: 18.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// ✅ Exploration overlay — يتحط جوا Stack مع Positioned
// ════════════════════════════════════════════════════════════════
class SubscriptionPromptOverlay extends StatelessWidget {
  final double? bottomOffset; // ✅ اختياري
  const SubscriptionPromptOverlay({super.key, this.bottomOffset});

  @override
  Widget build(BuildContext context) {
    final bottom = bottomOffset ??8.h;

    return Positioned(
      bottom: bottom,
      left: 24.w,
      right: 24.w,
      child: SubscriptionButton(),
    );
  }
}