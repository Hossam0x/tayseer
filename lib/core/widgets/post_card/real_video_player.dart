// ignore_for_file: unused_element_parameter

import 'package:tayseer/core/utils/router/route_observers.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/core/widgets/post_card/full_screen_video_player.dart';
import 'package:tayseer/my_import.dart';

class RealVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isReel;
  final VideoPlayerController? videoController;
  final Function(VideoPlayerController)? onControllerCreated;
  final Function(VideoPlayerController controller)? onReelTap;

  const RealVideoPlayer({
    super.key,
    required this.videoUrl,
    this.isReel = false,
    this.videoController,
    this.onControllerCreated,
    this.onReelTap,
  });

  @override
  State<RealVideoPlayer> createState() => _RealVideoPlayerState();
}

class _RealVideoPlayerState extends State<RealVideoPlayer> with RouteAware {
  VideoPlayerController? _controller;
  final _videoCacheManager = VideoCacheManager();

  // States
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isBuffering = false;
  bool _showControls = false;
  bool _isMuted = false;
  bool _isEnded = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    final route = ModalRoute.of(context);
    if (route != null) {
      videoRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didUpdateWidget(RealVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoController != oldWidget.videoController) {
      if (widget.videoController != null) {
        _disposeLocalController();
        _controller = widget.videoController;
        _setupController();
      }
    }
  }

  @override
  void dispose() {
    videoRouteObserver.unsubscribe(this);
    _disposeLocalController();
    super.dispose();
  }

  // ✅ Called when a new route is pushed on top of this one
  @override
  void didPushNext() {
    // Pause video when navigating to another screen (like Stories)
    if (_controller != null && _controller!.value.isPlaying) {
      _controller!.pause();
    }
  }

  // ✅ Called when returning to this route from another route
  @override
  void didPopNext() {
    // Video will auto-play again via VisibilityDetector when visible
    // No need to manually play here
  }

  void _disposeLocalController() {
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      if (widget.videoController == null) {
        _controller!.dispose();
      }
    }
    _controller = null;
    _isInitialized = false;
    _isBuffering = false;
  }

  // --- Initialization Logic ---
  // --- Initialization Logic ---

  Future<void> _initializeVideo() async {
    // A. مسار الكنترولر المشترك (Shared Controller - زي ما احنا)
    if (widget.videoController != null) {
      _controller = widget.videoController;
      _setupController();
      // لو راجعين من الديتيلز وكان شغال، ممكن يكمل، غير كده مش هيشتغل
      return;
    }

    // B. مسار التحميل الجديد
    if (_controller != null || widget.videoUrl.isEmpty) return;

    try {
      final cachedFile = await _videoCacheManager.getCachedFile(
        widget.videoUrl,
      );
      if (!mounted) return;

      if (cachedFile != null) {
        _controller = VideoPlayerController.file(cachedFile);
      } else {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
        );
        _videoCacheManager.preloadVideoInBackground(widget.videoUrl);
      }

      await _controller!.initialize();
      _controller!.setVolume(1.0);
      _setupController();

      widget.onControllerCreated?.call(_controller!);

      // ❌❌❌ تم حذف الكود اللي كان بيشغل الريلز هنا ❌❌❌
      // if (mounted && widget.isReel) { _controller!.play(); }  <-- مسحنا السطر ده

      // دلوقتي الفيديو بقى "جاهز" (Initialized) بس "واقف" (Paused)
      // ومش هيشتغل غير لما VisibilityDetector يبعت اشارة
    } catch (e) {
      debugPrint("❌ Error initializing video: $e");
      if (mounted) setState(() => _hasError = true);
    }
  }

  // --- Visibility Logic ---

  void _handleVisibility(VisibilityInfo info) {
    // 1. لو انتقلنا لصفحة تانية، متعملش حاجة
    final Route? route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;

    // 2. نسبة الظهور (خليناها 0.6 يعني 60% من الفيديو لازم يكون ظاهر)
    final double visibleFraction = info.visibleFraction;

    // 3. شرط التشغيل
    if (visibleFraction > 0.6) {
      if (_controller != null &&
          _isInitialized &&
          !_controller!.value.isPlaying &&
          !_isEnded &&
          !_hasError) {
        // ✅ هنا بس الفيديو هيشتغل
        _controller!.play();
      }
    }
    // 4. شرط التوقف
    else {
      if (_controller != null && _controller!.value.isPlaying) {
        // ✅ لو اختفى (أقل من 60%) يوقف فوراً
        _controller!.pause();
      }
    }
  }

  void _setupController() {
    if (_controller == null) return;
    _isInitialized = _controller!.value.isInitialized;
    _isMuted = _controller!.value.volume == 0;
    _isBuffering = _controller!.value.isBuffering;
    _controller!.addListener(_videoListener);
    if (mounted) setState(() {});
  }

  // --- Listeners & Helpers ---

  void _videoListener() {
    if (!mounted || _controller == null) return;
    final value = _controller!.value;

    if (value.isBuffering != _isBuffering) {
      setState(() => _isBuffering = value.isBuffering);
    }

    if (value.isInitialized &&
        !value.isPlaying &&
        value.position >= value.duration) {
      if (!_isEnded) {
        setState(() {
          _isEnded = true;
          _showControls = true;
        });
      }
    } else {
      if (_isEnded && value.position < value.duration) {
        setState(() => _isEnded = false);
      }
    }
  }

  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _isInitialized = false;
    });
    _disposeLocalController();
    _initializeVideo();
  }

  void _handleTap() {
    if (widget.isReel) {
      if (_isInitialized && _controller != null) {
        widget.onReelTap?.call(_controller!);
      }
    } else {
      _toggleControls();
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls && (_controller?.value.isPlaying ?? false)) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && (_controller?.value.isPlaying ?? false)) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  // --- Actions ---

  void _togglePlay() {
    _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
    setState(() {});
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller?.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _seekRelative(Duration offset) {
    if (_controller == null) return;
    final newPos = _controller!.value.position + offset;
    final dur = _controller!.value.duration;
    if (newPos < Duration.zero) {
      _controller!.seekTo(Duration.zero);
    } else if (newPos > dur) {
      _controller!.seekTo(dur);
    } else {
      _controller!.seekTo(newPos);
    }
  }

  Future<void> _openFullscreen() async {
    if (_controller == null || !_isInitialized) return;

    _controller!.pause();
    // تأكد من وجود كلاس FullscreenResult و FullscreenVideoPlayer

    final result = await Navigator.push<FullscreenResult>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => FullscreenVideoPlayer(
          videoUrl: widget.videoUrl,
          startPosition: _controller!.value.position,
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
      if (result.wasPlaying) _controller!.play();
    }
  }

  // --- Build UI ---

  @override
  Widget build(BuildContext context) {
    final aspectRatio = widget.isReel ? 4 / 5 : 16 / 9;
    final visibilityKey = Key(
      "${widget.videoUrl}_${widget.isReel ? 'reel' : 'post'}",
    );

    Widget content = AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: GestureDetector(
            onTap: _handleTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isInitialized && _controller != null)
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  ),

                if (_hasError) _buildErrorState(),
                if (!_isInitialized && !_hasError)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                if (_isInitialized && _isBuffering && !_showControls)
                  _buildBufferingIndicator(),

                if (!_isInitialized && !_hasError && !widget.isReel)
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 40.sp,
                      ),
                    ),
                  ),

                if (_isInitialized && _controller != null && !widget.isReel)
                  _ControlsOverlay(
                    controller: _controller!,
                    isVisible: _showControls,
                    isMuted: _isMuted,
                    isEnded: _isEnded,
                    onPlayPause: _togglePlay,
                    onMute: _toggleMute,
                    onReplay: () {
                      _controller!.seekTo(Duration.zero);
                      _controller!.play();
                      setState(() => _isEnded = false);
                    },
                    onSeekForward: () =>
                        _seekRelative(const Duration(seconds: 10)),
                    onSeekBackward: () =>
                        _seekRelative(const Duration(seconds: -10)),
                    onFullscreen: _openFullscreen,
                    onTapBackground: _handleTap,
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return VisibilityDetector(
      key: visibilityKey,
      onVisibilityChanged: _handleVisibility,
      child: content,
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.white54, size: 40.sp),
          SizedBox(height: 8.h),
          Text(
            'فشل التحميل',
            style: TextStyle(color: Colors.white54, fontSize: 12.sp),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: _retryInitialization,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: Colors.white, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    'إعادة',
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBufferingIndicator() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

// ... باقي الكلاسات (Overlay, Buttons, Seekbar) زي ما كانت في كودك الأخير
class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isVisible;
  final bool isMuted;
  final bool isEnded;
  final VoidCallback onPlayPause;
  final VoidCallback onMute;
  final VoidCallback onReplay;
  final VoidCallback onSeekForward;
  final VoidCallback onSeekBackward;
  final VoidCallback onFullscreen;
  final VoidCallback onTapBackground;

  const _ControlsOverlay({
    required this.controller,
    required this.isVisible,
    required this.isMuted,
    required this.isEnded,
    required this.onPlayPause,
    required this.onMute,
    required this.onReplay,
    required this.onSeekForward,
    required this.onSeekBackward,
    required this.onFullscreen,
    required this.onTapBackground,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapBackground,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !isVisible,
          child: Container(
            color: Colors.black.withOpacity(0.4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleButton(
                        icon: Icons.fullscreen_rounded,
                        onTap: onFullscreen,
                      ),
                      _CircleButton(
                        icon: isMuted ? Icons.volume_off : Icons.volume_up,
                        onTap: onMute,
                      ),
                    ],
                  ),
                ),
                isEnded
                    ? _CircleButton(
                        icon: Icons.replay,
                        size: 40.sp,
                        padding: 12.r,
                        onTap: onReplay,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: onSeekBackward,
                            icon: Icon(
                              Icons.replay_10,
                              color: Colors.white,
                              size: 30.sp,
                            ),
                          ),
                          SizedBox(width: 20.w),
                          _CircleButton(
                            icon: controller.value.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 40.sp,
                            padding: 8.r,
                            onTap: onPlayPause,
                          ),
                          SizedBox(width: 20.w),
                          IconButton(
                            onPressed: onSeekForward,
                            icon: Icon(
                              Icons.forward_10,
                              color: Colors.white,
                              size: 30.sp,
                            ),
                          ),
                        ],
                      ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
                  child: _VideoSeekBar(
                    controller: controller,
                    onSeek: (pos) => controller.seekTo(pos),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double? size;
  final double? padding;
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.size,
    this.padding,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding ?? 6.r),
        decoration: const BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size ?? 20.sp),
      ),
    );
  }
}

class _VideoSeekBar extends StatefulWidget {
  final VideoPlayerController controller;
  final Function(Duration) onSeek;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  const _VideoSeekBar({
    required this.controller,
    required this.onSeek,
    this.onDragStart,
    this.onDragEnd,
  });
  @override
  State<_VideoSeekBar> createState() => _VideoSeekBarState();
}

class _VideoSeekBarState extends State<_VideoSeekBar> {
  double? _dragValue;
  bool _isDragging = false;
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        final duration = value.duration;
        final position = value.position;
        if (duration.inMilliseconds == 0) return const SizedBox.shrink();
        final progress = _isDragging
            ? _dragValue!
            : position.inMilliseconds / duration.inMilliseconds;
        final displayPosition = _isDragging
            ? Duration(
                milliseconds: (_dragValue! * duration.inMilliseconds).toInt(),
              )
            : position;
        return Row(
          children: [
            SizedBox(
              width: 45.w,
              child: Text(
                _formatDuration(displayPosition),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4.h,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: _isDragging ? 8.r : 6.r,
                  ),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 16.r),
                  activeTrackColor: AppColors.kprimaryColor,
                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                  thumbColor: AppColors.kprimaryColor,
                  overlayColor: AppColors.kprimaryColor.withOpacity(0.2),
                ),
                child: Slider(
                  value: progress.clamp(0.0, 1.0),
                  onChangeStart: (value) {
                    setState(() {
                      _isDragging = true;
                      _dragValue = value;
                    });
                    widget.onDragStart?.call();
                  },
                  onChanged: (value) {
                    setState(() => _dragValue = value);
                  },
                  onChangeEnd: (value) {
                    final newPosition = Duration(
                      milliseconds: (value * duration.inMilliseconds).toInt(),
                    );
                    widget.onSeek(newPosition);
                    setState(() {
                      _isDragging = false;
                      _dragValue = null;
                    });
                    widget.onDragEnd?.call();
                  },
                ),
              ),
            ),
            SizedBox(
              width: 45.w,
              child: Text(
                _formatDuration(duration),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12.sp,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        );
      },
    );
  }
}
