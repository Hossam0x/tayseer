import 'package:flutter/material.dart';
import 'package:tayseer/core/functions/country_helper.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';
import 'package:tayseer/features/shared/packages/data/models/package_display_model.dart';
import 'package:tayseer/features/shared/packages/data/models/package_feature_model.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';

class GetPackageDisplayData {
  PackageDisplayModel call({
    required BuildContext context,
    required PackageType packageType,
    required List<NewAdvisorSubModel> apiPackages,
  }) {
    final bool gulf = isGulfGroup();
    final String currency = getCurrency();
    final apiSub = _findApiSub(apiPackages, packageType);

    switch (packageType) {
      case PackageType.basic:
        return _getBasicPackage(context, currency, gulf);
      case PackageType.pro:
        return _getProPackage(context, currency, gulf, apiSub);
      case PackageType.elite:
        return _getElitePackage(context, currency, gulf, apiSub);
    }
  }

  NewAdvisorSubModel? _findApiSub(
    List<NewAdvisorSubModel> subs,
    PackageType type,
  ) {
    if (subs.isEmpty || type == PackageType.basic) return null;
    final targetType = type == PackageType.pro ? 'gold' : 'ultra';
    try {
      return subs.firstWhere(
        (e) => e.subscriptionType == targetType && e.isMonthly,
        orElse: () => subs.firstWhere((e) => e.subscriptionType == targetType),
      );
    } catch (_) {
      return null;
    }
  }

  PackageDisplayModel _getBasicPackage(
    BuildContext context,
    String currency,
    bool gulf,
  ) {
    return PackageDisplayModel(
      id: 'basic',
      packageTitle: context.tr('basic_plan_title'),
      price: '0 $currency',
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
    NewAdvisorSubModel? apiSub,
  ) {
    final price = apiSub?.price?.toString() ?? (gulf ? '200' : '40');
    final sessions = apiSub?.numberOfSessions == -1
        ? context.tr('unlimited_sessions')
        : context.tr('20_sessions_monthly');
    final chats = apiSub?.numberOfChatRooms == -1
        ? context.tr('unlimited_messages')
        : context.tr('20_messages_monthly');
    final boosts = apiSub?.numberOfMonthlyReinforcements.toString() ?? '4';
    final events = apiSub?.numberOfMonthlyEvents.toString() ?? '1';

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
        PackageFeatureModel(title: chats, iconPath: AssetsData.threeMessages),
        PackageFeatureModel(
          title: '$events ${context.tr('event_monthly')}',
          iconPath: AssetsData.noEvents,
        ),
        PackageFeatureModel(
          title: context.tr('basic_stats'),
          iconPath: AssetsData.essentialStats,
        ),
        PackageFeatureModel(
          title: '$boosts ${context.tr('boosts_monthly')}',
          iconPath: AssetsData.oneBoost,
        ),
        PackageFeatureModel(
          title: sessions,
          iconPath: AssetsData.graySessionIcon,
        ),
      ],
    );
  }

  PackageDisplayModel _getElitePackage(
    BuildContext context,
    String currency,
    bool gulf,
    NewAdvisorSubModel? apiSub,
  ) {
    final price = apiSub?.price?.toString() ?? (gulf ? '399' : '80');
    final sessions = apiSub?.numberOfSessions == -1
        ? context.tr('unlimited_sessions')
        : context.tr('unlimited_sessions');
    final chats = apiSub?.numberOfChatRooms == -1
        ? context.tr('unlimited_messages')
        : context.tr('unlimited_messages');
    final boosts = apiSub?.numberOfMonthlyReinforcements.toString() ?? '10';
    final events = apiSub?.numberOfMonthlyEvents.toString() ?? '1';

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
        PackageFeatureModel(title: chats, iconPath: AssetsData.threeMessages),
        PackageFeatureModel(
          title: '$boosts ${context.tr('boosts_monthly')}',
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
          title: sessions,
          iconPath: AssetsData.eightSessionMonthIcon,
        ),
        PackageFeatureModel(
          title: context.tr('advanced_performance_reports'),
          iconPath: AssetsData.performanceReports,
        ),
        PackageFeatureModel(
          title: '$events ${context.tr('event_monthly')}',
          iconPath: AssetsData.noEvents,
        ),
        PackageFeatureModel(
          title: context.tr('who_visited_profile_action'),
          iconPath: AssetsData.normalApperance,
        ),
      ],
    );
  }
}
