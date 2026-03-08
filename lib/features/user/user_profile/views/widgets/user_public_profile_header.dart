import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/shared/followers/user_followings_view.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_state.dart';
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
    );
  }

  Widget _buildErrorHeader(BuildContext context, String? errorMessage) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Gap(40.h),
          Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
          Gap(10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0.w),
            child: Text(
              errorMessage ?? context.tr("error_loading_data"),
              style: Styles.textStyle14.copyWith(color: AppColors.kRedColor),
              textAlign: TextAlign.center,
            ),
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
                context.read<UserPublicProfileCubit>().fetchProfile(),
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

  Widget _buildHeaderContent({
    required String imageUrl,
    required String following,
    required BuildContext context,
    required UserProfileModel profile,
  }) {
    final isBlocked = context.select<UserPublicProfileCubit, bool>(
      (cubit) => cubit.state.profile?.isBlockedByMe ?? false,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Row(
        children: [
          Gap(20.w),
          // الصورة الشخصية
          SizedBox(
            width: 90.w,
            height: 90.w,
            child: Stack(
              children: [
                MyProfileImage(
                  width: 90.w,
                  imageUrl: imageUrl,
                  heroTag: 'profile_image_${profile.id}',
                  onTap: imageUrl.isNotEmpty && !isBlocked
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
    return GestureDetector(
      onTap: () {
        if (isGuest) {
          CustomshowDialogWithImage(
            context,
            title: context.tr('joinUs'),
            supTitle: context.tr("guest_login_first"),
            icon: Icons.lock_person_outlined,
            iconColor: AppColors.kprimaryColor,
            bottonText: context.tr("login"),
            showCancelButton: true,
            cancelText: context.tr('skip'),
            onPressed: () {
              CachNetwork.removeData(key: ktoken);
              context.pushNamedAndRemoveUntil(
                AppRouter.kRegisrationView,
                predicate: (_) => false,
              );
            },
            onCancel: () {},
          );
          return;
        }

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
