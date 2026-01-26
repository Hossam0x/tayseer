import 'package:tayseer/features/advisor/profille/views/widgets/profile_certificates_section.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/tabs/ratings_tab.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/widgets/user_advisor_posts_tab.dart';
import 'package:tayseer/my_import.dart';

class UserAdvisorProfileTabsSection extends StatefulWidget {
  const UserAdvisorProfileTabsSection({super.key});

  @override
  State<UserAdvisorProfileTabsSection> createState() =>
      _UserAdvisorProfileTabsSectionState();
}

class _UserAdvisorProfileTabsSectionState
    extends State<UserAdvisorProfileTabsSection>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  final List<String> _tabs = ["المنشورات", "الشهادات", "التقييمات"];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    // إضافة listener عشان نعمل setState لما الـ tab يتغير
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SliverToBoxAdapter(
      child: Column(children: [_buildTabsHeader(), _buildTabContent()]),
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
    return IndexedStack(
      index: _tabController.index,
      children: [
        KeepAlive(child: UserAdvisorPostsTab()),
        KeepAlive(child: ProfileCertificatesSection()),
        KeepAlive(child: RatingsTab()),
      ],
    );
  }
}

// ويدجت KeepAlive مساعد
class KeepAlive extends StatefulWidget {
  final Widget child;

  const KeepAlive({super.key, required this.child});

  @override
  State<KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
