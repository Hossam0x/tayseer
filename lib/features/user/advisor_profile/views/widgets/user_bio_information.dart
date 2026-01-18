import 'package:tayseer/features/user/advisor_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/advisor_profile/views/cubit/user_profile_cubit.dart';
import 'package:tayseer/features/user/advisor_profile/views/cubit/user_profile_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserBioInformation extends StatelessWidget {
  const UserBioInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserProfileCubit, UserProfileState>(
      listenWhen: (previous, current) =>
          previous.followActionState != current.followActionState &&
          current.followActionState != CubitStates.initial,
      listener: _handleFollowState,
      child: BlocBuilder<UserProfileCubit, UserProfileState>(
        buildWhen: (previous, current) =>
            previous.profileState != current.profileState ||
            previous.profile != current.profile,
        builder: (context, state) {
          switch (state.profileState) {
            case CubitStates.loading:
              return SliverToBoxAdapter(child: _buildSkeletonBio(context));
            case CubitStates.failure:
              return SliverToBoxAdapter(
                child: _buildErrorBio(context, state.profileErrorMessage),
              );
            case CubitStates.success:
              if (state.profile != null) {
                return SliverToBoxAdapter(
                  child: _buildBioContent(context, state.profile!),
                );
              }
              return _buildEmptyBio();
            default:
              return _buildEmptyBio();
          }
        },
      ),
    );
  }

  void _handleFollowState(BuildContext context, UserProfileState state) {
    final message = state.followMessage;
    switch (state.followActionState) {
      case CubitStates.success:
        state.isFollowAdded == true
            ? AppToast.success(context, message ?? 'تمت المتابعة بنجاح')
            : AppToast.info(context, message ?? 'تم إلغاء المتابعة');
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? 'حدث خطأ أثناء المتابعة');
        break;
      default:
        break;
    }
  }

  Widget _buildSkeletonBio(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: _buildBioContent(
        context,
        const UserProfileModel(
          name: 'اسم المستخدم',
          image: '',
          username: '@username',
          aboutYou: 'وصف قصير عن المستخدم',
          yearsOfExperience: 0,
          followers: 0,
          following: 0,
          isVerified: false,
          location: '',
          isMe: false,
        ),
      ),
    );
  }

  Widget _buildErrorBio(BuildContext context, String? errorMessage) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.kRedColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.kRedColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: AppColors.kRedColor, size: 32.w),
          Gap(10.h),
          Text(
            errorMessage ?? 'حدث خطأ في تحميل البيانات',
            style: Styles.textStyle14.copyWith(color: AppColors.kRedColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBioContent(BuildContext context, UserProfileModel profile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name with verification badge
          _buildNameSection(profile),

          // Username
          if (profile.username.isNotEmpty)
            Text(
              profile.username,
              style: Styles.textStyle14.copyWith(color: AppColors.hintText),
            ),

          Gap(8.h),

          // Professional info
          _buildProfessionalInfo(profile),

          // Location
          _buildLocation(profile),

          // About you
          _buildAboutYou(profile),

          // Follow Button (only if not my profile)
          if (!profile.isMe) _buildFollowButton(context, profile),
        ],
      ),
    );
  }

  Widget _buildNameSection(UserProfileModel profile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Dr / ${profile.name}",
          style: Styles.textStyle20SemiBold.copyWith(color: AppColors.blueText),
          overflow: TextOverflow.ellipsis,
        ),
        AppImage(AssetsData.expertAdvisor, width: 24.w),
        // if (profile.isVerified)
        //   Padding(
        //     padding: EdgeInsets.only(left: 8.w),
        //     child: Icon(
        //       Icons.verified,
        //       color: AppColors.kprimaryColor,
        //       size: 20.w,
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildProfessionalInfo(UserProfileModel profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "التخصص غير معروف",
          style: Styles.textStyle14.copyWith(color: AppColors.secondary800),
        ),
        Gap(4.h),
        if (profile.yearsOfExperience > 0)
          Text(
            "${profile.yearsOfExperience} سنين من الخبرة",
            style: Styles.textStyle14Meduim.copyWith(
              color: AppColors.secondary800,
            ),
          ),
      ],
    );
  }

  Widget _buildLocation(UserProfileModel profile) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          AppImage(AssetsData.locationIcon, width: 12.w),
          Gap(4.w),
          Expanded(
            child: Text(
              profile.location?.isEmpty ?? true
                  ? 'غير محدد'
                  : profile.location!,
              style: Styles.textStyle14.copyWith(color: AppColors.secondary800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutYou(UserProfileModel profile) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
      child: Text(
        profile.aboutYou.isNotEmpty ? profile.aboutYou : 'لا يوجد وصف للمستخدم',
        style: Styles.textStyle14.copyWith(
          color: AppColors.infoText,
          height: 1.5,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context, UserProfileModel profile) {
    return BlocBuilder<UserProfileCubit, UserProfileState>(
      buildWhen: (previous, current) =>
          previous.profile?.isFollowing != current.profile?.isFollowing ||
          previous.followActionState != current.followActionState,
      builder: (context, state) {
        final isFollowing = state.profile?.isFollowing ?? false;
        final isLoading = state.followActionState == CubitStates.loading;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            children: [
              Expanded(
                child: CustomBotton(
                  height: 54.h,
                  width: double.infinity,
                  title: isFollowing ? 'متابَع' : 'متابعة',
                  onPressed: isLoading
                      ? null
                      : () => context.read<UserProfileCubit>().toggleFollow(),
                  backGroundcolor: isFollowing
                      ? AppColors.kWhiteColor
                      : AppColors.kprimaryColor,
                  titleColor: isFollowing
                      ? AppColors.kprimaryColor
                      : AppColors.kWhiteColor,
                  radius: 10.r,
                  useGradient: isFollowing ? false : true,
                  isLoading: isLoading,
                  elevation: 0,
                ),
              ),
              Gap(13.w),
              Container(
                padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.primary500),
                ),
                child: AppImage(AssetsData.chatIconSVG, width: 22.w),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverToBoxAdapter _buildEmptyBio() {
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
