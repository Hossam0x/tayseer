// ignore_for_file: unused_element_parameter

import 'package:tayseer/core/utils/router/route_observers.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/video/video_state_manager.dart';
import 'package:tayseer/core/widgets/post_card/full_screen_video_player.dart';
import 'package:tayseer/my_import.dart';

class RealVideoPlayer extends StatefulWidget {
  final String postId;
  final String videoUrl;
  final bool isReel;
  final VideoPlayerController? videoController;
  final Function(VideoPlayerController)? onControllerCreated;
  final Function(VideoPlayerController controller)? onReelTap;

  const RealVideoPlayer({
    super.key,
    required this.postId,
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
  final _stateManager = VideoStateManager();

  // States
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isBuffering = false;
  bool _showControls = false;
  bool _isMuted = false;
  bool _isEnded = false;
  bool _isDisposed = false;

  // إعادة المحاولة
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    // نستمع للمدير عشان نعرف مين اللي عليه الدور يشتغل
    VideoManager.instance.currentlyPlayingPostId.addListener(
      _videoManagerListener,
    );

    // ملاحظة: لغينا التحميل المباشر هنا _initializeVideo()
    // التحميل هيتم بس لما الفيديو يظهر في الشاشة (في دالة _handleVisibility)
  }

  // دالة بتراقب المدير
  void _videoManagerListener() {
    if (_isDisposed || _controller == null) return;

    final activeId = VideoManager.instance.currentlyPlayingPostId.value;
    // لو الـ ID اللي شغال مش بتاعي، وأنا شغال، لازم أقف
    if (activeId != widget.postId) {
      try {
        if (_controller!.value.isPlaying) {
          _savePosition();
          _controller!.pause();
          // تأخير setState لتجنب خطأ build scope
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isDisposed) setState(() {});
          });
        }
      } catch (e) {
        // الـ controller تم تدميره
        debugPrint('⚠️ Cannot pause in listener, controller disposed');
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
  void didUpdateWidget(RealVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoController != oldWidget.videoController) {
      if (widget.videoController != null) {
        // تحقق من أن الـ controller الجديد لم يتم تدميره
        try {
          // محاولة الوصول للقيمة للتحقق من أنه لم يتم تدميره
          final _ = widget.videoController!.value;
          _disposeLocalController();
          _controller = widget.videoController;
          _setupController();
        } catch (e) {
          // الـ controller تم تدميره، تجاهله
          debugPrint('⚠️ Received disposed controller, ignoring');
        }
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    // حفظ الموضع قبل التدمير
    _savePosition();
    // نوقف الاستماع للمدير
    VideoManager.instance.currentlyPlayingPostId.removeListener(
      _videoManagerListener,
    );
    videoRouteObserver.unsubscribe(this);
    _disposeLocalController();
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
      // الـ controller تم تدميره
      debugPrint('⚠️ Cannot pause, controller disposed');
    }
  }

  void _savePosition() {
    if (_controller == null || widget.videoController != null) return;

    try {
      if (_controller!.value.isInitialized) {
        final position = _controller!.value.position;
        if (position.inSeconds > 0) {
          _stateManager.savePosition(widget.postId, position);
        }
      }
    } catch (e) {
      // الـ controller تم تدميره
      debugPrint('⚠️ Cannot save position, controller disposed');
    }
  }

  Future<void> _restorePosition() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final lastPosition = _stateManager.getLastPosition(widget.postId);
    if (lastPosition != null && lastPosition.inSeconds > 0) {
      final duration = _controller!.value.duration;
      // لا نستعيد إذا كان قريب من النهاية
      if (lastPosition < duration - const Duration(seconds: 2)) {
        await _controller!.seekTo(lastPosition);
        debugPrint(
          '📍 Restored position for ${widget.postId}: ${lastPosition.inSeconds}s',
        );
      }
    }
  }

  void _disposeLocalController() {
    if (_controller != null) {
      _controller!.removeListener(_videoListener);

      // لو الكنترولر ده مش جايلي من بره (مش shared)، يبقى بتاعي وأنا لازم اتخلص منه
      if (widget.videoController == null) {
        _controller!.dispose();
      } else {
        _controller!.pause(); // لو مشترك نوقفه بس
      }
    }
    _controller = null;
    _isInitialized = false;
    _isBuffering = false;
  }

  Future<void> _initializeVideo() async {
    // لو عندي كنترولر أصلاً، مش محتاج أحمل تاني
    if (_controller != null || _isDisposed) return;

    try {
      // 1. لو جاي كنترولر جاهز
      if (widget.videoController != null) {
        _controller = widget.videoController;
        _setupController();
        return;
      }

      // 2. تحميل جديد
      if (widget.videoUrl.isEmpty) return;

      final cachedFile = await _videoCacheManager.getCachedFile(
        widget.videoUrl,
      );
      if (!mounted || _isDisposed) return;

      if (cachedFile != null) {
        _controller = VideoPlayerController.file(cachedFile);
        debugPrint('📁 Home: Loading from cache');
      } else {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true, // مهم للأندرويد
            allowBackgroundPlayback: false,
          ),
        );
        // تحميل في الخلفية للكاش
        _videoCacheManager.preloadVideoInBackground(widget.videoUrl);
        debugPrint('🌐 Home: Loading from network');
      }

      await _controller!.initialize();
      if (!mounted || _isDisposed) {
        _controller?.dispose();
        return;
      }

      _controller!.setVolume(1.0);
      _setupController();

      widget.onControllerCreated?.call(_controller!);

      // استرجاع آخر موضع
      await _restorePosition();

      // تسجيل نجاح التحميل
      _stateManager.markAsLoaded(widget.postId);
      _retryCount = 0;

      // لو أنا الفيديو المختار حالياً من المدير، اشتغل فوراً
      if (VideoManager.instance.currentlyPlayingPostId.value == widget.postId) {
        _controller!.play();
      }
    } catch (e) {
      debugPrint("❌ Error initializing video: $e");
      if (mounted && !_isDisposed) {
        // إعادة محاولة تلقائية
        if (_retryCount < _maxRetries &&
            _stateManager.canRetry(widget.postId)) {
          _retryCount++;
          _stateManager.recordError(widget.postId);
          debugPrint('🔄 Auto-retrying... ($_retryCount/$_maxRetries)');
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

  void _handleVisibility(VisibilityInfo info) {
    if (!mounted || _isDisposed) return;

    final Route? route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;

    final double visibleFraction = info.visibleFraction;

    // حالة الظهور (أكتر من 70%)
    if (visibleFraction > 0.7) {
      // أ- لو الفيديو مش متحمل، حمله
      if (_controller == null && !_hasError) {
        _initializeVideo().then((_) {
          if (mounted && !_isDisposed && _isInitialized) {
            VideoManager.instance.playVideo(widget.postId);
            _controller!.play();
          }
        });
      }
      // ب- لو متحمل بس واقف
      else if (_controller != null &&
          _isInitialized &&
          !_controller!.value.isPlaying &&
          !_isEnded &&
          !_hasError) {
        VideoManager.instance.playVideo(widget.postId);
        _controller!.play();
      }
    }
    // حالة الاختفاء
    else {
      // لو اختفى جزئياً نوقفه مع حفظ الموضع
      if (_controller != null && _controller!.value.isPlaying) {
        _savePosition();
        _controller!.pause();
      }

      // لو اختفى تماماً (0.0) والكنترولر ده مش مشترك، امسحه من الذاكرة
      // لكن نحتفظ بالموضع في StateManager
      if (visibleFraction == 0.0 && widget.videoController == null) {
        _savePosition();
        _disposeLocalController();
        if (mounted && !_isDisposed) setState(() => _isInitialized = false);
      }
    }
  }

  void _setupController() {
    if (_controller == null) return;

    // تحقق من أن الـ controller لم يتم تدميره
    try {
      _isInitialized = _controller!.value.isInitialized;
      _isMuted = _controller!.value.volume == 0;
      _isBuffering = _controller!.value.isBuffering;
      _controller!.addListener(_videoListener);
      if (mounted && !_isDisposed) setState(() {});
    } catch (e) {
      // الـ controller تم تدميره
      debugPrint('⚠️ Controller disposed during setup: $e');
      _controller = null;
      _isInitialized = false;
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null || _isDisposed) return;

    try {
      final value = _controller!.value;

      // تأخير setState لتجنب خطأ build scope
      void safeSetState(VoidCallback fn) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDisposed) setState(fn);
        });
      }

      if (value.isBuffering != _isBuffering) {
        safeSetState(() => _isBuffering = value.isBuffering);
      }

      if (value.isInitialized &&
          !value.isPlaying &&
          value.position >= value.duration) {
        if (!_isEnded) {
          safeSetState(() {
            _isEnded = true;
            _showControls = true;
          });
        }
      } else {
        if (_isEnded && value.position < value.duration) {
          safeSetState(() => _isEnded = false);
        }
      }

      // حفظ الموضع دورياً
      if (_isInitialized &&
          value.position.inSeconds % 5 == 0 &&
          value.position.inSeconds > 0) {
        _savePosition();
      }
    } catch (e) {
      // الـ controller تم تدميره
      debugPrint('⚠️ Controller disposed in listener');
    }
  }

  void _retryInitialization() {
    if (_isDisposed) return;

    // إعادة تعيين حالة الخطأ
    _stateManager.resetErrorCount(widget.postId);
    _videoCacheManager.resetFailedStatus(widget.videoUrl);
    _retryCount = 0;

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

  void _togglePlay() {
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      // ✅ نبلغ المدير اننا هنشتغل عشان يقفل الباقي
      VideoManager.instance.playVideo(widget.postId);
      _controller!.play();
    }
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
      if (result.wasPlaying) {
        VideoManager.instance.playVideo(widget.postId);
        _controller!.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = widget.isReel ? 4 / 5 : 16 / 9;
    final visibilityKey = Key("${widget.postId}_${widget.videoUrl}");

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

                // لودينج لو لسة بنحمل
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
                      VideoManager.instance.playVideo(widget.postId);
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

// ... باقي الويدجتس (Overlay, Seekbar) زي ما هي في كودك القديم بالظبط
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
