import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/shared/followers/user_followings_view.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_profile_options_bottom_sheet.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserPublicProfileHeader extends StatelessWidget {
  const UserPublicProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserPublicProfileCubit, UserPublicProfileState>(
      buildWhen: (previous, current) =>
          previous.state != current.state || // ⭐ مراقبة state العامة
          previous.profile != current.profile,
      builder: (context, state) {
        // ⭐ التحقق من الحالة العامة أولاً
        if (state.state == CubitStates.loading) {
          return SliverToBoxAdapter(child: _buildSkeletonHeader(context));
        }

        if (state.state == CubitStates.failure) {
          return SliverToBoxAdapter(
            child: _buildErrorHeader(context, state.profileErrorMessage),
          );
        }

        if (state.profile != null) {
          return SliverToBoxAdapter(
            child: _buildProfileHeader(context, state.profile!),
          );
        }

        return _buildEmptyHeader();
      },
    );
  }

  Widget _buildSkeletonHeader(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: _buildHeaderContent(
        imageUrl: '',
        following: '0',
        context: context,
        profile: const UserProfileModel(
          id: '',
          name: 'اسم المستخدم',
          username: '@username',
          description: 'وصف المستخدم',
          image: '',
          following: 0,
          isMe: false,
          age: 0,
          gender: 'ذكر',
          isAnonymous: false,
          availableForMarry: false,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfileModel profile) {
    return _buildHeaderContent(
      imageUrl: profile.image ?? '',
      following: profile.following.toString(),
      context: context,
      profile: profile,
      imageBlur: profile.imageBlur ?? false,
    );
  }

  Widget _buildErrorHeader(BuildContext context, String? errorMessage) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.secondary600,
              size: 20.sp,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          CustomErrorView(
            message: errorMessage,
            onRetry: () =>
                context.read<UserPublicProfileCubit>().fetchProfile(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent({
    required String imageUrl,
    required String following,
    required BuildContext context,
    required UserProfileModel profile,
    bool imageBlur = false,
  }) {
    final isBlocked = context.select<UserPublicProfileCubit, bool>(
      (cubit) => cubit.state.profile?.isBlockedByMe ?? false,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(12.w),
              constraints: const BoxConstraints(),
              child: Icon(
                Icons.arrow_back_ios,
                color: AppColors.secondary600,
                size: 20.sp,
              ),
            ),
          ),
          // الصورة الشخصية
          SizedBox(
            width: 90.w,
            height: 90.w,
            child: Stack(
              children: [
                MyProfileImage(
                  width: 90.w,
                  imageUrl: imageUrl,
                  isBlur: imageBlur,
                  heroTag: 'profile_image_${profile.id}',
                  onTap: imageUrl.isNotEmpty && !isBlocked && !imageBlur
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImageView(
                                imageUrl: imageUrl,
                                heroTag: 'profile_image_${profile.id}',
                                userName: profile.name,
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
          Gap(55.w),

          // الإحصائيات
          _buildStatsItem(
            value: following,
            label: context.tr("followed"),
            onTap: () {},
            userId: profile.id,
            context: context,
          ),
          Spacer(),
          if (!profile.isMe)
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

  Widget _buildStatsItem({
    required String value,
    required String label,
    required VoidCallback onTap,
    required BuildContext context,
    required String userId,
  }) {
    final isBlocked = context.select<UserPublicProfileCubit, bool>(
      (cubit) => cubit.state.profile?.isBlockedByMe ?? false,
    );

    return GestureDetector(
      onTap: isBlocked
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserFollowingsView(userId: userId),
              ),
            ),
      child: Column(
        children: [
          Text(value, style: Styles.textStyle16SemiBold),
          Text(label, style: Styles.textStyle14),
        ],
      ),
    );
  }

  // في user_public_profile_header.dart
  Widget _buildMoreButton(BuildContext context) {
    return CustomClick(
      onTap: () {
        final cubit = context.read<UserPublicProfileCubit>();
        final profile = cubit.state.profile;
        final profileId = cubit.userId ?? profile?.id ?? '';
        final name = profile?.name;

        UserProfileOptionsBottomSheet.show(
          context,
          userId: profileId,
          userName: name,
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
