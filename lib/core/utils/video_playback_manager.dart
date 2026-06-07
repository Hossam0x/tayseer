import 'package:flutter/foundation.dart';
import 'package:tayseer/core/video/video_controller_manager.dart';

/// مدير بسيط للفيديو النشط - يعمل كـ facade للـ VideoControllerManager
class VideoManager {
  static final VideoManager instance = VideoManager._internal();

  VideoManager._internal();

  final VideoControllerManager _controllerManager = VideoControllerManager();

  // ✅ flag لمنع الفيديوهات من الاشتغال أثناء الـ refresh
  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  // ✅ Incremented every time stopAll() disposes all controllers.
  // RealVideoPlayer listens to this notifier and immediately nulls its
  // _controller reference so no stale platform ID reaches VideoPlayer.build().
  final ValueNotifier<int> evictionGeneration = ValueNotifier<int>(0);

  // نستخدم ValueNotifier لنخبر الجميع من هو البوست الذي يعمل حالياً
  ValueNotifier<String?> get currentlyPlayingPostId =>
      _controllerManager.currentlyPlayingVideoId;

  void playVideo(String postId) {
    // ✅ منع التشغيل أثناء الـ refresh
    if (_isRefreshing) {
      debugPrint('🚫 VideoManager: Blocked play during refresh for $postId');
      return;
    }
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

  /// ✅ وقّف الفيديو الحالي بس — بدون dispose أو refresh lock
  /// استخدمه عند تغيير الـ tab أو الانتقال لصفحة تانية
  void pauseAll() {
    currentlyPlayingPostId.value = null;
    _controllerManager.pauseAll();
    debugPrint('⏸️ VideoManager: Paused all (no dispose)');
  }

  Future<void> stopAll() async {
    _isRefreshing = true;
    debugPrint('🔒 VideoManager: Refresh lock ON');

    // ✅ Notify all RealVideoPlayer widgets that their controllers are about
    // to be destroyed. They listen to evictionGeneration and will null their
    // _controller reference before the next build frame, preventing
    // "Bad state: No active player with ID X" during the subsequent rebuild.
    evictionGeneration.value++;

    // ✅ تعيين null بدون إطلاق الـ listeners — الـ listeners هتتجاهل الـ event
    // لأن isRefreshing = true، لكن نضمن إن الـ value محدّث قبل disposeAll
    currentlyPlayingPostId.value = null;

    await _controllerManager.disposeAll();
    debugPrint('⏹️ VideoManager: Stopped and disposed all');

    // ✅ رفع الـ lock بعد تأخير كافٍ عشان الـ widgets تتحدث وتعيد البناء
    Future.delayed(const Duration(milliseconds: 300), () {
      _isRefreshing = false;
      debugPrint('🔓 VideoManager: Refresh lock OFF');
    });
  }

  /// هل الفيديو نشط؟
  bool isPlaying(String postId) {
    return currentlyPlayingPostId.value == postId;
  }
}
