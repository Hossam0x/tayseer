import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:story_view/story_view.dart';
import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/my_import.dart';

/// Custom video widget for stories that integrates with [GlobalMuteManager].
/// Replaces [StoryVideo.url] so the mute button works the same as in posts.
///
/// ─── Timing contract ───────────────────────────────────────────────────────
/// • While loading  → pause the StoryController so the progress bar waits.
/// • After loaded   → resume the StoryController so the progress bar runs.
/// • If disposed before loading finishes → do nothing (user swiped away).
/// • StoryController play/pause events → mirror them on the VideoPlayer.
/// ───────────────────────────────────────────────────────────────────────────
class StoryVideoMuted extends StatefulWidget {
  final String url;
  final StoryController storyController;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  /// Called once the video is initialized and the progress bar has been
  /// resumed. Use this to know when it is safe to call play() externally.
  final VoidCallback? onReady;

  const StoryVideoMuted({
    super.key,
    required this.url,
    required this.storyController,
    this.loadingWidget,
    this.errorWidget,
    this.onReady,
  });

  @override
  State<StoryVideoMuted> createState() => _StoryVideoMutedState();
}

class _StoryVideoMutedState extends State<StoryVideoMuted> {
  VideoPlayerController? _controller;
  StreamSubscription? _playbackSub;
  StreamSubscription? _guardSub; // intercepts play() while still loading
  bool _isInitialized = false;
  bool _hasError = false;
  bool _disposed = false;

  final _muteManager = GlobalMuteManager.instance;

  @override
  void initState() {
    super.initState();
    _muteManager.isMuted.addListener(_onMuteChanged);

    // ── Guard: keep the bar paused until the video is ready ─────────────────
    // Any play() signal that arrives before _isInitialized (e.g. from
    // StoryView._play() on first build, or from didUpdateWidget when the page
    // becomes active mid-download) is immediately countered with a pause().
    // Once _loadVideo() finishes it cancels this guard and calls play() itself.
    _guardSub = widget.storyController.playbackNotifier.listen((state) {
      if (_disposed || !mounted) return;
      if (state == PlaybackState.play && !_isInitialized) {
        // Re-pause on the next microtask so we don't emit synchronously
        // inside the stream listener (which can cause re-entrancy issues).
        Future.microtask(() {
          if (!_disposed && mounted && !_isInitialized) {
            widget.storyController.pause();
          }
        });
      }
    });

    // Seed the BehaviorSubject with pause so StoryView's listener sees it
    // immediately on subscribe, and fire a second pause in postFrameCallback
    // to catch the play() that StoryView._play() emits at the end of initState.
    widget.storyController.pause();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed && mounted && !_isInitialized) {
        widget.storyController.pause();
      }
    });

    _loadVideo();
  }

  @override
  void dispose() {
    _disposed = true;
    _muteManager.isMuted.removeListener(_onMuteChanged);
    _guardSub?.cancel();
    _playbackSub?.cancel();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  // ── Mute ──────────────────────────────────────────────────────────────────

  void _onMuteChanged() {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    try {
      ctrl.setVolume(_muteManager.isMuted.value ? 0.0 : 1.0);
    } catch (_) {}
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> _loadVideo() async {
    try {
      final fileInfo = await DefaultCacheManager().getSingleFile(widget.url);

      // User may have swiped to next story while we were downloading.
      if (_disposed || !mounted) return;

      _controller = VideoPlayerController.file(fileInfo);
      await _controller!.initialize();

      if (_disposed || !mounted) {
        _controller?.dispose();
        _controller = null;
        return;
      }

      await _controller!.setLooping(true);
      _controller!.setVolume(_muteManager.isMuted.value ? 0.0 : 1.0);

      // Mirror StoryController play/pause onto the VideoPlayer.
      _playbackSub = widget.storyController.playbackNotifier.listen((state) {
        if (_disposed || !mounted) return;
        if (state == PlaybackState.pause) {
          _controller?.pause();
        } else {
          _controller?.play();
        }
      });

      // Show the video frame before resuming the progress bar.
      if (mounted) setState(() => _isInitialized = true);

      // Cancel the loading guard — video is ready, we own play() from here.
      _guardSub?.cancel();
      _guardSub = null;

      // Resume the progress bar — this also starts the VideoPlayer via the
      // playbackNotifier subscription we just attached above.
      // Guard: only resume if we're still the active widget.
      if (!_disposed && mounted) {
        widget.storyController.play();
        widget.onReady?.call();
      }
    } catch (e) {
      debugPrint('❌ StoryVideoMuted error: $e');
      if (!_disposed && mounted) setState(() => _hasError = true);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ??
          const Center(
            child: Icon(Icons.error_outline, color: Colors.white54, size: 40),
          );
    }

    if (!_isInitialized || _controller == null) {
      return widget.loadingWidget ??
          const Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          );
    }

    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}
