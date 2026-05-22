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
class SecureImageWrapper extends StatelessWidget {
  final String? imageUrl;
  final Widget child;
  final String instanceId;
  final bool showFallbackUntilReady;

  const SecureImageWrapper({
    super.key,
    required this.child,
    this.imageUrl,
    this.instanceId = 'default',
    this.showFallbackUntilReady = true,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return _AndroidSecureImage(
          imageUrl: imageUrl!,
          showFallbackUntilReady: showFallbackUntilReady,
          flutterFallback: child,
        );
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return _IosSecureImage(
          key: ValueKey('${imageUrl}_$instanceId'),
          imageUrl: imageUrl!,
          flutterFallback: child,
          showFallbackUntilReady: showFallbackUntilReady,
        );
      }
    }

    return child;
  }
}

/// iOS: StatefulWidget مع key على الـ URL لضمان dispose صحيح
class _IosSecureImage extends StatefulWidget {
  final String imageUrl;
  final Widget flutterFallback;
  final bool showFallbackUntilReady;

  const _IosSecureImage({
    super.key,
    required this.imageUrl,
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
      // full screen mode: ابدأ الـ UiKitView فوراً بدون delay
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

  @override
  Widget build(BuildContext context) {
    // full screen mode: UiKitView فقط بدون أي fallback في الـ tree
    // الـ container الأسود بيتعرض لحد ما الـ native يجهز ثم بيتشال
    if (!widget.showFallbackUntilReady) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (!_nativeLoaded) Container(color: Colors.black),
          if (_ready && !_disposed)
            UiKitView(
              viewType: 'secure_image_view',
              layoutDirection: TextDirection.ltr,
              creationParams: {'url': widget.imageUrl},
              creationParamsCodec: const StandardMessageCodec(),
              gestureRecognizers:
                  const <Factory<OneSequenceGestureRecognizer>>{},
              onPlatformViewCreated: (_) {
                Future.delayed(const Duration(milliseconds: 150), () {
                  if (mounted && !_disposed) {
                    setState(() => _nativeLoaded = true);
                  }
                });
              },
            ),
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
            child: UiKitView(
              viewType: 'secure_image_view',
              layoutDirection: TextDirection.ltr,
              creationParams: {'url': widget.imageUrl},
              creationParamsCodec: const StandardMessageCodec(),
              gestureRecognizers:
                  const <Factory<OneSequenceGestureRecognizer>>{},
              onPlatformViewCreated: (_) {
                Future.delayed(const Duration(milliseconds: 250), () {
                  if (mounted && !_disposed) {
                    setState(() => _nativeLoaded = true);
                  }
                });
              },
            ),
          ),
      ],
    );
  }
}

/// Android: uses Hybrid Composition so SurfaceView renders correctly
class _AndroidSecureImage extends StatefulWidget {
  final String imageUrl;
  final bool showFallbackUntilReady;
  final Widget flutterFallback;

  const _AndroidSecureImage({
    required this.imageUrl,
    required this.showFallbackUntilReady,
    required this.flutterFallback,
  });

  @override
  State<_AndroidSecureImage> createState() => _AndroidSecureImageState();
}

class _AndroidSecureImageState extends State<_AndroidSecureImage> {
  bool _nativeLoaded = false;

  @override
  Widget build(BuildContext context) {
    final nativeView = PlatformViewLink(
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
            creationParams: {'url': widget.imageUrl},
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () => params.onFocusChanged(true),
          )
          ..addOnPlatformViewCreatedListener((id) {
            params.onPlatformViewCreated(id);
            // تأخير بسيط عشان الـ SurfaceView يكمل الـ render
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) setState(() => _nativeLoaded = true);
            });
          })
          ..create();
      },
    );

    // لو showFallbackUntilReady = false (full screen):
    // نبدأ بـ container أسود وبعدين نعرض الصورة لما تجهز
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

    // الـ cards العادية: نعرض الـ Flutter fallback لحد ما الـ native يجهز
    // الـ fallback بيتشال من الـ tree خالص لما الـ native يجهز
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
