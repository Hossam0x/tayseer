import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tayseer/core/widgets/secure_image_wrapper.dart';
import 'package:tayseer/my_import.dart';

/// صورة محمية من الـ screenshot
/// - Android: SurfaceView مع setSecure(true) — الصورة تظهر سودة في الـ screenshot
/// - iOS: UITextField مع isSecureTextEntry — حماية على مستوى الـ OS
/// - shouldBlur: للـ anonymous profiles (blur دايماً)
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

  Widget _buildImage() {
    if (isAnimating) {
      return AppImage(imageUrl, fit: fit);
    }
    return Hero(
      tag: imageUrl,
      child: AppImage(imageUrl, fit: fit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = shouldBlur
        ? ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: _buildImage(),
          )
        : _buildImage();

    return SecureImageWrapper(child: image);
  }
}
