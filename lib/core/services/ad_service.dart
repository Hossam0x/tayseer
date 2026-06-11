// lib/core/services/ad_service.dart
// ⚠️ ADS TEMPORARILY DISABLED — uncomment when Google Ads account is ready.
//
// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:tayseer/core/constant/constans.dart';
// import 'package:tayseer/core/services/ads_config.dart';

// Stub class — keeps all call-sites compiling without any ad SDK.
class AdService {
  AdService._();
  factory AdService.create() => AdService._();

  bool get shouldSuppressAds => true;
  bool get canShowBanner => false;
  bool get canShowNative => false;
  bool get canShowRewarded => false;

  Future<void> initialize() async {}
  void debugAdState() {}
  void dispose() {}

  Future<void> setAdsEnabled(bool value) async {}
  Future<void> setBannersEnabled(bool value) async {}
  Future<void> setInterstitialsEnabled(bool value) async {}
  Future<void> setRewardedEnabled(bool value) async {}
  Future<void> setNativeEnabled(bool value) async {}

  void preloadInterstitial() {}
  void preloadRewarded() {}
  Future<bool> showInterstitial() async => false;
  Future<bool> showRewarded({
    required void Function(dynamic) onRewarded,
  }) async => false;

  // ignore: avoid_returning_null
  dynamic createBannerAd({dynamic size}) => null;
  // ignore: avoid_returning_null
  dynamic createNativeAd({String factoryId = 'listTile', dynamic listener}) =>
      null;
}
