// lib/core/widgets/post_card/real_video_player.dart

// ignore_for_file: unused_element_parameter

import 'package:tayseer/core/utils/global_mute_manager.dart'; // ✅ أضف هذا
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
  final _muteManager = GlobalMuteManager.instance; // ✅ أضف هذا

  // States
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isBuffering = false;
  bool _showControls = false;
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

    // ✅ نستمع لتغييرات الـ Mute العام
    _muteManager.isMuted.addListener(_onGlobalMuteChanged);
  }

  // ✅ دالة جديدة: لما الـ Global Mute يتغير
  void _onGlobalMuteChanged() {
    if (_controller != null &&
        _controller!.value.isInitialized &&
        !_isDisposed) {
      try {
        _controller!.setVolume(_muteManager.isMuted.value ? 0.0 : 1.0);
        if (mounted) setState(() {});
      } catch (e) {
        debugPrint('⚠️ Cannot change volume: $e');
      }
    }
  }

  // ✅ دالة جديدة: تبديل الـ Mute (للزر)
  void _toggleGlobalMute() {
    _muteManager.toggleMute();
  }

  void _videoManagerListener() {
    if (_isDisposed || _controller == null) return;

    final activeId = VideoManager.instance.currentlyPlayingPostId.value;
    if (activeId != widget.postId) {
      try {
        if (_controller!.value.isPlaying) {
          _savePosition();
          _controller!.pause();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isDisposed) setState(() {});
          });
        }
      } catch (e) {
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
        try {
          final _ = widget.videoController!.value;
          _disposeLocalController();
          _controller = widget.videoController;
          _setupController();
        } catch (e) {
          debugPrint('⚠️ Received disposed controller, ignoring');
        }
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _savePosition();
    VideoManager.instance.currentlyPlayingPostId.removeListener(
      _videoManagerListener,
    );
    _muteManager.isMuted.removeListener(_onGlobalMuteChanged); // ✅ أضف هذا
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
      debugPrint('⚠️ Cannot save position, controller disposed');
    }
  }

  Future<void> _restorePosition() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final lastPosition = _stateManager.getLastPosition(widget.postId);
    if (lastPosition != null && lastPosition.inSeconds > 0) {
      final duration = _controller!.value.duration;
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

      if (widget.videoController == null) {
        _controller!.dispose();
      } else {
        _controller!.pause();
      }
    }
    _controller = null;
    _isInitialized = false;
    _isBuffering = false;
  }

  Future<void> _initializeVideo() async {
    if (_controller != null || _isDisposed) return;

    try {
      if (widget.videoController != null) {
        _controller = widget.videoController;
        _setupController();
        return;
      }

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
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
        );
        _videoCacheManager.preloadVideoInBackground(widget.videoUrl);
        debugPrint('🌐 Home: Loading from network');
      }

      await _controller!.initialize();
      if (!mounted || _isDisposed) {
        _controller?.dispose();
        return;
      }

      // ✅ استخدم الـ Global Mute State
      _controller!.setVolume(_muteManager.isMuted.value ? 0.0 : 1.0);
      _setupController();

      widget.onControllerCreated?.call(_controller!);

      await _restorePosition();

      _stateManager.markAsLoaded(widget.postId);
      _retryCount = 0;

      if (VideoManager.instance.currentlyPlayingPostId.value == widget.postId) {
        _controller!.play();
      }
    } catch (e) {
      debugPrint("❌ Error initializing video: $e");
      if (mounted && !_isDisposed) {
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

    if (visibleFraction > 0.7) {
      if (_controller == null && !_hasError) {
        _initializeVideo().then((_) {
          if (mounted && !_isDisposed && _isInitialized) {
            VideoManager.instance.playVideo(widget.postId);
            _controller!.play();
          }
        });
      } else if (_controller != null &&
          _isInitialized &&
          !_controller!.value.isPlaying &&
          !_isEnded &&
          !_hasError) {
        VideoManager.instance.playVideo(widget.postId);
        _controller!.play();
      }
    } else {
      if (_controller != null && _controller!.value.isPlaying) {
        _savePosition();
        _controller!.pause();
      }

      if (visibleFraction == 0.0 && widget.videoController == null) {
        _savePosition();
        _disposeLocalController();
        if (mounted && !_isDisposed) setState(() => _isInitialized = false);
      }
    }
  }

  void _setupController() {
    if (_controller == null) return;

    try {
      _isInitialized = _controller!.value.isInitialized;
      _isBuffering = _controller!.value.isBuffering;
      _controller!.addListener(_videoListener);

      // ✅ تطبيق الـ Global Mute State
      _controller!.setVolume(_muteManager.isMuted.value ? 0.0 : 1.0);

      if (mounted && !_isDisposed) setState(() {});
    } catch (e) {
      debugPrint('⚠️ Controller disposed during setup: $e');
      _controller = null;
      _isInitialized = false;
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null || _isDisposed) return;

    try {
      final value = _controller!.value;

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

      if (_isInitialized &&
          value.position.inSeconds % 5 == 0 &&
          value.position.inSeconds > 0) {
        _savePosition();
      }
    } catch (e) {
      debugPrint('⚠️ Controller disposed in listener');
    }
  }

  void _retryInitialization() {
    if (_isDisposed) return;

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
      VideoManager.instance.playVideo(widget.postId);
      _controller!.play();
    }
    setState(() {});
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
          // ✅ الـ FullscreenVideoPlayer هيستخدم الـ Global Mute برضو
        ),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    );

    if (result != null && mounted) {
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
                // Video Player
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

                // Error State
                if (_hasError) _buildErrorState(),

                // Loading
                if (!_isInitialized && !_hasError)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),

                // Buffering
                if (_isInitialized && _isBuffering && !_showControls)
                  _buildBufferingIndicator(),

                // Play Icon (when not initialized)
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

                // ✅ زرار الـ Mute العام (دايماً ظاهر في أسفل اليمين)
                if (_isInitialized && _controller != null && widget.isReel)
                  Positioned(
                    bottom: 12.h,
                    right: 12.w,
                    child: _GlobalMuteButton(onTap: _toggleGlobalMute),
                  ),

                // Controls Overlay (for non-reel videos)
                if (_isInitialized && _controller != null && !widget.isReel)
                  _ControlsOverlay(
                    controller: _controller!,
                    isVisible: _showControls,
                    isEnded: _isEnded,
                    onPlayPause: _togglePlay,
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

// ══════════════════════════════════════════════════════════════════════════════
// ✅ زرار الـ Mute العام (الجديد)
// ══════════════════════════════════════════════════════════════════════════════

class _GlobalMuteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GlobalMuteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: GlobalMuteManager.instance.isMuted,
      builder: (context, isMuted, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Controls Overlay (معدّل - بدون زرار mute لأنه بقى global)
// ══════════════════════════════════════════════════════════════════════════════

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isVisible;
  final bool isEnded;
  final VoidCallback onPlayPause;
  final VoidCallback onReplay;
  final VoidCallback onSeekForward;
  final VoidCallback onSeekBackward;
  final VoidCallback onFullscreen;
  final VoidCallback onTapBackground;

  const _ControlsOverlay({
    required this.controller,
    required this.isVisible,
    required this.isEnded,
    required this.onPlayPause,
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
                // Top Bar
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Fullscreen button
                      _CircleButton(
                        icon: Icons.fullscreen_rounded,
                        onTap: onFullscreen,
                      ),
                      // ✅ زرار الـ Mute العام
                      _GlobalMuteButton(
                        onTap: () => GlobalMuteManager.instance.toggleMute(),
                      ),
                    ],
                  ),
                ),

                // Center Controls
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

                // Seek Bar
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
