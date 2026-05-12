import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Controls FLAG_SECURE on Android to prevent screenshots/screen recording.
///
/// iOS is handled separately via UiKitView(secure_image_view) in SecureImageWrapper.
class SecureWindowService {
  static const _channel = MethodChannel('com.athr.tayser/secure_window');

  // عداد لعدد الـ screens اللي طلبت الحماية
  // بيضمن إن الـ FLAG_SECURE ما يتشالش لو في screen تاني لسه محتاجه
  static int _secureCount = 0;

  /// Enable screenshot protection (call in initState)
  static Future<void> enable() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _secureCount++;
      try {
        await _channel.invokeMethod('enableSecure');
      } catch (_) {}
    }
  }

  /// Disable screenshot protection (call in dispose)
  /// يشيل الحماية بس لو مفيش screen تاني محتاجها
  static Future<void> disable() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _secureCount = (_secureCount - 1).clamp(0, 999);
      if (_secureCount == 0) {
        try {
          await _channel.invokeMethod('disableSecure');
        } catch (_) {}
      }
    }
  }
}
