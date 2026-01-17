import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/user/advisor_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/advisor_profile/views/cubit/user_profile_cubit.dart';
import 'package:tayseer/features/user/advisor_profile/views/cubit/user_profile_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileCubit, UserProfileState>(
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

  Widget _buildProfileHeader(BuildContext context, UserProfileModel profile) {
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
              _buildMoreButton(context),
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
            onPressed: () => context.read<UserProfileCubit>().fetchProfile(),
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
          Gap(1.w),
          // Profile picture
          Stack(
            children: [
              MyProfileImage(width: 85.w, imageUrl: imageUrl),
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
          Gap(10.w),
          // Stats
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRouter.kFollowingView),
            child: Column(
              children: [
                Text(following, style: Styles.textStyle16SemiBold),
                Text("Following", style: Styles.textStyle14),
              ],
            ),
          ),
          Gap(20.w),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRouter.kFollowersView),
            child: Column(
              children: [
                Text(followers, style: Styles.textStyle16SemiBold),
                Text("Followers", style: Styles.textStyle14),
              ],
            ),
          ),
          Gap(10.w),

          // More button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMoreButton(context),
              SizedBox(height: 40.w),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMoreOptions(context),
      child: Icon(Icons.more_vert, color: AppColors.secondary600, size: 28.w),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.share, color: AppColors.kprimaryColor),
              title: Text('مشاركة البروفايل', style: Styles.textStyle16),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: AppColors.kRedColor),
              title: Text('حظر المستخدم', style: Styles.textStyle16),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement block functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.report, color: AppColors.kRedColor),
              title: Text('الإبلاغ', style: Styles.textStyle16),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement report functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildEmptyHeader() {
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
