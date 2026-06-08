import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Describes which OTP screen was active when the app was backgrounded.
enum OtpScreenType {
  /// Registration / login email-OTP  →  AppRouter.kOtpView
  authOtp,

  /// Phone-number OTP inside the onboarding / questions flow
  /// →  AppRouter.kOtpPhoneUserQuestion
  phoneOtp,
}

/// Lightweight descriptor that is persisted to SharedPreferences so the app
/// can restore the correct OTP screen after process death.
class OtpResumptionContext {
  const OtpResumptionContext({
    required this.screenType,
    this.isOnboarding = false,
    this.isAdvisorFlow = false,
  });

  final OtpScreenType screenType;

  /// Relevant only for [OtpScreenType.phoneOtp]
  final bool isOnboarding;

  /// Relevant only for [OtpScreenType.phoneOtp]
  final bool isAdvisorFlow;
}

/// Persists and restores which OTP screen the user was on when the app was
/// backgrounded, so that after process death the [SplashScreen] can route
/// back to the right screen instead of running the normal auth flow.
///
/// ## Lifecycle contract (called by OTP screen widgets)
///
/// ```dart
/// // initState
/// OtpResumptionService.instance.save(OtpResumptionContext(...));
///
/// // dispose
/// OtpResumptionService.instance.clear();
/// ```
///
/// ## Splash contract
///
/// ```dart
/// final ctx = await OtpResumptionService.instance.load();
/// if (ctx != null) {
///   OtpResumptionService.instance.clear();
///   // navigate to ctx.screenType
/// }
/// ```
class OtpResumptionService {
  OtpResumptionService._();

  static final OtpResumptionService instance = OtpResumptionService._();

  // ── SharedPreferences keys (private, no collision with existing keys) ──
  static const _kScreen = '_otp_resume_screen';
  static const _kOnboarding = '_otp_resume_onboarding';
  static const _kAdvisorFlow = '_otp_resume_advisor_flow';

  // ── In-memory active count (survives soft resume / WidgetsBindingObserver) ──
  int _activeCount = 0;

  /// True when at least one OTP screen is currently mounted.
  /// Used by [SplashScreen] to skip navigation during soft-resume.
  bool get isActiveInMemory => _activeCount > 0;

  // ────────────────────────────────────────────────────────────────────────
  // Public API
  // ────────────────────────────────────────────────────────────────────────

  /// Persist [ctx] to SharedPreferences and increment the in-memory counter.
  /// Call this from an OTP screen's [State.initState].
  Future<void> save(OtpResumptionContext ctx) async {
    _activeCount++;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kScreen, ctx.screenType.name);
      await prefs.setBool(_kOnboarding, ctx.isOnboarding);
      await prefs.setBool(_kAdvisorFlow, ctx.isAdvisorFlow);
      debugPrint(
        '🛡️ OtpResumptionService: saved ${ctx.screenType.name} '
        '(onboarding=${ctx.isOnboarding}, advisorFlow=${ctx.isAdvisorFlow})',
      );
    } catch (e) {
      debugPrint('⚠️ OtpResumptionService: save failed — $e');
    }
  }

  /// Remove the persisted record and decrement the in-memory counter.
  /// Call this from an OTP screen's [State.dispose].
  Future<void> clear() async {
    if (_activeCount > 0) _activeCount--;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kScreen);
      await prefs.remove(_kOnboarding);
      await prefs.remove(_kAdvisorFlow);
      debugPrint('🛡️ OtpResumptionService: cleared');
    } catch (e) {
      debugPrint('⚠️ OtpResumptionService: clear failed — $e');
    }
  }

  /// Read the persisted record.  Returns `null` if nothing was saved.
  /// Does NOT clear the record — call [clear] explicitly after consuming.
  Future<OtpResumptionContext?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final screenName = prefs.getString(_kScreen);
      if (screenName == null) return null;

      final screenType = OtpScreenType.values.firstWhere(
        (e) => e.name == screenName,
        orElse: () => OtpScreenType.authOtp,
      );
      final isOnboarding = prefs.getBool(_kOnboarding) ?? false;
      final isAdvisorFlow = prefs.getBool(_kAdvisorFlow) ?? false;

      return OtpResumptionContext(
        screenType: screenType,
        isOnboarding: isOnboarding,
        isAdvisorFlow: isAdvisorFlow,
      );
    } catch (e) {
      debugPrint('⚠️ OtpResumptionService: load failed — $e');
      return null;
    }
  }
}
