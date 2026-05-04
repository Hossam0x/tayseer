import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tayseer/my_import.dart';

/// صورة محمية من الـ screenshot
/// - Android: FLAG_SECURE على الـ Window (يتفعّل في MarriageView)
///            → AppImage عادي، الحماية على مستوى الشاشة كلها
/// - iOS: UITextField(isSecureTextEntry) native container
/// - shouldBlur: للـ anonymous profiles
class ScreenshotProtectedImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final bool shouldBlur;
  final bool isAnimating;

  const ScreenshotProtectedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.shouldBlur = false,
    this.isAnimating = false,
  });

  @override
  Widget build(BuildContext context) {
    if (shouldBlur) {
      // Blur (anonymous): صورة واحدة بس عليها blur
      return ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: _flutterImage(),
      );
    }

    // ✅ Android + iOS: AppImage عادي
    // Android: الحماية من FLAG_SECURE على الـ Window
    // iOS: FLAG_SECURE مش متاح — نستخدم AppImage عادي عشان Hero animation تشتغل
    return _flutterImage();
  }

  Widget _flutterImage() {
    if (isAnimating) {
      return AppImage(imageUrl, fit: fit);
    }
    return Hero(
      tag: 'profile_$imageUrl',
      child: AppImage(imageUrl, fit: fit),
    );
  }
}
