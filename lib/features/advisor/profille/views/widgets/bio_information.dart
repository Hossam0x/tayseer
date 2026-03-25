import 'package:tayseer/core/enum/advisor_status.dart';
import 'package:tayseer/features/advisor/profille/data/models/profile_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_state.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'bio_sections.dart';

class BioInformation extends StatelessWidget {
  const BioInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) {
        if (previous.profileState != current.profileState) return true;
        if (previous.profile == null && current.profile != null) return true;
        if (previous.profile != null && current.profile == null) return true;
        if (previous.profile != null && current.profile != null) {
          return previous.profile!.name != current.profile!.name ||
              previous.profile!.username != current.profile!.username ||
              previous.profile!.aboutYou != current.profile!.aboutYou ||
              previous.profile!.location != current.profile!.location ||
              previous.profile!.professionalSpecialization !=
                  current.profile!.professionalSpecialization ||
              previous.profile!.yearsOfExperience !=
                  current.profile!.yearsOfExperience;
        }
        return false;
      },
      builder: (context, state) {
        switch (state.profileState) {
          case CubitStates.loading:
            return SliverToBoxAdapter(child: _buildSkeleton(context));
          case CubitStates.failure:
            return SliverToBoxAdapter(
              child: _buildError(context, state.profileErrorMessage),
            );
          case CubitStates.success:
            if (state.profile != null) {
              return SliverToBoxAdapter(
                child: _buildContent(context, state.profile!),
              );
            }
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          default:
            return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
      },
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: _buildContent(
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
          approvalKey: '',
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String? errorMessage) {
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
            errorMessage ?? context.tr('error_loading_data'),
            style: Styles.textStyle14.copyWith(color: AppColors.kRedColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProfileModel profile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BioNameSection(profile: profile),
          if (profile.username.isNotEmpty) ...[
            Text(
              profile.username,
              style: Styles.textStyle14.copyWith(color: AppColors.hintText),
            ),
            Gap(8.h),
          ],
          BioProfessionalInfo(
            displaySpecialization: profile.displaySpecialization,
            displayYearsExperience: profile.displayYearsExperience,
          ),
          BioLocationSection(profile: profile),
          BioAboutSection(profile: profile),
          BlocBuilder<HomeCubit, HomeState>(
            buildWhen: (prev, curr) =>
                prev.currentAdvisorStatus != curr.currentAdvisorStatus,
            builder: (context, homeState) {
              final status = homeState.currentAdvisorStatus ?? advisorStatus;
              if (status != AdvisorStatus.approved)
                return const SizedBox.shrink();
              return const BioConsultationCard();
            },
          ),
        ],
      ),
    );
  }
}
