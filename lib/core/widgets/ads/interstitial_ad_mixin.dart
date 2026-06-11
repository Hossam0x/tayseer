// lib/core/widgets/ads/interstitial_ad_mixin.dart
// ⚠️ ADS TEMPORARILY DISABLED — uncomment when Google Ads account is ready.

// import 'package:tayseer/core/services/ad_service.dart';
// import 'package:tayseer/core/widgets/ads/ad_theme.dart';
// import 'package:tayseer/core/widgets/ads/interstitial_loading_overlay.dart';
// import 'package:tayseer/my_import.dart';

import 'package:flutter/widgets.dart';
import 'package:tayseer/core/widgets/ads/ad_theme.dart';

mixin InterstitialAdMixin<T extends StatefulWidget> on State<T> {
  /// No-op while ads are disabled.
  Future<void> showInterstitialAd({
    AdTheme? adTheme,
    String? overlayMessage,
  }) async {}

  /// No-op while ads are disabled.
  void preloadNextInterstitial() {}
}
