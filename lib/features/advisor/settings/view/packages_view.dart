import 'package:tayseer/features/advisor/settings/data/models/package_model.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/package_feature_grid.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/packages_tab_selector.dart';
import 'package:tayseer/features/advisor/settings/view_model/packages_cubit.dart';
import 'package:tayseer/core/functions/country_helper.dart';
import 'package:tayseer/my_import.dart';

class PackagesView extends StatefulWidget {
  const PackagesView({super.key});

  @override
  State<PackagesView> createState() => _PackagesViewState();
}

class _PackagesViewState extends State<PackagesView> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PackagesCubit>()..getPackages(),
      child: const _PackagesViewContent(),
    );
  }
}

class _PackagesViewContent extends StatefulWidget {
  const _PackagesViewContent();

  @override
  State<_PackagesViewContent> createState() => _PackagesViewContentState();
}

class _PackagesViewContentState extends State<_PackagesViewContent> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache images for smooth transitions
    precacheImage(const AssetImage(AssetsData.eliteBackgroundPng), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Transform.flip(
            flipX: isArabic ? false : true,
            child: SvgPicture.asset(AssetsData.backArrow),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Layer (Independent Rebuild)
          const _BackgroundLayer(),

          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  const Expanded(child: _PackageDetailSwitcher()),
                  const _TabSelectorSection(),
                  Gap(110.h),
                  const _BottomActionsSection(),
                  Gap(20.h),
                ],
              ),
            ),
          ),

          // King Icon (Independent Rebuild)
          Positioned(
            left: isArabic ? 65.w : null,
            right: !isArabic ? 25.w : null,
            top: 55.h,
            child: const _KingIconOverlay(),
          ),
        ],
      ),
    );
  }
}

class _BackgroundLayer extends StatefulWidget {
  const _BackgroundLayer();

  @override
  State<_BackgroundLayer> createState() => _BackgroundLayerState();
}

class _BackgroundLayerState extends State<_BackgroundLayer> {
  // Cache the backgrounds to avoid rebuilding
  Widget? _basicBg;
  Widget? _proBg;
  Widget? _eliteBg;

  @override
  void initState() {
    super.initState();
    // Precache backgrounds
    _precacheBackgrounds();
  }

  void _precacheBackgrounds() {
    // Precache basic background
    _basicBg = RepaintBoundary(
      child: SvgPicture.asset(
        AssetsData.basicBackground,
        key: const ValueKey('basic_bg'),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );

    // Precache pro background
    _proBg = RepaintBoundary(
      child: SvgPicture.asset(
        AssetsData.proBackground,
        key: const ValueKey('pro_bg'),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );

    // Precache elite background
    _eliteBg = RepaintBoundary(
      child: Image.asset(
        AssetsData.eliteBackgroundPng,
        key: const ValueKey('elite_bg'),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        cacheWidth: 1080, // Optimize memory
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PackagesCubit, PackagesState, SelectedPackage>(
      selector: (state) => state.selectedPackage,
      builder: (context, package) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _getBackground(package),
        );
      },
    );
  }

  Widget _getBackground(SelectedPackage package) {
    switch (package) {
      case SelectedPackage.basic:
        return _basicBg!;
      case SelectedPackage.pro:
        return _proBg!;
      case SelectedPackage.elite:
        return _eliteBg!;
    }
  }
}

class _PackageDetailSwitcher extends StatelessWidget {
  const _PackageDetailSwitcher();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PackagesCubit, PackagesState>(
      buildWhen: (prev, curr) =>
          prev.selectedPackage != curr.selectedPackage ||
          prev.packages != curr.packages,
      builder: (context, state) {
        final package = _getPackageData(
          context,
          state.selectedPackage,
          state.packages,
        );
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: RepaintBoundary(
            key: ValueKey(package.id),
            child: _PackageDetailContent(
              package: package,
              selected: state.selectedPackage,
            ),
          ),
        );
      },
    );
  }
}

class _PackageDetailContent extends StatelessWidget {
  final PackageModel package;
  final SelectedPackage selected;

  const _PackageDetailContent({required this.package, required this.selected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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

  Widget _buildTitle(
    BuildContext context,
    PackageModel package,
    SelectedPackage selected,
  ) {
    if (selected == SelectedPackage.elite) {
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
      return Text(
        package.packageTitle,
        textAlign: TextAlign.center,
        style: Styles.textStyle24Meduim.copyWith(color: AppColors.secondary800),
      );
    } else {
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
}

class _TabSelectorSection extends StatelessWidget {
  const _TabSelectorSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PackagesCubit, PackagesState, SelectedPackage>(
      selector: (state) => state.selectedPackage,
      builder: (context, selectedPackage) {
        return PackagesTabSelector(
          selectedPackage: selectedPackage,
          onSelected: (pkg) => context.read<PackagesCubit>().selectPackage(pkg),
        );
      },
    );
  }
}

class _BottomActionsSection extends StatelessWidget {
  const _BottomActionsSection();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PackagesCubit, PackagesState, SelectedPackage>(
      selector: (state) => state.selectedPackage,
      builder: (context, selectedPackage) {
        return _buildBottomActions(context, selectedPackage);
      },
    );
  }
}

class _KingIconOverlay extends StatelessWidget {
  const _KingIconOverlay();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PackagesCubit, PackagesState, SelectedPackage>(
      selector: (state) => state.selectedPackage,
      builder: (context, selectedPackage) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: selectedPackage == SelectedPackage.elite ? 1.0 : 0.0,
          child: selectedPackage == SelectedPackage.elite
              ? RepaintBoundary(
                  child: Transform.flip(
                    flipX: isArabic ? false : true,
                    child: SvgPicture.asset(AssetsData.kingIcon, height: 80.h),
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}

Widget _buildBottomActions(BuildContext context, SelectedPackage selected) {
  String buttonText;
  List<Color> gradientColors;
  final bool isElite = selected == SelectedPackage.elite;
  final bool gulf = isGulfGroup();
  final String currency = getCurrency();

  if (selected == SelectedPackage.basic) {
    buttonText = context.tr('continue_limited_account');
    gradientColors = [AppColors.primary300, AppColors.primary500];
  } else if (selected == SelectedPackage.pro) {
    final price = gulf ? "200" : "40";
    buttonText = context
        .tr('get_all_benefits_for')
        .replaceFirst('{}', price)
        .replaceFirst('{currency}', currency);
    gradientColors = [const Color(0xFFBD8F14), const Color(0xFFF5C003)];
  } else {
    final price = gulf ? "399" : "80";
    buttonText = context
        .tr('subscribe_vip_for')
        .replaceFirst('{}', price)
        .replaceFirst('{currency}', currency);
    gradientColors = [const Color(0xFF4BB8F9), const Color(0xFF6284FF)];
  }

  // basic & elite: top→bottom gradient. pro: right→left
  final bool isVertical = selected == SelectedPackage.basic || isElite;

  return Center(
    child: Container(
      width: 360.w,
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
          if (selected == SelectedPackage.basic) {
            Navigator.pop(context);
          } else {
            Navigator.pushNamed(
              context,
              AppRouter.kAdvisorSubscriptionView,
              arguments: selected,
            );
          }
        },
        child: Text(
          buttonText,
          style: Styles.textStyle18SemiBold.copyWith(color: Colors.white),
        ),
      ),
    ),
  );
}

PackageModel _getPackageData(
  BuildContext context,
  SelectedPackage pkg,
  List<AdvisorPackageModel> apiPackages,
) {
  final bool gulf = isGulfGroup();
  final String currency = getCurrency();

  // Map API package by type
  final typeStr = pkg == SelectedPackage.elite
      ? 'elite'
      : pkg == SelectedPackage.pro
      ? 'pro'
      : 'Free';

  final apiPkg = apiPackages.isEmpty
      ? null
      : apiPackages.firstWhere(
          (e) => e.type.toLowerCase() == typeStr.toLowerCase(),
          orElse: () => apiPackages.first,
        );

  if (pkg == SelectedPackage.basic) {
    final price = gulf ? "0" : "0";
    return PackageModel(
      id: 'basic',
      packageTitle: context.tr(apiPkg?.name ?? 'basic_plan_title'),
      price: '$price $currency',
      buttonText: context.tr('continue_limited_account'),
      themeColor: AppColors.primary500,
      backgroundGradient: [const Color(0xFFFFFFFF), const Color(0xFFFDE9ED)],
      features: [
        PackageFeatureModel(
          title: context.tr('8_session_monthly'),
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
          title: context.tr('1_boost_monthly'),
          iconPath: AssetsData.oneBoost,
        ),
        PackageFeatureModel(
          title: context.tr('basic_support'),
          iconPath: AssetsData.essentialSupport,
        ),
      ],
    );
  } else if (pkg == SelectedPackage.pro) {
    final price = apiPkg != null
        ? (gulf ? apiPkg.sarPrice.toString() : apiPkg.egPrice.toString())
        : (gulf ? "200" : "40");

    return PackageModel(
      id: 'pro',
      packageTitle: context.tr('enjoy_more_benefits'),
      price: '$price $currency',
      buttonText: context
          .tr('get_all_benefits_for')
          .replaceFirst('{}', price)
          .replaceFirst('{currency}', currency),
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
          iconPath: AssetsData.graySessionIcon,
        ),
      ],
    );
  } else {
    final price = apiPkg != null
        ? (gulf ? apiPkg.sarPrice.toString() : apiPkg.egPrice.toString())
        : (gulf ? "399" : "80");

    return PackageModel(
      id: 'elite',
      packageTitle: context.tr('enjoy_more_benefits'),
      price: '$price $currency',
      buttonText: context
          .tr('subscribe_vip_for')
          .replaceFirst('{}', price)
          .replaceFirst('{currency}', currency),
      themeColor: const Color(0xFF4BB8F9),
      backgroundGradient: [const Color(0xFFFFFFFF), const Color(0xFFE5F1FF)],
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
          title: context.tr('توثيق رسمى كامل'),
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
          iconPath: AssetsData.performanceReports,
        ),
        PackageFeatureModel(
          title: context.tr('who_visited_profile_action'),
          iconPath: AssetsData.normalApperance,
        ),
      ],
    );
  }
}
