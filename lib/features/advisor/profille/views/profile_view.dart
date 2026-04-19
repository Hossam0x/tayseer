import 'package:tayseer/core/enum/advisor_status.dart';
import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/widgets/advisor_status_widget.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/bio_information.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/profile_header.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/profile_stories_section.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/stories/profile_tabs_section.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
import 'package:tayseer/my_import.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with AutomaticKeepAliveClientMixin {
  late final ProfileCubit _profileCubit;
  late final StoriesCubit _storiesCubit;

  @override
  void initState() {
    super.initState();
    _profileCubit = getIt<ProfileCubit>();
    _storiesCubit = getIt<StoriesCubit>()
      ..fetchStories(isSpecial: true, advisorId: null, context: context)
      ..fetchMyStories();
  }

  @override
  void dispose() {
    // DO NOT close singleton cubits here as they are managed by GetIt
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
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
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<ProfileCubit>.value(value: _profileCubit),
                  BlocProvider<StoriesCubit>.value(value: _storiesCubit),
                  BlocProvider.value(value: getIt<ConnectivityCubit>()),
                  BlocProvider.value(value: getIt<HomeCubit>()),
                ],
                child: Stack(children: [_ProfileContent()]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LayoutCubit, LayoutState>(
          listenWhen: (previous, current) =>
              previous.scrollToTopTrigger != current.scrollToTopTrigger &&
              current.currentIndex == 3, // advisor profile is index 3
          listener: (context, state) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          },
        ),
        BlocListener<ConnectivityCubit, ConnectivityState>(
          listenWhen: (prev, curr) => !prev.isConnected && curr.isConnected,
          listener: (context, state) {
            final storiesCubit = context.read<StoriesCubit>();
            if (storiesCubit.state.mySpecialStoriesState ==
                    CubitStates.failure ||
                storiesCubit.state.mySpecialStories.isEmpty) {
              storiesCubit.fetchStories(
                isSpecial: true,
                advisorId: null,
                context: context,
              );
            }
            context.read<ProfileCubit>().refresh();
          },
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () async {
          if (getIt<ConnectivityCubit>().isOffline) return;
          AudioService.instance.playRefreshSound();
          VideoManager.instance.stopAll();
          await Future.wait([
            context.read<ProfileCubit>().refresh(),
            context.read<StoriesCubit>().fetchStories(
              isSpecial: true,
              advisorId: null,
              context: context,
            ),
            context.read<StoriesCubit>().fetchMyStories(),
          ]);
        },
        color: AppColors.kprimaryColor,
        backgroundColor: AppColors.kWhiteColor,
        displacement: 40.h,
        edgeOffset: 0,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Profile Header
            const ProfileHeader(),

            // Bio Information
            const BioInformation(),

            // Stories Section + Tabs — reactive to advisor status
            BlocBuilder<HomeCubit, HomeState>(
              buildWhen: (prev, curr) =>
                  prev.currentAdvisorStatus != curr.currentAdvisorStatus,
              builder: (context, homeState) {
                final status = homeState.currentAdvisorStatus ?? advisorStatus;
                final isApproved = status == AdvisorStatus.approved;
                return SliverMainAxisGroup(
                  slivers: [
                    if (isApproved)
                      const ProfileStoriesSection(advisorId: null),
                    SliverToBoxAdapter(child: Gap(20.h)),
                    if (isApproved)
                      const ProfileTabsSection()
                    else
                      SliverToBoxAdapter(child: AdvisorStatusWidget()),
                    SliverToBoxAdapter(child: Gap(100.h)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
