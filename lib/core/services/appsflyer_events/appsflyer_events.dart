import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:tayseer/core/constant/constans.dart';

import '../appsflyer_service.dart';

/// All AppsFlyer in-app events for Tayseer.
///
/// Each method maps to a single tracked event.
/// Add new events here — never directly in [AppsFlyerService].
///
/// Every event automatically includes [_globalParams] (gender, platform,
/// language, app_version, user_type).  Pass event-specific params on top.
class AppsFlyerEvents {
  AppsFlyerEvents._();

  static final _af = AppsFlyerService.instance;

  // ─────────────────────────────────────────────────────────────────────────
  // Global Parameters — merged into every event automatically
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns the standard params that must accompany every event.
  ///
  /// Keys:
  ///   gender        → male / female / unknown
  ///   platform      → ios / android
  ///   language      → ar / en / …
  ///   app_version   → e.g. 1.4.4
  ///   user_type     → user / advisor / guest
  static Future<Map<String, dynamic>> _globalParams() async {
    String appVersion = '';
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = info.version;
    } catch (_) {}

    return {
      'gender': kCurrentUserData?.gender ?? 'unknown',
      'platform': Platform.isIOS ? 'ios' : 'android',
      'language': selectedLanguage ?? 'ar',
      'app_version': appVersion,
      'user_type': selectedUserType?.name ?? 'unknown',
    };
  }

  /// Merges [eventParams] on top of [_globalParams] then fires the event.
  static Future<void> _log(
    String eventName, [
    Map<String, dynamic> eventParams = const {},
  ]) async {
    final global = await _globalParams();
    await _af.logEvent(eventName, {...global, ...eventParams});
  }

  // ─────────────────────────────────────────────────────────────────────────
  // App Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  /// Fired once on the very first app open (after install).
  /// Called from SplashScreen — guarded by a SharedPreferences flag.
  static Future<void> firstOpen() async {
    await _log('first_open');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Registration & Onboarding Funnel
  // ─────────────────────────────────────────────────────────────────────────

  /// User landed on the registration screen and started the signup flow.
  /// Use to measure drop-off between ad click → signup start.
  ///
  /// [method] → 'email' | 'google' | 'apple'
  static Future<void> signupStarted({required String method}) async {
    await _log('signup_started', {'method': method});
  }

  /// User successfully created an account.
  /// Main conversion event for Ads optimisation (Meta / Google / TikTok).
  ///
  /// [method]   → 'email' | 'google' | 'apple'
  /// [userType] → 'user' | 'advisor'
  static Future<void> signupCompleted({
    required String method,
    required String userType,
  }) async {
    await _log('signup_completed', {
      'af_registration_method': method, // AppsFlyer standard key
      'user_type': userType,
    });
  }

  /// User finished filling in all profile fields.
  /// Signals high-quality users for matching optimisation.
  static Future<void> completedProfile() async {
    await _log('completed_profile');
  }

  /// User selected their interests during onboarding.
  ///
  /// [interests] → list of interest keys, e.g. ['cooking', 'travel']
  static Future<void> interestsSelected({
    required List<String> interests,
  }) async {
    await _log('interests_selected', {
      'interests': interests.join(','),
      'interests_count': interests.length,
    });
  }

  /// User chose their intent / goal inside the app.
  /// Used for segmentation and personalising the experience.
  ///
  /// [intent] → 'marriage' | 'consultation' | …
  static Future<void> intentSelected({required String intent}) async {
    await _log('intent_selected', {'intent': intent});
  }

  /// User granted location permission.
  /// Improves matching and location-based features.
  static Future<void> locationEnabled() async {
    await _log('location_enabled');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Matching & Social Engagement
  // ─────────────────────────────────────────────────────────────────────────

  /// User sent a Like to another person.
  ///
  /// [targetUserId] → ID of the liked user
  static Future<void> matchLikeSent({required String targetUserId}) async {
    await _log('match_like_sent', {'target_user_id': targetUserId});
  }

  /// User opened another user's profile.
  ///
  /// [targetUserId] → ID of the viewed user
  static Future<void> viewedProfile({required String targetUserId}) async {
    await _log('viewed_profile', {'target_user_id': targetUserId});
  }

  /// Any message sent inside the app.
  ///
  /// [sessionType] → 'chat' | 'consultation' | …
  static Future<void> messageSent({required String sessionType}) async {
    await _log('message_sent', {'session_type': sessionType});
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Consultant Discovery & Engagement
  // ─────────────────────────────────────────────────────────────────────────

  /// User opened a consultant's profile — top of the consultation funnel.
  ///
  /// [advisorId] → ID of the consultant
  static Future<void> consultantProfileViewed({
    required String advisorId,
  }) async {
    await _log('consultant_profile_viewed', {
      'af_content_id': advisorId,
      'af_content_type': 'advisor_profile',
    });
  }

  /// User followed a consultant.
  ///
  /// [advisorId] → ID of the followed consultant
  static Future<void> consultantFollowed({required String advisorId}) async {
    await _log('consultant_followed', {'advisor_id': advisorId});
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Session Booking Funnel
  // ─────────────────────────────────────────────────────────────────────────

  /// User initiated the session booking flow.
  ///
  /// [advisorId]   → ID of the consultant
  /// [sessionType] → 'video' | 'audio' | 'chat'
  static Future<void> sessionBookingStarted({
    required String advisorId,
    required String sessionType,
  }) async {
    await _log('session_booking_started', {
      'advisor_id': advisorId,
      'session_type': sessionType,
    });
  }

  /// Session was booked successfully — key revenue event.
  ///
  /// [advisorId]   → ID of the consultant
  /// [sessionType] → 'video' | 'audio' | 'chat'
  /// [price]       → session price
  /// [currency]    → ISO currency code, e.g. 'EGP' | 'SAR' | 'USD'
  static Future<void> sessionBooked({
    required String advisorId,
    required String sessionType,
    required double price,
    required String currency,
  }) async {
    await _log('session_booked', {
      'advisor_id': advisorId,
      'session_type': sessionType,
      'af_price': price,
      'af_revenue': price,
      'af_currency': currency,
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Subscription Funnel
  // ─────────────────────────────────────────────────────────────────────────

  /// User opened the subscriptions / pricing page.
  static Future<void> viewedSubscription() async {
    await _log('viewed_subscription');
  }

  /// User started the subscription checkout flow.
  ///
  /// [planId] → subscription plan identifier
  static Future<void> subscriptionStarted({required String planId}) async {
    await _log('subscription_started', {'plan_id': planId});
  }

  /// Subscription purchased successfully — most important revenue event.
  ///
  /// [planId]   → subscription plan identifier
  /// [revenue]  → amount paid
  /// [currency] → ISO currency code
  static Future<void> subscriptionPurchased({
    required String planId,
    required double revenue,
    required String currency,
  }) async {
    await _log('subscription_purchased', {
      'plan_id': planId,
      'af_revenue': revenue,
      'af_currency': currency,
      'af_content_type': 'subscription',
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Purchases & Wallet
  // ─────────────────────────────────────────────────────────────────────────

  /// Any in-app purchase — used for ROAS and revenue analytics.
  ///
  /// [revenue]     → amount paid
  /// [currency]    → ISO currency code
  /// [contentType] → 'subscription' | 'session' | 'ticket' | 'boost' | …
  /// [contentId]   → optional item identifier
  static Future<void> purchase({
    required double revenue,
    required String currency,
    required String contentType,
    String? contentId,
  }) async {
    await _log('purchase', {
      'af_revenue': revenue,
      'af_currency': currency,
      'af_content_type': contentType,
      if (contentId != null) 'af_content_id': contentId,
    });
  }

  /// User topped up their in-app wallet.
  ///
  /// [amount]   → recharged amount
  /// [currency] → ISO currency code
  static Future<void> walletRecharged({
    required double amount,
    required String currency,
  }) async {
    await _log('wallet_recharged', {
      'af_revenue': amount,
      'af_currency': currency,
    });
  }

  /// User redeemed a discount coupon.
  ///
  /// [couponCode] → the coupon code used
  static Future<void> couponUsed({required String couponCode}) async {
    await _log('coupon_used', {'coupon_code': couponCode});
  }

  /// User purchased an event ticket.
  ///
  /// [eventId]  → ID of the event
  /// [revenue]  → ticket price
  /// [currency] → ISO currency code
  static Future<void> eventTicketPurchased({
    required String eventId,
    required double revenue,
    required String currency,
  }) async {
    await _log('event_ticket_purchased', {
      'event_id': eventId,
      'af_revenue': revenue,
      'af_currency': currency,
      'af_content_type': 'event_ticket',
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Discovery & Search
  // ─────────────────────────────────────────────────────────────────────────

  /// User performed a search inside the app.
  ///
  /// [query]    → optional search term (omit if sensitive)
  /// [category] → optional context, e.g. 'advisors' | 'users'
  static Future<void> searchUsed({String? query, String? category}) async {
    await _log('search_used', {
      if (query != null) 'af_search_string': query,
      if (category != null) 'category': category,
    });
  }

  /// User applied filters in a listing / search screen.
  ///
  /// [filterKeys] → list of applied filter names, e.g. ['gender', 'country']
  static Future<void> filterUsed({required List<String> filterKeys}) async {
    await _log('filter_used', {
      'filters': filterKeys.join(','),
      'filters_count': filterKeys.length,
    });
  }

  /// User viewed a compatibility score with another person.
  ///
  /// [targetUserId] → ID of the other person
  /// [score]        → compatibility percentage (0–100)
  static Future<void> compatibilityScoreViewed({
    required String targetUserId,
    required int score,
  }) async {
    await _log('compatibility_score_viewed', {
      'target_user_id': targetUserId,
      'score': score,
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Content Consumption
  // ─────────────────────────────────────────────────────────────────────────

  /// User watched a video.
  ///
  /// [videoId]  → optional video identifier
  /// [duration] → optional watch duration in seconds
  static Future<void> videoViewed({String? videoId, int? duration}) async {
    await _log('video_viewed', {
      if (videoId != null) 'video_id': videoId,
      if (duration != null) 'duration_seconds': duration,
    });
  }

  /// User viewed a Story.
  ///
  /// [storyId]    → optional story identifier
  /// [authorId]   → optional author user ID
  static Future<void> storyViewed({String? storyId, String? authorId}) async {
    await _log('story_viewed', {
      if (storyId != null) 'story_id': storyId,
      if (authorId != null) 'author_id': authorId,
    });
  }

  /// User liked a post.
  ///
  /// [postId] → ID of the liked post
  static Future<void> postLiked({required String postId}) async {
    await _log('post_liked', {'post_id': postId});
  }

  /// User added a comment.
  ///
  /// [postId] → ID of the post being commented on
  static Future<void> commentAdded({required String postId}) async {
    await _log('comment_added', {'post_id': postId});
  }

  /// User shared content from the app — key virality signal.
  ///
  /// [contentType] → 'post' | 'profile' | 'story' | …
  /// [contentId]   → optional ID of the shared item
  static Future<void> shareContent({
    required String contentType,
    String? contentId,
  }) async {
    await _log('share_content', {
      'af_content_type': contentType,
      if (contentId != null) 'af_content_id': contentId,
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Notifications
  // ─────────────────────────────────────────────────────────────────────────

  /// User received a push notification.
  ///
  /// [notificationType] → optional type, e.g. 'match' | 'message' | 'promo'
  static Future<void> pushReceived({String? notificationType}) async {
    await _log('push_received', {
      if (notificationType != null) 'notification_type': notificationType,
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Retention
  // ─────────────────────────────────────────────────────────────────────────

  /// Session duration — call when user backgrounds / closes the app.
  ///
  /// [durationSeconds] → total foreground time in seconds
  static Future<void> sessionDuration({required int durationSeconds}) async {
    await _log('session_duration', {
      'duration_seconds': durationSeconds,
      'duration_minutes': (durationSeconds / 60).floor(),
    });
  }

  /// User returned to the app 1 day after registration.
  static Future<void> retention1d() async {
    await _log('1d_retention');
  }

  /// User returned to the app 7 days after registration.
  static Future<void> retention7d() async {
    await _log('7d_retention');
  }

  /// User returned to the app 30 days after registration.
  static Future<void> retention30d() async {
    await _log('30d_retention');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Consultant-Specific Funnel
  // ─────────────────────────────────────────────────────────────────────────

  /// Consultant started the registration / onboarding flow.
  static Future<void> consultantSignupStarted() async {
    await _log('consultant_signup_started');
  }

  /// Consultant submitted their join application.
  static Future<void> consultantApplicationSubmitted() async {
    await _log('consultant_application_submitted');
  }

  /// Consultant uploaded the required verification documents.
  static Future<void> consultantDocumentsUploaded() async {
    await _log('consultant_documents_uploaded');
  }

  /// Consultant was approved and activated on the platform.
  static Future<void> consultantApproved() async {
    await _log('consultant_approved');
  }

  /// Consultant purchased a paid subscription plan.
  ///
  /// [planId]   → subscription plan identifier
  /// [revenue]  → amount paid
  /// [currency] → ISO currency code
  static Future<void> consultantSubscriptionPurchased({
    required String planId,
    required double revenue,
    required String currency,
  }) async {
    await _log('consultant_subscription_purchased', {
      'plan_id': planId,
      'af_revenue': revenue,
      'af_currency': currency,
    });
  }

  /// Consultant completed their first real session.
  ///
  /// [sessionType] → 'video' | 'audio' | 'chat'
  static Future<void> consultantFirstSession({
    required String sessionType,
  }) async {
    await _log('consultant_first_session', {'session_type': sessionType});
  }

  /// Consultant requested an earnings withdrawal.
  ///
  /// [amount]   → withdrawal amount
  /// [currency] → ISO currency code
  static Future<void> consultantEarningsWithdrawal({
    required double amount,
    required String currency,
  }) async {
    await _log('consultant_earnings_withdrawal', {
      'af_revenue': amount,
      'af_currency': currency,
    });
  }
}
