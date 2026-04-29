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

  const SecureImageWrapper({
    super.key,
    required this.child,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return _AndroidSecureImage(imageUrl: imageUrl!);
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return UiKitView(
          viewType: 'secure_image_view',
          layoutDirection: TextDirection.ltr,
          creationParams: {'url': imageUrl},
          creationParamsCodec: const StandardMessageCodec(),
        );
      }
    }

    return child;
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
