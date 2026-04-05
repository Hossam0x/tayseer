import 'package:tayseer/features/shared/profile/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/shared/profile/data/repositories/ratings_repository.dart';
import 'package:tayseer/features/shared/profile/cubit/certificates/certificates_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_cubit.dart';
import 'package:tayseer/features/shared/profile/cubit/ratings/ratings_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/posts_tab.dart';
import 'package:tayseer/features/shared/profile/widgets/certificates/profile_certificates_section.dart';
import 'package:tayseer/features/shared/profile/widgets/ratings/ratings_tab.dart';
import 'package:tayseer/features/shared/profile/cubit/profile_tabs_cubit.dart';
import 'package:tayseer/features/shared/profile/widgets/profile_tab_bar.dart';
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
    switch (index) {
      case 1:
        if (!_certificatesCubit.state.hasLoadedOnce) {
          await _certificatesCubit.fetchCertificatesAndVideos();
        }
        break;
      case 2:
        if (!_ratingsCubit.state.hasLoadedOnce) {
          await _ratingsCubit.fetchRatings(advisorId: '');
        }
        break;
    }
  }

  void _refreshTab(int index) {
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
    _tabController.removeListener(_onTabChanged);
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
              BlocBuilder<ProfileTabsCubit, ProfileTabsState>(
                buildWhen: (prev, curr) =>
                    prev.selectedIndex != curr.selectedIndex,
                builder: (context, state) {
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
