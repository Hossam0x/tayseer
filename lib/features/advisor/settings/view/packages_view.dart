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
              // Flip the svg icon
              icon: Transform.flip(
                flipX: isArabic ? false : true,
                child: SvgPicture.asset(AssetsData.backArrow),
              ),
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
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
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
                            state.selectedPackage,
                            key: ValueKey(package.id),
                          ),
                        ),
                      ),
                      Gap(80.h),
                      PackagesTabSelector(
                        selectedPackage: state.selectedPackage,
                        onSelected: (pkg) =>
                            context.read<PackagesCubit>().selectPackage(pkg),
                      ),
                      Gap(120.h),
                      _buildBottomActions(context, state.selectedPackage),
                      Gap(20.h),
                    ],
                  ),
                ),
              ),
              // Flip in Arabic
              if (state.selectedPackage == SelectedPackage.elite)
                Positioned(
                  left: isArabic ? 65.w : null,
                  right: !isArabic ? 25.w : null,
                  top: 65.h,
                  child: Transform.flip(
                    flipX: isArabic ? false : true,
                    child: SvgPicture.asset(AssetsData.kingIcon, height: 80.h),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ─── Background Layer ────────────────────────────────────────────────────────

  Widget _buildBackgroundLayer(SelectedPackage package) {
    // Elite uses PNG, others use SVG
    if (package == SelectedPackage.elite) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: Image.asset(
          AssetsData.eliteBackgroundPng,
          key: const ValueKey('elite_bg'),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    final String bgAsset = package == SelectedPackage.basic
        ? AssetsData.basicBackground
        : AssetsData.proBackground;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: SvgPicture.asset(
        bgAsset,
        key: ValueKey(bgAsset),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  // ─── Package Detail Container ────────────────────────────────────────────────

  Widget _buildPackageDetailContainer(
    BuildContext context,
    PackageModel package,
    SelectedPackage selected, {
    required Key key,
  }) {
    return SingleChildScrollView(
      key: key,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          _buildTitle(context, package, selected),
          Gap(40.h),
          PackageFeatureGrid(package: package),
        ],
      ),
    );
  }

  // ─── Title Builder (per-package style) ───────────────────────────────────────

  Widget _buildTitle(
    BuildContext context,
    PackageModel package,
    SelectedPackage selected,
  ) {
    if (selected == SelectedPackage.elite) {
      // Elite: king icon on the left + title in primary50
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              package.packageTitle,
              textAlign: TextAlign.center,
              style: Styles.textStyle24Meduim.copyWith(
                color: AppColors.primary50,
              ),
            ),
          ),
        ],
      );
    } else if (selected == SelectedPackage.pro) {
      // Pro: secondary800 dark text
      return Text(
        package.packageTitle,
        textAlign: TextAlign.center,
        style: Styles.textStyle24Meduim.copyWith(color: AppColors.secondary800),
      );
    } else {
      // Basic: primary500
      return Text(
        package.packageTitle,
        textAlign: TextAlign.center,
        style: Styles.textStyle24Meduim.copyWith(
          color: AppColors.primary500,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  // ─── Bottom Action Button ────────────────────────────────────────────────────

  Widget _buildBottomActions(BuildContext context, SelectedPackage selected) {
    String buttonText;
    List<Color> gradientColors;
    final bool isElite = selected == SelectedPackage.elite;

    if (selected == SelectedPackage.basic) {
      buttonText = context.tr('continue_limited_account');
      gradientColors = [AppColors.primary300, AppColors.primary500];
    } else if (selected == SelectedPackage.pro) {
      buttonText = context.tr('get_all_benefits_for').replaceFirst('{}', '30');
      gradientColors = [const Color(0xFFBD8F14), const Color(0xFFF5C003)];
    } else {
      buttonText = context.tr('subscribe_vip_for').replaceFirst('{}', '60');
      gradientColors = [const Color(0xFF4BB8F9), const Color(0xFF6284FF)];
    }

    // basic & elite: top→bottom gradient. pro: right→left
    final bool isVertical = selected == SelectedPackage.basic || isElite;

    return Center(
      child: Container(
        width: 348.w,
        height: 55.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11.r),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: isVertical ? Alignment.topCenter : Alignment.centerRight,
            end: isVertical ? Alignment.bottomCenter : Alignment.centerLeft,
          ),
          border: isElite ? Border.all(color: Colors.white, width: 1.5) : null,
          boxShadow: isElite
              ? [
                  BoxShadow(
                    color: const Color(0xFF6284FF).withOpacity(0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11.r),
            ),
          ),
          onPressed: () {
            // Subscription flow logic here
          },
          child: Text(
            buttonText,
            style: Styles.textStyle20SemiBold.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ─── Package Data ────────────────────────────────────────────────────────────

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
            title: context.tr('unlimited_messages'),
            iconPath: AssetsData.threeMessages,
          ),
          PackageFeatureModel(
            title: context.tr('1_event_monthly'),
            iconPath: AssetsData.noEvents,
          ),
          PackageFeatureModel(
            title: context.tr('basic_stats'),
            iconPath: AssetsData.essentialStats,
          ),
          PackageFeatureModel(
            title: context.tr('4_boosts_monthly'),
            iconPath: AssetsData.oneBoost,
          ),
          PackageFeatureModel(
            title: context.tr('initial_documentation'),
            iconPath: AssetsData.verifiedBegin,
          ),
          PackageFeatureModel(
            title: context.tr('unlimited_sessions'),
            iconPath: AssetsData.eightSessionMonthIcon,
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
            title: context.tr('unlimited_messages'),
            iconPath: AssetsData.threeMessages,
          ),
          PackageFeatureModel(
            title: context.tr('10_boosts_monthly'),
            iconPath: AssetsData.oneBoost,
          ),
          PackageFeatureModel(
            title: context.tr('basic_stats'),
            iconPath: AssetsData.essentialStats,
          ),
          PackageFeatureModel(
            title: context.tr('vip_support'),
            iconPath: AssetsData.premiumSupport,
          ),
          PackageFeatureModel(
            title: context.tr('full_official_documentation'),
            iconPath: AssetsData.verifiedBegin,
          ),
          PackageFeatureModel(
            title: context.tr('unlimited_sessions'),
            iconPath: AssetsData.eightSessionMonthIcon,
          ),
          PackageFeatureModel(
            title: context.tr('advanced_performance_reports'),
            iconPath: AssetsData.performanceReports,
          ),
          PackageFeatureModel(
            title: context.tr('appearance_count'),
            iconPath: AssetsData.normalApperance,
          ),
          PackageFeatureModel(
            title: context.tr('who_visited_profile_action'),
            iconPath: AssetsData.seeProfileVisits,
          ),
        ],
      );
    }
  }
}
