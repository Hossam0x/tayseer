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

  const StoryVideoMuted({
    super.key,
    required this.url,
    required this.storyController,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<StoryVideoMuted> createState() => _StoryVideoMutedState();
}

class _StoryVideoMutedState extends State<StoryVideoMuted> {
  VideoPlayerController? _controller;
  StreamSubscription? _playbackSub;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _disposed = false;

  final _muteManager = GlobalMuteManager.instance;

  @override
  void initState() {
    super.initState();
    _muteManager.isMuted.addListener(_onMuteChanged);

    // Pause the progress bar after the first frame so StoryView has had time
    // to register its playbackNotifier subscription and start the animation.
    // Without the postFrameCallback the pause() fires before StoryView's
    // _playbackSubscription is attached and gets silently dropped.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed && mounted) {
        widget.storyController.pause();
      }
    });

    _loadVideo();
  }

  @override
  void dispose() {
    _disposed = true;
    _muteManager.isMuted.removeListener(_onMuteChanged);
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

      // Resume the progress bar — this also starts the VideoPlayer via the
      // playbackNotifier subscription we just attached above.
      // Guard: only resume if we're still the active widget.
      if (!_disposed && mounted) {
        widget.storyController.play();
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
