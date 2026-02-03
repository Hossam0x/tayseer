import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoControllerCache {
  static final VideoControllerCache _instance =
      VideoControllerCache._internal();
  factory VideoControllerCache() => _instance;
  VideoControllerCache._internal();

  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, ValueNotifier<bool>> _initializationStatus = {};

  VideoPlayerController? getController(String videoUrl) {
    return _controllers[videoUrl];
  }

  ValueNotifier<bool> getInitializationStatus(String videoUrl) {
    return _initializationStatus.putIfAbsent(
      videoUrl,
      () => ValueNotifier<bool>(false),
    );
  }

  void setController(String videoUrl, VideoPlayerController controller) {
    // حذف الـ controller القديم لو موجود
    if (_controllers.containsKey(videoUrl)) {
      _controllers[videoUrl]?.dispose();
    }
    _controllers[videoUrl] = controller;
  }

  void removeController(String videoUrl) {
    _controllers[videoUrl]?.dispose();
    _controllers.remove(videoUrl);
    _initializationStatus.remove(videoUrl);
  }

  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _initializationStatus.clear();
  }
}
