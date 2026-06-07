import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

/// Wraps an image URL with a native secure layer.
/// [instanceId] — optional suffix للـ key عشان يمنع recreating_view
/// [showFallbackUntilReady] — لو true بيعرض الـ Flutter fallback لحد ما الـ native view يجهز (للـ cards)
///   لو false بيبدأ بـ container أسود بدون fallback (للـ full screen)
/// [fit] — 'cover' (default للـ cards) أو 'contain' (للـ full screen)
class SecureImageWrapper extends StatelessWidget {
  final String? imageUrl;
  final Widget child;
  final String instanceId;
  final bool showFallbackUntilReady;
  final String fit; // 'cover' | 'contain'

  const SecureImageWrapper({
    super.key,
    required this.child,
    this.imageUrl,
    this.instanceId = 'default',
    this.showFallbackUntilReady = true,
    this.fit = 'cover',
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return _AndroidSecureImage(
          imageUrl: imageUrl!,
          fit: fit,
          showFallbackUntilReady: showFallbackUntilReady,
          flutterFallback: child,
        );
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return _IosSecureImage(
          key: ValueKey('${imageUrl}_$instanceId'),
          imageUrl: imageUrl!,
          fit: fit,
          flutterFallback: child,
          showFallbackUntilReady: showFallbackUntilReady,
        );
      }
    }

    return child;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// iOS
// ─────────────────────────────────────────────────────────────────────────────

class _IosSecureImage extends StatefulWidget {
  final String imageUrl;
  final String fit;
  final Widget flutterFallback;
  final bool showFallbackUntilReady;

  const _IosSecureImage({
    super.key,
    required this.imageUrl,
    required this.fit,
    required this.flutterFallback,
    required this.showFallbackUntilReady,
  });

  @override
  State<_IosSecureImage> createState() => _IosSecureImageState();
}

class _IosSecureImageState extends State<_IosSecureImage> {
  bool _ready = false;
  bool _nativeLoaded = false;
  bool _disposed = false;
  Timer? _readyTimer;

  @override
  void initState() {
    super.initState();
    if (!widget.showFallbackUntilReady) {
      // full screen: ابدأ الـ UiKitView فوراً بدون delay
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _ready = true);
      });
    } else {
      // card mode: تأخير بسيط يمنع recreating_view
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _readyTimer = Timer(const Duration(milliseconds: 100), () {
          if (mounted) setState(() => _ready = true);
        });
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _readyTimer?.cancel();
    super.dispose();
  }

  UiKitView _buildUiKitView() {
    return UiKitView(
      // ✅ propagate the widget key so Flutter fully disposes the old native
      // view before creating a new one (prevents recreating_view on hot restart
      // and when imageUrl changes)
      key: widget.key,
      viewType: 'secure_image_view',
      layoutDirection: TextDirection.ltr,
      // ✅ بنبعت الـ fit للـ native عشان يعرف يستخدم scaleAspectFit أو scaleAspectFill
      creationParams: {'url': widget.imageUrl, 'fit': widget.fit},
      creationParamsCodec: const StandardMessageCodec(),
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
      onPlatformViewCreated: (_) {
        final delay = widget.showFallbackUntilReady ? 250 : 150;
        Future.delayed(Duration(milliseconds: delay), () {
          if (mounted && !_disposed) {
            setState(() => _nativeLoaded = true);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // full screen: UiKitView فقط — container أسود لحد ما يجهز ثم بيتشال
    if (!widget.showFallbackUntilReady) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (!_nativeLoaded) Container(color: Colors.black),
          if (_ready && !_disposed) _buildUiKitView(),
        ],
      );
    }

    // card mode: fallback يتعرض لحد ما الـ native يجهز ثم بيتشال من الـ tree
    return Stack(
      fit: StackFit.expand,
      children: [
        if (!_nativeLoaded) widget.flutterFallback,
        if (_ready && !_disposed)
          AnimatedOpacity(
            opacity: _nativeLoaded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: _buildUiKitView(),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Android
// ─────────────────────────────────────────────────────────────────────────────

class _AndroidSecureImage extends StatefulWidget {
  final String imageUrl;
  final String fit;
  final bool showFallbackUntilReady;
  final Widget flutterFallback;

  const _AndroidSecureImage({
    required this.imageUrl,
    required this.fit,
    required this.showFallbackUntilReady,
    required this.flutterFallback,
  });

  @override
  State<_AndroidSecureImage> createState() => _AndroidSecureImageState();
}

class _AndroidSecureImageState extends State<_AndroidSecureImage> {
  bool _nativeLoaded = false;

  PlatformViewLink _buildPlatformView() {
    return PlatformViewLink(
      viewType: 'secure_image_view',
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.transparent,
        );
      },
      onCreatePlatformView: (params) {
        return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: 'secure_image_view',
            layoutDirection: TextDirection.ltr,
            // ✅ بنبعت الـ fit للـ native
            creationParams: {'url': widget.imageUrl, 'fit': widget.fit},
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () => params.onFocusChanged(true),
          )
          ..addOnPlatformViewCreatedListener((id) {
            params.onPlatformViewCreated(id);
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) setState(() => _nativeLoaded = true);
            });
          })
          ..create();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final nativeView = _buildPlatformView();

    // full screen: container أسود لحد ما يجهز
    if (!widget.showFallbackUntilReady) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (!_nativeLoaded) Container(color: Colors.black),
          AnimatedOpacity(
            opacity: _nativeLoaded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: nativeView,
          ),
        ],
      );
    }

    // card mode: fallback لحد ما الـ native يجهز ثم بيتشال من الـ tree
    return Stack(
      fit: StackFit.expand,
      children: [
        if (!_nativeLoaded) widget.flutterFallback,
        AnimatedOpacity(
          opacity: _nativeLoaded ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: nativeView,
        ),
      ],
    );
  }
}
