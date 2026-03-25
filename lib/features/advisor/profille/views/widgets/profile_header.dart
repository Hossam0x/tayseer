import 'package:tayseer/features/advisor/profille/data/models/profile_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/core/utils/animation/slide_right_animation.dart';
import 'package:tayseer/features/advisor/settings/view/settings_view.dart';
import 'stories/profile_story_ring.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) {
        if (previous.profileState != current.profileState) return true;
        if (previous.profile == null && current.profile != null) return true;
        if (previous.profile != null && current.profile == null) return true;
        if (previous.profile != null && current.profile != null) {
          return previous.profile!.image != current.profile!.image ||
              previous.profile!.followers != current.profile!.followers ||
              previous.profile!.following != current.profile!.following ||
              previous.profile!.isVerified != current.profile!.isVerified;
        }
        return false;
      },
      builder: (context, state) {
        switch (state.profileState) {
          case CubitStates.loading:
            return SliverToBoxAdapter(child: _buildSkeleton(context));
          case CubitStates.failure:
            return SliverToBoxAdapter(
              child: _buildError(context, state.profileErrorMessage),
            );
          case CubitStates.success:
            if (state.profile != null) {
              return SliverToBoxAdapter(
                child: _buildContent(context, state.profile!),
              );
            }
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          default:
            return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
      },
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: _buildHeaderContent(
        imageUrl: '',
        following: '0',
        followers: '0',
        isVerified: false,
        context: context,
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProfileModel profile) {
    return _buildHeaderContent(
      imageUrl: profile.image,
      following: profile.following.toString(),
      followers: profile.followers.toString(),
      isVerified: profile.isVerified,
      context: context,
    );
  }

  Widget _buildError(BuildContext context, String? errorMessage) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 40.w),
              _SettingsButton(onTap: () => _openSettings(context)),
            ],
          ),
          Gap(10.h),
          Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
          Gap(10.h),
          Text(
            errorMessage ?? context.tr('error_loading_data'),
            style: Styles.textStyle14.copyWith(color: AppColors.kRedColor),
            textAlign: TextAlign.center,
          ),
          Gap(10.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kprimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () => context.read<ProfileCubit>().fetchProfile(),
            child: Text(
              context.tr('retry'),
              style: Styles.textStyle14Meduim.copyWith(
                color: AppColors.kWhiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent({
    required String imageUrl,
    required String following,
    required String followers,
    required bool isVerified,
    required BuildContext context,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ProfileStoryRing(fallbackImageUrl: imageUrl),
          GestureDetector(
            onTap: () => _openFollowing(context),
            child: Column(
              children: [
                Text(following, style: Styles.textStyle16SemiBold),
                Text(context.tr('followings'), style: Styles.textStyle14),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _openFollowers(context),
            child: Column(
              children: [
                Text(followers, style: Styles.textStyle16SemiBold),
                Text(context.tr('followers'), style: Styles.textStyle14),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SettingsButton(onTap: () => _openSettings(context)),
              SizedBox(height: 40.w),
            ],
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context) async {
    final result = await Navigator.push(
      context,
      SlideLeftRoute(
        page: const SettingsView(),
        routeSettings: const RouteSettings(name: AppRouter.kSettingsView),
      ),
    );
    if (context.mounted && result == true) {
      context.read<ProfileCubit>().fetchProfile();
    }
  }

  void _openFollowing(BuildContext context) =>
      Navigator.pushNamed(context, AppRouter.kFollowingView);

  void _openFollowers(BuildContext context) =>
      Navigator.pushNamed(context, AppRouter.kFollowersView);
}

class _SettingsButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SettingsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(9.w),
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          color: AppColors.primary100,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 2.0),
          child: AppImage(AssetsData.settingsIcon),
        ),
      ),
    );
  }
}
