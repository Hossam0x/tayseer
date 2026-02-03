import 'dart:developer';

import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/profile_repository.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/ratings_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/ratings_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/profile_certificates_section.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/posts_tab.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/ratings_tab.dart';
import 'package:tayseer/my_import.dart';

class ProfileTabsSection extends StatefulWidget {
  const ProfileTabsSection({super.key});

  @override
  State<ProfileTabsSection> createState() => _ProfileTabsSectionState();
}

class _ProfileTabsSectionState extends State<ProfileTabsSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProfileCubit _profileCubit;

  // ⭐ إضافة الـ Cubits
  late CertificatesCubit _certificatesCubit;
  late RatingsCubit _ratingsCubit;

  final List<String> _tabs = ["المنشورات", "المؤهلات", "التقييمات"];
  int _previousTabIndex = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _profileCubit = ProfileCubit(getIt<ProfileRepository>());

    // ⭐ إنشاء الـ Cubits
    _certificatesCubit = CertificatesCubit(getIt<CertificatesRepository>());
    _ratingsCubit = RatingsCubit(getIt<RatingsRepository>());

    _loadUserPosts();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _previousTabIndex = _tabController.index;
        log('Tab changed to: $_previousTabIndex');

        // ⭐ تحميل البيانات حسب الـ Tab
        _loadDataForTab(_previousTabIndex);
      });
    }
  }

  Future<void> _loadDataForTab(int index) async {
    switch (index) {
      case 0: // المنشورات
        await _profileCubit.fetchPosts();
        break;
      case 1: // الشهادات
        if (!_certificatesCubit.state.hasLoadedOnce) {
          await _certificatesCubit.fetchCertificatesAndVideos(
            loadMore: false,
            isSilent: false,
          );
        } else {
          await _certificatesCubit.fetchCertificatesAndVideos(
            loadMore: false,
            isSilent: true,
          );
        }
        break;
      case 2: // التقييمات
        if (!_ratingsCubit.state.hasLoadedOnce) {
          await _ratingsCubit.fetchRatings(
            advisorId: '', // ⭐ فاضي لأنه my profile
            loadMore: false,
            isSilent: false,
          );
        } else {
          await _ratingsCubit.fetchRatings(
            advisorId: '',
            loadMore: false,
            isSilent: true,
          );
        }
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _profileCubit.close();
    _certificatesCubit.close(); // ⭐
    _ratingsCubit.close(); // ⭐
    super.dispose();
  }

  Future<void> _loadUserPosts() async {
    await _profileCubit.fetchPosts();
  }

  void _handleTabTap(int index) {
    if (index == _tabController.index) {
      _refreshCurrentTab(index);
    } else {
      _tabController.animateTo(index);
    }
  }

  void _refreshCurrentTab(int index) {
    switch (index) {
      case 0:
        _profileCubit.fetchPosts();
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
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _profileCubit),
        BlocProvider.value(value: _certificatesCubit), // ⭐
        BlocProvider.value(value: _ratingsCubit), // ⭐
      ],
      child: SliverToBoxAdapter(
        child: Column(children: [_buildTabsHeader(), _buildTabContent()]),
      ),
    );
  }

  Widget _buildTabsHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Transform.translate(
                offset: Offset(110.w, 0),
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
                          Text(tab),
                          Gap(4.h),
                          Container(width: 75.w, color: Colors.transparent),
                        ],
                      ),
                    );
                  }).toList(),
                  onTap: _handleTabTap,
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
    switch (_tabController.index) {
      case 0:
        return PostsTab();
      case 1:
        return ProfileCertificatesSection(
          isMe: true,
          key: const ValueKey('certificates_tab'), // ⭐ key ثابت
          advisorId: '',
        );
      case 2:
        return RatingsTab(
          isMe: true,
          key: const ValueKey('ratings_tab'), // ⭐ key ثابت
          advisorId: '',
        );
      default:
        return Container();
    }
  }
}
