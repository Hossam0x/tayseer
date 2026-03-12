import 'package:tayseer/core/widgets/account_review_content.dart';
import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/advisor/profille/data/models/profile_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/core/utils/animation/slide_right_animation.dart';
import 'package:tayseer/features/advisor/settings/view/settings_view.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/add_story_view.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';

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
          // Profile picture with Upload Indicator
          BlocBuilder<StoriesCubit, StoriesState>(
            buildWhen: (previous, current) =>
                previous.createStoryState != current.createStoryState ||
                previous.uploadProgress != current.uploadProgress,
            builder: (context, storyState) {
              final isUploading =
                  storyState.createStoryState == CubitStates.loading;

              return CustomClick(
                onTap: isUploading
                    ? null
                    : () async {
                        if (context.mounted) {
                          // ⭐ فحص isApproved قبل فتح صفحة إضافة story
                          final profileState = context
                              .read<ProfileCubit>()
                              .state;
                          final isApproved =
                              profileState.profile?.isApproved ?? true;

                          if (!isApproved) {
                            // عرض الـ dialog
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (dialogContext) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: const AccountReviewContent(
                                  isDialog: true,
                                  showButton: true,
                                ),
                              ),
                            );
                            return;
                          }

                          final storiesCubit = context.read<StoriesCubit>();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider.value(
                                value: storiesCubit,
                                child: const AddStoryView(),
                              ),
                            ),
                          );
                        }
                      },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Upload Progress Ring
                    if (isUploading)
                      SizedBox(
                        width: 92.w,
                        height: 92.w,
                        child: CircularProgressIndicator(
                          value: storyState.uploadProgress > 0
                              ? storyState.uploadProgress
                              : null,
                          strokeWidth: 4,
                          color: AppColors.kprimaryColor,
                          backgroundColor: AppColors.secondary200,
                        ),
                      ),

                    MyProfileImage(width: 85.w, imageUrl: imageUrl),

                    // Add Icon (Hidden when uploading)
                    if (!isUploading)
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

                    // Percentage Text Overlay
                    if (isUploading)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '${(storyState.uploadProgress * 100).toInt()}%',
                          style: Styles.textStyle12.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          // Top bar with followers/following
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRouter.kFollowingView),
            child: Column(
              children: [
                Text(following, style: Styles.textStyle16SemiBold),
                Text(context.tr('followings'), style: Styles.textStyle14),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRouter.kFollowersView),
            child: Column(
              children: [
                Text(followers, style: Styles.textStyle16SemiBold),
                Text(context.tr('followers'), style: Styles.textStyle14),
              ],
            ),
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

  void _openSettings(BuildContext context) async {
    // ⭐ انتظار الرجوع من صفحة الإعدادات
    await Navigator.push(
      context,
      SlideLeftRoute(
        page: const SettingsView(),
        routeSettings: const RouteSettings(name: AppRouter.kSettingsView),
      ),
    );

    // ⭐ تحديث البروفايل بعد الرجوع من الإعدادات
    if (context.mounted) {
      context.read<ProfileCubit>().fetchProfile();
      // تحديث بيانات الهوم من الكاش أيضاً لضمان التزامن
      getIt<HomeCubit>().refreshUserInfoFromCache();
    }
  }
}
