// lib/core/widgets/ads/ad_theme.dart
//
// Shared theme config accepted by every ad widget.
// Default values mirror the app design system (AppColors + Styles) exactly.
// Pass a custom [AdTheme] to any widget to reskin without touching widget code.

import 'package:tayseer/my_import.dart';
// ─────────────────────────────────────────────────────────────────────────────
// AdTheme data class
// ─────────────────────────────────────────────────────────────────────────────

class AdTheme {
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final Color badgeColor;
  final Color badgeTextColor;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  final List<Color> ctaGradientColors;
  final TextStyle ctaTextStyle;
  final Color shimmerBase;
  final Color shimmerHighlight;

  const AdTheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderRadius,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.titleStyle,
    required this.bodyStyle,
    required this.ctaGradientColors,
    required this.ctaTextStyle,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  /// Flat post-card style — matches the feed's white-card with thin grey border.
  static AdTheme get defaults => AdTheme(
    backgroundColor: Colors.white,
    borderColor: Colors.grey.shade200,
    borderRadius: 0,
    badgeColor: AppColors.primary50,
    badgeTextColor: AppColors.primary500,
    titleStyle: Styles.textStyle14SemiBold.copyWith(
      color: AppColors.secondary800,
    ),
    bodyStyle: Styles.textStyle12.copyWith(color: AppColors.secondary600),
    ctaGradientColors: [AppColors.primary300, AppColors.primary500],
    ctaTextStyle: Styles.textStyle12SemiBold.copyWith(color: Colors.white),
    shimmerBase: Colors.grey.shade300,
    shimmerHighlight: Colors.grey.shade100,
  );

  /// Rounded card — for list items with spacing already around them.
  static AdTheme get card => AdTheme(
    backgroundColor: Colors.white,
    borderColor: AppColors.primary100,
    borderRadius: 16,
    badgeColor: AppColors.primary50,
    badgeTextColor: AppColors.primary500,
    titleStyle: Styles.textStyle14SemiBold.copyWith(
      color: AppColors.secondary800,
    ),
    bodyStyle: Styles.textStyle12.copyWith(color: AppColors.secondary600),
    ctaGradientColors: [AppColors.primary300, AppColors.primary500],
    ctaTextStyle: Styles.textStyle12SemiBold.copyWith(color: Colors.white),
    shimmerBase: Colors.grey.shade300,
    shimmerHighlight: Colors.grey.shade100,
  );

  AdTheme copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    Color? badgeColor,
    Color? badgeTextColor,
    TextStyle? titleStyle,
    TextStyle? bodyStyle,
    List<Color>? ctaGradientColors,
    TextStyle? ctaTextStyle,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) => AdTheme(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    borderRadius: borderRadius ?? this.borderRadius,
    badgeColor: badgeColor ?? this.badgeColor,
    badgeTextColor: badgeTextColor ?? this.badgeTextColor,
    titleStyle: titleStyle ?? this.titleStyle,
    bodyStyle: bodyStyle ?? this.bodyStyle,
    ctaGradientColors: ctaGradientColors ?? this.ctaGradientColors,
    ctaTextStyle: ctaTextStyle ?? this.ctaTextStyle,
    shimmerBase: shimmerBase ?? this.shimmerBase,
    shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Small pill badge using the localized "ads.badge" key.
/// RTL-safe — no hardcoded direction; Flutter mirrors it automatically.
class AdBadge extends StatelessWidget {
  const AdBadge({super.key, required this.theme, this.labelOverride});

  final AdTheme theme;

  /// Pass a pre-resolved string when you need a different label
  /// (e.g. from InterstitialLoadingOverlay which has no BuildContext).
  final String? labelOverride;

  @override
  Widget build(BuildContext context) {
    final label = labelOverride ?? context.tr('ads.badge');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.badgeColor,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(
          color: theme.badgeTextColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
          color: theme.badgeTextColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// CTA button with the app's primary gradient.
class AdCtaButton extends StatelessWidget {
  const AdCtaButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final VoidCallback onTap;
  final AdTheme theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.ctaGradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(label, style: theme.ctaTextStyle),
      ),
    );
  }
}

/// Shimmer placeholder that mirrors PostCardShimmer structure.
class AdLoadingShimmer extends StatelessWidget {
  const AdLoadingShimmer({super.key, required this.theme, this.height = 90});

  final AdTheme theme;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        border: Border.all(color: theme.borderColor),
        borderRadius: BorderRadius.circular(theme.borderRadius.r),
      ),
      child: Shimmer.fromColors(
        baseColor: theme.shimmerBase,
        highlightColor: theme.shimmerHighlight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _rect(w: double.infinity, h: 12),
                    SizedBox(height: 8.h),
                    _rect(w: 160, h: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rect({required double w, required double h}) => Container(
    width: w == double.infinity ? w : w.w,
    height: h.h,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4.r),
    ),
  );
}
