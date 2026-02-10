import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/features/user/user_advisor_profile/data/repositories/user_advisor_profile_repository.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_cubit.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/widgets/navigate_to_chat_listener.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/widgets/user_advisor_bio_information.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/widgets/user_advisor_profile_header.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/widgets/user_advisor_profile_tabs_section.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/profile_stories_section.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/my_import.dart';

class UserAdvisorProfileView extends StatelessWidget {
  final String advisorId;
  final String? advisorName;

  const UserAdvisorProfileView({
    super.key,
    required this.advisorId,
    this.advisorName,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic =
        context.read<LanguageCubit>().state.languageCode == 'ar';
    return Scaffold(
      body: AdvisorBackground(
        child: MultiBlocProvider(
          providers: [
            BlocProvider<UserAdvisorProfileCubit>(
              create: (_) => UserAdvisorProfileCubit(
                getIt<UserAdvisorProfileRepository>(),
                advisorId,
              ),
            ),
            BlocProvider<StoriesCubit>(
              create: (_) => getIt<StoriesCubit>()
                ..fetchStories(
                  isSpecial: true,
                  advisorId: advisorId,
                  context: context,
                ),
            ),
          ],
          child: Stack(
            children: [
              // Main scrollable content
              SafeArea(
                child: _UserProfileContent(
                  advisorName: advisorName,
                  advisorId: advisorId,
                ),
              ),

              Positioned(
                top: 40.h,
                right: isArabic ? 8.w : null,
                left: !isArabic ? 8.w : null,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios, size: 22.w),
                  ),
                ),
              ),

              // ⭐ نقل NavigateToChatListener داخل BlocProvider
              const NavigateToChatListener(),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserProfileContent extends StatelessWidget {
  final String? advisorName;
  final String advisorId;

  const _UserProfileContent({this.advisorName, required this.advisorId});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () => Future.wait([
        context.read<UserAdvisorProfileCubit>().refresh(),
        context.read<StoriesCubit>().fetchStories(
          isSpecial: true,
          advisorId: advisorId,
          context: context,
        ),
      ]),
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
          const UserAdvisorProfileHeader(),

          // Bio Information
          const UserAdvisorBioInformation(),

          // Stories Section
          ProfileStoriesSection(advisorId: advisorId),

          // Spacing
          SliverToBoxAdapter(child: Gap(20.h)),

          // Posts Tabs Section
          UserAdvisorProfileTabsSection(advisorId: advisorId),

          // Bottom padding
          SliverToBoxAdapter(child: Gap(100.h)),
        ],
      ),
    );
  }
}
