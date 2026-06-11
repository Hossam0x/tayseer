// lib/core/services/ads_config.dart
// ⚠️ ADS TEMPORARILY DISABLED — uncomment when Google Ads account is ready.
//
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// Stub class — keeps all call-sites compiling without any ad SDK.
class AdsConfig {
  AdsConfig._();
  static final AdsConfig instance = AdsConfig._();

  bool get adsEnabled => false;
  bool get bannersEnabled => false;
  bool get interstitialsEnabled => false;
  bool get rewardedEnabled => false;
  bool get nativeEnabled => false;

  Future<void> load() async {}
  Future<void> setAdsEnabled(bool value) async {}
  Future<void> setBannersEnabled(bool value) async {}
  Future<void> setInterstitialsEnabled(bool value) async {}
  Future<void> setRewardedEnabled(bool value) async {}
  Future<void> setNativeEnabled(bool value) async {}
  Future<void> applyServerConfig(Map<String, dynamic> config) async {}
}
