import 'dart:developer';
import 'package:tayseer/features/advisor/profille/data/repositories/certificates_repository.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/ratings_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/ratings_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/profile_certificates_section.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/ratings_tab.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_cubit.dart';
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
  late UserAdvisorProfileCubit _profileCubit;

  // ⭐ إنشاء الـ Cubits مرة واحدة فقط
  late CertificatesCubit _certificatesCubit;
  late RatingsCubit _ratingsCubit;

  final List<String> _tabs = ["المنشورات", "المؤهلات", "التقييمات"];
  int _previousTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _profileCubit = context.read<UserAdvisorProfileCubit>();

    // ⭐ إنشاء الـ Cubits مرة واحدة
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
        await _profileCubit.fetchPosts(isSilent: true);
        break;
      case 1: // الشهادات
        if (!_certificatesCubit.state.hasLoadedOnce) {
          await _certificatesCubit.fetchCertificatesAndVideos(
            advisorId: widget.advisorId,
            loadMore: false,
            isSilent: false,
          );
        } else {
          await _certificatesCubit.fetchCertificatesAndVideos(
            advisorId: widget.advisorId,
            loadMore: false,
            isSilent: true,
          );
        }
        break;
      case 2: // التقييمات
        if (!_ratingsCubit.state.hasLoadedOnce) {
          await _ratingsCubit.fetchRatings(
            advisorId: widget.advisorId,
            loadMore: false,
            isSilent: false,
          );
        } else {
          await _ratingsCubit.fetchRatings(
            advisorId: widget.advisorId,
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
    _certificatesCubit.close();
    _ratingsCubit.close();
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
      case 0: // المنشورات
        _profileCubit.fetchPosts(isSilent: true);
        break;
      case 1: // الشهادات
        _certificatesCubit.refresh(advisorId: widget.advisorId);
        break;
      case 2: // التقييمات
        _ratingsCubit.refresh(advisorId: widget.advisorId);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileCubit.state.profile;
    final isMe = profile?.isMe ?? false;

    return SliverToBoxAdapter(
      child: Column(
        children: [
          _buildTabsHeader(),
          // ⭐ استخدام MultiBlocProvider لتوفير الـ Cubits
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _certificatesCubit),
              BlocProvider.value(value: _ratingsCubit),
            ],
            child: _buildTabContent(isMe),
          ),
        ],
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

  Widget _buildTabContent(bool isMe) {
    switch (_tabController.index) {
      case 0:
        return UserAdvisorPostsTab(advisorId: widget.advisorId);
      case 1:
        return ProfileCertificatesSection(
          isMe: isMe,
          key: ValueKey(
            'certificates_${widget.advisorId}',
          ), // ⭐ key ثابت بناءً على advisorId
          advisorId: widget.advisorId,
        );
      case 2:
        return RatingsTab(
          isMe: isMe,
          key: ValueKey(
            'ratings_${widget.advisorId}',
          ), // ⭐ key ثابت بناءً على advisorId
          advisorId: widget.advisorId,
        );
      default:
        return Container();
    }
  }
}
