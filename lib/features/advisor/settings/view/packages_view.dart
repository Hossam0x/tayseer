import 'package:tayseer/features/advisor/settings/data/models/package_model.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/package_feature_grid.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/packages_tab_selector.dart';
import 'package:tayseer/features/advisor/settings/view_model/packages_cubit.dart';
import 'package:tayseer/my_import.dart';

class PackagesView extends StatelessWidget {
  const PackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PackagesCubit(),
      child: const _PackagesViewContent(),
    );
  }
}

class _PackagesViewContent extends StatelessWidget {
  const _PackagesViewContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PackagesCubit, PackagesState>(
      builder: (context, state) {
        final package = _getPackage(context, state.selectedPackage);
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: SvgPicture.asset(AssetsData.backArrow),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              _buildBackgroundLayer(state.selectedPackage),
              Positioned.fill(
                child: SafeArea(
                  child: Column(
                    children: [
                      Gap(20.h),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          switchInCurve: Curves.easeOutQuart,
                          switchOutCurve: Curves.easeInQuart,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation.drive(
                                  Tween(begin: 0.95, end: 1.0),
                                ),
                                child: child,
                              ),
                            );
                          },
                          child: _buildPackageDetailContainer(
                            context,
                            package,
                            key: ValueKey(package.id),
                          ),
                        ),
                      ),
                      Gap(40.h),
                      PackagesTabSelector(
                        selectedPackage: state.selectedPackage,
                        onSelected: (pkg) =>
                            context.read<PackagesCubit>().selectPackage(pkg),
                      ),
                      Gap(40.h),
                      _buildBottomActions(context, state.selectedPackage),
                      Gap(20.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundLayer(SelectedPackage package) {
    List<Color> colors;
    if (package == SelectedPackage.basic) {
      colors = [const Color(0xFFFFFFFF), const Color(0xFFFDE7EC)];
    } else if (package == SelectedPackage.pro) {
      colors = [const Color(0xFFFFFFFF), const Color(0xFFFFF8E5)];
    } else {
      colors = [const Color(0xFFFFFFFF), const Color(0xFFE5F3FF)];
    }

    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
    );
  }

  Widget _buildPackageDetailContainer(
    BuildContext context,
    PackageModel package, {
    required Key key,
  }) {
    return SingleChildScrollView(
      key: key,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Text(
            package.packageTitle,
            textAlign: TextAlign.center,
            style: Styles.textStyle24Meduim.copyWith(
              color: AppColors.primary500,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(40.h),
          PackageFeatureGrid(package: package),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, SelectedPackage selected) {
    String buttonText = '';
    Color color = AppColors.primary400;

    if (selected == SelectedPackage.basic) {
      buttonText = context.tr('continue_limited_account');
      color = AppColors.primary400;
    } else if (selected == SelectedPackage.pro) {
      buttonText = context.tr('get_all_benefits_for').replaceFirst('{}', '30');
      color = const Color(0xFFCF9916);
    } else {
      buttonText = context.tr('subscribe_vip_for').replaceFirst('{}', '60');
      color = const Color(0xFF1E88E5);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: SizedBox(
        width: double.infinity,
        height: 55.h,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r),
            gradient: LinearGradient(colors: [color.withOpacity(0.7), color]),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
            ),
            onPressed: () {
              // Subscription flow logic here
            },
            child: Text(
              buttonText,
              style: Styles.textStyle16Bold.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  PackageModel _getPackage(BuildContext context, SelectedPackage pkg) {
    if (pkg == SelectedPackage.basic) {
      return PackageModel(
        id: 'basic',
        packageTitle: context.tr('limited_basic_plan'),
        price: '0',
        buttonText: context.tr('continue_limited_account'),
        themeColor: AppColors.primary400,
        backgroundGradient: [const Color(0xFFFFFFFF), const Color(0xFFEB7A91)],
        features: [
          PackageFeatureModel(
            title: context.tr('3_session_monthly'),
            iconPath: AssetsData.eightSessionMonthIcon,
          ),
          PackageFeatureModel(
            title: context.tr('3_messages_monthly'),
            iconPath: AssetsData.threeMessages,
          ),
          PackageFeatureModel(
            title: context.tr('normal_appearance'),
            iconPath: AssetsData.normalApperance,
          ),
          PackageFeatureModel(
            title: context.tr('no_events'),
            iconPath: AssetsData.noEvents,
          ),
          PackageFeatureModel(
            title: context.tr('basic_support'),
            iconPath: AssetsData.essentialSupport,
          ),
          PackageFeatureModel(
            title: context.tr('1_boost_monthly'),
            iconPath: AssetsData.oneBoost,
          ),
        ],
      );
    } else if (pkg == SelectedPackage.pro) {
      return PackageModel(
        id: 'pro',
        packageTitle: context.tr('enjoy_more_benefits'),
        price: '30',
        buttonText: context.tr('get_all_benefits_for').replaceFirst('{}', '30'),
        themeColor: const Color(0xFFCF9916),
        backgroundGradient: [const Color(0xFFFFFFFF), const Color(0xFFFFF8E5)],
        features: [
          PackageFeatureModel(
            title: context.tr('3_session_monthly'),
            iconPath: AssetsData.eightSessionMonthIcon,
          ),
          PackageFeatureModel(
            title: context.tr('unlimited_messages'),
            iconPath: AssetsData.threeMessages,
          ),
          PackageFeatureModel(
            title: context.tr('initial_documentation'),
            iconPath: AssetsData.verifiedBegin,
          ),
          PackageFeatureModel(
            title: context.tr('4_boosts_monthly'),
            iconPath: AssetsData.oneBoost,
          ),
          PackageFeatureModel(
            title: context.tr('basic_support'),
            iconPath: AssetsData.essentialSupport,
          ),
          PackageFeatureModel(
            title: context.tr('1_event_monthly'),
            iconPath: AssetsData.noEvents,
          ),
        ],
      );
    } else {
      return PackageModel(
        id: 'elite',
        packageTitle: context.tr('enjoy_more_benefits'),
        price: '60',
        buttonText: context.tr('subscribe_vip_for').replaceFirst('{}', '60'),
        themeColor: const Color(0xFFFEC155),
        backgroundGradient: [const Color(0xFFFFFFFF), const Color(0xFFE5F3FF)],
        features: [
          PackageFeatureModel(
            title: context.tr('who_visited_profile_action'),
            iconPath: AssetsData.seeProfileVisits,
          ),
          PackageFeatureModel(
            title: context.tr('unlimited_messages'),
            iconPath: AssetsData.threeMessages,
          ),
          PackageFeatureModel(
            title: context.tr('full_official_documentation'),
            iconPath: AssetsData.verifiedBegin,
          ),
          PackageFeatureModel(
            title: context.tr('10_boosts_monthly'),
            iconPath: AssetsData.oneBoost,
          ),
          PackageFeatureModel(
            title: context.tr('vip_support'),
            iconPath: AssetsData.premiumSupport,
          ),
          PackageFeatureModel(
            title: context.tr('unlimited_sessions'),
            iconPath: AssetsData.eightSessionMonthIcon,
          ),
        ],
      );
    }
  }
}
