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
      buildWhen: (previous, current) {
        if (previous.profileState != current.profileState) return true;
        if (previous.profile == null && current.profile != null) return true;
        if (previous.profile != null && current.profile == null) return true;

        if (previous.profile != null && current.profile != null) {
          final oldImage = previous.profile!.image.split('?').first;
          final newImage = current.profile!.image.split('?').first;
          return oldImage != newImage ||
              previous.profile!.followers != current.profile!.followers ||
              previous.profile!.following != current.profile!.following ||
              previous.profile!.verificationType !=
                  current.profile!.verificationType ||
              previous.profile!.room?.isBlocked !=
                  current.profile!.room?.isBlocked;
        }
        return false;
      },
      builder: (context, state) {
        switch (state.profileState) {
          case CubitStates.loading:
            return SliverToBoxAdapter(child: _buildSkeletonHeader(context));
          case CubitStates.failure:
            return SliverToBoxAdapter(
              child: CustomErrorView(
                onRetry: () =>
                    context.read<UserAdvisorProfileCubit>().fetchProfile(),
              ),
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
      context: context,
      profileId: profile.id,
      profileName: profile.name,
      imageBlur: profile.imageBlur ?? false,
    );
  }

  Widget _buildHeaderContent({
    required String imageUrl,
    required String following,
    required String followers,
    required BuildContext context,
    required String profileId,
    String? profileName,
    bool imageBlur = false,
  }) {
    final isBlocked = context.select<UserAdvisorProfileCubit, bool>(
      (cubit) => cubit.state.profile?.room?.isBlocked ?? false,
    );

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 12.w,
        end: 12.w,
        top: 12.h,
        bottom: 12.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.secondary600,
                    size: 20.sp,
                  ),
                ),
              ),
              // Profile picture with Hero animation
              Stack(
                children: [
                  MyProfileImage(
                    width: 85.w,
                    imageUrl: imageUrl,
                    isBlur: imageBlur,
                    heroTag: 'advisor_profile_image_$profileId',
                    onTap: imageUrl.isNotEmpty && !isBlocked && !imageBlur
                        ? () => FullScreenImageView.show(
                            context,
                            imageUrl: imageUrl,
                            heroTag: 'advisor_profile_image_$profileId',
                            userName: profileName,
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
          Gap(20.w),
          // Stats
          CustomClick(
            onTap: isBlocked
                ? null
                : () => Navigator.pushNamed(
                    context,
                    AppRouter.kFollowingView,
                    arguments: profileId,
                  ),
            child: Column(
              children: [
                Text(following, style: Styles.textStyle16SemiBold),
                Text(context.tr("followings"), style: Styles.textStyle14),
              ],
            ),
          ),
          Gap(40.w),
          CustomClick(
            onTap: isBlocked
                ? null
                : () => Navigator.pushNamed(
                    context,
                    AppRouter.kFollowersView,
                    arguments: profileId,
                  ),
            child: Column(
              children: [
                Text(followers, style: Styles.textStyle16SemiBold),
                Text(context.tr("followers"), style: Styles.textStyle14),
              ],
            ),
          ),
          Gap(40.w),

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
    final cubit = context.read<UserAdvisorProfileCubit>();
    return CustomClick(
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
