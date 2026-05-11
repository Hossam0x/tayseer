import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppsFlyerService {
  AppsFlyerService._();
  static final AppsFlyerService instance = AppsFlyerService._();

  late AppsflyerSdk _sdk;
  bool _initialized = false;

  static String get _devKey => dotenv.env['APPSFLYER_DEV_KEY'] ?? '';
  static String get _appId => dotenv.env['APPSFLYER_IOS_APP_ID'] ?? '';

  /// true  → sandbox (debug builds / testing)
  /// false → production (release builds)
  static bool get _isSandbox {
    final env = dotenv.env['APPSFLYER_ENV'] ?? 'sandbox';
    return env.toLowerCase() == 'sandbox';
  }

  Future<void> initialize() async {
    if (_initialized) return;

    if (_devKey.isEmpty) {
      debugPrint(
        '⚠️ AppsFlyer: APPSFLYER_DEV_KEY missing in .env — skipping init',
      );
      return;
    }

    final bool showDebugLogs = kDebugMode || _isSandbox;

    final AppsFlyerOptions options = AppsFlyerOptions(
      afDevKey: _devKey,
      appId: _appId,
      // sandbox → showDebug: true  (logs كاملة في الـ console)
      // production → showDebug: false (لا logs في الـ release)
      showDebug: showDebugLogs,
      // ✅ 0 لأننا طلبنا ATT يدوياً في main.dart قبل استدعاء initialize()
      timeToWaitForATTUserAuthorization: 0,
      manualStart: false,
    );

    _sdk = AppsflyerSdk(options);

    debugPrint(
      '🔧 AppsFlyer env: ${_isSandbox ? "SANDBOX" : "PRODUCTION"} | '
      'debug=$showDebugLogs',
    );

    // ─── ✅ الـ callbacks لازم تتسجل قبل initSdk ───────────────────────────

    _sdk.onInstallConversionData((data) {
      debugPrint('📊 AF Conversion Data: $data');
    });

    _sdk.onAppOpenAttribution((data) {
      debugPrint('🔗 AF App Open Attribution: $data');
    });

    _sdk.onDeepLinking((DeepLinkResult result) {
      if (result.status == Status.FOUND) {
        debugPrint('🔗 AF UDL Found: ${result.deepLink}');
      } else if (result.status == Status.ERROR) {
        debugPrint('❌ AF UDL Error: ${result.error}');
      }
    });

    // ─── ✅ initSdk بعد تسجيل الـ callbacks ──────────────────────────────
    await _sdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    _sdk.startSDK(
      onSuccess: () {
        debugPrint(
          '✅ AppsFlyer SDK started (${_isSandbox ? "SANDBOX" : "PRODUCTION"})',
        );
      },
      onError: (int code, String message) {
        debugPrint('❌ AppsFlyer SDK start error: [$code] $message');
      },
    );

    _initialized = true;
    debugPrint('✅ AppsFlyer SDK v6.17.9+1 initialized');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // In-App Events
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logEvent(String eventName, Map<String, dynamic> params) async {
    if (!_initialized) return;
    try {
      final result = await _sdk.logEvent(eventName, params);
      debugPrint('📊 AF Event [$eventName]: result=$result | params=$params');
    } catch (e) {
      debugPrint('❌ AF logEvent error: $e');
    }
  }

  // ─── أحداث Tayseer ────────────────────────────────────────────────────────

  Future<void> logCompleteRegistration({
    required String method, // 'email' | 'google' | 'apple'
    required String userType, // 'user'  | 'advisor'
  }) async {
    await logEvent('af_complete_registration', {
      'af_registration_method': method,
      'user_type': userType,
    });
  }

  Future<void> logLogin({required String method}) async {
    await logEvent('af_login', {'af_registration_method': method});
  }

  Future<void> logBookSession({
    required String advisorId,
    required String sessionType,
    required double price,
    required String currency,
  }) async {
    await logEvent('book_session', {
      'advisor_id': advisorId,
      'session_type': sessionType,
      'af_price': price,
      'af_currency': currency,
    });
  }

  Future<void> logPurchase({
    required double revenue,
    required String currency,
    required String contentType,
    String? contentId,
  }) async {
    await logEvent('af_purchase', {
      'af_revenue': revenue,
      'af_currency': currency,
      'af_content_type': contentType,
      if (contentId != null) 'af_content_id': contentId,
    });
  }

  Future<void> logViewAdvisorProfile({required String advisorId}) async {
    await logEvent('af_content_view', {
      'af_content_id': advisorId,
      'af_content_type': 'advisor_profile',
    });
  }

  Future<void> logSendMessage({required String sessionType}) async {
    await logEvent('send_message', {'session_type': sessionType});
  }

  Future<void> logActivateBoost({
    required double price,
    required String currency,
  }) async {
    await logEvent('activate_boost', {
      'af_price': price,
      'af_currency': currency,
    });
  }

  Future<void> logRateAdvisor({
    required String advisorId,
    required double rating,
  }) async {
    await logEvent('af_rate', {
      'af_content_id': advisorId,
      'af_rating': rating,
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // User Identity
  // ─────────────────────────────────────────────────────────────────────────

  void setCustomerUserId(String userId) {
    if (!_initialized) return;
    _sdk.setCustomerUserId(userId);
    debugPrint('✅ AF Customer User ID set: $userId');
  }

  void clearCustomerUserId() {
    if (!_initialized) return;
    _sdk.setCustomerUserId('');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Privacy
  // ─────────────────────────────────────────────────────────────────────────

  void stopTracking(bool isStopped) {
    if (!_initialized) return;
    _sdk.stop(isStopped);
    debugPrint('⚠️ AF tracking stopped: $isStopped');
  }
}
