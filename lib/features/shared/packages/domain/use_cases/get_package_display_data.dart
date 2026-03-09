import 'package:flutter/material.dart';
import 'package:tayseer/core/functions/country_helper.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/features/advisor/settings/data/models/package_model.dart'
    hide PackageFeatureModel;
import 'package:tayseer/features/shared/packages/data/models/package_display_model.dart';
import 'package:tayseer/features/shared/packages/data/models/package_feature_model.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';

class GetPackageDisplayData {
  PackageDisplayModel call({
    required BuildContext context,
    required PackageType packageType,
    required List<AdvisorPackageModel> apiPackages,
  }) {
    final bool gulf = isGulfGroup();
    final String currency = getCurrency();

    final apiPkg = _findApiPackage(apiPackages, packageType);

    switch (packageType) {
      case PackageType.basic:
        return _getBasicPackage(context, currency, gulf, apiPkg);
      case PackageType.pro:
        return _getProPackage(context, currency, gulf, apiPkg);
      case PackageType.elite:
        return _getElitePackage(context, currency, gulf, apiPkg);
    }
  }

  AdvisorPackageModel? _findApiPackage(
    List<AdvisorPackageModel> packages,
    PackageType type,
  ) {
    if (packages.isEmpty) return null;
    try {
      return packages.firstWhere(
        (e) => e.type.toLowerCase() == type.apiType.toLowerCase(),
      );
    } catch (_) {
      return packages.first;
    }
  }

  PackageDisplayModel _getBasicPackage(
    BuildContext context,
    String currency,
    bool gulf,
    AdvisorPackageModel? apiPkg,
  ) {
    final price = gulf ? "0" : "0";
    return PackageDisplayModel(
      id: 'basic',
      packageTitle: context.tr(apiPkg?.name ?? 'basic_plan_title'),
      price: '$price $currency',
      buttonText: context.tr('continue_limited_account'),
      themeColor: AppColors.primary500,
      backgroundGradient: const [Color(0xFFFFFFFF), Color(0xFFFDE9ED)],
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
  }

  PackageDisplayModel _getProPackage(
    BuildContext context,
    String currency,
    bool gulf,
    AdvisorPackageModel? apiPkg,
  ) {
    final price = apiPkg != null
        ? (gulf ? apiPkg.sarPrice.toString() : apiPkg.egPrice.toString())
        : (gulf ? "200" : "40");

    return PackageDisplayModel(
      id: 'pro',
      packageTitle: context.tr('enjoy_more_benefits'),
      price: '$price $currency',
      buttonText: context
          .tr('get_all_benefits_for')
          .replaceFirst('{}', price)
          .replaceFirst('{currency}', currency),
      themeColor: const Color(0xFFCF9916),
      backgroundGradient: const [Color(0xFFFFFFFF), Color(0xFFFFF8E5)],
      features: [
        PackageFeatureModel(
          title: context.tr('20_messages_monthly'),
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
          title: context.tr('20_sessions_monthly'),
          iconPath: AssetsData.graySessionIcon,
        ),
      ],
    );
  }

  PackageDisplayModel _getElitePackage(
    BuildContext context,
    String currency,
    bool gulf,
    AdvisorPackageModel? apiPkg,
  ) {
    final price = apiPkg != null
        ? (gulf ? apiPkg.sarPrice.toString() : apiPkg.egPrice.toString())
        : (gulf ? "399" : "80");

    return PackageDisplayModel(
      id: 'elite',
      packageTitle: context.tr('enjoy_more_benefits'),
      price: '$price $currency',
      buttonText: context
          .tr('subscribe_vip_for')
          .replaceFirst('{}', price)
          .replaceFirst('{currency}', currency),
      themeColor: const Color(0xFF4BB8F9),
      backgroundGradient: const [Color(0xFFFFFFFF), Color(0xFFE5F1FF)],
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
