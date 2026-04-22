import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// Wraps any widget with a native secure layer that makes it appear black
/// in screenshots on both Android and iOS.
///
/// - Android: SurfaceView with setSecure(true) — image shows as black in screenshot
/// - iOS: UITextField with isSecureTextEntry = true — OS-level screenshot protection
class SecureImageWrapper extends StatelessWidget {
  final Widget child;

  const SecureImageWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Stack(
        fit: StackFit.passthrough,
        children: [
          // ✅ الـ Native Secure Surface في الخلف — بيخلي الـ OS يرسم أسود هنا في الـ screenshot
          const AndroidView(
            viewType: 'secure_image_view',
            layoutDirection: TextDirection.ltr,
            creationParamsCodec: StandardMessageCodec(),
          ),
          // ✅ صورتك فوقيه — بتظهر عادي على الشاشة، أسود في الـ screenshot
          child,
        ],
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Stack(
        fit: StackFit.passthrough,
        children: [
          // ✅ الـ Native Secure Container في الخلف
          const UiKitView(
            viewType: 'secure_image_view',
            layoutDirection: TextDirection.ltr,
            creationParamsCodec: StandardMessageCodec(),
          ),
          // ✅ صورتك فوقيه
          child,
        ],
      );
    }

    return child;
  }
}
