import 'package:tayseer/features/user/user_advisor_profile/data/repositories/user_advisor_profile_repository.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_cubit.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/widgets/navigate_to_chat_listener.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/widgets/user_advisor_bio_information.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/widgets/user_advisor_profile_header.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/widgets/user_advisor_profile_tabs_section.dart';
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
    return Scaffold(
      body: AdvisorBackground(
        child: BlocProvider<UserAdvisorProfileCubit>(
          create: (_) => UserAdvisorProfileCubit(
            getIt<UserAdvisorProfileRepository>(),
            advisorId,
          ),
          child: Stack(
            children: [
              // Main scrollable content
              SafeArea(child: _UserProfileContent(advisorName: advisorName)),

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

  const _UserProfileContent({this.advisorName});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () => context.read<UserAdvisorProfileCubit>().refresh(),
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

          // Spacing
          SliverToBoxAdapter(child: Gap(20.h)),

          // Posts Tabs Section
          const UserAdvisorProfileTabsSection(),

          // Bottom padding
          SliverToBoxAdapter(child: Gap(100.h)),
        ],
      ),
    );
  }
}
