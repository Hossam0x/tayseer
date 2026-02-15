import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/user/user_advisor_profile/data/models/user_advisor_profile_model.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_cubit.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_state.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/widgets/profile_options_bottom_sheet.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserAdvisorProfileHeader extends StatelessWidget {
  const UserAdvisorProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserAdvisorProfileCubit, UserAdvisorProfileState>(
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
        profileId: '',
      ),
    );
  }

  // في UserAdvisorProfileHeader
  Widget _buildProfileHeader(
    BuildContext context,
    UserAdvisorProfileModel profile,
  ) {
    return _buildHeaderContent(
      imageUrl: profile.image,
      following: profile.following.toString(),
      followers: profile.followers.toString(),
      isVerified: profile.isVerified,
      context: context,
      profileId: profile.id,
      profileName: profile.name,
    );
  }

  Widget _buildHeaderContent({
    required String imageUrl,
    required String following,
    required String followers,
    required bool isVerified,
    required BuildContext context,
    required String profileId,
    String? profileName,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Gap(1.w),
          // Profile picture with Hero animation
          Stack(
            children: [
              MyProfileImage(
                width: 85.w,
                imageUrl: imageUrl,
                heroTag: 'advisor_profile_image_$profileId',
                onTap: imageUrl.isNotEmpty
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageView(
                              imageUrl: imageUrl,
                              heroTag: 'advisor_profile_image_$profileId',
                              userName: profileName,
                            ),
                          ),
                        );
                      }
                    : null,
              ),
            ],
          ),
          Gap(10.w),
          // Stats
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.kFollowingView,
              arguments: profileId, // ⭐ استخدام الـ profileId
            ),
            child: Column(
              children: [
                Text(following, style: Styles.textStyle16SemiBold),
                Text(context.tr("followings"), style: Styles.textStyle14),
              ],
            ),
          ),
          Gap(20.w),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.kFollowersView,
              arguments: profileId, // ⭐ استخدام الـ profileId
            ),
            child: Column(
              children: [
                Text(followers, style: Styles.textStyle16SemiBold),
                Text(context.tr("followers"), style: Styles.textStyle14),
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
            errorMessage ?? context.tr("error_loading_data"),
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
            onPressed: () =>
                context.read<UserAdvisorProfileCubit>().fetchProfile(),
            child: Text(
              context.tr("retry"),
              style: Styles.textStyle14Meduim.copyWith(
                color: AppColors.kWhiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    final cubit = context.read<UserAdvisorProfileCubit>();
    return GestureDetector(
      onTap: () {
        final profileId = cubit.advisorId;
        final name = cubit.state.profile?.name;

        ProfileOptionsBottomSheet.show(
          context,
          advisorId: profileId,
          advisorName: name,
          cubit: cubit,
        );
      },
      child: Icon(Icons.more_vert, color: AppColors.secondary600, size: 28.w),
    );
  }

  SliverToBoxAdapter _buildEmptyHeader() {
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
