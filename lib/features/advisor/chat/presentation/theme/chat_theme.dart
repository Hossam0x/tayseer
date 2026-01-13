import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/colors.dart';

abstract class ChatColors {
  static const Color bubbleSender = Color(0xFFD84D65);
  static const Color bubbleReceiver = Colors.white;
  static const Color textSender = Colors.white;
  static const Color textReceiver = Color(0xFF212121);
  static const Color timeSender = Colors.white70;
  static const Color timeReceiver = Colors.grey;
  static const Color replyBorderSender = Colors.white70;
  static Color replyBorderReceiver = AppColors.kprimaryColor;
  static const Color replyBackgroundSender = Color(0x26FFFFFF);
  static const Color replyBackgroundReceiver = Color(0x1A9E9E9E);
  static const Color inputBackground = Color(0xFFF9EEFA);
  static const Color inputFieldBackground = Colors.white;
  static const Color chatBackground = Color(0xFFFDF7F8);
  static const Color highlightColor = Color(0x26D84D65);
  static const Color overlayBackground = Color(0x4D000000);
  static const Color scrollButtonBackground = Colors.white;
  static const Color scrollButtonIcon = Color(0xFF212121);
  static const Color typingIndicatorBackground = Color(0xE6FFFFFF);
  static const Color typingDots = Color(0xFF9E9E9E);
  static const Color sentIconColor = Color(0xFF9E9E9E);
}

abstract class ChatDimensions {
  static const double bubbleMaxWidthMobile = 240.0;
  static const double bubbleMaxWidthTablet = 320.0;
  static const double bubbleMaxWidthDesktop = 380.0;
  static const double bubbleWidthRatio = 0.72;

  static const double paddingHorizontalMobile = 12.0;
  static const double paddingHorizontalTablet = 14.0;
  static const double paddingVerticalMobile = 8.0;
  static const double paddingVerticalTablet = 10.0;

  static const double fontSizeMobile = 16.0;
  static const double fontSizeTablet = 20.0;
  static const double timeFontSizeMobile = 10.0;
  static const double timeFontSizeTablet = 12.0;

  static const double iconSizeMobile = 24.0;
  static const double iconSizeTablet = 28.0;

  static const double bubbleRadiusLarge = 16.0;
  static const double bubbleRadiusSmall = 8.0;

  static const double mediaPreviewSize = 45.0;
  static const double replyBorderWidth = 3.0;
}

abstract class ChatAnimations {
  static const Duration messageEntryDuration = Duration(milliseconds: 300);
  static const Duration highlightDuration = Duration(seconds: 2);
  static const Duration scrollDuration = Duration(milliseconds: 300);
  static const Duration typingDotsDuration = Duration(milliseconds: 1200);
  static const Curve defaultCurve = Curves.easeOut;
}
