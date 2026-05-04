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

  Future<void> initialize() async {
    if (_initialized) return;

    if (_devKey.isEmpty || _devKey == 'YOUR_APPSFLYER_DEV_KEY') {
      debugPrint(
        '⚠️ AppsFlyer: APPSFLYER_DEV_KEY missing in .env — skipping init',
      );
      return;
    }
    if (_appId.isEmpty || _appId == 'YOUR_IOS_APP_ID') {
      debugPrint(
        '⚠️ AppsFlyer: APPSFLYER_IOS_APP_ID missing in .env — skipping init',
      );
      return;
    }

    final AppsFlyerOptions options = AppsFlyerOptions(
      afDevKey: _devKey,
      appId: _appId,
      showDebug: kDebugMode,
      timeToWaitForATTUserAuthorization: 50,
      manualStart: false,
    );

    _sdk = AppsflyerSdk(options);

    await _sdk.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );

    _sdk.onInstallConversionData((data) {
      debugPrint('📊 AppsFlyer Conversion Data: $data');
      // data['status']       → 'Non-organic' أو 'Organic'
      // data['media_source'] → 'facebook_ads', 'googleadwords_int', etc.
      // data['campaign']     → اسم الـ campaign
    });

    // ─── Legacy Deep Link ─────────────────────────────────────────────────
    _sdk.onAppOpenAttribution((data) {
      debugPrint('🔗 AppsFlyer App Open Attribution: $data');
    });

    // ─── Unified Deep Link (UDL) ──────────────────────────────────────────
    _sdk.onDeepLinking((DeepLinkResult result) {
      if (result.status == Status.FOUND) {
        debugPrint('🔗 AppsFlyer UDL Found: ${result.deepLink}');
        // result.deepLink?.deepLinkValue
        // result.deepLink?.getStringValue('custom_param')
      } else if (result.status == Status.ERROR) {
        debugPrint('❌ AppsFlyer UDL Error: ${result.error}');
      }
    });

    _initialized = true;
    debugPrint('✅ AppsFlyer SDK v6.17.9+1 initialized');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // In-App Events
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logEvent(String eventName, Map<String, dynamic> params) async {
    if (!_initialized) return;
    try {
      await _sdk.logEvent(eventName, params);
      debugPrint('📊 AF Event: $eventName | $params');
    } catch (e) {
      debugPrint('❌ AF logEvent error: $e');
    }
  }

  // ─── أحداث Tayseer الجاهزة ────────────────────────────────────────────────

  /// تسجيل مستخدم جديد
  Future<void> logCompleteRegistration({
    required String method, // 'email' | 'google' | 'apple'
    required String userType, // 'user'  | 'advisor'
  }) async {
    await logEvent('af_complete_registration', {
      'af_registration_method': method,
      'user_type': userType,
    });
  }

  /// تسجيل دخول
  Future<void> logLogin({required String method}) async {
    await logEvent('af_login', {'af_registration_method': method});
  }

  /// حجز جلسة استشارة
  Future<void> logBookSession({
    required String advisorId,
    required String sessionType, // 'chat' | 'voice' | 'video'
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

  /// شراء رصيد أو اشتراك
  Future<void> logPurchase({
    required double revenue,
    required String currency,
    required String contentType, // 'credits' | 'subscription' | 'boost'
    String? contentId,
  }) async {
    await logEvent('af_purchase', {
      'af_revenue': revenue,
      'af_currency': currency,
      'af_content_type': contentType,
      if (contentId != null) 'af_content_id': contentId,
    });
  }

  /// مشاهدة ملف مستشار
  Future<void> logViewAdvisorProfile({required String advisorId}) async {
    await logEvent('af_content_view', {
      'af_content_id': advisorId,
      'af_content_type': 'advisor_profile',
    });
  }

  /// إرسال رسالة
  Future<void> logSendMessage({required String sessionType}) async {
    await logEvent('send_message', {'session_type': sessionType});
  }

  /// تفعيل Boost
  Future<void> logActivateBoost({
    required double price,
    required String currency,
  }) async {
    await logEvent('activate_boost', {
      'af_price': price,
      'af_currency': currency,
    });
  }

  /// تقييم مستشار
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

  /// ربط الـ AppsFlyer ID بـ User ID — استدعيها بعد تسجيل الدخول
  void setCustomerUserId(String userId) {
    if (!_initialized) return;
    _sdk.setCustomerUserId(userId);
    debugPrint('✅ AF Customer User ID: $userId');
  }

  /// مسح الـ User ID عند تسجيل الخروج
  void clearCustomerUserId() {
    if (!_initialized) return;
    _sdk.setCustomerUserId('');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Privacy
  // ─────────────────────────────────────────────────────────────────────────

  /// إيقاف الـ tracking (GDPR أو لو المستخدم رفض)
  void stopTracking(bool isStopped) {
    if (!_initialized) return;
    _sdk.stop(isStopped);
    debugPrint('⚠️ AF tracking stopped: $isStopped');
  }
}
