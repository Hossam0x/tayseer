import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tayseer/core/services/screenshot_detector.dart';
import 'package:tayseer/my_import.dart';

/// صورة محمية من الـ screenshot
/// - Android: بيستخدم EventChannel من MainActivity
/// - iOS: بيستخدم AppLifecycleState.inactive
/// - shouldBlur: للـ anonymous profiles (blur دايماً)
class ScreenshotProtectedImage extends StatefulWidget {
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
  State<ScreenshotProtectedImage> createState() =>
      _ScreenshotProtectedImageState();
}

class _ScreenshotProtectedImageState extends State<ScreenshotProtectedImage>
    with WidgetsBindingObserver {
  // iOS فقط
  bool _iosInactive = false;

  bool get _isScreenshotActive =>
      _iosInactive || ScreenshotDetector.isScreenshotActive.value;

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      WidgetsBinding.instance.addObserver(this);
    }
    ScreenshotDetector.isScreenshotActive.addListener(_onScreenshotChanged);
  }

  @override
  void dispose() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      WidgetsBinding.instance.removeObserver(this);
    }
    ScreenshotDetector.isScreenshotActive.removeListener(_onScreenshotChanged);
    super.dispose();
  }

  void _onScreenshotChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    final inactive =
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused;
    if (_iosInactive != inactive && mounted) {
      setState(() => _iosInactive = inactive);
    }
  }

  Widget _buildImage() {
    if (widget.isAnimating) {
      return AppImage(widget.imageUrl, fit: widget.fit);
    }
    return Hero(
      tag: widget.imageUrl,
      child: AppImage(widget.imageUrl, fit: widget.fit),
    );
  }

  @override
  Widget build(BuildContext context) {
    // لما يتعمل screenshot — اخبي الصورة كلياً
    if (_isScreenshotActive) {
      return Container(
        color: Colors.grey.shade800,
        child: Center(
          child: Icon(
            Icons.hide_image_outlined,
            color: Colors.grey.shade500,
            size: 64,
          ),
        ),
      );
    }

    // anonymous profile — blur دايماً
    if (widget.shouldBlur) {
      return ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: _buildImage(),
      );
    }

    return _buildImage();
  }
}
