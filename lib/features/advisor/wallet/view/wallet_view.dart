import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/wallet_cubit.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/wallet_tab_content.dart';
import 'package:tayseer/my_import.dart';

class WalletView extends StatelessWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<WalletCubit>()..loadInitialData(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.kScaffoldColor,
          body: AdvisorBackground(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 105.h,
                  child: Image.asset(
                    AssetsData.homeBarBackgroundImage,
                    fit: BoxFit.fill,
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Gap(16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: SimpleAppBar(title: context.tr('my_wallet')),
                      ),
                      const _WalletTabBar(),
                      const Expanded(
                        child: TabBarView(
                          children: [WalletTabContent(), EarningsTabContent()],
                        ),
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

class _WalletTabBar extends StatelessWidget {
  const _WalletTabBar();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width > 600;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
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
          labelStyle: isTablet ? Styles.textStyle16 : Styles.textStyle20,
          labelPadding: isTablet
              ? EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h)
              : EdgeInsets.zero,
          labelColor: AppColors.secondary950,
          unselectedLabelColor: AppColors.blackColor,
          unselectedLabelStyle: Styles.textStyle16,
          tabs: [
            Tab(text: context.tr('my_wallet')),
            Tab(text: context.tr('earnings')),
          ],
        ),
      ),
    );
  }
}
