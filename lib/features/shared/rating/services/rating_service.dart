import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/features/shared/rating/constants/rating_constants.dart';
import 'package:tayseer/features/shared/rating/services/app_usage_tracker_service.dart';

/// Handles eligibility checks and native store-review triggering.
class RatingService {
  RatingService._();
  static final RatingService instance = RatingService._();

  final InAppReview _inAppReview = InAppReview.instance;

  // ── Eligibility ───────────────────────────────────────────────────────────

  /// Returns true when all conditions are met for showing the auto rating prompt.
  ///
  /// Never shows again if the user already tapped "Rate Now" ([kHasRated] = true).
  /// Respects the cooldown after "Maybe Later" ([kPromptDismissedTimestamp]).
  Future<bool> isEligibleForReview() async {
    final prefs = await SharedPreferences.getInstance();

    // User already rated via the dialog → never auto-prompt again.
    if (prefs.getBool(RatingConstants.kHasRated) == true) return false;

    final launches = await AppUsageTrackerService.instance.getLaunchCount();
    if (launches < RatingConstants.minLaunchCount) return false;

    final usageSeconds = await AppUsageTrackerService.instance
        .getTotalUsageSeconds();
    if (usageSeconds < RatingConstants.minUsageSeconds) return false;

    // Cooldown after "Maybe Later" dismissal.
    final dismissed =
        prefs.getInt(RatingConstants.kPromptDismissedTimestamp) ?? 0;
    if (dismissed > 0) {
      final daysSince = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(dismissed))
          .inDays;
      if (daysSince < RatingConstants.minDaysBetweenPrompts) return false;
    }

    // Legacy cooldown from old kLastReviewTimestamp (keep for safety).
    final lastReview = prefs.getInt(RatingConstants.kLastReviewTimestamp) ?? 0;
    if (lastReview > 0) {
      final daysSince = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(lastReview))
          .inDays;
      if (daysSince < RatingConstants.minDaysBetweenPrompts) return false;
    }

    return true;
  }

  // ── Confirmation dialog + native review ──────────────────────────────────

  /// Shows a custom confirmation dialog first.
  ///
  /// - "Rate Now" → calls [onConfirmed], marks as rated ([kHasRated] = true),
  ///   then opens the native store review. Will never auto-prompt again.
  /// - "Maybe Later" → records dismiss timestamp for cooldown re-prompt.
  void showRateConfirmationAndReview(
    BuildContext context, {
    VoidCallback? onConfirmed,
  }) {
    if (!context.mounted) return;
    CustomshowDialogWithImage(
      context,
      title: context.tr('rate_app_prompt_title'),
      supTitle: context.tr('rate_app_prompt_message'),
      icon: Icons.star_rounded,
      iconColor: const Color(0xFFFFC107),
      iconBackgroundColor: const Color(0xFFFFF8E1),
      bottonText: context.tr('rate_app_prompt_confirm'),
      showCancelButton: true,
      cancelText: context.tr('rate_app_prompt_cancel'),
      onPressed: () {
        // Mark permanently so auto-prompt never shows again.
        markAsRated();
        onConfirmed?.call();
        requestNativeReview();
      },
      onCancel: () {
        // Record dismiss time → cooldown before next auto-prompt.
        _recordDismissTimestamp();
      },
    );
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

  /// Mark that the user confirmed rating → auto-prompt disabled permanently.
  /// Settings-triggered rating is always allowed regardless of this flag.
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

  /// Record when the user dismissed the dialog with "Maybe Later".
  Future<void> _recordDismissTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      RatingConstants.kPromptDismissedTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> _recordReviewTimestamp(SharedPreferences prefs) async {
    await prefs.setInt(
      RatingConstants.kLastReviewTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
