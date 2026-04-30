import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// FeedVideoPreloader — Facebook Newsfeed strategy
///
/// بيعمل pre-initialize للـ VideoPlayerControllers للفيديوهات القادمة في الـ feed
/// عشان لما اليوزر يوصل للفيديو يلاقيه جاهز فوراً بدون أي تأخير.
///
/// Strategy:
/// - بيحتفظ بـ window من الـ controllers (current ± preloadAhead)
/// - بيعمل dispose للـ controllers البعيدة عن الـ window
/// - بيستخدم Completer dedup لمنع double-init لنفس الفيديو
/// ═══════════════════════════════════════════════════════════════════════════
class FeedVideoPreloader {
  static final FeedVideoPreloader instance = FeedVideoPreloader._internal();
  FeedVideoPreloader._internal();

  final VideoCacheManager _cacheManager = VideoCacheManager();

  // الـ controllers الجاهزة — key: postId
  final Map<String, _PreloadedController> _controllers = {};

  // Completers لمنع double-init
  final Map<String, Completer<VideoPlayerController?>> _pending = {};

  // الـ posts الحالية في الـ feed
  List<PostModel> _feedPosts = [];

  // عدد الفيديوهات اللي نحملها قدام
  static const int _preloadAhead = 3;

  // عدد الفيديوهات اللي نحتفظ بيها ورا (عشان لو رجع)
  static const int _keepBehind = 1;

  // الحد الأقصى للـ controllers في الذاكرة
  static const int _maxControllers = 5;

  // آخر index شافه اليوزر
  int _lastVisibleIndex = -1;

  bool _isDisposed = false;

  // ═══════════════════════════════════════════════════════════════════
  // Public API
  // ═══════════════════════════════════════════════════════════════════

  /// تحديث قائمة الـ posts في الـ feed
  void updateFeedPosts(List<PostModel> posts) {
    if (_isDisposed) return;
    _feedPosts = posts;

    // ابدأ preload للفيديوهات الأولى فوراً
    if (_lastVisibleIndex == -1 && posts.isNotEmpty) {
      _triggerPreload(0);
    }
  }

  /// اليوزر وصل لـ post معين — trigger preload للقادمين
  void onPostVisible(String postId) {
    if (_isDisposed) return;

    final index = _feedPosts.indexWhere((p) => p.postId == postId);
    if (index == -1) return;

    if (index == _lastVisibleIndex) return;
    _lastVisibleIndex = index;

    _triggerPreload(index);
  }

  /// الحصول على controller جاهز لـ post معين (لو موجود)
  VideoPlayerController? getReadyController(String postId) {
    final preloaded = _controllers[postId];
    if (preloaded == null) return null;
    if (!preloaded.controller.value.isInitialized) return null;
    return preloaded.controller;
  }

  /// هل الـ controller جاهز؟
  bool isReady(String postId) {
    return _controllers[postId]?.controller.value.isInitialized == true;
  }

  /// إيقاف كل الفيديوهات الشغالة (لما التطبيق يروح للخلفية)
  void pauseAll() {
    if (_isDisposed) return;
    for (final preloaded in _controllers.values) {
      try {
        final ctrl = preloaded.controller;
        if (ctrl.value.isInitialized && ctrl.value.isPlaying) {
          ctrl.pause();
          debugPrint('⏸️ Preloader paused: ${preloaded.postId}');
        }
      } catch (_) {}
    }
  }

  /// إعادة تعيين عند الـ refresh
  Future<void> reset() async {
    _isDisposed = false; // إعادة تفعيل بعد الـ reset
    _lastVisibleIndex = -1;
    _feedPosts = [];
    await _disposeAll();
  }

  /// تنظيف كامل
  Future<void> dispose() async {
    _isDisposed = true;
    await _disposeAll();
  }

  // ═══════════════════════════════════════════════════════════════════
  // Internal Logic
  // ═══════════════════════════════════════════════════════════════════

  void _triggerPreload(int visibleIndex) {
    if (_isDisposed) return;

    // حدد الـ window
    final start = (visibleIndex - _keepBehind).clamp(0, _feedPosts.length - 1);
    final end = (visibleIndex + _preloadAhead).clamp(0, _feedPosts.length - 1);

    // dispose الـ controllers خارج الـ window
    _evictOutOfWindow(start, end);

    // preload الـ controllers في الـ window
    for (int i = start; i <= end; i++) {
      final post = _feedPosts[i];
      if (_isVideoPost(post)) {
        _preloadController(post);
      }
    }
  }

  bool _isVideoPost(PostModel post) {
    final url = post.videoData?.video ?? post.videoUrl ?? '';
    return url.isNotEmpty &&
        (post.contentType == PostContentType.reel ||
            post.contentType == PostContentType.post);
  }

  Future<void> _preloadController(PostModel post) async {
    if (_isDisposed) return;

    final postId = post.postId;
    final url = post.videoData?.video ?? post.videoUrl ?? '';
    if (url.isEmpty) return;

    // موجود بالفعل؟
    if (_controllers.containsKey(postId)) return;

    // بيتحمل حالياً؟
    if (_pending.containsKey(postId)) return;

    // تجاوز الحد الأقصى؟
    if (_controllers.length >= _maxControllers) return;

    final completer = Completer<VideoPlayerController?>();
    _pending[postId] = completer;

    // helper آمن — بيتحقق قبل ما يعمل complete
    void safeComplete(VideoPlayerController? value) {
      if (!completer.isCompleted) completer.complete(value);
    }

    VideoPlayerController? createdController;

    try {
      // حمّل الملف في الخلفية أولاً (بدون انتظار)
      _cacheManager.preloadVideoInBackground(url);

      // حاول تجيب الملف من الكاش
      final cachedFile = await _cacheManager.getCachedFile(url);

      // تحقق بعد كل await — ممكن يكون اتعمل evict أو dispose في الأثناء
      if (_isDisposed || !_pending.containsKey(postId)) {
        safeComplete(null);
        _pending.remove(postId);
        return;
      }

      VideoPlayerController controller;
      if (cachedFile != null) {
        controller = VideoPlayerController.file(
          cachedFile,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: false,
            allowBackgroundPlayback: false,
          ),
        );
        debugPrint('📁 Preloading from cache: $postId');
      } else {
        controller = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: false,
            allowBackgroundPlayback: false,
          ),
        );
        debugPrint('🌐 Preloading from network: $postId');
      }

      createdController = controller;
      await controller.initialize();

      // تحقق تاني بعد initialize (أطول عملية)
      if (_isDisposed || !_pending.containsKey(postId)) {
        try {
          controller.dispose();
        } catch (_) {}
        createdController = null;
        safeComplete(null);
        _pending.remove(postId);
        return;
      }

      // إعداد الـ controller
      await controller.setLooping(true);
      await controller.setVolume(0.0); // صامت حتى يبدأ التشغيل الفعلي
      await controller.pause(); // متوقف حتى يظهر على الشاشة

      // تحقق أخير قبل الحفظ
      if (_isDisposed || !_pending.containsKey(postId)) {
        try {
          controller.dispose();
        } catch (_) {}
        createdController = null;
        safeComplete(null);
        _pending.remove(postId);
        return;
      }

      _controllers[postId] = _PreloadedController(
        controller: controller,
        postId: postId,
        createdAt: DateTime.now(),
      );

      safeComplete(controller);
      debugPrint('✅ Preloaded controller ready: $postId');
    } catch (e) {
      debugPrint('⚠️ Failed to preload controller for $postId: $e');
      // dispose الـ controller لو اتعمل قبل الخطأ
      if (createdController != null) {
        try {
          createdController.dispose();
        } catch (_) {}
        createdController = null;
      }
      safeComplete(null);
    } finally {
      _pending.remove(postId);
    }
  }

  void _evictOutOfWindow(int windowStart, int windowEnd) {
    final windowIds = <String>{};
    for (int i = windowStart; i <= windowEnd; i++) {
      windowIds.add(_feedPosts[i].postId);
    }

    final toEvict = _controllers.keys
        .where((id) => !windowIds.contains(id))
        .toList();

    for (final id in toEvict) {
      _disposeController(id);
    }

    // كمان cancel الـ pending اللي خارج الـ window
    final pendingToCancel = _pending.keys
        .where((id) => !windowIds.contains(id))
        .toList();
    for (final id in pendingToCancel) {
      final c = _pending.remove(id);
      if (c != null && !c.isCompleted) c.complete(null);
    }
  }

  void _disposeController(String postId) {
    final preloaded = _controllers.remove(postId);
    if (preloaded == null) return;

    try {
      final ctrl = preloaded.controller;
      if (ctrl.value.isInitialized) {
        ctrl.setVolume(0.0);
        if (ctrl.value.isPlaying) ctrl.pause();
      }
      ctrl.dispose();
      debugPrint('🗑️ Evicted preloaded controller: $postId');
    } catch (e) {
      debugPrint('⚠️ Error evicting controller $postId: $e');
    }
  }

  Future<void> _disposeAll() async {
    // Cancel all pending — safe check قبل complete
    final pendingEntries = Map<String, Completer<VideoPlayerController?>>.from(
      _pending,
    );
    _pending.clear();
    for (final completer in pendingEntries.values) {
      if (!completer.isCompleted) completer.complete(null);
    }

    // Dispose all controllers
    final ids = _controllers.keys.toList();
    for (final id in ids) {
      _disposeController(id);
    }
    _controllers.clear();
  }
}

class _PreloadedController {
  final VideoPlayerController controller;
  final String postId;
  final DateTime createdAt;

  _PreloadedController({
    required this.controller,
    required this.postId,
    required this.createdAt,
  });
}
