import 'package:tayseer/core/enum/add_post_enum.dart';
import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/advisor/profille/data/models/profile_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/core/utils/animation/slide_right_animation.dart';
import 'package:tayseer/features/settings/view/settings_view.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) =>
          previous.profileState != current.profileState ||
          previous.profile != current.profile,
      builder: (context, state) {
        switch (state.profileState) {
          case CubitStates.loading:
            return SliverToBoxAdapter(child: _buildSkeletonHeader(context));
          case CubitStates.failure:
            return SliverToBoxAdapter(
              child: _buildErrorHeader(context, state.profileErrorMessage),
            );
          case CubitStates.success:
            if (state.profile != null) {
              return SliverToBoxAdapter(
                child: _buildProfileHeader(context, state.profile!),
              );
            }
            return _buildEmptyHeader();
          default:
            return _buildEmptyHeader();
        }
      },
    );
  }

  Widget _buildSkeletonHeader(BuildContext context) {
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

  Widget _buildProfileHeader(BuildContext context, ProfileModel profile) {
    return _buildHeaderContent(
      imageUrl: profile.image,
      following: profile.following.toString(),
      followers: profile.followers.toString(),
      isVerified: profile.isVerified,
      context: context,
    );
  }

  Widget _buildErrorHeader(BuildContext context, String? errorMessage) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 40.w),
              GestureDetector(
                onTap: () => _openSettings(context),
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
              ),
            ],
          ),
          Gap(10.h),
          Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
          Gap(10.h),
          Text(
            errorMessage ?? 'حدث خطأ أثناء تحميل البيانات',
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
              'إعادة المحاولة',
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
          // Profile picture
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.kAddPostView,
                arguments: AddPostEnum.story,
              );
            },
            child: Stack(
              children: [
                MyProfileImage(width: 85.w, imageUrl: imageUrl),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      color: AppColors.kprimaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AppImage(
                        width: 12.w,
                        AssetsData.icAdd,
                        color: AppColors.kWhiteColor,
                      ),
                    ),
                  ),
                ),
                if (isVerified)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: AppColors.kWhiteColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.kprimaryColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.verified,
                          color: AppColors.kprimaryColor,
                          size: 14.w,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Top bar with followers/following
          Column(
            children: [
              Text(following, style: Styles.textStyle16SemiBold),
              Text("Following", style: Styles.textStyle14),
            ],
          ),
          Column(
            children: [
              Text(followers, style: Styles.textStyle16SemiBold),
              Text("Followers", style: Styles.textStyle14),
            ],
          ),

          // Settings
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _openSettings(context),
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
              ),
              SizedBox(height: 40.w),
            ],
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildEmptyHeader() {
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      SlideLeftRoute(
        page: const SettingsView(),
        routeSettings: const RouteSettings(name: AppRouter.kSettingsView),
      ),
    );
  }
}
