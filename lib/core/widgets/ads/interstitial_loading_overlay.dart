// lib/core/widgets/ads/interstitial_loading_overlay.dart
//
// Branded loading overlay shown for ~500 ms before the AdMob full-screen ad.
// Prevents the jarring white-flash between the app screen and the ad.
//
// Usage:
//   await InterstitialLoadingOverlay.show(
//     context,
//     message: context.tr('ads.loading'),
//   );
//   await getIt<AdService>().showInterstitial();

import 'package:tayseer/core/widgets/ads/ad_theme.dart';
import 'package:tayseer/my_import.dart';

class InterstitialLoadingOverlay {
  InterstitialLoadingOverlay._();

  static Future<void> show(
    BuildContext context, {
    Duration duration = const Duration(milliseconds: 500),
    AdTheme? adTheme,
    String? message,
  }) async {
    final overlay = Overlay.of(context);
    final theme = adTheme ?? AdTheme.defaults;
    // Resolve the message here while context is still valid
    final resolvedMsg = message ?? context.tr('ads.loading');

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _OverlayBody(theme: theme, message: resolvedMsg),
    );

    overlay.insert(entry);
    await Future.delayed(duration);
    entry.remove();
  }
}

class _OverlayBody extends StatelessWidget {
  const _OverlayBody({required this.theme, required this.message});

  final AdTheme theme;
  final String message; // already resolved — no BuildContext needed

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withValues(alpha: 0.55),
        alignment: Alignment.center,
        child: Container(
          width: 200.w,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48.w,
                height: 48.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation(
                    theme.ctaGradientColors.first,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Badge using pre-resolved string — no context.tr() needed here
              AdBadge(theme: theme, labelOverride: context.tr('ads.badge')),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Styles.textStyle12.copyWith(
                  color: AppColors.secondary600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
