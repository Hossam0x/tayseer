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
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 15.h,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Text(
                        'الباقات',
                        style: Styles.textStyle24Meduim.copyWith(
                          color: AppColors.secondary700,
                        ),
                      ),
                    ],
                  ),
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
                      ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 6.h,
                        ),
                        children: [
                          PackageCard(
                            title: 'باقة شاملة اولي',
                            features: [
                              '3 محادثات',
                              'تعزيز البوستات',
                              'تثبيت في الاعلي لمدة يوم',
                            ],
                            price: '170',
                            savings: '150',
                            onSubscribe: () {},
                          ),
                          PackageCard(
                            title: 'باقة شاملة مميزة',
                            features: [
                              '3 محادثات',
                              'تعزيز البوستات',
                              'تثبيت في الاعلي لمدة يوم',
                            ],
                            price: '170',
                            savings: '150',
                            isFeatured: true,
                            onSubscribe: () {},
                          ),
                        ],
                      ),

                      // Subscriptions Tab Content
                      ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 16.h,
                        ),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
