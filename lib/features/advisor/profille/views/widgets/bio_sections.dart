import 'package:flutter/cupertino.dart';
import 'package:tayseer/features/advisor/profille/data/models/profile_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_state.dart';
import 'package:tayseer/features/shared/profile/widgets/bio_sections.dart';
import 'package:tayseer/my_import.dart';

// Re-export shared widgets under the original names for backward compatibility.
typedef BioNameSection = _BioNameSectionWrapper;
typedef BioProfessionalInfo = SharedBioProfessionalInfo;
typedef BioLocationSection = _BioLocationSectionWrapper;
typedef BioAboutSection = _BioAboutSectionWrapper;

/// Thin wrapper so existing callers can pass a [ProfileModel] directly.
class _BioNameSectionWrapper extends StatelessWidget {
  final ProfileModel profile;
  const _BioNameSectionWrapper({required this.profile});

  @override
  Widget build(BuildContext context) => SharedBioNameSection(
    name: profile.name,
    verificationType: profile.verificationType,
  );
}

class _BioLocationSectionWrapper extends StatelessWidget {
  final ProfileModel profile;
  const _BioLocationSectionWrapper({required this.profile});

  @override
  Widget build(BuildContext context) =>
      SharedBioLocationSection(location: profile.location);
}

class _BioAboutSectionWrapper extends StatelessWidget {
  final ProfileModel profile;
  const _BioAboutSectionWrapper({required this.profile});

  @override
  Widget build(BuildContext context) =>
      SharedBioAboutSection(aboutYou: profile.aboutYou);
}

/// Consultation dashboard card (approved advisors only).
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
        final subscriptionType = state.analytics?.subscriptionType ?? 'free';
        final isFree = subscriptionType == 'free';

        return CustomClick(
          onTap: () {
            if (isFree) {
              Navigator.pushNamed(context, AppRouter.kSubscriptionRequiredView);
            } else {
              Navigator.pushNamed(
                context,
                AppRouter.kProfessionalInfoDashboardView,
              );
            }
          },
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
                              isFree
                                  ? context.tr('subscribe_to_view_stats')
                                  : '$totalViews ${context.tr('views_last_30_days')}',
                              style: Styles.textStyle14.copyWith(
                                color: isFree
                                    ? AppColors.kprimaryColor
                                    : AppColors.secondary700,
                              ),
                            ),
                    ),
                    if (isFree)
                      Icon(
                        Icons.lock_outline,
                        color: AppColors.kprimaryColor,
                        size: 18.w,
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
