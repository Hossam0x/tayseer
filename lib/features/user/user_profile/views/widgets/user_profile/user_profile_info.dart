import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/my_import.dart';

class UserProfileInfo extends StatelessWidget {
  final UserProfileModel? userProfile;

  const UserProfileInfo({super.key, this.userProfile});

  @override
  Widget build(BuildContext context) {
    if (userProfile == null) return _UserProfileInfoSkeleton();

    final displayName = kCurrentUserData?.name ?? userProfile!.name;
    final displayUsername = kCurrentUserData?.username ?? userProfile!.username;

    return Column(
      children: [
        Text(
          displayName,
          style: Styles.textStyle24Bold.copyWith(color: AppColors.blueText),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        if (displayUsername.isNotEmpty) ...[
          Gap(4.h),
          Text(
            displayUsername,
            style: Styles.textStyle16.copyWith(color: AppColors.secondary600),
          ),
        ],
        Gap(8.h),
        GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            AppRouter.kUserPublicProfileView,
            arguments: userProfile!.id,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppImage(AssetsData.navigateIcon, width: 12.w),
              Gap(10.w),
              Text(
                context.tr("show_profile"),
                style: Styles.textStyle14.copyWith(
                  color: AppColors.secondary600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserProfileInfoSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 150.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: AppColors.secondary200,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        Gap(4.h),
        Container(
          width: 100.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: AppColors.secondary200,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        Gap(8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 12.w, height: 12.w, color: AppColors.secondary200),
            Gap(10.w),
            Container(
              width: 120.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: AppColors.secondary200,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
