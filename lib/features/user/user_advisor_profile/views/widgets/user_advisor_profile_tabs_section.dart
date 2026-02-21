import 'dart:developer';

import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/ratings_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/ratings_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/profile_certificates_section.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/ratings_tab.dart';
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_cubit.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_tabs_cubit.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_state.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_tabs_state.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/widgets/blocked_profile_placeholder.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/widgets/user_advisor_posts_tab.dart';
import 'package:tayseer/my_import.dart';

class UserAdvisorProfileTabsSection extends StatefulWidget {
  final String advisorId;
  const UserAdvisorProfileTabsSection({super.key, required this.advisorId});

  @override
  State<UserAdvisorProfileTabsSection> createState() =>
      _UserAdvisorProfileTabsSectionState();
}

class _UserAdvisorProfileTabsSectionState
    extends State<UserAdvisorProfileTabsSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CertificatesCubit _certificatesCubit;
  late RatingsCubit _ratingsCubit;
  late UserAdvisorTabsCubit _tabsCubit;

  final List<String> _tabs = ['posts', 'certificates', 'ratings'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    _certificatesCubit = CertificatesCubit(getIt<CertificatesRepository>());
    _ratingsCubit = RatingsCubit(getIt<RatingsRepository>());
    _tabsCubit = UserAdvisorTabsCubit();

    _tabController.addListener(_onTabControllerChanged);

    // Initial fetch for first tab (Posts) is usually handled by parent page or default state
    // _loadDataForTab(0);
  }

  void _onTabControllerChanged() {
    if (!_tabController.indexIsChanging) {
      _tabsCubit.updateIndex(_tabController.index);
    }
  }

  Future<void> _loadDataForTab(int index) async {
    log('Loading data for tab: $index');
    switch (index) {
      case 0: // Posts
        // Only load if needed
        break;
      case 1: // Certificates
        if (!_certificatesCubit.state.hasLoadedOnce) {
          await _certificatesCubit.fetchCertificatesAndVideos(
            advisorId: widget.advisorId,
            loadMore: false,
            isSilent: false,
          );
        }
        break;
      case 2: // Ratings
        if (!_ratingsCubit.state.hasLoadedOnce) {
          await _ratingsCubit.fetchRatings(
            advisorId: widget.advisorId,
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
        context.read<UserAdvisorProfileCubit>().fetchPosts(isSilent: true);
        break;
      case 1:
        _certificatesCubit.refresh(advisorId: widget.advisorId);
        break;
      case 2:
        _ratingsCubit.refresh(advisorId: widget.advisorId);
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
    final profile = context.read<UserAdvisorProfileCubit>().state.profile;
    final isMe = profile?.isMe ?? false;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _certificatesCubit),
        BlocProvider.value(value: _ratingsCubit),
        BlocProvider.value(value: _tabsCubit),
      ],
      child: BlocListener<UserAdvisorTabsCubit, UserAdvisorTabsState>(
        listener: (context, state) {
          if (state.refreshTimestamp != 0) {
            _refreshCurrentTab(state.selectedIndex);
          }
          if (state.selectedIndex != _tabController.index) {
            _tabController.animateTo(state.selectedIndex);
          }
          _loadDataForTab(state.selectedIndex);
        },
        listenWhen: (previous, current) {
          return previous.selectedIndex != current.selectedIndex ||
              previous.refreshTimestamp != current.refreshTimestamp;
        },
        child: SliverToBoxAdapter(
          child: Column(children: [_buildTabsHeader(), _buildTabContent(isMe)]),
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

  Widget _buildTabContent(bool isMe) {
    return BlocBuilder<UserAdvisorProfileCubit, UserAdvisorProfileState>(
      buildWhen: (previous, current) =>
          previous.profile?.room?.isBlocked != current.profile?.room?.isBlocked,
      builder: (context, profileState) {
        final isBlocked = profileState.profile?.room?.isBlocked ?? false;
        if (isBlocked) {
          return const BlockedProfilePlaceholder(isSliver: false);
        }
        return BlocBuilder<UserAdvisorTabsCubit, UserAdvisorTabsState>(
          buildWhen: (previous, current) =>
              previous.selectedIndex != current.selectedIndex,
          builder: (context, state) {
            switch (state.selectedIndex) {
              case 0:
                return UserAdvisorPostsTab(advisorId: widget.advisorId);
              case 1:
                return ProfileCertificatesSection(
                  isMe: isMe,
                  key: ValueKey('certificates_${widget.advisorId}'),
                  advisorId: widget.advisorId,
                );
              case 2:
                return RatingsTab(
                  isMe: isMe,
                  key: ValueKey('ratings_${widget.advisorId}'),
                  advisorId: widget.advisorId,
                );
              default:
                return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }
}
