// lib/core/widgets/ads/native_ad_widget.dart
// ⚠️ ADS TEMPORARILY DISABLED — uncomment when Google Ads account is ready.

// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:tayseer/core/services/ad_service.dart';
// import 'package:tayseer/core/widgets/ads/ad_context.dart';
// import 'package:tayseer/core/widgets/ads/ad_theme.dart';
// import 'package:tayseer/my_import.dart';

import 'package:flutter/material.dart';
import 'package:tayseer/core/widgets/ads/ad_context.dart';
import 'package:tayseer/core/widgets/ads/ad_theme.dart';

class NativeAdWidget extends StatelessWidget {
  // ignore: avoid_unused_constructor_parameters
  const NativeAdWidget({
    super.key,
    this.adContext = AdContext.listItem,
    this.height,
    this.adTheme,
  });

  final AdContext adContext;
  final double? height;
  final AdTheme? adTheme;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
