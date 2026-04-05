import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_state.dart';
import 'package:tayseer/my_import.dart';

class MySpaceMarriageContent extends StatelessWidget {
  const MySpaceMarriageContent({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ نقرأ من الـ cubit لو موجود
    bool isDataCompleted = false;
    try {
      final userState = context.watch<UserProfileCubit>().state;
      if (userState is SettingsLoaded) {
        isDataCompleted = userState.userProfile?.dataCompleted ?? false;
      }
    } catch (_) {}

    // ✅ لو البيانات مكتملة، ما نعرضش شاشة الاستكمال
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

                  // ✅ روح لصفحة الزواج عشان يستكمل بياناته
                  CustomBotton(
                    radius: 16.r,
                    useGradient: true,
                    title: context.tr('complete_your_profile_bott'),
                    onPressed: () async {
                      context.read<LayoutCubit>().changeIndex(1);
                    },
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
