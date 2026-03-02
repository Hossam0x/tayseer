import 'package:tayseer/my_import.dart';

class SubscriptionPromptOverlay extends StatelessWidget {
  const SubscriptionPromptOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: false,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.white.withOpacity(0.98),
                Colors.white.withOpacity(0.0),
              ],
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40.h),
                _interactionSubscriptionButton(
                  context.tr("subscribe_to_see_likes"),
                  context,
                  onPressed: () {
                    context.pushNamed(AppRouter.kinteractionSubscriptionView);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _interactionSubscriptionButton(
    String label,
    BuildContext context, {
    required void Function()? onPressed,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
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
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(AssetsData.diamondIcon, width: 24.w, height: 24.h),
            SizedBox(width: 20.w),
            Text(
              label,
              style: Styles.textStyle20SemiBold.copyWith(
                fontSize: 20.sp,
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