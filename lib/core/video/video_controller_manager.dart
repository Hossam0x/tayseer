import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/core/video/video_state_manager.dart';

/// مدير التحكم في الفيديوهات - يضمن تشغيل فيديو واحد فقط مع preloading ذكي
class VideoControllerManager {
  static final VideoControllerManager _instance =
      VideoControllerManager._internal();
  factory VideoControllerManager() => _instance;
  VideoControllerManager._internal();

  final VideoCacheManager _cacheManager = VideoCacheManager();
  final VideoStateManager _stateManager = VideoStateManager();

  // الـ controller النشط حالياً
  VideoPlayerController? _activeController;
  String? _activeVideoId;

  // Controllers محملة مسبقاً
  final Map<String, _PreloadedVideo> _preloadedControllers = {};

  // نستخدم ValueNotifier لنخبر الجميع من هو البوست الذي يعمل حالياً
  final ValueNotifier<String?> currentlyPlayingVideoId = ValueNotifier(null);

  // الحد الأقصى للتحميل المسبق
  static const int _maxPreloadCount = 3;

  // حالة التهيئة
  bool _isInitialized = false;

  /// تهيئة المدير - يجب استدعاؤها في main.dart
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    debugPrint('✅ VideoControllerManager initialized');
  }

  /// الحصول على الـ controller النشط
  VideoPlayerController? get activeController => _activeController;

  /// الحصول على ID الفيديو النشط
  String? get activeVideoId => _activeVideoId;

  /// تشغيل فيديو معين
  // منع recursive retry لا نهائي
  int _retryDepth = 0;
  static const int _maxRetryDepth = 3;

  Future<VideoPlayerController?> playVideo(String videoId, String url) async {
    // نفس الفيديو؟ فقط تأكد أنه يعمل
    if (_activeVideoId == videoId && _activeController != null) {
      try {
        if (_activeController!.value.isInitialized) {
          if (!_activeController!.value.isPlaying) {
            await _activeController!.play();
          }
          currentlyPlayingVideoId.value = videoId;
          return _activeController;
        }
      } catch (e) {
        debugPrint('⚠️ Active controller disposed, re-creating');
        _activeController = null;
        _activeVideoId = null;
      }
    }

    // حفظ موضع الفيديو الحالي قبل التبديل
    _saveCurrentVideoPosition();

    // إيقاف الفيديو الحالي
    await _pauseAndDisposeActive();

    // تحقق من الـ preloaded
    if (_preloadedControllers.containsKey(videoId)) {
      final preloaded = _preloadedControllers.remove(videoId)!;
      _activeController = preloaded.controller;
      _activeVideoId = videoId;

      try {
        if (_activeController!.value.isInitialized) {
          // استرجاع آخر موضع
          await _restoreVideoPosition(videoId);

          await _activeController!.play();
          currentlyPlayingVideoId.value = videoId;
          _stateManager.markAsLoaded(videoId);
          debugPrint('▶️ Playing preloaded video: $videoId');
          _retryDepth = 0;
          return _activeController;
        }
      } catch (e) {
        debugPrint('⚠️ Preloaded controller error: $e');
        try {
          _activeController?.dispose();
        } catch (_) {}
        _activeController = null;
        _activeVideoId = null;
      }
    }

    // إنشاء controller جديد
    try {
      _activeController = await _createController(videoId, url);
      _activeVideoId = videoId;

      if (_activeController != null && _activeController!.value.isInitialized) {
        // استرجاع آخر موضع
        await _restoreVideoPosition(videoId);

        await _activeController!.play();
        currentlyPlayingVideoId.value = videoId;
        _stateManager.markAsLoaded(videoId);
        debugPrint('▶️ Playing new video: $videoId');
      }

      _retryDepth = 0;
      return _activeController;
    } catch (e) {
      debugPrint('❌ Error playing video: $e');

      // تسجيل الخطأ وإعادة المحاولة مع حماية من التكرار اللانهائي
      if (_retryDepth < _maxRetryDepth && _stateManager.recordError(videoId)) {
        _retryDepth++;
        debugPrint('🔄 Retrying video (depth $_retryDepth): $videoId');
        await Future.delayed(Duration(milliseconds: 500 * _retryDepth));
        return playVideo(videoId, url);
      }
      _retryDepth = 0;
      return null;
    }
  }

  /// حفظ موضع الفيديو الحالي
  void _saveCurrentVideoPosition() {
    if (_activeController != null &&
        _activeVideoId != null &&
        _activeController!.value.isInitialized) {
      _stateManager.savePosition(
        _activeVideoId!,
        _activeController!.value.position,
      );
    }
  }

  /// استرجاع آخر موضع للفيديو
  Future<void> _restoreVideoPosition(String videoId) async {
    final lastPosition = _stateManager.getLastPosition(videoId);
    if (lastPosition != null && _activeController != null) {
      await _activeController!.seekTo(lastPosition);
      debugPrint(
        '📍 Restored position for $videoId: ${lastPosition.inSeconds}s',
      );
    }
  }

  /// إنشاء Controller
  Future<VideoPlayerController?> _createController(
    String videoId,
    String url,
  ) async {
    try {
      // محاولة التحميل من الكاش أولاً
      final cachedFile = await _cacheManager.getCachedFile(url);

      VideoPlayerController controller;

      if (cachedFile != null) {
        // من الكاش (أسرع بكثير)
        controller = VideoPlayerController.file(
          cachedFile,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
        );
        debugPrint('📁 Loading from cache: $videoId');
      } else {
        // من الشبكة
        controller = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
        );
        debugPrint('🌐 Loading from network: $videoId');

        // بدء التحميل في الخلفية للكاش بالتوازي
        _cacheManager.preloadVideoInBackground(url);
      }

      await controller.initialize();
      controller.setLooping(true);
      await controller.setVolume(1.0);

      return controller;
    } catch (e) {
      debugPrint('❌ Error creating controller for $videoId: $e');
      return null;
    }
  }

  /// التحميل المسبق للفيديوهات القادمة
  Future<void> preloadVideos(List<VideoItem> upcomingVideos) async {
    // تنظيف القديم
    await _cleanupOldPreloads(upcomingVideos);

    for (var video in upcomingVideos.take(_maxPreloadCount)) {
      if (!_preloadedControllers.containsKey(video.id) &&
          video.id != _activeVideoId) {
        // تحميل الملف في الخلفية أولاً
        _cacheManager.preloadVideoInBackground(video.url);

        // إنشاء controller
        try {
          final controller = await _createController(video.id, video.url);
          if (controller != null && controller.value.isInitialized) {
            _preloadedControllers[video.id] = _PreloadedVideo(
              controller: controller,
              url: video.url,
              createdAt: DateTime.now(),
            );
            debugPrint('⏳ Preloaded video: ${video.id}');
          }
        } catch (e) {
          debugPrint('⚠️ Failed to preload: ${video.id}');
        }
      }
    }
  }

  /// تحميل مسبق لفيديو واحد
  Future<void> preloadSingleVideo(String videoId, String url) async {
    if (_preloadedControllers.containsKey(videoId) ||
        videoId == _activeVideoId) {
      return;
    }

    // تحميل الملف في الخلفية
    _cacheManager.preloadVideoInBackground(url);

    try {
      final controller = await _createController(videoId, url);
      if (controller != null && controller.value.isInitialized) {
        _preloadedControllers[videoId] = _PreloadedVideo(
          controller: controller,
          url: url,
          createdAt: DateTime.now(),
        );
        debugPrint('⏳ Preloaded single video: $videoId');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to preload single: $videoId');
    }
  }

  /// إيقاف مؤقت وتدمير الـ active controller
  Future<void> _pauseAndDisposeActive() async {
    if (_activeController != null) {
      try {
        if (_activeController!.value.isPlaying) {
          await _activeController!.pause();
        }
        await _activeController!.dispose();
      } catch (e) {
        debugPrint('⚠️ Error disposing controller: $e');
      }
      _activeController = null;
      _activeVideoId = null;
      currentlyPlayingVideoId.value = null;
    }
  }

  /// تنظيف الـ preloads القديمة
  Future<void> _cleanupOldPreloads(List<VideoItem> upcomingVideos) async {
    final upcomingIds = upcomingVideos.map((v) => v.id).toSet();
    final toRemove = <String>[];

    _preloadedControllers.forEach((id, preloaded) {
      // إزالة إذا لم يعد في القائمة القادمة أو أقدم من 60 ثانية
      final isOld =
          DateTime.now().difference(preloaded.createdAt).inSeconds > 60;
      if (!upcomingIds.contains(id) || isOld) {
        toRemove.add(id);
      }
    });

    for (var id in toRemove) {
      try {
        await _preloadedControllers[id]?.controller.dispose();
      } catch (e) {
        debugPrint('⚠️ Error disposing preloaded: $e');
      }
      _preloadedControllers.remove(id);
      debugPrint('🗑️ Removed preloaded: $id');
    }
  }

  /// إيقاف الفيديو الحالي (بدون تدمير)
  void pauseCurrent() {
    if (_activeController != null) {
      try {
        if (_activeController!.value.isPlaying) {
          _activeController!.pause();
          debugPrint('⏸️ Paused current video');
        }
      } catch (e) {
        debugPrint('⚠️ Cannot pause, controller disposed: $e');
      }
    }
  }

  /// استئناف الفيديو الحالي
  void resumeCurrent() {
    if (_activeController != null) {
      try {
        if (_activeController!.value.isInitialized &&
            !_activeController!.value.isPlaying) {
          _activeController!.play();
          debugPrint('▶️ Resumed current video');
        }
      } catch (e) {
        debugPrint('⚠️ Cannot resume, controller disposed: $e');
      }
    }
  }

  /// إيقاف كل شيء
  void pauseAll() {
    pauseCurrent();
    currentlyPlayingVideoId.value = null;
  }

  /// إيقاف فيديو معين بناءً على الـ ID
  void stopVideo(String videoId) {
    if (_activeVideoId == videoId) {
      _saveCurrentVideoPosition();
      pauseCurrent();
    }
  }

  /// هل الفيديو نشط حالياً؟
  bool isVideoActive(String videoId) {
    return _activeVideoId == videoId &&
        _activeController != null &&
        _activeController!.value.isPlaying;
  }

  /// إعادة تعيين خطأ فيديو (للسماح بإعادة المحاولة)
  void resetVideoError(String videoId) {
    _stateManager.resetErrorCount(videoId);
  }

  /// التنظيف الكامل
  Future<void> dispose() async {
    _saveCurrentVideoPosition();
    await _pauseAndDisposeActive();

    for (var preloaded in _preloadedControllers.values) {
      try {
        await preloaded.controller.dispose();
      } catch (e) {
        debugPrint('⚠️ Error disposing: $e');
      }
    }
    _preloadedControllers.clear();
    _stateManager.cleanupOldStates();
    debugPrint('🧹 VideoControllerManager disposed');
  }
}

/// نموذج للفيديو المحمل مسبقاً
class _PreloadedVideo {
  final VideoPlayerController controller;
  final String url;
  final DateTime createdAt;

  _PreloadedVideo({
    required this.controller,
    required this.url,
    required this.createdAt,
  });
}

/// نموذج بسيط للفيديو
class VideoItem {
  final String id;
  final String url;

  VideoItem({required this.id, required this.url});
}
