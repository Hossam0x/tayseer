import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

/// Wraps an image URL with a native secure layer.
/// The image is loaded INSIDE the native secure SurfaceView (Android)
/// or UITextField secure container (iOS).
/// [instanceId] — optional suffix للـ key عشان يمنع recreating_view
/// لما نفس الـ URL يتعرض في أكتر من مكان في نفس الوقت (مثلاً card + full screen)
class SecureImageWrapper extends StatelessWidget {
  final String? imageUrl;
  final Widget child;
  final String instanceId;

  const SecureImageWrapper({
    super.key,
    required this.child,
    this.imageUrl,
    this.instanceId = 'default',
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return _AndroidSecureImage(imageUrl: imageUrl!);
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Key = url + instanceId عشان card وfull screen يكون ليهم views مستقلة
        return _IosSecureImage(
          key: ValueKey('${imageUrl}_$instanceId'),
          imageUrl: imageUrl!,
          flutterFallback: child,
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

  const _IosSecureImage({
    super.key,
    required this.imageUrl,
    required this.flutterFallback,
  });

  @override
  State<_IosSecureImage> createState() => _IosSecureImageState();
}

class _IosSecureImageState extends State<_IosSecureImage> {
  bool _ready = false;
  bool _nativeLoaded = false;
  // debounce flag لمنع PlatformException(recreating_view)
  Timer? _readyTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // تأخير بسيط يمنع recreating_view لما الـ widget يتبني بسرعة
      _readyTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _ready = true);
      });
    });
  }

  @override
  void dispose() {
    _readyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // الـ fallback بيتخفى بـ fade ناعم
        AnimatedOpacity(
          opacity: _nativeLoaded ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: widget.flutterFallback,
        ),

        // الـ UiKitView بيبدأ بـ opacity 0 ويتظهر تدريجياً
        if (_ready)
          AnimatedOpacity(
            opacity: _nativeLoaded ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: UiKitView(
              viewType: 'secure_image_view',
              layoutDirection: TextDirection.ltr,
              creationParams: {'url': widget.imageUrl},
              creationParamsCodec: const StandardMessageCodec(),
              // ✅ empty gestureRecognizers — يخلي Flutter يمسك الـ tap
              // EagerGestureRecognizer كانت بتكسب الـ arena قبل الـ GestureDetector
              gestureRecognizers:
                  const <Factory<OneSequenceGestureRecognizer>>{},
              onPlatformViewCreated: (_) {
                Future.delayed(const Duration(milliseconds: 250), () {
                  if (mounted) setState(() => _nativeLoaded = true);
                });
              },
            ),
          ),
      ],
    );
  }
}

/// Android: uses Hybrid Composition so SurfaceView renders correctly
class _AndroidSecureImage extends StatelessWidget {
  final String imageUrl;

  const _AndroidSecureImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return PlatformViewLink(
      viewType: 'secure_image_view',
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: 'secure_image_view',
            layoutDirection: TextDirection.ltr,
            creationParams: {'url': imageUrl},
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () => params.onFocusChanged(true),
          )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }
}
