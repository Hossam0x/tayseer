import 'dart:developer';

import 'package:tayseer/features/advisor/profille/data/repositories/profile_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
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

  final List<String> _tabs = ["المنشورات", "المؤهلات", "التقييمات"];

  // 🔹 متغير لحفظ آخر تاب تم الضغط عليه
  int _previousTabIndex = 0;

  @override

  void initState() {
    super.initState();

    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _profileCubit = ProfileCubit(getIt<ProfileRepository>());
    _loadUserPosts();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _previousTabIndex = _tabController.index;
        log('$_previousTabIndex');
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _profileCubit.close();
    super.dispose();
  }

  Future<void> _loadUserPosts() async {
    await _profileCubit.fetchPosts();
  }

  // 🔹 دالة للتعامل مع الضغط على التاب
  void _handleTabTap(int index) {
    // ✅ إذا كان المستخدم ضغط على نفس التاب المفتوح حالياً
    if (index == _tabController.index) {
      _refreshCurrentTab(index);
    } else {
      // الانتقال للتاب الجديد
      _tabController.animateTo(index);
    }
  }

  // 🔹 دالة لعمل refresh حسب التاب المفتوح
  void _refreshCurrentTab(int index) {
    switch (index) {
      // case 0:
      //   print("Refresh الاستفسارات");
      //   break;
      case 0:
        // Refresh للمنشورات
        _profileCubit.fetchPosts();
        break;
      case 1:
        // Refresh للشهادات - سيتم refresh من خلال BlocProvider داخل التاب
        // يمكنك إضافة key للـ ProfileCertificatesSection لإجبارها على rebuild
        setState(() {});
        break;
      case 2:
        // Refresh للتقييمات - سيتم refresh من خلال BlocProvider داخل التاب
        setState(() {});
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileCubit,
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
        // 🔹 استخدام key فريد لإجبار rebuild عند الضغط على نفس التاب
        return ProfileCertificatesSection(
          key: ValueKey(
            'certificates_${DateTime.now().millisecondsSinceEpoch}',
          ),
          advisorId: '',
        );
      case 2:
        // س🔹 استخدام key فريد لإجبار rebuild عند الضغط على نفس التاب
        return RatingsTab(
          isMe: true,
          key: ValueKey('ratings_${DateTime.now().millisecondsSinceEpoch}'),
          advisorId: '',
        );
      default:
        return Container();
    }
  }
}
