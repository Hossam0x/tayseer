import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayseer/features/shared/rating/constants/rating_constants.dart';
import 'package:tayseer/features/shared/rating/services/app_usage_tracker_service.dart';

/// Handles eligibility checks and native store-review triggering.
class RatingService {
  RatingService._();
  static final RatingService instance = RatingService._();

  final InAppReview _inAppReview = InAppReview.instance;

  // ── Eligibility ───────────────────────────────────────────────────────────

  /// Returns true when all conditions are met for showing the rating prompt.
  Future<bool> isEligibleForReview() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(RatingConstants.kHasRated) == true) return false;

    final launches = await AppUsageTrackerService.instance.getLaunchCount();
    if (launches < RatingConstants.minLaunchCount) return false;

    final usageSeconds = await AppUsageTrackerService.instance
        .getTotalUsageSeconds();
    if (usageSeconds < RatingConstants.minUsageSeconds) return false;

    final lastReview = prefs.getInt(RatingConstants.kLastReviewTimestamp) ?? 0;
    if (lastReview > 0) {
      final daysSince = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(lastReview))
          .inDays;
      if (daysSince < RatingConstants.minDaysBetweenPrompts) return false;
    }

    return true;
  }

  // ── Native review ─────────────────────────────────────────────────────────

  /// Opens the native in-app review sheet.
  ///
  /// On debug builds or when the native sheet is unavailable, falls back to
  /// opening the store listing directly so the flow always works.
  Future<void> requestNativeReview() async {
    try {
      final available = await _inAppReview.isAvailable();

      // In debug mode or when native sheet is unavailable → open store listing.
      if (!available || kDebugMode) {
        await _inAppReview.openStoreListing(appStoreId: '6756886227');
        return;
      }

      await _inAppReview.requestReview();
    } catch (_) {
      // Best-effort — silently ignore failures.
      try {
        await _inAppReview.openStoreListing(appStoreId: '6756886227');
      } catch (_) {}
    }
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  /// Mark that the user has submitted a rating so we never auto-prompt again.
  Future<void> markAsRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(RatingConstants.kHasRated, true);
    await _recordReviewTimestamp(prefs);
  }

  /// Record the timestamp of the last review request (for cooldown).
  Future<void> recordReviewRequest() async {
    final prefs = await SharedPreferences.getInstance();
    await _recordReviewTimestamp(prefs);
  }

  Future<void> _recordReviewTimestamp(SharedPreferences prefs) async {
    await prefs.setInt(
      RatingConstants.kLastReviewTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
