import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/advisor/profille/data/models/profile_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/core/utils/animation/slide_right_animation.dart';
import 'package:tayseer/features/advisor/settings/view/settings_view.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/add_story_view.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/story_details_view.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/core/widgets/full_screen_image_view.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) {
        // ✅ تجنّب الـ rebuild إذا كانت بيانات العرض لم تتغير حتى لو تغيّر الـ state
        if (previous.profileState != current.profileState) return true;
        if (previous.profile == null && current.profile != null) return true;
        if (previous.profile != null && current.profile == null) return true;

        // كلاهما موجودين → اقارن فقط الحقول المهمة للـ UI
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
          // ── Profile picture with Stories ring ──────────────────────────────
          _ProfileStoryRing(fallbackImageUrl: imageUrl),

          // Top bar with followers/following
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
    final result = await Navigator.push(
      context,
      SlideLeftRoute(
        page: const SettingsView(),
        routeSettings: const RouteSettings(name: AppRouter.kSettingsView),
      ),
    );

    // ⭐ تحديث البروفايل فقط إذا تم تغيير البيانات
    if (context.mounted && result == true) {
      // تم الاعتماد على الـ EventBus للمزامنة الفورية
      // لكن بنطلب تحديث صامت من الـ API لضمان بقية البيانات (مثل عدد المتابعين إلخ)
      context.read<ProfileCubit>().fetchProfile();
    }
  }

  void _openFollowing(BuildContext context) async {
    await Navigator.pushNamed(context, AppRouter.kFollowingView);
    // No need to reload data when returning from following list
  }

  void _openFollowers(BuildContext context) async {
    await Navigator.pushNamed(context, AppRouter.kFollowersView);
    // No need to reload - followers count rarely changes
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Story Ring — shows the my-stories ring in the profile header.
// Reads from StoriesCubit.state.myStories (the /stories/my-stories endpoint).
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileStoryRing extends StatelessWidget {
  final String fallbackImageUrl;

  const _ProfileStoryRing({required this.fallbackImageUrl});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoriesCubit, StoriesState>(
      buildWhen: (previous, current) =>
          previous.createStoryState != current.createStoryState ||
          previous.uploadProgress != current.uploadProgress ||
          previous.myStories != current.myStories ||
          previous.myStoriesState != current.myStoriesState,
      builder: (context, storyState) {
        final isUploading = storyState.createStoryState == CubitStates.loading;
        final myStories = storyState.myStories;
        final hasStories = myStories != null && myStories.stories.isNotEmpty;

        return CustomClick(
          onTap: isUploading
              ? null
              : () => _handleTap(context, storyState, myStories),
          onLongPress: () => _openFullScreenImage(context, fallbackImageUrl),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Upload Progress Ring ──────────────────────────────────────
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

              // ── Story ring decoration ─────────────────────────────────────
              if (hasStories && !isUploading)
                Container(
                  width: 95.w,
                  height: 95.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: myStories.allViewed
                          ? AppColors.kGreyB3
                          : AppColors.kprimaryColor,
                      width: 3.sp,
                    ),
                  ),
                ),

              // ── Profile image ─────────────────────────────────────────────
              Padding(
                padding: hasStories && !isUploading
                    ? EdgeInsets.all(4.r)
                    : EdgeInsets.zero,
                child: Hero(
                  tag: 'profile_image_main',
                  child: MyProfileImage(
                    width: hasStories && !isUploading ? 79.w : 85.w,
                    imageUrl: fallbackImageUrl,
                  ),
                ),
              ),

              // ── Add story button (hidden while uploading) ─────────────────
              if (!isUploading)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: CustomClick(
                    onTap: () => _openAddStory(context),
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
                ),

              // ── Upload percentage overlay ─────────────────────────────────
              if (isUploading)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
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
    );
  }

  void _handleTap(
    BuildContext context,
    StoriesState storyState,
    UserStoriesModel? myStories,
  ) {
    if (myStories != null && myStories.stories.isNotEmpty) {
      _openMyStories(context, myStories);
    } else {
      _openAddStory(context);
    }
  }

  void _openMyStories(BuildContext context, UserStoriesModel myStories) async {
    final storiesCubit = context.read<StoriesCubit>();

    // Open my story fast without blocking the transition.
    // We still request a quiet refetch in the background.
    storiesCubit.fetchMyStories(isSilent: true);

    final latestMyStories = storiesCubit.state.myStories ?? myStories;

    // Show stories in chronological order (oldest first)
    final chronological = latestMyStories.copyWith(
      stories: latestMyStories.stories.reversed.toList(),
    );

    if (context.mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (newContext, animation, secondaryAnimation) =>
              BlocProvider.value(
                value: storiesCubit,
                child: StoryDetailsView(
                  usersStories: [chronological],
                  initialUserIndex: 0,
                ),
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ).then((_) {
        // Re-fetch after the viewer closes
        if (context.mounted) {
          context.read<StoriesCubit>().fetchMyStories(isSilent: true);
        }
      });
    }
  }

  void _openAddStory(BuildContext context) {
    if (!context.mounted) return;
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

  void _openFullScreenImage(BuildContext context, String imageUrl) {
    if (imageUrl.isEmpty) return;
    FullScreenImageView.show(
      context,
      imageUrl: imageUrl,
      heroTag: 'profile_image_main',
    );
  }
}
