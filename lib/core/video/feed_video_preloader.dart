import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// FeedVideoPreloader — Disk-cache-only strategy (no VideoPlayerController)
///
/// Previously this class pre-initialized VideoPlayerControllers which consumed
/// hardware AVC decoder slots on Android.  Qualcomm devices have a pool of
/// only 4-6 concurrent hardware decoders; pre-initializing 5 feed controllers
/// plus 6 reels controllers exhausted the pool and caused
///   DecoderInitializationException: c2.qti.avc.decoder start failed
///
/// New strategy:
///   • Pre-download the video file to flutter_cache_manager disk cache so
///     RealVideoPlayer can open a local File instead of a network URL.
///   • RealVideoPlayer already reads the cache first (getCachedFile) so it
///     gets the fast "from cache" path with zero additional latency.
///   • Zero VideoPlayerControllers are held here → zero hardware decoder slots
///     consumed → no more DecoderInitializationException.
///
/// getReadyController() always returns null.  RealVideoPlayer handles that
/// gracefully — it creates its own controller from the cached file.
/// ═══════════════════════════════════════════════════════════════════════════
class FeedVideoPreloader {
  static final FeedVideoPreloader instance = FeedVideoPreloader._internal();
  FeedVideoPreloader._internal();

  final VideoCacheManager _cacheManager = VideoCacheManager();

  // The posts currently in the feed
  List<PostModel> _feedPosts = [];

  // How many videos ahead to pre-download (file only)
  static const int _preloadAhead = 3;

  // How many behind to keep warm
  static const int _keepBehind = 1;

  // Last visible index
  int _lastVisibleIndex = -1;

  bool _isDisposed = false;

  // Offline flag — background downloads are suppressed when true
  bool _isOffline = false;

  // ═══════════════════════════════════════════════════════════════════
  // Public API
  // ═══════════════════════════════════════════════════════════════════

  /// Set offline state — when true, background file downloads are no-ops.
  void setOffline(bool offline) {
    _isOffline = offline;
  }

  /// Update the feed post list.
  void updateFeedPosts(List<PostModel> posts) {
    if (_isDisposed) return;
    _feedPosts = posts;
    if (_lastVisibleIndex == -1 && posts.isNotEmpty) {
      _triggerPreload(0);
    }
  }

  /// Called when a post becomes visible — triggers background file downloads
  /// for the upcoming posts.
  void onPostVisible(String postId) {
    if (_isDisposed) return;
    final index = _feedPosts.indexWhere((p) => p.postId == postId);
    if (index == -1 || index == _lastVisibleIndex) return;
    _lastVisibleIndex = index;
    _triggerPreload(index);
  }

  /// Always returns null — controller creation is delegated to RealVideoPlayer.
  /// Kept for API compatibility; callers handle null gracefully.
  VideoPlayerController? getReadyController(String postId) => null;

  /// Always returns false — no controllers are held.
  bool isReady(String postId) => false;

  /// No-op (no controllers to pause).
  void pauseAll() {}

  /// Reset state.
  Future<void> reset() async {
    _isDisposed = false;
    _lastVisibleIndex = -1;
    _feedPosts = [];
  }

  /// Dispose.
  Future<void> dispose() async {
    _isDisposed = true;
  }

  /// Check disk cache size and evict if over 500 MB.
  Future<void> trimCacheIfNeeded() => _cacheManager.trimCacheIfNeeded();

  // ═══════════════════════════════════════════════════════════════════
  // Internal
  // ═══════════════════════════════════════════════════════════════════

  void _triggerPreload(int visibleIndex) {
    if (_isDisposed || _isOffline) return;

    final start = (visibleIndex - _keepBehind).clamp(0, _feedPosts.length - 1);
    final end = (visibleIndex + _preloadAhead).clamp(0, _feedPosts.length - 1);

    for (int i = start; i <= end; i++) {
      final post = _feedPosts[i];
      final url = post.videoData?.video ?? post.videoUrl ?? '';
      if (url.isNotEmpty) {
        _cacheManager.preloadVideoInBackground(url);
      }
    }
  }
}
