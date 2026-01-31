import 'dart:developer'; // للـ log إذا عايز

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

  final List<String> _tabs = ["المنشورات", "الشهادات", "التقييمات"];

  int _previousTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _profileCubit = context
        .read<UserAdvisorProfileCubit>(); // استخدم الـ cubit الموجود
    _loadUserPosts();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _previousTabIndex = _tabController.index;
        log('$_previousTabIndex'); // optional
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super
        .dispose(); // مش لازم close الـ cubit هنا عشان موجود في BlocProvider أعلى
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
        // silent refresh → يحافظ على البيانات القديمة
        context.read<UserAdvisorProfileCubit>().fetchPosts(isSilent: true);
        break;

      case 1: // الشهادات
        // لو عندك CertificatesCubit منفصل → نفس المنطق
        // context.read<CertificatesCubit>().fetchCertificatesAndVideos(
        //   advisorId: widget.advisorId,
        //   loadMore: false,
        //   isSilent: true,   // تحتاج تضيف الباراميتر ده كمان
        // );
        setState(() {}); // أو أفضل: استخدم key + silent fetch
        break;

      case 2: // التقييمات
        // نفس الفكرة مع RatingsCubit
        setState(() {});
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileCubit.state.profile;
    final isMe = profile?.isMe ?? false;
    return SliverToBoxAdapter(
      child: Column(children: [_buildTabsHeader(), _buildTabContent(isMe)]),
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
                  onTap: _handleTabTap, // أضف onTap للـ refresh
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
          key: ValueKey(
            'certificates_${DateTime.now().millisecondsSinceEpoch}',
          ), // للـ rebuild
          advisorId: widget.advisorId,
        );
      case 2:
        return RatingsTab(
          isMe: isMe,
          key: ValueKey(
            'ratings_${DateTime.now().millisecondsSinceEpoch}',
          ), // للـ rebuild
          advisorId: widget.advisorId,
        );
      default:
        return Container();
    }
  }
}
