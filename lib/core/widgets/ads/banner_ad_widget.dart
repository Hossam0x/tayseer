// lib/core/widgets/ads/banner_ad_widget.dart
//
// Custom-styled banner ad.
//
// Chrome matches the app's white-card feed style (same border/bg as PostCard).
// "إعلان" badge is pinned start-top; the AdMob AdWidget fills the inner area.
// Fixed total height = AdMob banner height + 20 px label row → zero layout shift.
// Returns SizedBox.shrink() when ads are suppressed or kill-switched.
// Accepts [adTheme] for easy reskin.

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tayseer/core/services/ad_service.dart';
import 'package:tayseer/core/widgets/ads/ad_theme.dart';
import 'package:tayseer/my_import.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key, this.adSize = AdSize.banner, this.adTheme});

  final AdSize adSize;

  /// Custom theme — falls back to [AdTheme.defaults].
  final AdTheme? adTheme;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _adLoaded = false;

  AdTheme get _theme => widget.adTheme ?? AdTheme.defaults;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final ad = getIt<AdService>().createBannerAd(size: widget.adSize);
    if (ad == null) return; // kill-switched or role-suppressed

    ad.load().then((_) {
      if (mounted) {
        setState(() {
          _bannerAd = ad;
          _adLoaded = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_adLoaded || _bannerAd == null) return const SizedBox.shrink();

    const labelRowH = 20.0;
    const vertPad = 4.0;
    final adH = _bannerAd!.size.height.toDouble();
    final adW = _bannerAd!.size.width.toDouble();
    final totalH = adH + labelRowH + vertPad * 2;

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        height: totalH.h,
        decoration: BoxDecoration(
          color: _theme.backgroundColor,
          border: Border(top: BorderSide(color: _theme.borderColor)),
          borderRadius: _theme.borderRadius > 0
              ? BorderRadius.circular(_theme.borderRadius.r)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Label row ──────────────────────────────────────────────
            SizedBox(
              height: labelRowH.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                  children: [
                    AdBadge(theme: _theme),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            // ── AdMob content ──────────────────────────────────────────
            SizedBox(
              width: adW,
              height: adH,
              child: AdWidget(ad: _bannerAd!),
            ),
            SizedBox(height: vertPad.h),
          ],
        ),
      ),
    );
  }
}
