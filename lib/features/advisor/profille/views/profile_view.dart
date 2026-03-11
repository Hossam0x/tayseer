import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/widgets/account_review_content.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_state.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/account_review_dialog_listener.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/bio_information.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/profile_header.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/profile_stories_section.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/profile_tabs_section.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
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
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<ProfileCubit>(
                    create: (_) => getIt<ProfileCubit>(),
                  ),
                  BlocProvider<StoriesCubit>(
                    create: (_) => getIt<StoriesCubit>()
                      ..fetchStories(
                        isSpecial: true,
                        advisorId: null,
                        context: context,
                      ),
                  ),
                  BlocProvider.value(value: getIt<ConnectivityCubit>()),
                ],
                child: Stack(
                  children: [
                    _ProfileContent(),

                    // ⭐ إضافة AccountReviewDialogListener
                    const AccountReviewDialogListener(),
                  ],
                ),
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
            if (storiesCubit.state.storiesState == CubitStates.failure ||
                storiesCubit.state.storiesList.isEmpty) {
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
          VideoManager.instance.stopAll();
          await Future.wait([
            context.read<ProfileCubit>().refresh(),
            context.read<StoriesCubit>().fetchStories(
              isSpecial: true,
              advisorId: null,
              context: context,
            ),
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

            // Stories Section
            const ProfileStoriesSection(advisorId: null),

            // Spacing
            SliverToBoxAdapter(child: Gap(20.h)),

            // Posts Tabs Section or Account Review Content
            BlocBuilder<ProfileCubit, ProfileState>(
              buildWhen: (previous, current) =>
                  previous.profile?.isApproved != current.profile?.isApproved,
              builder: (context, state) {
                final isApproved = state.profile?.isApproved ?? true;

                if (!isApproved) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: const AccountReviewContent(
                        isDialog: false,
                        showButton: false,
                      ),
                    ),
                  );
                }

                return const ProfileTabsSection();
              },
            ),

            // Bottom padding for better scrolling
            SliverToBoxAdapter(child: Gap(100.h)),
          ],
        ),
      ),
    );
  }
}
