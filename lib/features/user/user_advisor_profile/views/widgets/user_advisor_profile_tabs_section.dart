import 'dart:developer';

import 'package:tayseer/features/shared/profile/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/shared/profile/data/repositories/ratings_repository.dart';
import 'package:tayseer/features/shared/profile/cubit/certificates/certificates_cubit.dart';
import 'package:tayseer/features/shared/profile/cubit/ratings/ratings_cubit.dart';
import 'package:tayseer/features/shared/profile/widgets/certificates/profile_certificates_section.dart';
import 'package:tayseer/features/shared/profile/widgets/ratings/ratings_tab.dart';
import 'package:tayseer/features/shared/profile/cubit/profile_tabs_cubit.dart';
import 'package:tayseer/features/shared/profile/widgets/profile_tab_bar.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_cubit.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_state.dart';
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
  late ProfileTabsCubit _tabsCubit;

  final List<String> _tabs = ['posts', 'certificates', 'ratings'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _certificatesCubit = CertificatesCubit(getIt<CertificatesRepository>());
    _ratingsCubit = RatingsCubit(getIt<RatingsRepository>());
    _tabsCubit = ProfileTabsCubit();
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _tabsCubit.updateIndex(_tabController.index);
    }
  }

  Future<void> _loadTabIfNeeded(int index) async {
    log('Loading tab: $index');
    switch (index) {
      case 1:
        if (!_certificatesCubit.state.hasLoadedOnce) {
          await _certificatesCubit.fetchCertificatesAndVideos(
            advisorId: widget.advisorId,
          );
        }
        break;
      case 2:
        if (!_ratingsCubit.state.hasLoadedOnce) {
          await _ratingsCubit.fetchRatings(advisorId: widget.advisorId);
        }
        break;
    }
  }

  void _refreshTab(int index) {
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
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _certificatesCubit.close();
    _ratingsCubit.close();
    _tabsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMe =
        context.read<UserAdvisorProfileCubit>().state.profile?.isMe ?? false;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _certificatesCubit),
        BlocProvider.value(value: _ratingsCubit),
        BlocProvider.value(value: _tabsCubit),
      ],
      child: BlocListener<ProfileTabsCubit, ProfileTabsState>(
        listenWhen: (prev, curr) =>
            prev.selectedIndex != curr.selectedIndex ||
            prev.refreshTimestamp != curr.refreshTimestamp,
        listener: (context, state) {
          if (state.refreshTimestamp != 0) _refreshTab(state.selectedIndex);
          if (state.selectedIndex != _tabController.index) {
            _tabController.animateTo(state.selectedIndex);
          }
          _loadTabIfNeeded(state.selectedIndex);
        },
        child: SliverToBoxAdapter(
          child: Column(
            children: [
              ProfileTabBar(
                tabController: _tabController,
                tabs: _tabs,
                tabsCubit: _tabsCubit,
              ),
              BlocBuilder<UserAdvisorProfileCubit, UserAdvisorProfileState>(
                buildWhen: (prev, curr) =>
                    prev.profile?.room?.isBlocked !=
                    curr.profile?.room?.isBlocked,
                builder: (context, profileState) {
                  if (profileState.profile?.room?.isBlocked == true) {
                    return const BlockedProfilePlaceholder(isSliver: false);
                  }
                  return BlocBuilder<ProfileTabsCubit, ProfileTabsState>(
                    buildWhen: (prev, curr) =>
                        prev.selectedIndex != curr.selectedIndex,
                    builder: (context, state) {
                      switch (state.selectedIndex) {
                        case 0:
                          return UserAdvisorPostsTab(
                            advisorId: widget.advisorId,
                          );
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
