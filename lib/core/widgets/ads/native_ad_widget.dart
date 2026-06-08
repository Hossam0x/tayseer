// lib/core/widgets/ads/native_ad_widget.dart
//
// Contextual native ad — renders as real content for each placement.
//
//  AdContext.post        → full PostCard chrome (same padding/border as feed)
//  AdContext.profileCard → ProfileCard chrome (rounded, same card shape)
//  AdContext.story       → story circle + "Sponsored" label below
//  AdContext.listItem    → compact list-tile row (default)
//
// All strings come from localization keys — zero hardcoded text.
// RTL layout is automatic via Flutter's bidi engine.
// Returns SizedBox.shrink() when ads are suppressed or kill-switched.

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tayseer/core/services/ad_service.dart';
import 'package:tayseer/core/widgets/ads/ad_context.dart';
import 'package:tayseer/core/widgets/ads/ad_theme.dart';
import 'package:tayseer/my_import.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({
    super.key,
    this.adContext = AdContext.listItem,
    this.height,
    this.adTheme,
  });

  final AdContext adContext;

  /// Override content-area height. Defaults to [AdContext.defaultHeight].
  final double? height;

  /// Custom theme — falls back to [AdTheme.defaults].
  final AdTheme? adTheme;

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _adLoaded = false;

  AdTheme get _theme => widget.adTheme ?? AdTheme.defaults;
  double get _contentH => widget.height ?? widget.adContext.defaultHeight;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final ad = getIt<AdService>().createNativeAd(
      factoryId: widget.adContext.factoryId,
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _adLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            '🔴 NativeAd [${widget.adContext.factoryId}] failed: $error',
          );
          ad.dispose();
        },
      ),
    );
    if (ad == null) return; // kill-switched or role-suppressed
    ad.load();
    _nativeAd = ad;
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_adLoaded || _nativeAd == null) {
      return _NativeAdShimmer(
        theme: _theme,
        adContext: widget.adContext,
        height: _contentH,
      );
    }

    final adView = SizedBox(
      height: _contentH.h,
      child: AdWidget(ad: _nativeAd!),
    );
    return _chromeFor(context, adView);
  }

  Widget _chromeFor(BuildContext context, Widget adView) {
    switch (widget.adContext) {
      case AdContext.post:
        return _PostAdChrome(theme: _theme, child: adView);
      case AdContext.profileCard:
        return _ProfileCardAdChrome(theme: _theme, child: adView);
      case AdContext.story:
        return _StoryAdChrome(theme: _theme, height: _contentH, child: adView);
      case AdContext.listItem:
        return _ListItemAdChrome(theme: _theme, child: adView);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Post chrome — flat card matching PostCard (white bg, thin grey border).
//
// ⚠️  AdMob rule: ALL ad assets (headline, body, CTA, badge) MUST live inside
//     the GADNativeAdView / NativeAdView boundary.  Any Dart widget drawn on
//     top of the AdWidget (Stack overlay, header row, badge, etc.) that is NOT
//     part of the platform NativeAdView will trigger the "assets outside native
//     ad view" validator error.
//
//     Fix: the Dart chrome is a plain container that holds the AdWidget at
//     full width.  The headline, body, icon, badge and CTA are all rendered
//     INSIDE the native layout by NativeAdFactories.kt / NativeAdFactories.swift.
// ─────────────────────────────────────────────────────────────────────────────

class _PostAdChrome extends StatelessWidget {
  const _PostAdChrome({required this.theme, required this.child});
  final AdTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        border: Border.all(color: Colors.grey.shade200),
      ),
      // The AdWidget fills the full width — native factory owns the layout.
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ProfileCard chrome — rounded card matching the advisor/marriage list cards
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileCardAdChrome extends StatelessWidget {
  const _ProfileCardAdChrome({required this.theme, required this.child});
  final AdTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary100),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary50,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  AdBadge(theme: theme),
                  SizedBox(width: 6.w),
                  Text(
                    context.tr('ads.sponsored_profile'),
                    style: theme.bodyStyle,
                  ),
                ],
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Story chrome — circular avatar with gradient ring + label below
// ─────────────────────────────────────────────────────────────────────────────

class _StoryAdChrome extends StatelessWidget {
  const _StoryAdChrome({
    required this.theme,
    required this.height,
    required this.child,
  });
  final AdTheme theme;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: height.w,
          height: height.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: theme.ctaGradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: ClipOval(child: child),
        ),
        SizedBox(height: 4.h),
        Text(
          context.tr('ads.sponsored_story'),
          style: theme.bodyStyle.copyWith(fontSize: 10.sp),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ListItem chrome — compact row with badge pinned to top-start (RTL-safe)
// ─────────────────────────────────────────────────────────────────────────────

class _ListItemAdChrome extends StatelessWidget {
  const _ListItemAdChrome({required this.theme, required this.child});
  final AdTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        border: Border(
          top: BorderSide(color: theme.borderColor),
          bottom: BorderSide(color: theme.borderColor),
        ),
      ),
      child: Stack(
        children: [
          child,
          // Positioned to top-end in LTR; Flutter mirrors to top-start in RTL
          PositionedDirectional(
            top: 4.h,
            end: 8.w,
            child: AdBadge(theme: theme),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer placeholders — one per AdContext
// ─────────────────────────────────────────────────────────────────────────────

class _NativeAdShimmer extends StatelessWidget {
  const _NativeAdShimmer({
    required this.theme,
    required this.adContext,
    required this.height,
  });

  final AdTheme theme;
  final AdContext adContext;
  final double height;

  @override
  Widget build(BuildContext context) {
    switch (adContext) {
      case AdContext.post:
        return _postShimmer();
      case AdContext.profileCard:
        return _cardShimmer();
      case AdContext.story:
        return _storyShimmer();
      case AdContext.listItem:
        return _listShimmer();
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _shimmer(Widget child) => Shimmer.fromColors(
    baseColor: theme.shimmerBase,
    highlightColor: theme.shimmerHighlight,
    child: child,
  );

  Widget _rect({required double w, required double h, double r = 4}) =>
      Container(
        width: w == double.infinity ? w : w.w,
        height: h.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.r),
        ),
      );

  Widget _circle(double size) => Container(
    width: size.w,
    height: size.w,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
  );

  // ── Post ───────────────────────────────────────────────────────────────────

  Widget _postShimmer() => Container(
    padding: EdgeInsets.symmetric(vertical: 14.h),
    decoration: BoxDecoration(
      color: theme.backgroundColor,
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: _shimmer(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                _circle(40),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _rect(w: 120, h: 12),
                      SizedBox(height: 6.h),
                      _rect(w: 60, h: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          _rect(w: double.infinity, h: height, r: 0),
        ],
      ),
    ),
  );

  // ── ProfileCard ────────────────────────────────────────────────────────────

  Widget _cardShimmer() => Container(
    margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: theme.backgroundColor,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: AppColors.primary100),
    ),
    child: _shimmer(
      Column(
        children: [
          _rect(w: double.infinity, h: height, r: 0),
          Padding(
            padding: EdgeInsets.all(10.w),
            child: Row(
              children: [
                _rect(w: 80, h: 10),
                SizedBox(width: 8.w),
                _rect(w: 40, h: 10),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  // ── Story ──────────────────────────────────────────────────────────────────

  Widget _storyShimmer() => _shimmer(
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _circle(height),
        SizedBox(height: 4.h),
        _rect(w: height, h: 10),
      ],
    ),
  );

  // ── ListItem ───────────────────────────────────────────────────────────────

  Widget _listShimmer() => Container(
    height: height.h,
    decoration: BoxDecoration(
      color: theme.backgroundColor,
      border: Border(
        top: BorderSide(color: theme.borderColor),
        bottom: BorderSide(color: theme.borderColor),
      ),
    ),
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
    child: _shimmer(
      Row(
        children: [
          _circle(40),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _rect(w: double.infinity, h: 12),
                SizedBox(height: 6.h),
                _rect(w: 120, h: 10),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
