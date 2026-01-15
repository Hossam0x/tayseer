import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/bio_information.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/profile_header.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/profile_tabs_section.dart';
import 'package:tayseer/my_import.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: Stack(
          children: [
            // Background header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 110.h,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsData.homeBarBackgroundImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),

            // Main scrollable content
            SafeArea(
              child: BlocProvider<ProfileCubit>(
                create: (_) => getIt<ProfileCubit>(),
                child: _ProfileContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () => context.read<ProfileCubit>().refresh(),
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
          const ProfileHeader(),

          // Bio Information
          const BioInformation(),

          // Spacing
          SliverToBoxAdapter(child: Gap(20.h)),

          // Posts Tabs Section
          const ProfileTabsSection(),

          // Bottom padding for better scrolling
          SliverToBoxAdapter(child: Gap(100.h)),
        ],
      ),
    );
  }
}
