/// All configurable thresholds for the app-rating eligibility check.
abstract class RatingConstants {
  /// Minimum number of app launches before prompting.
  static const int minLaunchCount = 10;

  /// Minimum total usage time (in seconds) before prompting.
  static const int minUsageSeconds = 300; // 5 minutes

  /// Minimum days between two automatic review prompts (after "Maybe Later").
  static const int minDaysBetweenPrompts = 60;

  // ── SharedPreferences keys ──────────────────────────────────────────────
  static const String kLaunchCount = 'rating_launch_count';
  static const String kTotalUsageSeconds = 'rating_total_usage_seconds';
  static const String kLastReviewTimestamp = 'rating_last_review_timestamp';
  static const String kHasRated = 'rating_has_rated';
  static const String kSessionStartTimestamp = 'rating_session_start';

  /// Set when user taps "Maybe Later" — used for cooldown re-prompt.
  static const String kPromptDismissedTimestamp = 'rating_prompt_dismissed_ts';
}
