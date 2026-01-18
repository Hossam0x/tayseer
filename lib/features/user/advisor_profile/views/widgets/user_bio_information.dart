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
          yearsOfExperience: null,
          followers: 0,
          following: 0,
          isVerified: false,
          location: '',
          isMe: false,
          professionalSpecialization: null,
          jobGrade: null,
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
    // ⭐ استخدام extension methods
    final displaySpecialization = profile.displaySpecialization;
    final displayYearsExperience = profile.displayYearsExperience;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name with verification badge
          _buildNameSection(profile),

          // Username - عرض فقط إذا كان موجوداً
          if (profile.username.isNotEmpty) ...[
            Text(
              profile.username,
              style: Styles.textStyle14.copyWith(color: AppColors.hintText),
            ),
            Gap(8.h),
          ],

          // Professional info - عرض فقط إذا كان هناك بيانات
          _buildProfessionalInfo(displaySpecialization, displayYearsExperience),

          // Location - عرض فقط إذا كان موجوداً
          _buildLocation(profile),

          // About you - عرض فقط إذا كان موجوداً
          _buildAboutYou(profile),

          // ⭐ Follow Button (only if not my profile)
          if (!profile.isMe) _buildFollowSection(context, profile),
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
        if (profile.isVerified)
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: AppImage(AssetsData.expertAdvisor, width: 24.w),
          ),
      ],
    );
  }

  Widget _buildProfessionalInfo(
    String? displaySpecialization,
    String? displayYearsExperience,
  ) {
    final hasSpecialization =
        displaySpecialization != null && displaySpecialization.isNotEmpty;
    final hasYearsExperience =
        displayYearsExperience != null && displayYearsExperience.isNotEmpty;

    // ⭐ إذا لم يكن هناك بيانات، لا تعرض أي شيء
    if (!hasSpecialization && !hasYearsExperience) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ⭐ عرض التخصص إذا كان موجوداً
        if (hasSpecialization)
          Text(
            displaySpecialization,
            style: Styles.textStyle14.copyWith(
              color: AppColors.secondary800,
              fontWeight: FontWeight.w600,
            ),
          ),

        // ⭐ المسافة بين التخصص وسنوات الخبرة
        if (hasSpecialization && hasYearsExperience) Gap(4.h),

        // ⭐ عرض سنوات الخبرة إذا كانت موجودة
        if (hasYearsExperience)
          Text(
            '$displayYearsExperience من الخبرة',
            style: Styles.textStyle14Meduim.copyWith(
              color: AppColors.secondary800,
            ),
          ),

        Gap(8.h),
      ],
    );
  }

  Widget _buildLocation(UserProfileModel profile) {
    final hasLocation =
        profile.location != null && profile.location!.isNotEmpty;

    if (!hasLocation) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          AppImage(AssetsData.locationIcon, width: 12.w),
          Gap(4.w),
          Expanded(
            child: Text(
              profile.location!,
              style: Styles.textStyle14.copyWith(color: AppColors.secondary800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutYou(UserProfileModel profile) {
    final hasAboutYou = profile.aboutYou.isNotEmpty;

    if (!hasAboutYou) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profile.aboutYou,
            style: Styles.textStyle14.copyWith(
              color: AppColors.infoText,
              height: 1.5,
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  // ⭐ تحديث قسم المتابعة والرسائل
  Widget _buildFollowSection(BuildContext context, UserProfileModel profile) {
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
              // زر المتابعة
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

              // زر المحادثة (يظهر فقط إذا كان المستخدم يتابع أو كان صديقاً)
              if (isFollowing) // ⭐ يظهر فقط إذا كان يتابع
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 13.h,
                    horizontal: 16.w,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary100,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.primary500),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      // TODO: افتح شات مع المستخدم
                    },
                    child: AppImage(AssetsData.chatIconSVG, width: 22.w),
                  ),
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
