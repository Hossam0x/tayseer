import 'package:tayseer/features/advisor/profille/views/widgets/profile_certificates_section.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/ratings_tab.dart';
import 'package:tayseer/features/user/advisor_profile/views/cubit/user_profile_cubit.dart';
import 'package:tayseer/features/user/advisor_profile/views/widgets/user_posts_tab.dart';
import 'package:tayseer/my_import.dart';

class UserProfileTabsSection extends StatefulWidget {
  const UserProfileTabsSection({super.key});

  @override
  State<UserProfileTabsSection> createState() => _UserProfileTabsSectionState();
}

class _UserProfileTabsSectionState extends State<UserProfileTabsSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    // "الاستفسارات",
    "المنشورات",
    "الشهادات",
    "التقييمات",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      // case 0:
      //   print("Refresh الاستفسارات");
      //   break;
      case 0:
        context.read<UserProfileCubit>().fetchPosts();
        break;
      case 1:
        // Refresh للشهادات
        setState(() {});
        break;
      case 2:
        // Refresh للتقييمات
        setState(() {});
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(children: [_buildTabsHeader(), _buildTabContent()]),
    );
  }

  Widget _buildTabsHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelPadding: EdgeInsets.symmetric(horizontal: 8.w),
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.blackColor,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorPadding: EdgeInsets.zero,
            indicator: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.blackColor, width: 1.5.h),
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
          Divider(height: 1.h, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tabController.index) {
      // case 0:
      //   return InquiryTab();
      case 0:
        return const UserPostsTab();
      case 1:
        // 🔹 استخدام key فريد لإجبار rebuild عند الضغط على نفس التاب
        return ProfileCertificatesSection(
          key: ValueKey(
            'certificates_${DateTime.now().millisecondsSinceEpoch}',
          ),
        );
      case 2:
        // 🔹 استخدام key فريد لإجبار rebuild عند الضغط على نفس التاب
        return RatingsTab(
          key: ValueKey('ratings_${DateTime.now().millisecondsSinceEpoch}'),
        );
      default:
        return Container();
    }
  }
}
