import 'package:flutter/cupertino.dart';
import 'package:tayseer/features/advisor/profille/data/models/profile_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BioInformation extends StatelessWidget {
  const BioInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
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
    );
  }

  Widget _buildSkeletonBio(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: _buildBioContent(
        context,
        const ProfileModel(
          name: 'اسم المستخدم',
          image: '',
          username: '@username',
          aboutYou: 'وصف قصير عن المستخدم',
          yearsOfExperience: 'سنتين',
          followers: 0,
          following: 0,
          isVerified: false,
          location: '',
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

  Widget _buildBioContent(BuildContext context, ProfileModel profile) {
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

          // Consultation packages
          _buildConsultationCard(context),
        ],
      ),
    );
  }

  Widget _buildNameSection(ProfileModel profile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            "Dr / ${profile.name}",
            style: Styles.textStyle20SemiBold.copyWith(
              color: AppColors.blueText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
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

  Widget _buildLocation(ProfileModel profile) {
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

  Widget _buildAboutYou(ProfileModel profile) {
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

  Widget _buildConsultationCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRouter.kProfessionalInfoDashboardView);
      },
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.cBackground100,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.primary300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "لوحة المعلومات الاحترافية",
              style: Styles.textStyle16SemiBold.copyWith(
                color: AppColors.blackColor,
              ),
            ),
            Gap(12.h),
            Row(
              children: [
                Icon(
                  CupertinoIcons.arrow_up_left,
                  color: AppColors.secondary700,
                  size: 24.w,
                ),
                Gap(8.w),
                Text(
                  "1350 ألف مشاهدة خلال 30 يوم.",
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.secondary700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildEmptyBio() {
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
