import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:story_view/story_view.dart';
import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/core/utils/story_audio_manager.dart';
import 'package:tayseer/my_import.dart';

/// Story video widget that:
/// • Integrates with [GlobalMuteManager] for app-wide mute toggle.
/// • Registers its [VideoPlayerController] with [StoryAudioManager] so the
///   story screen can silence it immediately on navigation / dispose.
/// • Uses mixWithOthers:false to take exclusive audio focus.
class StoryVideoMuted extends StatefulWidget {
  final String url;
  final StoryController storyController;
  final Widget? loadingWidget;
  final Widget? errorWidget;
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
  StreamSubscription? _guardSub;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _disposed = false;

  final _mute = GlobalMuteManager.instance;
  final _audio = StoryAudioManager.instance;

  @override
  void initState() {
    super.initState();
    _mute.isMuted.addListener(_onMuteChanged);

    // Guard: keep progress bar paused until video is ready.
    _guardSub = widget.storyController.playbackNotifier.listen((s) {
      if (_disposed || !mounted) return;
      if (s == PlaybackState.play && !_isInitialized) {
        Future.microtask(() {
          if (!_disposed && mounted && !_isInitialized) {
            widget.storyController.pause();
          }
        });
      }
    });

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
    _mute.isMuted.removeListener(_onMuteChanged);
    _guardSub?.cancel();
    _playbackSub?.cancel();
    // Unregister BEFORE dispose so silenceAll() can still reach it if called
    // concurrently (e.g. didPushNext fires while dispose is in progress).
    if (_controller != null) {
      _audio.unregister(_controller!);
      try {
        _controller!.pause();
        _controller!.setVolume(0);
      } catch (_) {}
      _controller!.dispose();
      _controller = null;
    }
    super.dispose();
  }

  void _onMuteChanged() {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    try {
      ctrl.setVolume(_mute.isMuted.value ? 0.0 : 1.0);
    } catch (_) {}
  }

  Future<void> _loadVideo() async {
    try {
      final fileInfo = await DefaultCacheManager().getSingleFile(widget.url);
      if (_disposed || !mounted) return;

      _controller = VideoPlayerController.file(
        fileInfo,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );
      await _controller!.initialize();

      if (_disposed || !mounted) {
        _controller?.dispose();
        _controller = null;
        return;
      }

      await _controller!.setLooping(true);
      _controller!.setVolume(_mute.isMuted.value ? 0.0 : 1.0);

      // Register with StoryAudioManager so navigation can silence this.
      _audio.register(_controller!);

      // Mirror StoryController play/pause onto VideoPlayer.
      _playbackSub = widget.storyController.playbackNotifier.listen((s) {
        if (_disposed || !mounted) return;
        if (s == PlaybackState.pause) {
          _controller?.pause();
        } else {
          _controller?.play();
        }
      });

      if (mounted) setState(() => _isInitialized = true);

      _guardSub?.cancel();
      _guardSub = null;

      if (!_disposed && mounted) {
        widget.storyController.play();
        widget.onReady?.call();
      }
    } catch (e) {
      debugPrint('❌ StoryVideoMuted error: $e');
      if (!_disposed && mounted) setState(() => _hasError = true);
    }
  }

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
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}
