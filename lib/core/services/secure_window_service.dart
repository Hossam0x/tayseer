import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Controls FLAG_SECURE on Android to prevent screenshots/screen recording
/// on the entire marriage screen.
///
/// iOS is handled separately via UITextField(isSecureTextEntry) in AppDelegate.
class SecureWindowService {
  static const _channel = MethodChannel('com.athr.tayser/secure_window');

  /// Enable screenshot protection (call in initState)
  static Future<void> enable() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _channel.invokeMethod('enableSecure');
      } catch (_) {}
    }
  }

  /// Disable screenshot protection (call in dispose)
  static Future<void> disable() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _channel.invokeMethod('disableSecure');
      } catch (_) {}
    }
  }
}
