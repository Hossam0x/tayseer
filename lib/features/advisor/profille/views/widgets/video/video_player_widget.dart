import 'package:tayseer/features/advisor/profille/views/cubit/video/video_player_cubit.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/utils/router/route_observers.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/video/video_state_manager.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/video/profile_full_screen_video_player.dart';
import 'video_controller_cache.dart';
import 'video_player_builders.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool showFullScreenButton;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.showFullScreenButton = true,
  });

  @override
  State<VideoPlayerWidget> createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with RouteAware, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  VideoPlayerController? _controller;
  final _videoCacheManager = VideoCacheManager();
  final _stateManager = VideoStateManager();
  final _controllerCache = VideoControllerCache();
  late VideoPlayerCubit _cubit;

  int _retryCount = 0;
  static const int _maxRetries = 3;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _cubit = VideoPlayerCubit();
    VideoManager.instance.currentlyPlayingPostId.addListener(
      _videoManagerListener,
    );

    _controller = _controllerCache.getController(widget.videoUrl);

    if (_controller != null && _controller!.value.isInitialized) {
      _cubit.setInitialized(true);
      _controller!.addListener(_videoListener);
      WidgetsBinding.instance.addPostFrameCallback((_) => _restorePosition());
    } else {
      _initializeVideo();
    }
  }

  void _videoManagerListener() {
    if (_isDisposed || _controller == null) return;
    final activeId = VideoManager.instance.currentlyPlayingPostId.value;
    if (activeId != widget.videoUrl && _controller!.value.isPlaying) {
      try {
        _savePosition();
        _controller!.pause();
        _cubit.setPlaying(false);
      } catch (e) {
        debugPrint('⚠️ Cannot pause in listener: $e');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) videoRouteObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _savePosition();
    // Pause to stop audio immediately — controller is cached, not disposed here
    if (_controller != null) {
      try {
        if (_controller!.value.isPlaying) _controller!.pause();
      } catch (e) {
        debugPrint('⚠️ Cannot pause cached controller on dispose: $e');
      }
    }
    VideoManager.instance.currentlyPlayingPostId.removeListener(
      _videoManagerListener,
    );
    videoRouteObserver.unsubscribe(this);
    if (_controller != null) _controller!.removeListener(_videoListener);
    _cubit.close();
    super.dispose();
  }

  @override
  void didPushNext() {
    if (_controller == null) return;
    try {
      if (_controller!.value.isPlaying) {
        _savePosition();
        _controller!.pause();
        _cubit.setPlaying(false);
      }
    } catch (e) {
      debugPrint('⚠️ Cannot pause: $e');
    }
  }

  void _savePosition() {
    if (_controller == null) return;
    try {
      if (_controller!.value.isInitialized) {
        final position = _controller!.value.position;
        if (position.inSeconds > 0)
          _stateManager.savePosition(widget.videoUrl, position);
      }
    } catch (e) {
      debugPrint('⚠️ Cannot save position: $e');
    }
  }

  Future<void> _restorePosition() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final lastPosition = _stateManager.getLastPosition(widget.videoUrl);
    if (lastPosition != null && lastPosition.inSeconds > 0) {
      final duration = _controller!.value.duration;
      if (lastPosition < duration - const Duration(seconds: 2)) {
        await _controller!.seekTo(lastPosition);
      }
    }
  }

  Future<void> _initializeVideo() async {
    if (_controller != null || _isDisposed) return;
    try {
      if (widget.videoUrl.isEmpty) return;

      final cachedFile = await _videoCacheManager.getCachedFile(
        widget.videoUrl,
      );
      if (!mounted || _isDisposed) return;

      _controller = cachedFile != null
          ? VideoPlayerController.file(
              cachedFile,
              videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: false,
                allowBackgroundPlayback: false,
              ),
            )
          : VideoPlayerController.networkUrl(
              Uri.parse(widget.videoUrl),
              videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: false,
                allowBackgroundPlayback: false,
              ),
              httpHeaders: {'Range': 'bytes=0-'},
            );

      _controllerCache.setController(widget.videoUrl, _controller!);
      await _controller!.initialize();
      if (!mounted || _isDisposed) return;

      _controller!.setVolume(0.0);
      _controller!.addListener(_videoListener);
      await _restorePosition();
      _stateManager.markAsLoaded(widget.videoUrl);
      _retryCount = 0;

      if (mounted && !_isDisposed) {
        _cubit.setInitialized(true);
        _cubit.setMuted(_controller!.value.volume == 0);
      }
    } catch (e) {
      debugPrint("❌ Error initializing video: $e");
      if (mounted && !_isDisposed) {
        if (_retryCount < _maxRetries &&
            _stateManager.canRetry(widget.videoUrl)) {
          _retryCount++;
          _stateManager.recordError(widget.videoUrl);
          await Future.delayed(Duration(milliseconds: 500 * _retryCount));
          if (mounted && !_isDisposed) _initializeVideo();
        } else {
          _cubit.setError(true);
        }
      }
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null || _isDisposed) return;
    try {
      final value = _controller!.value;

      if (value.isBuffering != _cubit.state.isBuffering) {
        if (mounted) _cubit.setBuffering(value.isBuffering);
      }

      if (value.isInitialized &&
          !value.isPlaying &&
          value.position >=
              value.duration - const Duration(milliseconds: 500)) {
        if (!_cubit.state.isEnded && mounted) {
          _cubit.setEnded(true);
          _cubit.setControls(true);
          _cubit.setPlaying(false);
        }
      } else {
        if (_cubit.state.isEnded &&
            value.position < value.duration - const Duration(seconds: 1)) {
          if (mounted) {
            _cubit.setEnded(false);
            _cubit.setPlaying(value.isPlaying);
          }
        } else if (_cubit.state.isPlaying != value.isPlaying) {
          _cubit.setPlaying(value.isPlaying);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error in video listener: $e');
    }
  }

  void _retryInitialization() {
    if (_isDisposed) return;
    _stateManager.resetErrorCount(widget.videoUrl);
    _videoCacheManager.resetFailedStatus(widget.videoUrl);
    _retryCount = 0;
    _cubit.setError(false);
    _cubit.setInitialized(false);

    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controllerCache.removeController(widget.videoUrl);
      _controller = null;
    }
    _initializeVideo();
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      _cubit.setPlaying(false);
    } else {
      VideoManager.instance.playVideo(widget.videoUrl);
      _controller!.play();
      _cubit.setPlaying(true);
    }
  }

  void _toggleControls() {
    if (mounted) _cubit.toggleControls();
    if (_cubit.state.showControls && (_controller?.value.isPlaying ?? false)) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted &&
            (_controller?.value.isPlaying ?? false) &&
            _cubit.state.showControls) {
          _cubit.setControls(false);
        }
      });
    }
  }

  void _skipBackward() {
    if (_controller == null) return;
    final newPos = _controller!.value.position - const Duration(seconds: 10);
    _controller!.seekTo(newPos.isNegative ? Duration.zero : newPos);
  }

  void _skipForward() {
    if (_controller == null) return;
    final newPos = _controller!.value.position + const Duration(seconds: 10);
    final duration = _controller!.value.duration;
    _controller!.seekTo(newPos > duration ? duration : newPos);
  }

  Future<void> _openFullscreen() async {
    if (_controller == null || !_cubit.state.isInitialized) return;

    final wasPlaying = _controller!.value.isPlaying;
    final currentPosition = _controller!.value.position;

    if (wasPlaying) {
      _controller!.pause();
      _cubit.setPlaying(false);
    }

    final result = await Navigator.push<ProfileFullscreenResult>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProfileFullscreenVideoPlayer(
              videoUrl: widget.videoUrl,
              startPosition: currentPosition,
              isMuted: _cubit.state.isMuted,
              controller: _controller,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );

    if (result != null && mounted) {
      _cubit.setMuted(result.isMuted);
      _controller!.setVolume(result.isMuted ? 0.0 : 1.0);
      await _controller!.seekTo(result.position);
      if (result.wasPlaying) {
        VideoManager.instance.playVideo(widget.videoUrl);
        _controller!.play();
        _cubit.setPlaying(true);
      }
    } else if (wasPlaying && mounted) {
      VideoManager.instance.playVideo(widget.videoUrl);
      _controller!.play();
      _cubit.setPlaying(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return VisibilityDetector(
      key: Key('video_player_${widget.videoUrl}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0.0 &&
            _controller != null &&
            _controller!.value.isPlaying &&
            mounted) {
          _controller!.pause();
          _cubit.setPlaying(false);
        }
      },
      child: BlocProvider.value(
        value: _cubit,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
              builder: (context, state) {
                if (!state.isInitialized || _controller == null) {
                  return VideoLoadingState(
                    state: state,
                    onRetry: _retryInitialization,
                  );
                }
                return VideoPlayerContent(
                  controller: _controller!,
                  state: state,
                  videoUrl: widget.videoUrl,
                  showFullScreenButton: widget.showFullScreenButton,
                  onToggleControls: _toggleControls,
                  onSkipBackward: _skipBackward,
                  onSkipForward: _skipForward,
                  onTogglePlayPause: _togglePlayPause,
                  onOpenFullscreen: _openFullscreen,
                  onToggleMute: () {
                    final isMuted = state.isMuted;
                    _controller!.setVolume(isMuted ? 1.0 : 0.0);
                    _cubit.setMuted(!isMuted);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
