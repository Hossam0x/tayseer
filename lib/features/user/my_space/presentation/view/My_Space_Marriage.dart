import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_state.dart';
import 'package:tayseer/features/user/my_space/users_chat/presentation/view/user_chat_content.dart';
import 'package:tayseer/my_import.dart';

class MySpaceMarriageContent extends StatelessWidget {
  const MySpaceMarriageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserProfileCubit>().state;

    // ✅ لو لسه بيتحمل، اعرض shimmer بدل ما تعرض incomplete profile
    if (userState is SettingsInitial || userState is SettingsLoading) {
      return const _LoadingShimmer();
    }

    bool isDataCompleted = false;
    if (userState is SettingsLoaded) {
      isDataCompleted = userState.userProfile?.dataCompleted ?? false;
    }

    if (!isDataCompleted) {
      return _buildIncompleteProfile(context);
    }

    return const _MarriageWithSystemChat();
  }

  Widget _buildIncompleteProfile(BuildContext context) {
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
                  AppImage(AssetsData.lockIcon, width: 228.w),
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

/// Widget يجمع الـ system chat (من MySpaceCubit) مع الـ user chats (من UserChatContent)
/// في الـ Marriage tab
class _MarriageWithSystemChat extends StatelessWidget {
  const _MarriageWithSystemChat();

  @override
  Widget build(BuildContext context) {
    // ✅ UserChatContent تقرأ الـ system rooms بنفسها من MySpaceCubit
    // بدل ما تتمرر كـ parameter — عشان منعمل dispose/recreate للـ cubit
    return const UserChatContent(readSystemRoomsFromContext: true);
  }
}

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          margin: EdgeInsets.only(bottom: 12.h),
          height: 80.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}
