// lib/core/services/ad_service.dart
//
// Central AdMob service — registered as a lazy singleton via GetIt.
// Handles SDK init, ad loading, caching, retry, role-based suppression,
// and remote kill-switch via AdsConfig.
//
// ⚠️ Ad Unit IDs:
//   - Debug builds use Google's official test IDs.
//   - Release builds use the placeholder IDs below — replace them with your
//     real AdMob unit IDs before publishing.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/services/ads_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Ad Unit IDs
// ─────────────────────────────────────────────────────────────────────────────

abstract class _AdUnitIds {
  // ── Android test IDs (debug) ──────────────────────────────────────────────
  static const String _androidTestBanner =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _androidTestRewarded =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _androidTestNative =
      'ca-app-pub-3940256099942544/2247696110';

  // ── iOS test IDs (debug) ──────────────────────────────────────────────────
  static const String _iosTestBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const String _iosTestInterstitial =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _iosTestRewarded =
      'ca-app-pub-3940256099942544/1712485313';
  static const String _iosTestNative = 'ca-app-pub-3940256099942544/3986624511';

  // ── Production IDs — ⚠️ Replace before release ───────────────────────────
  static const String _androidProdBanner =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _androidProdInterstitial =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _androidProdRewarded =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _androidProdNative =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';

  static const String _iosProdBanner = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _iosProdInterstitial =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _iosProdRewarded =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _iosProdNative = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';

  // ── Resolved (auto-select test vs prod, Android vs iOS) ──────────────────
  static String get banner => _isAndroid
      ? (kDebugMode ? _androidTestBanner : _androidProdBanner)
      : (kDebugMode ? _iosTestBanner : _iosProdBanner);

  static String get interstitial => _isAndroid
      ? (kDebugMode ? _androidTestInterstitial : _androidProdInterstitial)
      : (kDebugMode ? _iosTestInterstitial : _iosProdInterstitial);

  static String get rewarded => _isAndroid
      ? (kDebugMode ? _androidTestRewarded : _androidProdRewarded)
      : (kDebugMode ? _iosTestRewarded : _iosProdRewarded);

  static String get native => _isAndroid
      ? (kDebugMode ? _androidTestNative : _androidProdNative)
      : (kDebugMode ? _iosTestNative : _iosProdNative);

  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
}

// ─────────────────────────────────────────────────────────────────────────────
// AdService
// ─────────────────────────────────────────────────────────────────────────────

class AdService {
  AdService._();

  /// Factory constructor used by the DI layer (GetIt).
  factory AdService.create() => AdService._();

  bool _initialized = false;

  // Cached interstitial — preloaded for the next screen transition
  InterstitialAd? _cachedInterstitial;
  bool _loadingInterstitial = false;

  // Cached rewarded ad
  RewardedAd? _cachedRewarded;
  bool _loadingRewarded = false;

  // Frequency cap: max interstitials shown per app session
  int _interstitialShowCount = 0;
  static const int _maxInterstitialsPerSession = 5;

  // ── Kill switch passthrough ─────────────────────────────────────────────

  /// Delegates to [AdsConfig] — preferred way to toggle ads from a server
  /// response or feature flag.
  Future<void> setAdsEnabled(bool value) =>
      AdsConfig.instance.setAdsEnabled(value);

  Future<void> setBannersEnabled(bool value) =>
      AdsConfig.instance.setBannersEnabled(value);

  Future<void> setInterstitialsEnabled(bool value) =>
      AdsConfig.instance.setInterstitialsEnabled(value);

  Future<void> setRewardedEnabled(bool value) =>
      AdsConfig.instance.setRewardedEnabled(value);

  Future<void> setNativeEnabled(bool value) =>
      AdsConfig.instance.setNativeEnabled(value);

  // ── Role + config guard ─────────────────────────────────────────────────

  /// True when ALL ad types must be suppressed.
  /// Guests never see ads. Advisors see ads in shared screens (home, feed,
  /// stories) — only suppressed on their professional work screens.
  /// The work-screen guard is applied at the widget/screen level, not here.
  bool get shouldSuppressAds {
    if (isGuest) return true;
    return !AdsConfig.instance.adsEnabled;
  }

  bool get _canShowBanner =>
      !shouldSuppressAds && AdsConfig.instance.bannersEnabled;

  bool get _canShowInterstitial =>
      !shouldSuppressAds && AdsConfig.instance.interstitialsEnabled;

  bool get _canShowRewarded =>
      !shouldSuppressAds && AdsConfig.instance.rewardedEnabled;

  bool get _canShowNative =>
      !shouldSuppressAds && AdsConfig.instance.nativeEnabled;

  // ── SDK Init ────────────────────────────────────────────────────────────

  /// Call once from main() after [setupGetIt] and [AdsConfig.instance.load()].
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      // AdsConfig.load() is called in main() before this — no double-load.
      await MobileAds.instance.initialize();
      _initialized = true;
      debugPrint('✅ [AdService] SDK initialized successfully');
      debugPrint(
        '📢 [AdService] adsEnabled=${AdsConfig.instance.adsEnabled} '
        '| banners=${AdsConfig.instance.bannersEnabled} '
        '| interstitials=${AdsConfig.instance.interstitialsEnabled} '
        '| native=${AdsConfig.instance.nativeEnabled} '
        '| rewarded=${AdsConfig.instance.rewardedEnabled}',
      );
      debugPrint(
        '👤 [AdService] isUser=$isUser | isAdvisor=$isAdvisor | isGuest=$isGuest',
      );
      debugPrint('🛡️  [AdService] shouldSuppressAds=$shouldSuppressAds');
      if (_canShowInterstitial) preloadInterstitial();
      if (_canShowRewarded) preloadRewarded();
    } catch (e) {
      debugPrint('⚠️  [AdService] init error: $e');
    }
  }

  // ── Banner ──────────────────────────────────────────────────────────────

  /// Creates a new [BannerAd]. Caller is responsible for disposing it.
  /// Returns null when banners are disabled.
  BannerAd? createBannerAd({AdSize size = AdSize.banner}) {
    debugPrint(
      '🏷️  [AdService] createBannerAd → canShow=$_canShowBanner '
      '(suppress=$shouldSuppressAds, config=${AdsConfig.instance.bannersEnabled})',
    );
    if (!_canShowBanner) return null;
    return BannerAd(
      adUnitId: _AdUnitIds.banner,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => debugPrint('🟢 [AdService] Banner loaded'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('🔴 [AdService] Banner failed: $error');
          ad.dispose();
        },
      ),
    );
  }

  // ── Interstitial ────────────────────────────────────────────────────────

  /// Preloads an interstitial into the cache. No-op when disabled.
  void preloadInterstitial() {
    if (!_canShowInterstitial) return;
    if (_loadingInterstitial || _cachedInterstitial != null) return;

    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: _AdUnitIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _cachedInterstitial = ad;
          _loadingInterstitial = false;
          debugPrint('🟢 Interstitial preloaded');
        },
        onAdFailedToLoad: (error) {
          _loadingInterstitial = false;
          debugPrint(
            '🔴 Interstitial preload failed: $error — retrying in 30s',
          );
          Future.delayed(const Duration(seconds: 30), preloadInterstitial);
        },
      ),
    );
  }

  /// Shows the cached interstitial and immediately preloads the next one.
  /// Returns true if the ad was shown.
  Future<bool> showInterstitial() async {
    if (!_canShowInterstitial) return false;
    if (_interstitialShowCount >= _maxInterstitialsPerSession) return false;
    if (_cachedInterstitial == null) {
      preloadInterstitial();
      return false;
    }

    final ad = _cachedInterstitial!;
    _cachedInterstitial = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _interstitialShowCount++;
        debugPrint('🟢 Interstitial shown (#$_interstitialShowCount)');
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('🔴 Interstitial show failed: $error');
        ad.dispose();
        preloadInterstitial();
      },
    );

    await ad.show();
    return true;
  }

  // ── Rewarded ────────────────────────────────────────────────────────────

  /// Preloads a rewarded ad. No-op when disabled.
  void preloadRewarded() {
    if (!_canShowRewarded) return;
    if (_loadingRewarded || _cachedRewarded != null) return;

    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: _AdUnitIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _cachedRewarded = ad;
          _loadingRewarded = false;
          debugPrint('🟢 Rewarded ad preloaded');
        },
        onAdFailedToLoad: (error) {
          _loadingRewarded = false;
          debugPrint('🔴 Rewarded preload failed: $error — retrying in 30s');
          Future.delayed(const Duration(seconds: 30), preloadRewarded);
        },
      ),
    );
  }

  /// Shows the rewarded ad and invokes [onRewarded] on success.
  /// Returns true if the ad was shown.
  Future<bool> showRewarded({
    required void Function(RewardItem) onRewarded,
  }) async {
    if (!_canShowRewarded) return false;
    if (_cachedRewarded == null) {
      preloadRewarded();
      return false;
    }

    final ad = _cachedRewarded!;
    _cachedRewarded = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preloadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('🔴 Rewarded show failed: $error');
        ad.dispose();
        preloadRewarded();
      },
    );

    await ad.show(onUserEarnedReward: (_, reward) => onRewarded(reward));
    return true;
  }

  // ── Native ──────────────────────────────────────────────────────────────

  /// Creates a [NativeAd]. Returns null when native ads are disabled.
  /// Caller must dispose the returned ad when done.
  NativeAd? createNativeAd({
    String factoryId = 'listTile',
    NativeAdListener? listener,
  }) {
    debugPrint(
      '📰 [AdService] createNativeAd(factoryId=$factoryId) → '
      'canShow=$_canShowNative '
      '(suppress=$shouldSuppressAds, config=${AdsConfig.instance.nativeEnabled}) '
      '| initialized=$_initialized',
    );
    if (!_canShowNative) return null;
    return NativeAd(
      adUnitId: _AdUnitIds.native,
      factoryId: factoryId,
      request: const AdRequest(),
      listener:
          listener ??
          NativeAdListener(
            onAdLoaded: (_) => debugPrint('🟢 Native ad loaded'),
            onAdFailedToLoad: (ad, error) {
              debugPrint('🔴 Native ad failed: $error');
              ad.dispose();
            },
          ),
    );
  }

  // ── Convenience type-check (used by widgets) ────────────────────────────

  bool get canShowBanner => _canShowBanner;
  bool get canShowNative => _canShowNative;
  bool get canShowRewarded => _canShowRewarded;

  // ── Debug helper ─────────────────────────────────────────────────────────

  /// Call from anywhere to dump the full ad state to the debug console.
  /// Example: getIt<AdService>().debugAdState();
  void debugAdState() {
    debugPrint('══════════════════════════════════════════');
    debugPrint('📊 [AdService] DEBUG STATE');
    debugPrint('  initialized      : $_initialized');
    debugPrint('  isUser           : $isUser');
    debugPrint('  isAdvisor        : $isAdvisor');
    debugPrint('  isGuest          : $isGuest');
    debugPrint('  shouldSuppress   : $shouldSuppressAds');
    debugPrint('  adsEnabled       : ${AdsConfig.instance.adsEnabled}');
    debugPrint(
      '  bannersEnabled   : ${AdsConfig.instance.bannersEnabled}  → canShow: $_canShowBanner',
    );
    debugPrint(
      '  interstitials    : ${AdsConfig.instance.interstitialsEnabled} → canShow: $_canShowInterstitial',
    );
    debugPrint(
      '  rewardedEnabled  : ${AdsConfig.instance.rewardedEnabled} → canShow: $_canShowRewarded',
    );
    debugPrint(
      '  nativeEnabled    : ${AdsConfig.instance.nativeEnabled}   → canShow: $_canShowNative',
    );
    debugPrint('  cachedInterstitial: ${_cachedInterstitial != null}');
    debugPrint('  cachedRewarded   : ${_cachedRewarded != null}');
    debugPrint(
      '  interstitialCount: $_interstitialShowCount / $_maxInterstitialsPerSession',
    );
    debugPrint('══════════════════════════════════════════');
  }

  // ── Contextual ad factory ────────────────────────────────────────────────

  /// Convenience documentation anchor.
  /// In your widget tree use [NativeAdWidget] directly:
  ///
  ///   NativeAdWidget(adContext: AdContext.post)
  ///   NativeAdWidget(adContext: AdContext.profileCard)
  ///   NativeAdWidget(adContext: AdContext.story)
  ///   NativeAdWidget(adContext: AdContext.listItem)  // default
  ///
  /// Each value maps to a factory ID registered on both native platforms.

  // ── Disposal ─────────────────────────────────────────────────────────────

  void dispose() {
    _cachedInterstitial?.dispose();
    _cachedInterstitial = null;
    _cachedRewarded?.dispose();
    _cachedRewarded = null;
  }
}
