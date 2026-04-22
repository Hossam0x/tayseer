import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// يراقب الـ screenshot على Android عبر EventChannel
/// وعلى iOS عبر AppLifecycleState.inactive
class ScreenshotDetector {
  static const _eventChannel =
      EventChannel('com.athr.tayser/screenshot_events');

  static StreamSubscription? _subscription;
  static final ValueNotifier<bool> isScreenshotActive =
      ValueNotifier<bool>(false);

  static void init() {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    _subscription?.cancel();
    _subscription = _eventChannel.receiveBroadcastStream().listen((event) {
      isScreenshotActive.value = event as bool;
    });
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
