import 'package:tayseer/features/advisor/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/profille/view/widgets/profile_certificates_section.dart';
import 'package:tayseer/features/advisor/profille/view/widgets/tabs/comments_tab.dart';
import 'package:tayseer/features/advisor/profille/view/widgets/tabs/inquiries_tab.dart';
import 'package:tayseer/features/advisor/profille/view/widgets/tabs/posts_tab.dart';
import 'package:tayseer/features/advisor/profille/view/widgets/tabs/ratings_tab.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/home/reposiotry/home_repository.dart';

class ProfileTabsSection extends StatefulWidget {
  const ProfileTabsSection({super.key});

  @override
  State<ProfileTabsSection> createState() => _ProfileTabsSectionState();
}

class _ProfileTabsSectionState extends State<ProfileTabsSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late HomeCubit _profileHomeCubit;

  final List<String> _tabs = [
    "الاستفسارات",
    "المنشورات",
    "التعليقات",
    "الشهادات",
    "التقييمات",
  ];

  @override
  void initState() {
    super.initState();

    // إنشاء TabController
    _tabController = TabController(length: _tabs.length, vsync: this);

    // إضافة listener للتحديث عند تغيير التبويب بالسحب
    _tabController.addListener(_onTabChanged);

    // إنشاء HomeCubit خاص بالملف الشخصي
    _profileHomeCubit = HomeCubit(getIt<HomeRepository>());

    // جلب منشورات المستخدم الحالي
    _loadUserPosts();
  }

  void _onTabChanged() {
    // تحديث الـ state فقط إذا كان التبويب يتغير (وليس أثناء الحركة)
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _profileHomeCubit.close();
    super.dispose();
  }

  Future<void> _loadUserPosts() async {
    // TODO: هنا تحتاج إلى تنفيذ دالة خاصة لجلب منشورات المستخدم الحالي
    await _profileHomeCubit.fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileHomeCubit,
      child: SliverToBoxAdapter(
        child: Column(
          children: [
            // Tabs Header - مرتبط مع TabController
            _buildTabsHeader(),

            // Tab Content with Animation
            _buildTabContent(),
          ],
        ),
      ),
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
            padding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
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
            unselectedLabelStyle: Styles.textStyle16,
            tabs: _tabs.map((tab) {
              return Tab(
                height: 33.h,
                child: Column(
                  children: [
                    Text(tab),
                    Gap(4.h),
                    Container(width: 75.w, color: Colors.transparent),
                  ],
                ),
              );
            }).toList(),
            onTap: (index) {
              _tabController.animateTo(index);
            },
          ),
          Divider(height: 1.h, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 260.h,
      child: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          // Tab 1: الاستفسارات
          InquiryTab(),

          // Tab 2: المنشورات
          PostsTab(),

          // Tab 3: التعليقات
          CommentsTab(),

          // Tab 4: الشهادات
          ProfileCertificatesSection(),

          // Tab 5: التقييمات
          RatingsTab(),
        ],
      ),
    );
  }
}
