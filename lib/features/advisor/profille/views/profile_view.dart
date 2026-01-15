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
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: Gap(20.h)),

              // Header with profile picture, stats, bio, etc.
              const ProfileHeader(),

              // Bio and specialization
              BioInformation(),

              // Stories
              // BlocProvider.value(
              //   value: getIt<StoriesCubit>()..fetchStories(),
              //   child: const ProfileStoriesSection(),
              // ),

              // Tabs with Content
              const ProfileTabsSection(),

              // Extra Space
              SliverToBoxAdapter(child: Gap(100.h)),
            ],
          ),
        ),
      ),
    );
  }
}
