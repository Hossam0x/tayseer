import 'package:tayseer/features/advisor/profille/view/widgets/bio_information.dart';
import 'package:tayseer/features/advisor/profille/view/widgets/boost_button.dart';
import 'package:tayseer/features/advisor/profille/view/widgets/profile_certificates_section.dart';
import 'package:tayseer/features/advisor/profille/view/widgets/profile_header.dart';
import 'package:tayseer/features/advisor/profille/view/widgets/profile_stories_section.dart';
import 'package:tayseer/features/advisor/profille/view/widgets/profile_tabs_section.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/my_import.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: Gap(20.h)),
              // Header with profile picture, stats, bio, etc.
              const ProfileHeader(),

              // Bio and specialization
              BioInformation(),

              // Stories
              BlocProvider.value(
                value: getIt<StoriesCubit>()..fetchStories(),
                child: const ProfileStoriesSection(),
              ),

              // Tabs: المنشورات, الاستشارات, الشهادات
              const ProfileTabsSection(),

              // Certificates section (shown initially, other tabs can be implemented later)
              const ProfileCertificatesSection(),

              // مثال للاستخدام
              BoostButtonSliver(text: "تعزيز", onPressed: () {}),

              // Extra Space
              SliverToBoxAdapter(child: Gap(100.h)),
            ],
          ),
        ),
      ),
    );
  }
}
