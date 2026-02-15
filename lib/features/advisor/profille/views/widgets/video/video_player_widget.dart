import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/video/cubit/video_player_cubit.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/utils/router/route_observers.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/video/video_state_manager.dart';
import 'package:tayseer/core/widgets/post_card/full_screen_video_player.dart';
import 'video_controller_cache.dart';

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
  bool get wantKeepAlive => true; // ⭐ للحفاظ على الحالة

  VideoPlayerController? _controller;
  final _videoCacheManager = VideoCacheManager();
  final _stateManager = VideoStateManager();
  final _controllerCache = VideoControllerCache(); // ⭐ الـ cache
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

    // ⭐ محاولة استرجاع الـ controller من الـ cache
    _controller = _controllerCache.getController(widget.videoUrl);

    if (_controller != null && _controller!.value.isInitialized) {
      // ⭐ الـ controller موجود ومجهز
      _cubit.setInitialized(true);
      _controller!.addListener(_videoListener);

      // استرجاع الموضع
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // if (mounted) {
        //   _restorePosition();
        // }
        _restorePosition();
      });
    } else {
      // ⭐ تهيئة جديدة
      _initializeVideo();
    }
  }

  void _videoManagerListener() {
    if (_isDisposed || _controller == null) return;

    final activeId = VideoManager.instance.currentlyPlayingPostId.value;
    if (activeId != widget.videoUrl) {
      try {
        if (_controller!.value.isPlaying) {
          _savePosition();
          _controller!.pause();
          // if (mounted && !_isDisposed) setState(() {});
          _cubit.setPlaying(false);
        }
      } catch (e) {
        debugPrint('⚠️ Cannot pause in listener: $e');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      videoRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _savePosition();

    VideoManager.instance.currentlyPlayingPostId.removeListener(
      _videoManagerListener,
    );
    videoRouteObserver.unsubscribe(this);

    // ⭐ لا نحذف الـ controller، فقط نحفظه في الـ cache
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      // لا نعمل dispose هنا - الـ cache يتعامل معه
    }
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
        if (position.inSeconds > 0) {
          _stateManager.savePosition(widget.videoUrl, position);
        }
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

      if (cachedFile != null) {
        _controller = VideoPlayerController.file(cachedFile);
      } else {
        // ⭐ استخدام network مع httpHeaders للـ streaming
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
          httpHeaders: {
            'Range': 'bytes=0-', // ⭐ للسماح بالـ streaming
          },
        );
      }

      // ⭐ حفظ في الـ cache
      _controllerCache.setController(widget.videoUrl, _controller!);

      await _controller!.initialize();
      if (!mounted || _isDisposed) {
        return;
      }

      _controller!.setVolume(1.0);
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
          if (mounted && !_isDisposed) {
            _initializeVideo();
          }
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
        if (!_cubit.state.isEnded) {
          if (mounted) {
            _cubit.setEnded(true);
            _cubit.setControls(true);
            _cubit.setPlaying(false);
          }
        }
      } else {
        if (_cubit.state.isEnded &&
            value.position < value.duration - const Duration(seconds: 1)) {
          if (mounted) {
            _cubit.setEnded(false);
            _cubit.setPlaying(value.isPlaying);
          }
        } else {
          // update playing state generally
          if (_cubit.state.isPlaying != value.isPlaying) {
            _cubit.setPlaying(value.isPlaying);
          }
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
    if (mounted) {
      _cubit.toggleControls();
    }

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
    final newPosition =
        _controller!.value.position - const Duration(seconds: 10);
    _controller!.seekTo(newPosition.isNegative ? Duration.zero : newPosition);
  }

  void _skipForward() {
    if (_controller == null) return;
    final newPosition =
        _controller!.value.position + const Duration(seconds: 10);
    final duration = _controller!.value.duration;
    _controller!.seekTo(newPosition > duration ? duration : newPosition);
  }

  Future<void> _openFullscreen() async {
    if (_controller == null || !_cubit.state.isInitialized) return;

    final wasPlaying = _controller!.value.isPlaying;
    final currentPosition = _controller!.value.position;

    if (wasPlaying) {
      _controller!.pause();
      _cubit.setPlaying(false);
    }

    final result = await Navigator.push<FullscreenResult>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => FullscreenVideoPlayer(
          videoUrl: widget.videoUrl,
          startPosition: currentPosition,
          isMuted: _cubit.state.isMuted,
        ),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
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
      // إذا تم إلغاء الـ fullscreen، أكمل التشغيل
      VideoManager.instance.playVideo(widget.videoUrl);
      _controller!.play();
      _cubit.setPlaying(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ⭐ مهم للـ AutomaticKeepAliveClientMixin

    return BlocProvider.value(
      value: _cubit, // Provide local cubit
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
              return state.isInitialized && _controller != null
                  ? _buildVideoPlayer(state)
                  : _buildLoadingState(state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(VideoPlayerState state) {
    return Container(
      height: 400.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: state.hasError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 40.w),
                  SizedBox(height: 10.h),
                  Text('فشل تحميل الفيديو', style: Styles.textStyle14),
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    onPressed: _retryInitialization,
                    child: Text('إعادة المحاولة'),
                  ),
                ],
              )
            : Container(),
      ),
    );
  }

  Widget _buildVideoPlayer(VideoPlayerState state) {
    final videoSize = _controller!.value.size;

    return SizedBox(
      width: double.infinity,
      height: 400.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video Player
          Center(
            child: AspectRatio(
              aspectRatio: videoSize.width / videoSize.height,
              child: VideoPlayer(_controller!),
            ),
          ),

          // Controls
          if (state.showControls)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleControls,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _skipBackward,
                        icon: Icon(
                          Icons.forward_10,
                          color: Colors.white,
                          size: 35.w,
                        ),
                      ),
                      Gap(16.w),
                      IconButton(
                        onPressed: _togglePlayPause,
                        icon: Icon(
                          state.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: Colors.white,
                          size: 45.w,
                        ),
                      ),
                      Gap(16.w),
                      IconButton(
                        onPressed: _skipForward,
                        icon: Icon(
                          Icons.replay_10,
                          color: Colors.white,
                          size: 35.w,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Progress Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showFullScreenButton)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: _openFullscreen,
                        icon: Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 30.w,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Tap to show/hide controls
          if (!state.showControls && !state.isBuffering)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleControls,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),
        ],
      ),
    );
  }
}
