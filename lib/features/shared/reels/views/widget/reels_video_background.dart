import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/core/video/video_state_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/router/route_observers.dart';

class ReelsVideoBackground extends StatefulWidget {
  final String videoUrl;
  final String? videoId;
  final String? thumbnailUrl;
  final bool shouldPlay;
  final VoidCallback onTap;
  final void Function(Offset)? onDoubleTap;
  final bool showProgressBar;
  final VideoPlayerController? sharedController;
  final ValueChanged<VideoPlayerController>? onControllerCreated;

  const ReelsVideoBackground({
    super.key,
    required this.videoUrl,
    this.videoId,
    this.thumbnailUrl,
    required this.shouldPlay,
    required this.onTap,
    this.onDoubleTap,
    this.showProgressBar = true,
    this.sharedController,
    this.onControllerCreated,
  });

  @override
  State<ReelsVideoBackground> createState() => _ReelsVideoBackgroundState();
}

class _ReelsVideoBackgroundState extends State<ReelsVideoBackground>
    with WidgetsBindingObserver, RouteAware {
  VideoPlayerController? _controller;
  final _videoCacheManager = VideoCacheManager();
  final _stateManager = VideoStateManager();
  final _muteManager = GlobalMuteManager.instance;

  bool _isInitialized = false;
  bool _hasError = false;
  bool _isBuffering = false;
  bool _isDragging = false;
  bool _isDisposed = false;
  bool _isSpeedUp = false;
  bool _showSpeedIndicator = false;

  int _retryCount = 0;
  int _lastSavedSecond = -1;
  static const int _maxRetries = 3;

  String get _videoId => widget.videoId ?? widget.videoUrl.hashCode.toString();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _muteManager.isMuted.addListener(_onGlobalMuteChanged);
    _initializeVideo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      videoRouteObserver.subscribe(this, modalRoute);
    }
  }

  void _onGlobalMuteChanged() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isDisposed) {
      return;
    }
    try {
      controller.setVolume(_muteManager.isMuted.value ? 0.0 : 1.0);
    } catch (e) {
      debugPrint('⚠️ Cannot change volume: $e');
    }
  }

  double get _volume => _muteManager.isMuted.value ? 0.0 : 1.0;

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;

    // Shared Controller
    if (widget.sharedController != null) {
      _controller = widget.sharedController;
      await _controller!.setVolume(_volume);

      if (!mounted || _controller == null || _isDisposed) return;

      if (_controller!.value.isInitialized) {
        _isInitialized = true;
        _hasError = false;
        await _controller!.setLooping(true);
        await _restorePosition();
        if (widget.shouldPlay) _controller!.play();
      }
      _controller!.addListener(_videoListener);
      widget.onControllerCreated?.call(_controller!);
      if (mounted && !_isDisposed) setState(() {});
      return;
    }

    try {
      if (widget.videoUrl.isEmpty) return;

      final cachedFile = await _videoCacheManager.getCachedFile(
        widget.videoUrl,
      );
      if (!mounted || _isDisposed) return;

      _controller = cachedFile != null
          ? VideoPlayerController.file(cachedFile)
          : VideoPlayerController.networkUrl(
              Uri.parse(widget.videoUrl),
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
            );

      if (cachedFile == null) {
        _videoCacheManager.preloadVideoInBackground(widget.videoUrl);
      }

      _controller!.addListener(_videoListener);
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setVolume(_volume);

      if (!mounted || _isDisposed) {
        _controller?.dispose();
        _controller = null;
        return;
      }

      widget.onControllerCreated?.call(_controller!);
      await _restorePosition();

      setState(() {
        _isInitialized = true;
        _hasError = false;
      });

      _stateManager.markAsLoaded(_videoId);
      _retryCount = 0;

      if (widget.shouldPlay) _controller!.play();
    } catch (e) {
      debugPrint('❌ Error initializing video: $e');
      if (!mounted || _isDisposed) return;

      if (_retryCount < _maxRetries && _stateManager.canRetry(_videoId)) {
        _retryCount++;
        _stateManager.recordError(_videoId);
        await Future.delayed(Duration(milliseconds: 500 * _retryCount));
        if (mounted && !_isDisposed) _initializeVideo();
      } else {
        _scheduleSetState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
    }
  }

  Future<void> _restorePosition() async {
    if (_controller == null) return;

    try {
      if (!_controller!.value.isInitialized) return;

      final lastPosition = _stateManager.getLastPosition(_videoId);
      if (lastPosition != null && lastPosition.inSeconds > 0) {
        // لا نستعيد إذا كان قريب جداً من البداية أو النهاية
        final duration = _controller!.value.duration;
        if (lastPosition < duration - const Duration(seconds: 2)) {
          await _controller!.seekTo(lastPosition);
          debugPrint('📍 Restored reel position: ${lastPosition.inSeconds}s');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Cannot restore position, controller disposed');
    }
  }

  void _savePosition() {
    if (_controller == null || widget.sharedController != null) return;

    try {
      if (_controller!.value.isInitialized) {
        final position = _controller!.value.position;
        if (position.inSeconds > 0) {
          _stateManager.savePosition(_videoId, position);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Cannot save position, controller disposed');
    }
  }

  void _videoListener() {
    final controller = _controller;
    if (controller == null || !mounted || _isDisposed) return;

    try {
      final value = controller.value;

      if (value.isBuffering != _isBuffering) {
        _scheduleSetState(() => _isBuffering = value.isBuffering);
      }

      // Debounced position save
      final currentSecond = value.position.inSeconds;
      if (_isInitialized &&
          !_isDragging &&
          currentSecond > 0 &&
          currentSecond % 5 == 0 &&
          currentSecond != _lastSavedSecond) {
        _lastSavedSecond = currentSecond;
        _savePosition();
      }
    } catch (e) {
      debugPrint('⚠️ Controller disposed in listener');
    }
  }

  void _scheduleSetState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) setState(fn);
    });
  }

  @override
  void didUpdateWidget(covariant ReelsVideoBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isInitialized && _controller != null && !_isDisposed) {
      try {
        if (widget.shouldPlay && !oldWidget.shouldPlay) {
          _controller!.play();
        } else if (!widget.shouldPlay && oldWidget.shouldPlay) {
          _savePosition(); // حفظ قبل الإيقاف
          _controller!.pause();
        }
      } catch (e) {
        debugPrint('⚠️ Controller disposed in didUpdateWidget');
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_controller?.value.isPlaying == true) {
        _controller?.pause();
        _savePosition();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (widget.shouldPlay && _controller?.value.isInitialized == true) {
        _controller?.play();
      }
    }
  }

  @override
  void didPushNext() {
    if (_controller?.value.isPlaying == true) {
      _controller?.pause();
      _savePosition();
    }
  }

  @override
  void didPopNext() {
    if (widget.shouldPlay && _controller?.value.isInitialized == true) {
      _controller?.play();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _savePosition();
    _muteManager.isMuted.removeListener(_onGlobalMuteChanged);
    videoRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);

    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_videoListener);
      if (widget.sharedController == null) {
        controller.dispose();
      }
    }
    _controller = null;
    super.dispose();
  }

  void _retryInitialization() {
    if (_isDisposed) return;

    // إعادة تعيين حالة الخطأ
    _stateManager.resetErrorCount(_videoId);
    _videoCacheManager.resetFailedStatus(widget.videoUrl);
    _retryCount = 0;

    setState(() {
      _hasError = false;
      _isInitialized = false;
    });

    if (widget.sharedController == null && _controller != null) {
      _controller!.removeListener(_videoListener);
      _controller!.dispose();
    }
    _controller = null;
    _initializeVideo();
  }

  void _seekTo(Duration position) {
    _controller?.seekTo(position);
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (_controller == null || !_isInitialized) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final tapPosition = details.localPosition.dx;

    // Check if tap is on left or right third of the screen
    final isOnSide =
        tapPosition < screenWidth / 3 || tapPosition > screenWidth * 2 / 3;

    if (isOnSide) {
      setState(() {
        _isSpeedUp = true;
        _showSpeedIndicator = true;
      });
      _controller?.setPlaybackSpeed(2.0);
    }
  }

  void _onLongPressEnd(LongPressEndDetails details) => _resetSpeed();

  void _onLongPressCancel() => _resetSpeed();

  void _resetSpeed() {
    if (!_isSpeedUp) return;
    setState(() {
      _isSpeedUp = false;
      _showSpeedIndicator = false;
    });
    _controller?.setPlaybackSpeed(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTapDown: (details) =>
          widget.onDoubleTap?.call(details.globalPosition),
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      onLongPressCancel: _onLongPressCancel,
      child: ColoredBox(
        color: Colors.black,
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail (instant display before video loads)
              if (!_isInitialized &&
                  widget.thumbnailUrl != null &&
                  widget.thumbnailUrl!.isNotEmpty)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: widget.thumbnailUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const ColoredBox(color: Colors.black),
                    errorWidget: (_, __, ___) =>
                        const ColoredBox(color: Colors.black),
                  ),
                ),

              // Video
              if (_isInitialized && _controller != null)
                Center(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),

              // Loading
              if (!_isInitialized && !_hasError)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),

              // Buffering
              if (_isInitialized && _isBuffering && widget.shouldPlay)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),

              // Speed Indicator (2x)
              if (_showSpeedIndicator)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 75.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fast_forward,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '2x',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Error – opaque overlay absorbs taps so they reach the retry button
              if (_hasError)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _retryInitialization,
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.6),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white54,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.refresh, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'إعادة المحاولة',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Progress Bar
              if (widget.showProgressBar &&
                  _isInitialized &&
                  _controller != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _VideoSeekBar(
                    controller: _controller!,
                    onDragStart: () {
                      if (mounted) setState(() => _isDragging = true);
                    },
                    onDragEnd: () {
                      if (mounted) setState(() => _isDragging = false);
                    },
                    onSeek: _seekTo,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Corrected _VideoSeekBar Class
class _VideoSeekBar extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;
  final Function(Duration) onSeek;

  const _VideoSeekBar({
    required this.controller,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onSeek,
  });

  @override
  State<_VideoSeekBar> createState() => _VideoSeekBarState();
}

class _VideoSeekBarState extends State<_VideoSeekBar> {
  double? _dragValue;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: widget.controller,
        builder: (context, value, child) {
          final duration = value.duration;
          final position = value.position;

          if (duration.inMilliseconds == 0) return const SizedBox.shrink();

          final progress = _isDragging
              ? _dragValue!
              : position.inMilliseconds / duration.inMilliseconds;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (details) {
              _isDragging = true;
              widget.onDragStart();
              _updateDragPosition(details.localPosition.dx, context);
            },
            onHorizontalDragUpdate: (details) {
              _updateDragPosition(details.localPosition.dx, context);
            },
            onHorizontalDragEnd: (details) {
              _isDragging = false;
              widget.onDragEnd();
              final newPosition = Duration(
                milliseconds: (_dragValue! * duration.inMilliseconds).toInt(),
              );
              widget.onSeek(newPosition);
            },
            onTapUp: (details) {
              final width = context.size!.width;
              final tapPosition = details.localPosition.dx / width;
              final newPosition = Duration(
                milliseconds:
                    (tapPosition.clamp(0.0, 1.0) * duration.inMilliseconds)
                        .toInt(),
              );
              widget.onSeek(newPosition);
            },
            child: Container(
              height: 30.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Gray background + white progress inside it
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3.r),
                    child: Container(
                      height: _isDragging ? 6.h : 3.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: _isDragging
                            ? Duration.zero
                            : const Duration(milliseconds: 100),
                        height: _isDragging ? 6.h : 3.h,
                        width:
                            (MediaQuery.of(context).size.width - 24.w) *
                            progress.clamp(0.0, 1.0),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Drag circle
                  if (_isDragging)
                    Positioned(
                      left:
                          (MediaQuery.of(context).size.width - 24.w) *
                              progress.clamp(0.0, 1.0) -
                          7.r,
                      child: Container(
                        width: 14.r,
                        height: 14.r,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _updateDragPosition(double dx, BuildContext context) {
    final width = MediaQuery.of(context).size.width - 24.w;
    final position = ((dx - 12.w) / width).clamp(0.0, 1.0);
    setState(() => _dragValue = position);
  }
}
