import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// StoryVideoPreloader — pre-initializes VideoPlayerControllers for story
/// videos so the user never sees a loading spinner when swiping stories.
///
/// Strategy (mirrors FeedVideoPreloader):
///  • When the story screen opens, call [preloadForUser] with the full list
///    of story video URLs for the current + adjacent users.
///  • When the user swipes to a new story index, call [onStoryVisible] so
///    the window shifts and the next videos are pre-initialized.
///  • [getReadyController] returns an already-initialized controller (or null
///    if not ready yet) — StoryVideoMuted checks this first.
///  • Controllers outside the window are disposed automatically.
/// ═══════════════════════════════════════════════════════════════════════════
class StoryVideoPreloader {
  static final StoryVideoPreloader instance = StoryVideoPreloader._internal();
  StoryVideoPreloader._internal();

  final VideoCacheManager _cacheManager = VideoCacheManager();

  // key: video URL → ready controller
  final Map<String, _PreloadedVideo> _controllers = {};

  // Completers to prevent double-init for the same URL
  final Map<String, Completer<VideoPlayerController?>> _pending = {};

  // Current ordered list of video URLs being tracked
  List<String> _urls = [];

  // How many videos ahead to pre-initialize
  static const int _preloadAhead = 2;

  // How many videos behind to keep (for back-swipe)
  static const int _keepBehind = 1;

  // Max controllers in memory at once
  static const int _maxControllers = 6;

  int _lastVisibleIndex = -1;

  // ═══════════════════════════════════════════════════════════════════
  // Public API
  // ═══════════════════════════════════════════════════════════════════

  /// Call this when the story screen opens (or when the user list changes).
  /// [urls] is the ordered list of video URLs for the current user's stories.
  /// [startIndex] is the index of the first visible story.
  void preloadForUser(List<String> urls, {int startIndex = 0}) {
    _urls = urls.where((u) => u.isNotEmpty).toList();
    _lastVisibleIndex = -1; // reset so onStoryVisible triggers a full window
    if (_urls.isNotEmpty) {
      _triggerPreload(startIndex.clamp(0, _urls.length - 1));
    }
  }

  /// Call this right after the stories API fetch succeeds.
  /// Extracts all video URLs from [allUsers] and starts background
  /// file-download + controller pre-initialization immediately,
  /// so by the time the user taps a story ring everything is ready.
  void preloadFromStories(List<UserStoriesModel> allUsers) {
    final videoUrls = <String>[];
    for (final user in allUsers) {
      for (final story in user.stories) {
        if (!story.isPostStory && story.video?.isNotEmpty == true) {
          videoUrls.add(story.video!);
        }
        // Warm CachedNetworkImage disk + memory cache for images
        if (!story.isPostStory &&
            (story.video?.isEmpty ?? true) &&
            story.image.isNotEmpty) {
          CachedNetworkImageProvider(
            story.image,
          ).resolve(const ImageConfiguration());
        }
      }
    }
    if (videoUrls.isEmpty) return;
    // Kick off background file downloads for all videos (no-op if cached)
    for (final url in videoUrls) {
      _cacheManager.preloadVideoInBackground(url);
    }
    // Pre-initialize controllers for the first window
    _urls = videoUrls;
    _lastVisibleIndex = -1;
    _triggerPreload(0);
  }

  /// Call this when the user swipes to a new story index within a user's list.
  void onStoryVisible(int index) {
    if (index == _lastVisibleIndex) return;
    _lastVisibleIndex = index;
    _triggerPreload(index);
  }

  /// Returns a ready [VideoPlayerController] for [url], or null if not ready.
  /// The caller must NOT dispose this controller — the preloader owns it.
  VideoPlayerController? getReadyController(String url) {
    final preloaded = _controllers[url];
    if (preloaded == null) return null;

    try {
      if (!preloaded.controller.value.isInitialized) return null;
      // Probe to confirm the controller is still alive
      void probe() {}
      preloaded.controller.addListener(probe);
      preloaded.controller.removeListener(probe);
    } catch (e) {
      debugPrint('⚠️ StoryPreloader: stale controller for $url, removing');
      _controllers.remove(url);
      return null;
    }

    return preloaded.controller;
  }

  /// Whether a controller for [url] is ready.
  bool isReady(String url) =>
      _controllers[url]?.controller.value.isInitialized == true;

  /// Pause all preloaded controllers (e.g. app goes to background).
  void pauseAll() {
    for (final p in _controllers.values) {
      try {
        if (p.controller.value.isInitialized && p.controller.value.isPlaying) {
          p.controller.pause();
        }
      } catch (_) {}
    }
  }

  /// Release a specific controller back to the preloader pool after the
  /// StoryVideoMuted widget is done with it (i.e. on dispose).
  /// The controller is paused + muted but kept alive for re-use.
  void releaseController(String url) {
    final p = _controllers[url];
    if (p == null) return;
    try {
      if (p.controller.value.isInitialized) {
        p.controller.pause();
        p.controller.setVolume(0.0);
        p.controller.seekTo(Duration.zero);
      }
    } catch (_) {}
  }

  /// Clear everything — call when the story screen is fully closed.
  Future<void> clear() async {
    _urls = [];
    _lastVisibleIndex = -1;
    await _disposeAll();
  }

  // ═══════════════════════════════════════════════════════════════════
  // Internal
  // ═══════════════════════════════════════════════════════════════════

  void _triggerPreload(int visibleIndex) {
    if (_urls.isEmpty) return;

    final start = (visibleIndex - _keepBehind).clamp(0, _urls.length - 1);
    final end = (visibleIndex + _preloadAhead).clamp(0, _urls.length - 1);

    _evictOutOfWindow(start, end);

    for (int i = start; i <= end; i++) {
      _preloadUrl(_urls[i]);
    }
  }

  Future<void> _preloadUrl(String url) async {
    if (url.isEmpty) return;
    if (_controllers.containsKey(url)) return; // already ready
    if (_pending.containsKey(url)) return; // already loading
    if (_controllers.length >= _maxControllers) return; // pool full

    final completer = Completer<VideoPlayerController?>();
    _pending[url] = completer;

    void safeComplete(VideoPlayerController? v) {
      if (!completer.isCompleted) completer.complete(v);
    }

    VideoPlayerController? created;

    try {
      // Kick off background file download first (no-op if already cached)
      _cacheManager.preloadVideoInBackground(url);

      // Try to get from disk cache
      final cachedFile = await _cacheManager.getCachedFile(url);

      // Guard: may have been evicted while we awaited
      if (!_pending.containsKey(url)) {
        safeComplete(null);
        return;
      }

      VideoPlayerController ctrl;
      if (cachedFile != null) {
        ctrl = VideoPlayerController.file(
          cachedFile,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: false,
            allowBackgroundPlayback: false,
          ),
        );
        debugPrint('📁 StoryPreloader: from cache ${_name(url)}');
      } else {
        ctrl = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: false,
            allowBackgroundPlayback: false,
          ),
          httpHeaders: const {'Range': 'bytes=0-'},
        );
        debugPrint('🌐 StoryPreloader: from network ${_name(url)}');
      }

      created = ctrl;
      await ctrl.initialize();

      // Guard after initialize (longest step)
      if (!_pending.containsKey(url)) {
        try {
          ctrl.dispose();
        } catch (_) {}
        created = null;
        safeComplete(null);
        return;
      }

      await ctrl.setLooping(true);
      await ctrl.setVolume(0.0);
      await ctrl.pause();

      // Final guard before storing
      if (!_pending.containsKey(url)) {
        try {
          ctrl.dispose();
        } catch (_) {}
        created = null;
        safeComplete(null);
        return;
      }

      _controllers[url] = _PreloadedVideo(controller: ctrl, url: url);
      safeComplete(ctrl);
      debugPrint('✅ StoryPreloader: ready ${_name(url)}');
    } catch (e) {
      debugPrint('⚠️ StoryPreloader: failed ${_name(url)}: $e');
      if (created != null) {
        try {
          created.dispose();
        } catch (_) {}
      }
      safeComplete(null);
    } finally {
      _pending.remove(url);
    }
  }

  void _evictOutOfWindow(int windowStart, int windowEnd) {
    final windowUrls = <String>{};
    for (int i = windowStart; i <= windowEnd; i++) {
      windowUrls.add(_urls[i]);
    }

    final toEvict = _controllers.keys
        .where((u) => !windowUrls.contains(u))
        .toList();
    for (final u in toEvict) {
      _disposeController(u);
    }

    final pendingToCancel = _pending.keys
        .where((u) => !windowUrls.contains(u))
        .toList();
    for (final u in pendingToCancel) {
      final c = _pending.remove(u);
      if (c != null && !c.isCompleted) c.complete(null);
    }
  }

  void _disposeController(String url) {
    final p = _controllers.remove(url);
    if (p == null) return;
    try {
      final ctrl = p.controller;
      if (ctrl.value.isInitialized) {
        ctrl.setVolume(0.0);
        if (ctrl.value.isPlaying) ctrl.pause();
      }
      ctrl.dispose();
      debugPrint('🗑️ StoryPreloader: evicted ${_name(url)}');
    } catch (e) {
      debugPrint('⚠️ StoryPreloader: evict error $e');
    }
  }

  Future<void> _disposeAll() async {
    final pendingCopy = Map<String, Completer<VideoPlayerController?>>.from(
      _pending,
    );
    _pending.clear();
    for (final c in pendingCopy.values) {
      if (!c.isCompleted) c.complete(null);
    }

    final ids = _controllers.keys.toList();
    for (final id in ids) {
      _disposeController(id);
    }
    _controllers.clear();
  }

  String _name(String url) => url.split('/').last.split('?').first;
}

class _PreloadedVideo {
  final VideoPlayerController controller;
  final String url;

  _PreloadedVideo({required this.controller, required this.url});
}
