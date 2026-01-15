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
          yearsOfExperience: 0,
          followers: 0,
          following: 0,
          isVerified: false,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name with verification badge
          _buildNameSection(profile),

          // Username
          Text(
            profile.username,
            style: Styles.textStyle14.copyWith(color: AppColors.hintText),
          ),

          Gap(8.h),

          // Professional info
          _buildProfessionalInfo(profile),

          // Location
          _buildLocation(),

          // About you
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
        if (profile.isVerified)
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: Icon(
              Icons.verified,
              color: AppColors.kprimaryColor,
              size: 20.w,
            ),
          ),
      ],
    );
  }

  Widget _buildProfessionalInfo(ProfileModel profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "استشاري نفسي وعلاقات زوجية",
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

  Widget _buildLocation() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          AppImage(AssetsData.locationIcon, width: 12.w),
          Gap(4.w),
          Expanded(
            child: Text(
              'مصر, دمياط الجديدة',
              style: Styles.textStyle14.copyWith(color: AppColors.secondary800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutYou(ProfileModel profile) {
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
