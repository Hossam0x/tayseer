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
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const ProfileHeader(),
                  BioInformation(),
                  // Stories...
                  SliverToBoxAdapter(child: Gap(20.h)),
                  const ProfileTabsSection(),
                  SliverToBoxAdapter(child: Gap(100.h)),
                ],
              ),
            ),

            // Fixed top bar
          ],
        ),
      ),
    );
  }
}
