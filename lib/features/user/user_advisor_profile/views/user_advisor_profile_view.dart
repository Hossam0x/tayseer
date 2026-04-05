import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/features/user/user_advisor_profile/data/repositories/user_advisor_profile_repository.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_cubit.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_state.dart';
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
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;
        // ✅ Restore global stories when leaving a filtered profile
        getIt<StoriesCubit>().fetchStories(
          isSpecial: true,
          advisorId: null,
          context: context,
          isSilent: true,
        );
      },
      child: Scaffold(
        body: AdvisorBackground(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<UserAdvisorProfileCubit>(
                create:
                    (_) => UserAdvisorProfileCubit(
                      getIt<UserAdvisorProfileRepository>(),
                      advisorId,
                    ),
              ),
              BlocProvider<StoriesCubit>.value(
                value:
                    getIt<StoriesCubit>()
                      ..fetchStories(
                        isSpecial: true,
                        advisorId: advisorId,
                        context: context,
                      ),
              ),
              BlocProvider.value(value: getIt<ConnectivityCubit>()),
            ],
            child: Stack(
              children: [
                SafeArea(
                  child: _UserProfileContent(
                    advisorName: advisorName,
                    advisorId: advisorId,
                  ),
                ),
                const NavigateToChatListener(),
              ],
            ),
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
    return MultiBlocListener(
      listeners: [
        BlocListener<UserAdvisorProfileCubit, UserAdvisorProfileState>(
          listenWhen: (previous, current) =>
              (previous.profile?.room?.isBlocked == true &&
              current.profile?.room?.isBlocked == false),
          listener: (context, state) {
            // ✅ Refetch everything when unblocked
            context.read<UserAdvisorProfileCubit>().refresh();
            context.read<StoriesCubit>().fetchStories(
                  isSpecial: true,
                  advisorId: advisorId,
                  context: context,
                );
          },
        ),
        BlocListener<ConnectivityCubit, ConnectivityState>(
          listenWhen: (prev, curr) => !prev.isConnected && curr.isConnected,
          listener: (context, state) {
            final storiesCubit = context.read<StoriesCubit>();
            if (storiesCubit.state.advisorSpecialStoriesState == CubitStates.failure ||
                storiesCubit.state.advisorSpecialStories.isEmpty) {
              storiesCubit.fetchStories(
                isSpecial: true,
                advisorId: advisorId,
                context: context,
              );
            }
            context.read<UserAdvisorProfileCubit>().refresh();
          },
        ),
      ],
      child: BlocBuilder<UserAdvisorProfileCubit, UserAdvisorProfileState>(
        buildWhen: (previous, current) =>
            previous.profile?.room?.isBlocked !=
            current.profile?.room?.isBlocked,
        builder: (context, state) {
          final isBlocked = state.profile?.room?.isBlocked ?? false;

          return RefreshIndicator(
            onRefresh: () async {
              if (getIt<ConnectivityCubit>().isOffline) return;
              VideoManager.instance.stopAll();
              await Future.wait([
                context.read<UserAdvisorProfileCubit>().refresh(),
                if (!isBlocked)
                  context.read<StoriesCubit>().fetchStories(
                        isSpecial: true,
                        advisorId: advisorId,
                        context: context,
                      ),
              ]);
            },
            color: AppColors.kprimaryColor,
            backgroundColor: AppColors.kWhiteColor,
            displacement: 40.h,
            edgeOffset: 0,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Profile Header - Always visible
                const UserAdvisorProfileHeader(),

                // Bio Information - Always visible
                const UserAdvisorBioInformation(),

                // Stories Section - Now handles blocked state internally
                ProfileStoriesSection(
                  advisorId: advisorId,
                  isBlocked: isBlocked,
                ),

                if (!isBlocked) ...[
                  // Spacing
                  SliverToBoxAdapter(child: Gap(20.h)),

                  // Posts Tabs Section
                  UserAdvisorProfileTabsSection(advisorId: advisorId),
                ],

                // Bottom padding
                SliverToBoxAdapter(child: Gap(100.h)),
              ],
            ),
          );
        },
      ),
    );
  }
}
