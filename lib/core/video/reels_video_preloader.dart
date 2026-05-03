import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// ReelsVideoPreloader — Sliding Window Strategy
///
/// بيحتفظ بـ sliding window من الـ initialized controllers:
///   [current-keepBehind  ...  current  ...  current+preloadAhead]
///
/// لما اليوزر يقلب للأمام:
///   - يضيف controller جديد في آخر الـ window
///   - يشيل الـ controller الأقدم ورا (اللي بعيد عن الـ current)
///
/// النتيجة: اليوزر دايماً بيلاقي الفيديو الجاي جاهز فوراً.
/// ═══════════════════════════════════════════════════════════════════════════
class ReelsVideoPreloader {
  static final ReelsVideoPreloader instance = ReelsVideoPreloader._internal();
  ReelsVideoPreloader._internal();

  final VideoCacheManager _cacheManager = VideoCacheManager();

  // الـ controllers الجاهزة — key: postId
  final Map<String, _PreloadedReelController> _controllers = {};

  // Queue مرتبة بالـ index عشان نعرف مين الأقدم
  final Queue<String> _loadOrder = Queue<String>();

  // Completers لمنع double-init لنفس الفيديو
  final Map<String, Completer<VideoPlayerController?>> _pending = {};

  // الـ reels الحالية
  List<PostModel> _reels = [];

  // ─── Window Settings ───────────────────────────────────────────────
  // عدد الفيديوهات اللي نحملها قدام الـ current
  static const int _preloadAhead = 4;

  // عدد الفيديوهات اللي نحتفظ بيها ورا الـ current (للرجوع)
  static const int _keepBehind = 1;

  // الحد الأقصى للـ controllers في الذاكرة = preloadAhead + keepBehind + 1 (current)
  static const int _maxControllers = _preloadAhead + _keepBehind + 1;

  // آخر index شافه اليوزر
  int _lastVisibleIndex = -1;

  bool _isDisposed = false;

  // ═══════════════════════════════════════════════════════════════════
  // Public API
  // ═══════════════════════════════════════════════════════════════════

  /// تحديث قائمة الـ reels — يبدأ preload للأولى فوراً
  void updateReels(List<PostModel> reels) {
    if (_isDisposed) return;
    _reels = reels;

    if (_lastVisibleIndex == -1 && reels.isNotEmpty) {
      _triggerPreload(0);
    }
  }

  /// اليوزر وصل لـ reel معين — يحدّث الـ window
  void onReelVisible(int index) {
    if (_isDisposed) return;
    if (index < 0 || index >= _reels.length) return;
    if (index == _lastVisibleIndex) return;

    _lastVisibleIndex = index;
    _triggerPreload(index);
  }

  /// ✅ Transfer of ownership — يشيل الـ controller من الـ preloader ويديه للـ caller
  /// الـ caller بيبقى مسؤول عن dispose الـ controller
  VideoPlayerController? claimController(String postId) {
    final preloaded = _controllers.remove(postId);
    _loadOrder.remove(postId);

    if (preloaded == null) return null;

    // Guard: تحقق إن الـ controller لسه valid
    try {
      if (!preloaded.controller.value.isInitialized) {
        try {
          preloaded.controller.dispose();
        } catch (_) {}
        return null;
      }
      void probe() {}
      preloaded.controller.addListener(probe);
      preloaded.controller.removeListener(probe);
    } catch (e) {
      debugPrint('⚠️ Claimed controller for $postId was disposed: $e');
      return null;
    }

    debugPrint('🤝 Claimed preloaded controller: $postId');
    return preloaded.controller;
  }

  /// الحصول على controller جاهز بدون نقل الملكية (للـ peek فقط)
  VideoPlayerController? getReadyController(String postId) {
    final preloaded = _controllers[postId];
    if (preloaded == null) return null;

    try {
      if (!preloaded.controller.value.isInitialized) return null;
      void probe() {}
      preloaded.controller.addListener(probe);
      preloaded.controller.removeListener(probe);
    } catch (e) {
      _controllers.remove(postId);
      _loadOrder.remove(postId);
      return null;
    }

    return preloaded.controller;
  }

  /// هل الـ controller جاهز؟
  bool isReady(String postId) =>
      _controllers[postId]?.controller.value.isInitialized == true;

  /// إيقاف كل الفيديوهات (لما التطبيق يروح للخلفية)
  void pauseAll() {
    if (_isDisposed) return;
    for (final preloaded in _controllers.values) {
      try {
        final ctrl = preloaded.controller;
        if (ctrl.value.isInitialized && ctrl.value.isPlaying) {
          ctrl.pause();
        }
      } catch (_) {}
    }
  }

  /// إعادة تعيين عند الـ refresh أو تغيير الـ tab
  Future<void> reset() async {
    _isDisposed = false;
    _lastVisibleIndex = -1;
    _reels = [];
    _loadOrder.clear();
    await _disposeAll();
  }

  /// تنظيف كامل
  Future<void> dispose() async {
    _isDisposed = true;
    _loadOrder.clear();
    await _disposeAll();
  }

  // ═══════════════════════════════════════════════════════════════════
  // Internal — Sliding Window Logic
  // ═══════════════════════════════════════════════════════════════════

  void _triggerPreload(int visibleIndex) {
    if (_isDisposed) return;

    // حدد الـ window الجديدة
    final windowStart = (visibleIndex - _keepBehind).clamp(
      0,
      _reels.length - 1,
    );
    final windowEnd = (visibleIndex + _preloadAhead).clamp(
      0,
      _reels.length - 1,
    );

    final windowIds = <String>{};
    for (int i = windowStart; i <= windowEnd; i++) {
      windowIds.add(_reels[i].postId);
    }

    // ─── Evict: شيل الـ controllers اللي خارج الـ window ───
    // بنستخدم الـ _loadOrder عشان نشيل الأقدم أولاً
    _evictOutsideWindow(windowIds);

    // ─── Preload: حمّل الـ controllers الجديدة في الـ window ───
    // نبدأ من الـ current وروح للأمام (الأولوية للقادمين)
    for (int i = visibleIndex; i <= windowEnd; i++) {
      _preloadController(_reels[i]);
    }
    // بعدين الـ keepBehind (أولوية أقل)
    for (int i = windowStart; i < visibleIndex; i++) {
      _preloadController(_reels[i]);
    }
  }

  Future<void> _preloadController(PostModel post) async {
    if (_isDisposed) return;

    final postId = post.postId;
    final url = post.videoUrl ?? '';
    if (url.isEmpty) return;

    // موجود بالفعل؟
    if (_controllers.containsKey(postId)) return;

    // بيتحمل حالياً؟
    if (_pending.containsKey(postId)) return;

    // تجاوز الحد الأقصى؟ — شيل الأقدم أولاً
    if (_controllers.length >= _maxControllers) {
      _evictOldest();
      // لو لسه ممتلي (كل الـ controllers محمية)، skip
      if (_controllers.length >= _maxControllers) return;
    }

    final completer = Completer<VideoPlayerController?>();
    _pending[postId] = completer;

    void safeComplete(VideoPlayerController? value) {
      if (!completer.isCompleted) completer.complete(value);
    }

    VideoPlayerController? createdController;

    try {
      // حمّل الملف في الخلفية أولاً (بدون انتظار)
      _cacheManager.preloadVideoInBackground(url);

      // حاول تجيب الملف من الكاش
      final cachedFile = await _cacheManager.getCachedFile(url);

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
        debugPrint('📁 Reels preloading from cache: $postId');
      } else {
        controller = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: false,
            allowBackgroundPlayback: false,
          ),
        );
        debugPrint('🌐 Reels preloading from network: $postId');
      }

      createdController = controller;
      await controller.initialize();

      if (_isDisposed || !_pending.containsKey(postId)) {
        try {
          controller.dispose();
        } catch (_) {}
        createdController = null;
        safeComplete(null);
        _pending.remove(postId);
        return;
      }

      // تحقق تاني إن الـ window مش ممتلية بعد الـ await
      if (_controllers.length >= _maxControllers) {
        _evictOldest();
        if (_controllers.length >= _maxControllers) {
          try {
            controller.dispose();
          } catch (_) {}
          createdController = null;
          safeComplete(null);
          _pending.remove(postId);
          return;
        }
      }

      await controller.setLooping(true);
      await controller.setVolume(0.0); // صامت حتى يبدأ التشغيل الفعلي
      await controller.pause(); // متوقف حتى يظهر على الشاشة

      if (_isDisposed || !_pending.containsKey(postId)) {
        try {
          controller.dispose();
        } catch (_) {}
        createdController = null;
        safeComplete(null);
        _pending.remove(postId);
        return;
      }

      _controllers[postId] = _PreloadedReelController(
        controller: controller,
        postId: postId,
        createdAt: DateTime.now(),
      );
      _loadOrder.addLast(postId); // ✅ سجّل الترتيب

      safeComplete(controller);
      debugPrint(
        '✅ Reels preloaded controller ready: $postId '
        '(${_controllers.length}/$_maxControllers)',
      );
    } catch (e) {
      debugPrint('⚠️ Failed to preload reel controller for $postId: $e');
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

  /// ✅ Sliding window eviction — شيل الـ controllers خارج الـ window
  /// بنستخدم delay عشان ندي الـ ReelsVideoBackground فرصة يعمل claimController
  void _evictOutsideWindow(Set<String> windowIds) {
    final toEvict = _controllers.keys
        .where((id) => !windowIds.contains(id))
        .toList();

    if (toEvict.isEmpty) return;

    // cancel الـ pending اللي خارج الـ window فوراً
    final pendingToCancel = _pending.keys
        .where((id) => !windowIds.contains(id))
        .toList();
    for (final id in pendingToCancel) {
      final c = _pending.remove(id);
      if (c != null && !c.isCompleted) c.complete(null);
    }

    // ✅ Delay الـ evict عشان ندي الـ widget فرصة يعمل claimController
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_isDisposed) return;
      for (final id in toEvict) {
        if (_controllers.containsKey(id)) {
          _disposeController(id);
        }
      }
    });
  }

  /// شيل الـ controller الأقدم في الـ queue (FIFO)
  void _evictOldest() {
    while (_loadOrder.isNotEmpty) {
      final oldest = _loadOrder.removeFirst();
      if (_controllers.containsKey(oldest)) {
        _disposeController(oldest);
        return;
      }
    }
  }

  void _disposeController(String postId) {
    _loadOrder.remove(postId);
    final preloaded = _controllers.remove(postId);
    if (preloaded == null) return;

    try {
      final ctrl = preloaded.controller;
      if (ctrl.value.isInitialized) {
        ctrl.setVolume(0.0);
        if (ctrl.value.isPlaying) ctrl.pause();
      }
      ctrl.dispose();
      debugPrint('🗑️ Evicted reels controller: $postId');
    } catch (e) {
      debugPrint('⚠️ Error evicting reel controller $postId: $e');
    }
  }

  Future<void> _disposeAll() async {
    // Cancel all pending
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
    _loadOrder.clear();
  }
}

class _PreloadedReelController {
  final VideoPlayerController controller;
  final String postId;
  final DateTime createdAt;

  _PreloadedReelController({
    required this.controller,
    required this.postId,
    required this.createdAt,
  });
}
