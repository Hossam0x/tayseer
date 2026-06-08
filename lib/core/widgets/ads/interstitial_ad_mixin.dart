// lib/core/widgets/ads/interstitial_ad_mixin.dart
//
// Mixin for StatefulWidgets that need to show a full-screen interstitial at a
// natural transition point (session ends, booking confirmed, etc.).
//
// Usage:
//   class _MyState extends State<MyScreen> with InterstitialAdMixin {
//     void _onDone() async {
//       await showInterstitialAd();  // overlay → AdMob full-screen
//     }
//   }

import 'package:tayseer/core/services/ad_service.dart';
import 'package:tayseer/core/widgets/ads/ad_theme.dart';
import 'package:tayseer/core/widgets/ads/interstitial_loading_overlay.dart';
import 'package:tayseer/my_import.dart';

mixin InterstitialAdMixin<T extends StatefulWidget> on State<T> {
  /// Shows the branded overlay (500 ms) then the AdMob interstitial.
  /// No-ops silently when ads are suppressed or the kill-switch is off.
  Future<void> showInterstitialAd({
    AdTheme? adTheme,
    String? overlayMessage,
  }) async {
    final adService = getIt<AdService>();
    if (adService.shouldSuppressAds) return;
    if (!mounted) return;

    final msg = overlayMessage ?? context.tr('ads.loading');
    await InterstitialLoadingOverlay.show(
      context,
      adTheme: adTheme,
      message: msg,
      duration: const Duration(milliseconds: 500),
    );

    await adService.showInterstitial();
  }

  /// Warms up the interstitial cache on the screen *before* the transition
  /// point so the ad is ready when needed.
  void preloadNextInterstitial() => getIt<AdService>().preloadInterstitial();
}
