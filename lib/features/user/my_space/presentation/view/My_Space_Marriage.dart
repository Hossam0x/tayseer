import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_state.dart';
import 'package:tayseer/my_import.dart';

class MySpaceMarriageContent extends StatefulWidget {
  const MySpaceMarriageContent({super.key});

  @override
  State<MySpaceMarriageContent> createState() => _MySpaceMarriageContentState();
}

class _MySpaceMarriageContentState extends State<MySpaceMarriageContent> {
  void _goToMarriageView() async {
    await context.pushNamed(AppRouter.kMarriageView);

    if (!mounted) return;

    // ✅ أظهر الـ navbar بعد الرجوع
    context.read<LayoutCubit>().setNavVisibility(true);

    // ✅ حدّث البيانات عشان يتحقق من dataCompleted
    try {
      context.read<UserProfileCubit>().fetchUserProfile();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    bool isDataCompleted = false;
    try {
      final userState = context.watch<UserProfileCubit>().state;
      if (userState is SettingsLoaded) {
        isDataCompleted = userState.userProfile?.dataCompleted ?? false;
      }
    } catch (_) {}

    if (isDataCompleted) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppImage(AssetsData.guestLockImage, width: 228.w),

                  SizedBox(height: 24.w),

                  Text(
                    context.tr('complete_your_profile'),
                    textAlign: TextAlign.center,
                    style: Styles.textStyle16SemiBold.copyWith(
                      color: AppColors.kTextGrey,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Text(
                    context.tr('complete_your_profile_description'),
                    textAlign: TextAlign.center,
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.kGrey666,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  CustomBotton(
                    radius: 16.r,
                    useGradient: true,
                    title: context.tr('complete_your_profile_bott'),
                    onPressed: _goToMarriageView,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 90.h),
        ],
      ),
    );
  }
}