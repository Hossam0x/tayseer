import 'package:tayseer/features/user/advisor_profile/data/repositories/user_profile_repository.dart';
import 'package:tayseer/features/user/advisor_profile/views/cubit/user_profile_cubit.dart';
import 'package:tayseer/features/user/advisor_profile/views/widgets/user_bio_information.dart';
import 'package:tayseer/features/user/advisor_profile/views/widgets/user_profile_header.dart';
import 'package:tayseer/features/user/advisor_profile/views/widgets/user_profile_tabs_section.dart';
import 'package:tayseer/my_import.dart';

class UserProfileView extends StatelessWidget {
  final String advisorId;
  final String? advisorName;

  const UserProfileView({super.key, required this.advisorId, this.advisorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: Stack(
          children: [
            // Main scrollable content
            SafeArea(
              child: BlocProvider<UserProfileCubit>(
                create: (_) =>
                    UserProfileCubit(getIt<UserProfileRepository>(), advisorId),
                child: _UserProfileContent(advisorName: advisorName),
              ),
            ),

            Positioned(
              top: 40.h,
              right: 5.w,
              child: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_ios, size: 22.w),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserProfileContent extends StatelessWidget {
  final String? advisorName;

  const _UserProfileContent({this.advisorName});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () => context.read<UserProfileCubit>().refresh(),
      color: AppColors.kprimaryColor,
      backgroundColor: AppColors.kWhiteColor,
      displacement: 40.h,
      edgeOffset: 0,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Profile Header
          const UserProfileHeader(),

          // Bio Information
          const UserBioInformation(),

          // Spacing
          SliverToBoxAdapter(child: Gap(20.h)),

          // Posts Tabs Section
          const UserProfileTabsSection(),

          // Bottom padding
          SliverToBoxAdapter(child: Gap(100.h)),
        ],
      ),
    );
  }
}
