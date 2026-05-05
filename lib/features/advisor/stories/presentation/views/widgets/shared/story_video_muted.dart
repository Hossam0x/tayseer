import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:story_view/story_view.dart';
import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/core/utils/story_audio_manager.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/core/video/story_video_preloader.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_image_guard.dart';
import 'package:tayseer/my_import.dart';

/// Story video widget that:
/// • Checks [StoryVideoPreloader] first — if the controller is already
///   initialized, it shows instantly with zero loading time.
/// • Falls back to downloading + initializing on its own if not preloaded.
/// • Integrates with [GlobalMuteManager] for app-wide mute toggle.
/// • Registers its [VideoPlayerController] with [StoryAudioManager] so the
///   story screen can silence it immediately on navigation / dispose.
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

  // Whether this widget created the controller itself (must dispose it)
  // vs. borrowed it from the preloader (must release it back).
  bool _ownsController = false;

  final _mute = GlobalMuteManager.instance;
  final _audio = StoryAudioManager.instance;
  final _preloader = StoryVideoPreloader.instance;
  final _cacheManager = VideoCacheManager();

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

    // ── Fast path: preloader already has a ready controller ──────────────
    final preloaded = _preloader.getReadyController(widget.url);
    if (preloaded != null) {
      _controller = preloaded;
      _ownsController = false;
      _attachController();
    } else {
      // ── Slow path: load it ourselves ─────────────────────────────────
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed && mounted && !_isInitialized) {
          widget.storyController.pause();
        }
      });
      _loadVideo();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _mute.isMuted.removeListener(_onMuteChanged);
    _guardSub?.cancel();
    _playbackSub?.cancel();

    if (_controller != null) {
      _audio.unregister(_controller!);
      try {
        _controller!.pause();
        _controller!.setVolume(0);
      } catch (_) {}

      if (_ownsController) {
        _controller!.dispose();
      } else {
        // Return the borrowed controller to the preloader pool
        _preloader.releaseController(widget.url);
      }
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

  /// Attach an already-initialized controller (from preloader or self-loaded).
  void _attachController() {
    if (_disposed || !mounted) return;

    final ctrl = _controller!;

    ctrl.setVolume(_mute.isMuted.value ? 0.0 : 1.0);
    ctrl.setLooping(true);

    // Register with StoryAudioManager so navigation can silence this.
    _audio.register(ctrl);

    // Mirror StoryController play/pause onto VideoPlayer.
    _playbackSub = widget.storyController.playbackNotifier.listen((s) {
      if (_disposed || !mounted) return;
      if (s == PlaybackState.pause) {
        ctrl.pause();
      } else {
        ctrl.play();
      }
    });

    if (mounted) setState(() => _isInitialized = true);

    _guardSub?.cancel();
    _guardSub = null;

    if (!_disposed && mounted) {
      widget.storyController.play();
      widget.onReady?.call();
    }
  }

  Future<void> _loadVideo() async {
    try {
      // Recheck preloader — it may have finished while we were waiting
      final preloaded = _preloader.getReadyController(widget.url);
      if (preloaded != null && !_disposed && mounted) {
        _controller = preloaded;
        _ownsController = false;
        _attachController();
        return;
      }

      // Try disk cache first (fast), then network
      final cachedFile = await _cacheManager.getCachedFile(widget.url);
      if (_disposed || !mounted) return;

      final file =
          cachedFile ?? await DefaultCacheManager().getSingleFile(widget.url);
      if (_disposed || !mounted) return;

      _controller = VideoPlayerController.file(
        file,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );
      _ownsController = true;
      await _controller!.initialize();

      if (_disposed || !mounted) {
        _controller?.dispose();
        _controller = null;
        return;
      }

      _attachController();
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
      return widget.loadingWidget ?? const StoryLoadingRing();
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
