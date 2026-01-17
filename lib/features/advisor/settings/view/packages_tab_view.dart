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
                        horizontal: 30.w,
                        vertical: 15.h,
                      ),
                      child: SimpleAppBar(title: 'الباقات'),
                    ),

                    // Tab Bar Container
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 40.w,
                        vertical: 10.h,
                      ),
                      padding: EdgeInsets.all(2.5.w),
                      decoration: BoxDecoration(
                        color: AppColors.tabsBack,
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(color: AppColors.primary100),
                      ),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: AppColors.primary300,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        labelColor: AppColors.secondary950,
                        unselectedLabelColor: AppColors.blackColor,
                        tabs: const [
                          Tab(text: 'الباقات'),
                          Tab(text: 'الاشتراكات'),
                        ],
                      ),
                    ),

                    Expanded(
                      child: TabBarView(
                        children: [
                          // Packages Tab Content
                          _PackagesTabContent(),

                          // Subscriptions Tab Content
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

// تبويب الباقات
class _PackagesTabContent extends StatefulWidget {
  @override
  State<_PackagesTabContent> createState() => _PackagesTabContentState();
}

class _PackagesTabContentState extends State<_PackagesTabContent> {
  // نوع الباقة المختار
  String _selectedPackageType = 'الشاملة';

  // قائمة الباقات الشاملة
  final List<PackageCard> _comprehensivePackages = [
    PackageCard(
      title: 'باقة شاملة اولي',
      features: ['3 محادثات', 'تعزيز البوستات', 'تثبيت في الاعلي لمدة يوم'],
      price: '170',
      savings: '150',
      onSubscribe: () {},
    ),
    PackageCard(
      title: 'باقة شاملة مميزة',
      features: ['3 محادثات', 'تعزيز البوستات', 'تثبيت في الاعلي لمدة يوم'],
      price: '170',
      savings: '150',
      isFeatured: true,
      onSubscribe: () {},
    ),
  ];

  // قائمة الباقات المفصلة (بدون features)
  final List<PackageCard> _detailedPackages = [
    PackageCard(
      title: 'باقة مفصلة اولي',
      features: null, // بدون features
      price: '100',
      savings: '80',
      onSubscribe: () {},
    ),
    PackageCard(
      title: 'باقة مفصلة مميزة',
      features: null, // بدون features
      price: '120',
      savings: '90',
      isFeatured: true,
      onSubscribe: () {},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // اختيار القائمة بناءً على النوع المختار
    final List<PackageCard> currentPackages = _selectedPackageType == 'الشاملة'
        ? _comprehensivePackages
        : _detailedPackages;

    return GestureDetector(
      onTap: () {
        _showPackageTypeSelection(context);
      },
      child: Column(
        children: [
          // Selection Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary950,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Text(
                    'الباقات $_selectedPackageType',
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.secondary300,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.secondary300,
                  ),
                ],
              ),
            ),
          ),
          Gap(5.h),

          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
              children: [...currentPackages],
            ),
          ),
        ],
      ),
    );
  }

  // عرض قائمة اختيار نوع الباقة
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
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
              bottomLeft: Radius.circular(24.r),
              bottomRight: Radius.circular(24.r),
            ),
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
              // Header with Close Button
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
                        'اختر نوع الباقات',
                        style: Styles.textStyle16SemiBold.copyWith(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Option 1: الباقات الشاملة
              _buildPackageTypeOption(
                title: 'الباقات الشاملة',
                subtitle: 'باقات متكاملة مع جميع المميزات',
                isSelected: _selectedPackageType == 'الشاملة',
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedPackageType = 'الشاملة';
                  });
                },
              ),

              Gap(12.h),

              // Option 2: الباقات المفصلة
              _buildPackageTypeOption(
                title: 'الباقات المفصلة',
                subtitle: 'اختر المميزات التي تحتاجها فقط',
                isSelected: _selectedPackageType == 'المفصلة',
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedPackageType = 'المفصلة';
                  });
                },
              ),

              Gap(24.h),
            ],
          ),
        );
      },
    );
  }

  // Widget لعرض خيار نوع الباقة
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

            // Text Content
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

// تبويب الاشتراكات (بدون تغيير)
class _SubscriptionsTabContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      children: const [
        SubscriptionCard(
          title: 'باقة شاملة اولي',
          dateStart: '12/10/2020',
          dateEnd: '13/11/2020',
          isExpiring: true,
        ),
        SubscriptionCard(
          title: 'باقة شاملة اولي',
          dateStart: '12/10/2020',
          dateEnd: '13/11/2020',
        ),
        SubscriptionCard(
          title: 'باقة شاملة اولي',
          dateStart: '12/10/2020',
          dateEnd: '13/11/2020',
          canRenew: false,
        ),
      ],
    );
  }
}
