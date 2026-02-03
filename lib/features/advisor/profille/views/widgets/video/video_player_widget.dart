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

  // States
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isBuffering = false;
  bool _showControls = false;
  bool _isMuted = false;
  bool _isEnded = false;
  bool _isDisposed = false;

  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();

    VideoManager.instance.currentlyPlayingPostId.addListener(
      _videoManagerListener,
    );

    // ⭐ محاولة استرجاع الـ controller من الـ cache
    _controller = _controllerCache.getController(widget.videoUrl);

    if (_controller != null && _controller!.value.isInitialized) {
      // ⭐ الـ controller موجود ومجهز
      _isInitialized = true;
      _controller!.addListener(_videoListener);

      // استرجاع الموضع
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
          _restorePosition();
        }
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
          if (mounted && !_isDisposed) setState(() {});
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

    super.dispose();
  }

  @override
  void didPushNext() {
    if (_controller == null) return;

    try {
      if (_controller!.value.isPlaying) {
        _savePosition();
        _controller!.pause();
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
        setState(() {
          _isInitialized = true;
          _isMuted = _controller!.value.volume == 0;
        });
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
          setState(() => _hasError = true);
        }
      }
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null || _isDisposed) return;

    try {
      final value = _controller!.value;

      if (value.isBuffering != _isBuffering) {
        if (mounted) setState(() => _isBuffering = value.isBuffering);
      }

      if (value.isInitialized &&
          !value.isPlaying &&
          value.position >=
              value.duration - const Duration(milliseconds: 500)) {
        if (!_isEnded) {
          if (mounted) {
            setState(() {
              _isEnded = true;
              _showControls = true;
            });
          }
        }
      } else {
        if (_isEnded &&
            value.position < value.duration - const Duration(seconds: 1)) {
          if (mounted) setState(() => _isEnded = false);
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

    setState(() {
      _hasError = false;
      _isInitialized = false;
    });

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
    } else {
      VideoManager.instance.playVideo(widget.videoUrl);
      _controller!.play();
    }
    if (mounted) setState(() {});
  }

  void _toggleControls() {
    if (mounted) {
      setState(() => _showControls = !_showControls);
    }

    if (_showControls && (_controller?.value.isPlaying ?? false)) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted &&
            (_controller?.value.isPlaying ?? false) &&
            _showControls) {
          setState(() => _showControls = false);
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
    if (_controller == null || !_isInitialized) return;

    final wasPlaying = _controller!.value.isPlaying;
    final currentPosition = _controller!.value.position;

    if (wasPlaying) {
      _controller!.pause();
    }

    final result = await Navigator.push<FullscreenResult>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => FullscreenVideoPlayer(
          videoUrl: widget.videoUrl,
          startPosition: currentPosition,
          isMuted: _isMuted,
        ),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    );

    if (result != null && mounted) {
      setState(() => _isMuted = result.isMuted);
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);

      await _controller!.seekTo(result.position);

      if (result.wasPlaying) {
        VideoManager.instance.playVideo(widget.videoUrl);
        _controller!.play();
      }
    } else if (wasPlaying && mounted) {
      // إذا تم إلغاء الـ fullscreen، أكمل التشغيل
      VideoManager.instance.playVideo(widget.videoUrl);
      _controller!.play();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ⭐ مهم للـ AutomaticKeepAliveClientMixin

    return Container(
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
        child: _isInitialized && _controller != null
            ? _buildVideoPlayer()
            : _buildLoadingState(),
      ),
    );
  }

  // ... باقي الـ methods بدون تغيير

  Widget _buildLoadingState() {
    return Container(
      height: 400.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: _hasError
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
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.kprimaryColor),
                  SizedBox(height: 16.h),
                  Text('جاري التحميل...', style: Styles.textStyle14),
                ],
              ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    final duration = _controller!.value.duration;
    final position = _controller!.value.position;
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

          // Play Button Overlay
          if (!_controller!.value.isPlaying && !_isBuffering)
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow, color: Colors.white, size: 32.w),
              ),
            ),

          // Controls
          if (_showControls)
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
                          _controller!.value.isPlaying
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
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: _openFullscreen,
                        icon: Icon(
                          Icons.fullscreen,
                          color: Colors.white,
                          size: 24.w,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Text(
                        _formatDuration(position),
                        style: Styles.textStyle12.copyWith(color: Colors.white),
                      ),
                      Expanded(
                        child: Slider(
                          value: position.inMilliseconds.toDouble().clamp(
                            0.0,
                            duration.inMilliseconds.toDouble(),
                          ),
                          min: 0,
                          max: duration.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            _controller!.seekTo(
                              Duration(milliseconds: value.toInt()),
                            );
                          },
                          activeColor: AppColors.kprimaryColor,
                          inactiveColor: Colors.grey.shade400,
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: Styles.textStyle12.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Buffering Indicator
          if (_isBuffering)
            Center(
              child: CircularProgressIndicator(color: AppColors.kprimaryColor),
            ),

          // Tap to show/hide controls
          if (!_showControls && !_isBuffering)
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
