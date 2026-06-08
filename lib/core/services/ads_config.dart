// lib/core/services/ads_config.dart
//
// Remote kill switch for ads.
// ─────────────────────────────────────────────────────────────────────────────
// Reads/writes flags from SharedPreferences so the backend (or your remote
// config layer) can disable ads at runtime without a new release.
//
// Usage from your API / remote config handler:
//   await AdsConfig.instance.setAdsEnabled(false);        // kill all ads
//   await AdsConfig.instance.setBannersEnabled(false);     // kill banners only
//   AdsConfig.instance.bannersEnabled;                     // synchronous read

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences keys
const _kAdsEnabled = 'ads_enabled';
const _kBannersEnabled = 'ads_banners_enabled';
const _kInterstitialsEnabled = 'ads_interstitials_enabled';
const _kRewardedEnabled = 'ads_rewarded_enabled';
const _kNativeEnabled = 'ads_native_enabled';

class AdsConfig {
  AdsConfig._();
  static final AdsConfig instance = AdsConfig._();

  // ── In-memory cache (sync reads, no await required in hot paths) ──────────
  bool _adsEnabled = true;
  bool _bannersEnabled = true;
  bool _interstitialsEnabled = true;
  bool _rewardedEnabled = true;
  bool _nativeEnabled = true;

  // ── Public getters ─────────────────────────────────────────────────────────

  /// Master switch — false means ALL ad types are disabled.
  bool get adsEnabled => _adsEnabled;

  bool get bannersEnabled => _adsEnabled && _bannersEnabled;
  bool get interstitialsEnabled => _adsEnabled && _interstitialsEnabled;
  bool get rewardedEnabled => _adsEnabled && _rewardedEnabled;
  bool get nativeEnabled => _adsEnabled && _nativeEnabled;

  // ── Init — call once at startup after setupGetIt ───────────────────────────

  /// Loads persisted flags into memory. Non-blocking; safe to await in main().
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _adsEnabled = prefs.getBool(_kAdsEnabled) ?? true;
      _bannersEnabled = prefs.getBool(_kBannersEnabled) ?? true;
      _interstitialsEnabled = prefs.getBool(_kInterstitialsEnabled) ?? true;
      _rewardedEnabled = prefs.getBool(_kRewardedEnabled) ?? true;
      _nativeEnabled = prefs.getBool(_kNativeEnabled) ?? true;
      debugPrint(
        '📢 AdsConfig loaded — '
        'adsEnabled=$_adsEnabled | '
        'banners=$_bannersEnabled | '
        'interstitials=$_interstitialsEnabled | '
        'rewarded=$_rewardedEnabled | '
        'native=$_nativeEnabled',
      );
    } catch (e) {
      debugPrint('⚠️ AdsConfig.load error: $e — using defaults');
    }
  }

  // ── Runtime setters (called from API/remote config response) ──────────────

  /// Master toggle. Setting to false suppresses every ad type immediately.
  Future<void> setAdsEnabled(bool value) async {
    _adsEnabled = value;
    await _persist(_kAdsEnabled, value);
    debugPrint('📢 AdsConfig: adsEnabled → $value');
  }

  Future<void> setBannersEnabled(bool value) async {
    _bannersEnabled = value;
    await _persist(_kBannersEnabled, value);
  }

  Future<void> setInterstitialsEnabled(bool value) async {
    _interstitialsEnabled = value;
    await _persist(_kInterstitialsEnabled, value);
  }

  Future<void> setRewardedEnabled(bool value) async {
    _rewardedEnabled = value;
    await _persist(_kRewardedEnabled, value);
  }

  Future<void> setNativeEnabled(bool value) async {
    _nativeEnabled = value;
    await _persist(_kNativeEnabled, value);
  }

  /// Convenience: apply a full config map received from the server.
  ///
  /// Example server payload:
  /// ```json
  /// { "ads_enabled": true, "banners": true, "interstitials": false }
  /// ```
  Future<void> applyServerConfig(Map<String, dynamic> config) async {
    if (config.containsKey('ads_enabled')) {
      await setAdsEnabled(config['ads_enabled'] as bool);
    }
    if (config.containsKey('banners')) {
      await setBannersEnabled(config['banners'] as bool);
    }
    if (config.containsKey('interstitials')) {
      await setInterstitialsEnabled(config['interstitials'] as bool);
    }
    if (config.containsKey('rewarded')) {
      await setRewardedEnabled(config['rewarded'] as bool);
    }
    if (config.containsKey('native')) {
      await setNativeEnabled(config['native'] as bool);
    }
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _persist(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('⚠️ AdsConfig._persist error: $e');
    }
  }
}
