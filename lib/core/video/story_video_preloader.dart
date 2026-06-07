import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// StoryVideoPreloader — (userId, storyIndex) keyed pool
///
/// Strategy (Task 3):
///  • Pool keyed by "${userId}_${storyIndex}" instead of flat URL map.
///  • _preloadAhead = 1, _keepBehind = 0, _maxControllers = 3  → ~60 MB max.
///  • [preloadFromStories] only processes NEW URLs not already in pool and
///    only calls _triggerPreload(0) on the initial fetch, not on loadMore.
///  • [onUserVisible] initialises index-0 of the new user immediately and
///    queues index-1 in background; disposes the previous user's controllers.
///  • Back-swipe (previous user): shows thumbnail — controllers are NOT
///    re-initialised automatically; call [onUserVisible] explicitly on tap.
///  • [getReadyController] accepts a URL and still works for already-cached
///    disk files even when offline.
/// ═══════════════════════════════════════════════════════════════════════════
class StoryVideoPreloader {
  static final StoryVideoPreloader instance = StoryVideoPreloader._internal();
  StoryVideoPreloader._internal();

  final VideoCacheManager _cacheManager = VideoCacheManager();

  // key: "${userId}_${storyIndex}" → ready controller
  final Map<String, _PreloadedVideo> _controllers = {};

  // Completers to prevent double-init for the same key
  final Map<String, Completer<VideoPlayerController?>> _pending = {};

  // ── Pool limits ──────────────────────────────────────────────────────────
  // ⚠️ Keep total initialized controllers ≤ 2 for stories
  // (current story + 1 preloaded next story of same user)
  static const int _preloadAhead = 1;
  static const int _maxControllers = 2;

  // ── State ────────────────────────────────────────────────────────────────
  // All users currently being tracked (for the open story screen).
  List<UserStoriesModel> _allUsers = [];

  // Index of the currently visible user.
  int _currentUserIndex = -1;

  // URLs already submitted to preloadFromStories to avoid re-processing.
  final Set<String> _knownUrls = {};

  // Whether any stories have been loaded yet (used to guard loadMore calls).
  bool _hasInitialLoad = false;

  // ═══════════════════════════════════════════════════════════════════════════
  // Public API
  // ═══════════════════════════════════════════════════════════════════════════

  /// Called right after a fresh stories API fetch (page 1 / initial).
  /// Extracts video URLs and pre-initialises the first window.
  /// Image stories: warm only the first 5 to avoid unbounded ImageCache growth.
  void preloadFromStories(List<UserStoriesModel> allUsers) {
    _allUsers = allUsers;

    // ── Collect NEW video URLs ──────────────────────────────────────────────
    final newVideoUrls = <String>[];
    int imageStoryCount = 0;

    for (final user in allUsers) {
      for (final story in user.stories) {
        if (!story.isPostStory && story.video?.isNotEmpty == true) {
          final url = story.video!;
          if (!_knownUrls.contains(url)) {
            newVideoUrls.add(url);
            _knownUrls.add(url);
          }
        }
        // Warm image cache for first 5 image stories only
        if (!story.isPostStory &&
            (story.video?.isEmpty ?? true) &&
            story.image.isNotEmpty &&
            imageStoryCount < 5) {
          CachedNetworkImageProvider(
            story.image,
          ).resolve(const ImageConfiguration());
          imageStoryCount++;
        }
      }
    }

    // Background file downloads for new videos only
    for (final url in newVideoUrls) {
      _cacheManager.preloadVideoInBackground(url);
    }

    // Only trigger controller pre-init on the initial fetch
    if (!_hasInitialLoad && allUsers.isNotEmpty) {
      _hasInitialLoad = true;
      _currentUserIndex = 0;
      _triggerPreload(0);
    }
    // On loadMore: do NOT call _triggerPreload — window stays as-is
  }

  /// Lightweight background file download for a single URL.
  /// Used on loadMore to warm the disk cache without touching the controller pool.
  void preloadVideoUrl(String url) {
    if (url.isEmpty) return;
    _cacheManager.preloadVideoInBackground(url);
  }

  /// Call when the story screen opens for a specific user.
  /// Immediately initialises index-0, queues index-1 in background,
  /// and disposes the previously active user's controllers.
  void onUserVisible(int userIndex) {
    if (userIndex < 0 || userIndex >= _allUsers.length) return;

    final previousUserIndex = _currentUserIndex;
    _currentUserIndex = userIndex;

    // Dispose previous user's controllers immediately
    if (previousUserIndex >= 0 &&
        previousUserIndex < _allUsers.length &&
        previousUserIndex != userIndex) {
      final prevUser = _allUsers[previousUserIndex];
      for (int i = 0; i < prevUser.stories.length; i++) {
        _disposeKey(_keyFor(prevUser.userId, i));
      }
    }

    _triggerPreload(userIndex);
  }

  /// Call when the user swipes to a new story index within the current user.
  void onStoryVisible(int storyIndex) {
    if (_currentUserIndex < 0 || _currentUserIndex >= _allUsers.length) return;
    final user = _allUsers[_currentUserIndex];
    final end = (storyIndex + _preloadAhead).clamp(0, user.stories.length - 1);
    for (int i = storyIndex; i <= end; i++) {
      final story = user.stories[i];
      if (!story.isPostStory && story.video?.isNotEmpty == true) {
        _preloadKey(_keyFor(user.userId, i), story.video!);
      }
    }
  }

  /// Returns a ready [VideoPlayerController] for the given [url], or null.
  /// Works for disk-cached videos even when offline.
  VideoPlayerController? getReadyController(String url) {
    // Search by URL across all keys
    for (final entry in _controllers.entries) {
      if (entry.value.url == url) {
        final ctrl = entry.value.controller;
        try {
          if (!ctrl.value.isInitialized) continue;
          void probe() {}
          ctrl.addListener(probe);
          ctrl.removeListener(probe);
          return ctrl;
        } catch (_) {
          _controllers.remove(entry.key);
          return null;
        }
      }
    }
    return null;
  }

  /// Whether a controller for [url] is ready.
  bool isReady(String url) => getReadyController(url) != null;

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

  /// Release a specific controller back to the pool after a widget disposes.
  /// Pauses + mutes + seeks to zero but keeps it alive for re-use.
  void releaseController(String url) {
    for (final p in _controllers.values) {
      if (p.url == url) {
        try {
          if (p.controller.value.isInitialized) {
            p.controller.pause();
            p.controller.setVolume(0.0);
            p.controller.seekTo(Duration.zero);
          }
        } catch (_) {}
        return;
      }
    }
  }

  /// Clear everything — call when the story screen is fully closed.
  Future<void> clear() async {
    _allUsers = [];
    _currentUserIndex = -1;
    _hasInitialLoad = false;
    _knownUrls.clear();
    await _disposeAll();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Internal
  // ═══════════════════════════════════════════════════════════════════════════

  /// Build a pool key from userId + storyIndex.
  String _keyFor(String userId, int storyIndex) => '${userId}_$storyIndex';

  /// Trigger preloading for the window around [userIndex].
  void _triggerPreload(int userIndex) {
    if (userIndex < 0 || userIndex >= _allUsers.length) return;

    // keepBehind = 0: only current + ahead
    final windowStart = userIndex; // no behind
    final windowEnd = (userIndex + _preloadAhead).clamp(
      0,
      _allUsers.length - 1,
    );

    // Evict keys outside the current window
    _evictOutsideWindow(userIndex, windowStart, windowEnd);

    // Preload current user index-0 first, then index-1
    for (int ui = windowStart; ui <= windowEnd; ui++) {
      final user = _allUsers[ui];
      // Index 0 always
      if (user.stories.isNotEmpty) {
        final s0 = user.stories[0];
        if (!s0.isPostStory && s0.video?.isNotEmpty == true) {
          _preloadKey(_keyFor(user.userId, 0), s0.video!);
        }
      }
      // Index 1 only for the currently visible user
      if (ui == userIndex && user.stories.length > 1) {
        final s1 = user.stories[1];
        if (!s1.isPostStory && s1.video?.isNotEmpty == true) {
          _preloadKey(_keyFor(user.userId, 1), s1.video!);
        }
      }
    }
  }

  Future<void> _preloadKey(String key, String url) async {
    if (url.isEmpty) return;
    if (_controllers.containsKey(key)) return; // already ready
    if (_pending.containsKey(key)) return; // already loading
    if (_controllers.length >= _maxControllers) return; // pool full

    final completer = Completer<VideoPlayerController?>();
    _pending[key] = completer;

    void safeComplete(VideoPlayerController? v) {
      if (!completer.isCompleted) completer.complete(v);
    }

    VideoPlayerController? created;

    try {
      _cacheManager.preloadVideoInBackground(url);
      final cachedFile = await _cacheManager.getCachedFile(url);

      if (!_pending.containsKey(key)) {
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

      if (!_pending.containsKey(key)) {
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

      if (!_pending.containsKey(key)) {
        try {
          ctrl.dispose();
        } catch (_) {}
        created = null;
        safeComplete(null);
        return;
      }

      _controllers[key] = _PreloadedVideo(controller: ctrl, url: url);
      safeComplete(ctrl);
      debugPrint(
        '✅ StoryPreloader: ready $key '
        '(${_controllers.length}/$_maxControllers)',
      );
    } catch (e) {
      debugPrint('⚠️ StoryPreloader: failed $key: $e');
      if (created != null) {
        try {
          created.dispose();
        } catch (_) {}
      }
      safeComplete(null);
    } finally {
      _pending.remove(key);
    }
  }

  void _evictOutsideWindow(
    int currentUserIndex,
    int windowStart,
    int windowEnd,
  ) {
    // Build the set of keys that should stay in the pool
    final keepKeys = <String>{};
    for (int ui = windowStart; ui <= windowEnd; ui++) {
      if (ui < 0 || ui >= _allUsers.length) continue;
      final user = _allUsers[ui];
      keepKeys.add(_keyFor(user.userId, 0));
      if (ui == currentUserIndex) {
        keepKeys.add(_keyFor(user.userId, 1));
      }
    }

    final toEvict = _controllers.keys
        .where((k) => !keepKeys.contains(k))
        .toList();
    for (final k in toEvict) {
      _disposeKey(k);
    }

    final pendingToCancel = _pending.keys
        .where((k) => !keepKeys.contains(k))
        .toList();
    for (final k in pendingToCancel) {
      final c = _pending.remove(k);
      if (c != null && !c.isCompleted) c.complete(null);
    }
  }

  void _disposeKey(String key) {
    final p = _controllers.remove(key);
    if (p == null) return;
    try {
      final ctrl = p.controller;
      if (ctrl.value.isInitialized) {
        ctrl.setVolume(0.0);
        if (ctrl.value.isPlaying) ctrl.pause();
      }
      ctrl.dispose();
      debugPrint('🗑️ StoryPreloader: evicted $key');
    } catch (e) {
      debugPrint('⚠️ StoryPreloader: evict error $key: $e');
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

    final keys = _controllers.keys.toList();
    for (final k in keys) {
      _disposeKey(k);
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
