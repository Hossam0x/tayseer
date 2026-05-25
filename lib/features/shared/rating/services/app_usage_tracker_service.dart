import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayseer/features/shared/rating/constants/rating_constants.dart';

/// Tracks app launch count and cumulative usage time via [WidgetsBindingObserver].
///
/// Call [onAppLaunch] once at startup (e.g. in SplashScreen.initState).
/// The observer handles foreground/background transitions automatically.
class AppUsageTrackerService with WidgetsBindingObserver {
  AppUsageTrackerService._();
  static final AppUsageTrackerService instance = AppUsageTrackerService._();

  DateTime? _sessionStart;
  bool _observing = false;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Call once when the app starts (after the user is authenticated).
  Future<void> onAppLaunch() async {
    _startSession();
    await _incrementLaunchCount();
    if (!_observing) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
    }
  }

  /// Stop observing (call on logout / app dispose if needed).
  void dispose() {
    if (_observing) {
      WidgetsBinding.instance.removeObserver(this);
      _observing = false;
    }
  }

  // ── WidgetsBindingObserver ────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _startSession();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _endSession();
        break;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _startSession() {
    _sessionStart = DateTime.now();
  }

  Future<void> _endSession() async {
    if (_sessionStart == null) return;
    final elapsed = DateTime.now().difference(_sessionStart!).inSeconds;
    _sessionStart = null;
    if (elapsed <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(RatingConstants.kTotalUsageSeconds) ?? 0;
    await prefs.setInt(RatingConstants.kTotalUsageSeconds, current + elapsed);
  }

  Future<void> _incrementLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(RatingConstants.kLaunchCount) ?? 0) + 1;
    await prefs.setInt(RatingConstants.kLaunchCount, count);
  }

  // ── Read helpers (used by RatingService) ─────────────────────────────────

  Future<int> getLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(RatingConstants.kLaunchCount) ?? 0;
  }

  Future<int> getTotalUsageSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(RatingConstants.kTotalUsageSeconds) ?? 0;
  }
}
