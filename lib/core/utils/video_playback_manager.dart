import 'package:flutter/foundation.dart';
import 'package:tayseer/core/video/video_controller_manager.dart';

/// مدير بسيط للفيديو النشط - يعمل كـ facade للـ VideoControllerManager
class VideoManager {
  static final VideoManager instance = VideoManager._internal();

  VideoManager._internal();

  final VideoControllerManager _controllerManager = VideoControllerManager();

  // نستخدم ValueNotifier لنخبر الجميع من هو البوست الذي يعمل حالياً
  ValueNotifier<String?> get currentlyPlayingPostId =>
      _controllerManager.currentlyPlayingVideoId;

  void playVideo(String postId) {
    if (currentlyPlayingPostId.value != postId) {
      currentlyPlayingPostId.value = postId;
      debugPrint('▶️ VideoManager: Playing $postId');
    }
  }

  void stopVideo(String postId) {
    if (currentlyPlayingPostId.value == postId) {
      _controllerManager.stopVideo(postId);
      debugPrint('⏹️ VideoManager: Stopped $postId');
    }
  }

  void stopAll() {
    _controllerManager.pauseAll();
    debugPrint('⏹️ VideoManager: Stopped all');
  }

  /// هل الفيديو نشط؟
  bool isPlaying(String postId) {
    return currentlyPlayingPostId.value == postId;
  }
}
