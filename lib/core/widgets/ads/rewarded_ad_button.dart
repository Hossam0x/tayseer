// lib/core/widgets/ads/rewarded_ad_button.dart
//
// Opt-in rewarded-ad button styled with the app's gradient.
// The user taps deliberately — ads are never auto-shown.
// All label text must be passed as a pre-resolved localized string:
//
//   RewardedAdButton(label: context.tr('ads.watch_to_unlock'), ...)
//
// Returns SizedBox.shrink() when rewarded ads are disabled or suppressed.

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tayseer/core/services/ad_service.dart';
import 'package:tayseer/core/widgets/ads/ad_theme.dart';
import 'package:tayseer/my_import.dart';

class RewardedAdButton extends StatefulWidget {
  const RewardedAdButton({
    super.key,
    required this.label,
    required this.onRewarded,
    this.onNotAvailable,
    this.adTheme,
    this.icon = Icons.play_circle_filled_rounded,
    this.width,
    this.height,
  });

  /// Caller is responsible for localizing this, e.g. context.tr('ads.watch_to_unlock').
  final String label;
  final void Function(RewardItem reward) onRewarded;
  final VoidCallback? onNotAvailable;
  final AdTheme? adTheme;
  final IconData icon;
  final double? width;
  final double? height;

  @override
  State<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton> {
  bool _loading = false;

  AdTheme get _theme => widget.adTheme ?? AdTheme.defaults;

  Future<void> _onTap() async {
    if (_loading) return;
    setState(() => _loading = true);

    final shown = await getIt<AdService>().showRewarded(
      onRewarded: widget.onRewarded,
    );

    if (mounted) setState(() => _loading = false);
    if (!shown) widget.onNotAvailable?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!getIt<AdService>().canShowRewarded) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _loading ? null : _onTap,
      child: Container(
        width: widget.width,
        height: widget.height ?? 46.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _loading
                ? [AppColors.secondary200, AppColors.secondary200]
                : _theme.ctaGradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: _loading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary400.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: widget.width == null
              ? MainAxisSize.min
              : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Small badge — white on gradient background
            AdBadge(
              theme: _theme.copyWith(
                badgeColor: Colors.white.withValues(alpha: 0.25),
                badgeTextColor: Colors.white,
              ),
            ),
            SizedBox(width: 8.w),
            if (_loading)
              SizedBox(
                width: 18.w,
                height: 18.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              )
            else
              Icon(widget.icon, color: Colors.white, size: 18.sp),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                widget.label,
                style: Styles.textStyle12SemiBold.copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
