// lib/core/widgets/ads/rewarded_ad_button.dart
// ⚠️ ADS TEMPORARILY DISABLED — uncomment when Google Ads account is ready.

// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:tayseer/core/services/ad_service.dart';
// import 'package:tayseer/core/widgets/ads/ad_theme.dart';
// import 'package:tayseer/my_import.dart';

import 'package:flutter/material.dart';
import 'package:tayseer/core/widgets/ads/ad_theme.dart';

class RewardedAdButton extends StatelessWidget {
  // ignore: avoid_unused_constructor_parameters
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

  final String label;
  final void Function(dynamic reward) onRewarded;
  final VoidCallback? onNotAvailable;
  final AdTheme? adTheme;
  final IconData icon;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
