import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/package_card.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/subscriprion_card.dart'
    show SubscriptionCard;
import 'package:tayseer/my_import.dart';

class PackagesTabView extends StatelessWidget {
  const PackagesTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        body: AdvisorBackground(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 105.h,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AssetsData.homeBarBackgroundImage),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 15.h,
                      ),
                      child: SimpleAppBar(title: context.tr('packages')),
                    ),

                    // ── نفس الـ TabBar الموجود في الأرشيف ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        padding: EdgeInsets.all(2.5.w),
                        decoration: BoxDecoration(
                          color: AppColors.tabsBack,
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(color: AppColors.primary100),
                        ),
                        child: Builder(
                          builder: (context) {
                            final bool isTablet =
                                MediaQuery.of(context).size.width > 600;
                            return TabBar(
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              indicator: BoxDecoration(
                                color: AppColors.primary300,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              labelStyle: isTablet
                                  ? Styles.textStyle16
                                  : Styles.textStyle20,
                              labelPadding: isTablet
                                  ? EdgeInsets.symmetric(
                                      horizontal: 24.w,
                                      vertical: 12.h,
                                    )
                                  : EdgeInsets.zero,
                              labelColor: AppColors.secondary950,
                              unselectedLabelColor: AppColors.blackColor,
                              unselectedLabelStyle: Styles.textStyle16,
                              tabs: [
                                Tab(text: context.tr('packages')),
                                Tab(text: context.tr('subscriptions')),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    // المحتوى
                    const Expanded(
                      child: TabBarView(
                        children: [
                          _PackagesTabContent(),
                          _SubscriptionsTabContent(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── محتوى تبويب الباقات (مع اختيار النوع داخليًا) ──
class _PackagesTabContent extends StatefulWidget {
  const _PackagesTabContent();

  @override
  State<_PackagesTabContent> createState() => _PackagesTabContentState();
}

class _PackagesTabContentState extends State<_PackagesTabContent> {
  List<PackageCard> get _comprehensivePackages => [
    PackageCard(
      title: context.tr('comprehensive_package_one'),
      features: [
        context.tr('conversations_count', args: ['3']),
        context.tr('boost_posts'),
        context.tr('pin_top_one_day'),
      ],
      price: '170',
      savings: '150',
      onSubscribe: () {},
    ),
    PackageCard(
      title: context.tr('premium_comprehensive_package'),
      features: [
        context.tr('conversations_count', args: ['3']),
        context.tr('boost_posts'),
        context.tr('pin_top_one_day'),
      ],
      price: '170',
      savings: '150',
      isFeatured: true,
      onSubscribe: () {},
    ),
  ];

  List<PackageCard> get _detailedPackages => [
    PackageCard(
      title: context.tr('detailed_package_one'),
      features: null,
      price: '100',
      savings: '80',
      onSubscribe: () {},
    ),
    PackageCard(
      title: context.tr('premium_detailed_package'),
      features: null,
      price: '120',
      savings: '90',
      isFeatured: true,
      onSubscribe: () {},
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedPackageType = 'comprehensive';
  }

  late String _selectedPackageType;

  @override
  Widget build(BuildContext context) {
    final List<PackageCard> currentPackages =
        _selectedPackageType == 'comprehensive'
        ? _comprehensivePackages
        : _detailedPackages;

    return GestureDetector(
      onTap: () => _showPackageTypeSelection(context),
      child: Column(
        children: [
          // شريط اختيار النوع
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 23.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.secondary950.withOpacity(0.75),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Text(
                    context.tr(
                      'packages_of_type',
                      args: [context.tr(_selectedPackageType)],
                    ),
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.secondary600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.secondary300,
                    size: 24.h,
                  ),
                ],
              ),
            ),
          ),
          Gap(5.h),

          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              children: [...currentPackages],
            ),
          ),
        ],
      ),
    );
  }

  void _showPackageTypeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.secondary950,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: Icon(Icons.close, size: 20.sp),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        context.tr('select_package_type'),
                        style: Styles.textStyle16SemiBold,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              _buildPackageTypeOption(
                title: context.tr('comprehensive_packages'),
                subtitle: context.tr('comprehensive_packages_desc'),
                isSelected: _selectedPackageType == 'comprehensive',
                onTap: () {
                  setState(() => _selectedPackageType = 'comprehensive');
                  Navigator.pop(context);
                },
              ),
              Gap(12.h),
              _buildPackageTypeOption(
                title: context.tr('detailed_packages'),
                subtitle: context.tr('detailed_packages_desc'),
                isSelected: _selectedPackageType == 'detailed',
                onTap: () {
                  setState(() => _selectedPackageType = 'detailed');
                  Navigator.pop(context);
                },
              ),
              Gap(24.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackageTypeOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary50 : AppColors.secondary50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary400 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Gap(16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Styles.textStyle14SemiBold.copyWith(
                      color: isSelected
                          ? AppColors.primary600
                          : AppColors.titleCard,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    subtitle,
                    style: Styles.textStyle12.copyWith(
                      color: isSelected
                          ? AppColors.primary500
                          : AppColors.secondary600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// تبويب الاشتراكات (نفس اللي كان موجود)
class _SubscriptionsTabContent extends StatelessWidget {
  const _SubscriptionsTabContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      children: [
        SubscriptionCard(
          title: context.tr('comprehensive_package_one'),
          dateStart: '12/10/2020',
          dateEnd: '13/11/2020',
          isExpiring: true,
        ),
        Gap(10.h),
        SubscriptionCard(
          title: context.tr('comprehensive_package_one'),
          dateStart: '12/10/2020',
          dateEnd: '13/11/2020',
        ),
        Gap(10.h),
        SubscriptionCard(
          title: context.tr('comprehensive_package_one'),
          dateStart: '12/10/2020',
          dateEnd: '13/11/2020',
          canRenew: false,
        ),
      ],
    );
  }
}
