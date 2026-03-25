import 'package:flutter/cupertino.dart';
import 'package:tayseer/features/advisor/profille/data/models/profile_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_state.dart';
import 'package:tayseer/my_import.dart';

/// Name + verification badge
class BioNameSection extends StatelessWidget {
  final ProfileModel profile;
  const BioNameSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            profile.name,
            style: Styles.textStyle20SemiBold.copyWith(
              color: AppColors.blueText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (profile.isVerified) ...[
          Gap(8.w),
          Icon(Icons.verified, color: Colors.blue, size: 20.w),
        ],
      ],
    );
  }
}

/// Specialization + years of experience
class BioProfessionalInfo extends StatelessWidget {
  final String? displaySpecialization;
  final String? displayYearsExperience;
  const BioProfessionalInfo({
    super.key,
    this.displaySpecialization,
    this.displayYearsExperience,
  });

  @override
  Widget build(BuildContext context) {
    final hasSpec =
        displaySpecialization != null && displaySpecialization!.isNotEmpty;
    final hasExp =
        displayYearsExperience != null && displayYearsExperience!.isNotEmpty;

    if (!hasSpec && !hasExp) return const SizedBox.shrink();

    String specText = '';
    if (hasSpec) {
      specText = context.tr(displaySpecialization!);
      if (!context.isArabicLang) {
        specText = specText
            .split(' ')
            .map(
              (w) =>
                  w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
            )
            .join(' ');
      }
    }

    String expText = '';
    if (hasExp) {
      expText = context.tr(displayYearsExperience!);
      expText = context.isArabicLang
          ? '${expText.replaceAll('-', 'الي')} ${context.tr('years_experience')}'
          : '${expText.replaceAll('-', 'to')} ${context.tr('years_experience')}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasSpec)
          Text(
            specText,
            style: Styles.textStyle14.copyWith(
              color: AppColors.secondary800,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (hasSpec && hasExp) Gap(4.h),
        if (hasExp)
          Text(
            expText,
            style: Styles.textStyle14Meduim.copyWith(
              color: AppColors.secondary800,
            ),
          ),
        Gap(8.h),
      ],
    );
  }
}

/// Location row
class BioLocationSection extends StatelessWidget {
  final ProfileModel profile;
  const BioLocationSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    if (profile.location == null || profile.location!.isEmpty)
      return const SizedBox.shrink();

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
}

/// About you text
class BioAboutSection extends StatelessWidget {
  final ProfileModel profile;
  const BioAboutSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    if (profile.aboutYou.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
      child: Text(
        profile.aboutYou,
        style: Styles.textStyle14.copyWith(
          color: AppColors.infoText,
          height: 1.5,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}

/// Consultation dashboard card (approved advisors only)
class BioConsultationCard extends StatelessWidget {
  const BioConsultationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (prev, curr) =>
          prev.analyticsState != curr.analyticsState ||
          prev.analytics != curr.analytics,
      builder: (context, state) {
        final isLoading = state.analyticsState == CubitStates.loading;
        final totalViews = state.analytics?.overview.views ?? 0;

        return CustomClick(
          onTap: () => Navigator.pushNamed(
            context,
            AppRouter.kProfessionalInfoDashboardView,
          ),
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
                  context.tr('professional_info_dashboard'),
                  style: Styles.textStyle16SemiBold.copyWith(
                    color: AppColors.blackColor,
                  ),
                ),
                Gap(12.h),
                Row(
                  children: [
                    Icon(
                      isArabic
                          ? CupertinoIcons.arrow_up_left
                          : CupertinoIcons.arrow_up_right,
                      color: AppColors.secondary700,
                      size: 24.w,
                    ),
                    Gap(8.w),
                    Expanded(
                      child: isLoading
                          ? _LoadingViewsShimmer()
                          : Text(
                              '$totalViews ${context.tr('views_last_30_days')}',
                              style: Styles.textStyle14.copyWith(
                                color: AppColors.secondary700,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoadingViewsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16.h,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: 120.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }
}
