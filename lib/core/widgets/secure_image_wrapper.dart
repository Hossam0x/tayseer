import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// Wraps an image URL with a native secure layer.
/// The image is loaded INSIDE the native secure SurfaceView (Android)
/// or UITextField secure container (iOS).
class SecureImageWrapper extends StatelessWidget {
  final String? imageUrl;
  final Widget child;

  const SecureImageWrapper({super.key, required this.child, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return _AndroidSecureImage(imageUrl: imageUrl!);
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // ✅ Key على الـ URL عشان Flutter يعمل dispose للـ view القديم
        // قبل ما يعمل create للجديد — يمنع PlatformException(recreating_view)
        return _IosSecureImage(
          key: ValueKey(imageUrl),
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

  @override
  void initState() {
    super.initState();
    // ✅ نأخر الـ UiKitView create بـ frame واحد عشان نضمن إن الـ dispose
    // القديم اتم على الـ platform channel قبل ما نعمل create جديد
    // يمنع: PlatformException(recreating_view, trying to create an already created view)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return widget.flutterFallback;
    return UiKitView(
      viewType: 'secure_image_view',
      layoutDirection: TextDirection.ltr,
      creationParams: {'url': widget.imageUrl},
      creationParamsCodec: const StandardMessageCodec(),
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
