import 'dart:developer';

import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/ratings_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/ratings_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_tabs_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_tabs_state.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/profile_certificates_section.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/posts_tab.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/ratings_tab.dart';
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/my_import.dart';

class ProfileTabsSection extends StatefulWidget {
  const ProfileTabsSection({super.key});

  @override
  State<ProfileTabsSection> createState() => _ProfileTabsSectionState();
}

class _ProfileTabsSectionState extends State<ProfileTabsSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CertificatesCubit _certificatesCubit;
  late RatingsCubit _ratingsCubit;
  late ProfileTabsCubit _tabsCubit;

  final List<String> _tabs = ['posts', 'certificates', 'ratings'];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _tabs.length, vsync: this);

    // Create Cubits
    _certificatesCubit = CertificatesCubit(getIt<CertificatesRepository>());
    _ratingsCubit = RatingsCubit(getIt<RatingsRepository>());
    _tabsCubit = ProfileTabsCubit();

    // Listen to TabController for swipe changes only
    _tabController.addListener(_onTabControllerChanged);

    // Initial load (optional if View already loaded it, but safe to keep)
    // _loadDataForTab(0); // View usually loads posts initially via ProfileCubit
  }

  void _onTabControllerChanged() {
    if (!_tabController.indexIsChanging) {
      // Update Cubit index when swipe completes
      _tabsCubit.updateIndex(_tabController.index);
    }
  }

  Future<void> _loadDataForTab(int index) async {
    log('Loading data for tab: $index');
    switch (index) {
      case 0: // Posts
        // Standard flow: ProfileCubit manages this.
        // We only fetch if needed or if refresh requested.
        // On tab switch, maybe we don't force fetch if already loaded?
        // But for consistency with previous logic, we can leave it to the user's "refresh" action.
        // However, previous code called fetchPosts() on every tab switch.
        // To improve performance, we might skip if we have data?
        // But user asked for "rebuild/fetch only on tap same tab".
        // So on Switch, we might just show what we have.
        // Let's check what user requested: "not rebuild every time I switch... only on tap same tab".
        // SO: We should NOT call fetchPosts() on TAB SWITCH, only on REFRESH.
        break;
      case 1: // Certificates
        if (!_certificatesCubit.state.hasLoadedOnce) {
          await _certificatesCubit.fetchCertificatesAndVideos(
            loadMore: false,
            isSilent: false,
          );
        }
        break;
      case 2: // Ratings
        if (!_ratingsCubit.state.hasLoadedOnce) {
          await _ratingsCubit.fetchRatings(
            advisorId: '',
            loadMore: false,
            isSilent: false,
          );
        }
        break;
    }
  }

  void _refreshCurrentTab(int index) {
    log('Refreshing tab: $index');
    switch (index) {
      case 0:
        context.read<ProfileCubit>().fetchPosts();
        break;
      case 1:
        _certificatesCubit.refresh(advisorId: '');
        break;
      case 2:
        _ratingsCubit.refresh(advisorId: '');
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabControllerChanged);
    _tabController.dispose();
    _certificatesCubit.close();
    _ratingsCubit.close();
    _tabsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _certificatesCubit),
        BlocProvider.value(value: _ratingsCubit),
        BlocProvider.value(value: _tabsCubit),
      ],
      child: BlocListener<ProfileTabsCubit, ProfileTabsState>(
        listener: (context, state) {
          // Listen for Refresh triggers (timestamp change)
          if (state.refreshTimestamp != 0) {
            _refreshCurrentTab(state.selectedIndex);
          }
          // Listen for Index changes (load initial data if needed)
          if (state.selectedIndex != _tabController.index) {
            // Sync controller if state changed externally (rare here but good practice)
            _tabController.animateTo(state.selectedIndex);
          }
          _loadDataForTab(state.selectedIndex);
        },
        listenWhen: (previous, current) {
          // We trigger on index change OR refresh
          return previous.selectedIndex != current.selectedIndex ||
              previous.refreshTimestamp != current.refreshTimestamp;
        },
        child: SliverToBoxAdapter(
          child: Column(children: [_buildTabsHeader(), _buildTabContent()]),
        ),
      ),
    );
  }

  Widget _buildTabsHeader() {
    final bool isArabic =
        context.read<LanguageCubit>().state.languageCode == 'ar';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Transform.translate(
                offset: Offset(isArabic ? 110.w : -110.w, 0),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelPadding: EdgeInsets.symmetric(horizontal: 8.w),
                  indicatorColor: AppColors.blackColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorPadding: EdgeInsets.zero,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.blackColor,
                        width: 1.5.h,
                      ),
                    ),
                  ),
                  dividerHeight: 0,
                  labelColor: AppColors.blackColor,
                  unselectedLabelColor: AppColors.secondary400,
                  labelStyle: Styles.textStyle16Bold,
                  unselectedLabelStyle: Styles.textStyle14,
                  tabs: _tabs.map((tab) {
                    return Tab(
                      height: 33.w,
                      child: Column(
                        children: [
                          Text(context.tr(tab)),
                          Gap(4.h),
                          Container(width: 75.w, color: Colors.transparent),
                        ],
                      ),
                    );
                  }).toList(),
                  onTap: (index) {
                    _tabsCubit.changeTab(index);
                  },
                ),
              ),
            ],
          ),
          Divider(height: 1.h, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return BlocBuilder<ProfileTabsCubit, ProfileTabsState>(
      buildWhen: (previous, current) =>
          previous.selectedIndex != current.selectedIndex,
      builder: (context, state) {
        // Use IndexedStack or just switch to avoid state loss if wanted?
        // But switching widgets is standard here.
        // The user asked for performance. "not rebuild every tab switch".
        // Actually, keeping state alive (AutomaticKeepAlive) is key for performance + IndexedStack.
        // But SliverToBoxAdapter -> Column -> Content.
        // If we use simple switch, we lose state of scroll position in inner lists unless we use PageStorageKeys.
        // The previous code verified using simple switch.
        // We will stick to simple switch but wrapped in Builder to restrict rebuild to this area only.
        switch (state.selectedIndex) {
          case 0:
            return const PostsTab();
          case 1:
            return ProfileCertificatesSection(
              isMe: true,
              key: const ValueKey('certificates_tab'),
              advisorId: '',
            );
          case 2:
            return RatingsTab(
              isMe: true,
              key: const ValueKey('ratings_tab'),
              advisorId: '',
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
