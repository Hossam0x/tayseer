import 'dart:async';
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
  final bool shouldInitialize;
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
    this.shouldInitialize = true,
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

  Completer<void>? _initCompleter;

  int _retryCount = 0;
  int _lastSavedSecond = -1;
  static const int _maxRetries = 5;

  Timer? _autoRetryTimer;

  String get _videoId => widget.videoId ?? widget.videoUrl.hashCode.toString();

  bool _isListenerAttached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _muteManager.isMuted.addListener(_onGlobalMuteChanged);
    if (widget.shouldInitialize) {
      _initializeVideo();
    }
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

    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      return _initCompleter!.future;
    }

    if (_controller != null && _isInitialized) return;

    _initCompleter = Completer<void>();

    // Shared Controller
    if (widget.sharedController != null) {
      _controller = widget.sharedController;
      try {
        await _controller!.setVolume(_volume);

        if (!mounted || _controller == null || _isDisposed) {
          _initCompleter?.complete();
          return;
        }

        if (_controller!.value.isInitialized) {
          _isInitialized = true;
          _hasError = false;
          await _controller!.setLooping(true);
          await _restorePosition();
          if (widget.shouldPlay) _controller!.play();
        }
        _attachListener();
        widget.onControllerCreated?.call(_controller!);
        if (mounted && !_isDisposed) setState(() {});
      } catch (e) {
        debugPrint('⚠️ Error setting up shared controller: $e');
      }
      _initCompleter?.complete();
      return;
    }

    try {
      if (widget.videoUrl.isEmpty) {
        _initCompleter?.complete();
        return;
      }

      final cachedFile = await _videoCacheManager.getCachedFile(
        widget.videoUrl,
      );
      if (!mounted || _isDisposed) {
        _initCompleter?.complete();
        return;
      }

      _controller = cachedFile != null
          ? VideoPlayerController.file(cachedFile)
          : VideoPlayerController.networkUrl(
              Uri.parse(widget.videoUrl),
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
            );

      if (cachedFile == null) {
        _videoCacheManager.preloadVideoInBackground(widget.videoUrl);
      }

      await _controller!.initialize();

      if (!mounted || _isDisposed) {
        _controller?.dispose();
        _controller = null;
        _initCompleter?.complete();
        return;
      }

      _attachListener();

      await _controller!.setLooping(true);
      await _controller!.setVolume(_volume);

      widget.onControllerCreated?.call(_controller!);
      await _restorePosition();

      setState(() {
        _isInitialized = true;
        _hasError = false;
      });

      _stateManager.markAsLoaded(_videoId);
      _retryCount = 0;
      _autoRetryTimer?.cancel();

      if (widget.shouldPlay) _controller!.play();

      _initCompleter?.complete();
    } catch (e) {
      debugPrint('❌ Error initializing video: $e');
      if (!mounted || _isDisposed) {
        _initCompleter?.complete();
        return;
      }

      try {
        _detachListener();
        _controller?.dispose();
      } catch (_) {}
      _controller = null;
      _isInitialized = false;

      if (_retryCount < _maxRetries && _stateManager.canRetry(_videoId)) {
        _retryCount++;
        _stateManager.recordError(_videoId);
        _initCompleter?.complete();

        final delay = Duration(milliseconds: 800 * _retryCount);
        _autoRetryTimer?.cancel();
        _autoRetryTimer = Timer(delay, () {
          if (mounted && !_isDisposed) {
            _initCompleter = null;
            _initializeVideo();
          }
        });
      } else {
        _scheduleSetState(() {
          _hasError = true;
          _isInitialized = false;
        });
        _initCompleter?.complete();
      }
    }
  }

  Future<void> _restorePosition() async {
    // Reels should always start from the beginning (position 0:00)
    return;
  }

  // ✅ التعديل الأساسي: شيلنا شرط sharedController عشان نحفظ الـ position دايماً
  // لأن البوست في الـ Home محتاج يقرأ الـ position دي لما اليوزر يرجع
  void _savePosition() {
    if (_controller == null) return; // ✅ بدون شرط sharedController

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

      if (value.hasError && !_hasError) {
        debugPrint('⚠️ Reel video error: ${value.errorDescription}');
        _handleSilentRetry();
        return;
      }

      if (value.isBuffering != _isBuffering) {
        _scheduleSetState(() => _isBuffering = value.isBuffering);
      }

      // ✅ تعديل: بنحفظ كل ثانية بدل كل 5 ثواني
      // عشان لما اليوزر يرجع للـ Home يلاقي الـ position محدّثة
      final currentSecond = value.position.inSeconds;
      if (_isInitialized &&
          !_isDragging &&
          currentSecond > 0 &&
          currentSecond != _lastSavedSecond) {
        _lastSavedSecond = currentSecond;
        _savePosition();
      }
    } catch (e) {
      debugPrint('⚠️ Controller disposed in listener');
    }
  }

  void _handleSilentRetry() {
    if (_isDisposed || !mounted) return;

    if (_retryCount < _maxRetries) {
      _retryCount++;
      debugPrint('🔄 Silent reel auto-retry #$_retryCount for $_videoId');

      try {
        _detachListener();
        if (widget.sharedController == null) {
          _controller?.dispose();
        }
      } catch (_) {}
      _controller = null;
      _isInitialized = false;
      _initCompleter = null;

      final delay = Duration(milliseconds: 800 * _retryCount);
      _autoRetryTimer?.cancel();
      _autoRetryTimer = Timer(delay, () {
        if (mounted && !_isDisposed) {
          _initializeVideo();
        }
      });
    } else {
      _scheduleSetState(() {
        _hasError = true;
        _isInitialized = false;
      });
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

    if (widget.shouldInitialize &&
        !oldWidget.shouldInitialize &&
        !_isInitialized &&
        _controller == null) {
      _initializeVideo();
      return;
    }

    if (!widget.shouldInitialize &&
        oldWidget.shouldInitialize &&
        !widget.shouldPlay) {
      _disposeController();
      return;
    }

    if (_isInitialized && _controller != null && !_isDisposed) {
      try {
        if (widget.shouldPlay && !oldWidget.shouldPlay) {
          _attachListener();
          _controller!.play();
        } else if (!widget.shouldPlay && oldWidget.shouldPlay) {
          _savePosition();
          _controller!.pause();
          _detachListener();
        }
      } catch (e) {
        debugPrint('⚠️ Controller disposed in didUpdateWidget');
      }
    }
  }

  void _attachListener() {
    if (!_isListenerAttached && _controller != null) {
      _controller!.addListener(_videoListener);
      _isListenerAttached = true;
    }
  }

  void _detachListener() {
    if (_isListenerAttached && _controller != null) {
      _controller!.removeListener(_videoListener);
      _isListenerAttached = false;
    }
  }

  void _disposeController() {
    if (_controller == null) return;
    _savePosition();
    try {
      _controller!.pause();
    } catch (_) {}
    _detachListener();
    if (widget.sharedController == null) {
      _controller!.dispose();
    }
    _controller = null;
    _isInitialized = false;
    _initCompleter = null;
    if (mounted && !_isDisposed) setState(() {});
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
      _videoCacheManager.resetAllFailedStatuses();
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

  // ✅ جديد: حفظ الـ position في deactivate (بيتنادى قبل dispose)
  // ده بيضمن إن الـ position تتحفظ في أقرب وقت لما الـ widget يتشال من الشجرة
  @override
  void deactivate() {
    _savePosition();
    super.deactivate();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoRetryTimer?.cancel();
    _savePosition();

    // ✅ أكمل أي Completer معلّق عشان مفيش future يفضل hanging
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      _initCompleter!.complete();
    }

    _muteManager.isMuted.removeListener(_onGlobalMuteChanged);
    videoRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);

    final controller = _controller;
    if (controller != null) {
      _detachListener();
      if (widget.sharedController == null) {
        controller.dispose();
      }
    }
    _controller = null;
    super.dispose();
  }

  void _retryInitialization() {
    if (_isDisposed) return;

    _stateManager.resetErrorCount(_videoId);
    _videoCacheManager.resetFailedStatus(widget.videoUrl);
    _retryCount = 0;
    _initCompleter = null;

    setState(() {
      _hasError = false;
      _isInitialized = false;
    });

    if (widget.sharedController == null && _controller != null) {
      _detachListener();
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

  Widget _buildVideoPlayer() {
    if (_controller == null) return const SizedBox.shrink();

    final videoSize = _controller!.value.size;

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: videoSize.width,
        height: videoSize.height,
        child: VideoPlayer(_controller!),
      ),
    );
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
              if (!_isInitialized &&
                  widget.thumbnailUrl != null &&
                  widget.thumbnailUrl!.isNotEmpty)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: widget.thumbnailUrl!,
                    fit: BoxFit.contain,
                    placeholder: (_, __) =>
                        const ColoredBox(color: Colors.black),
                    errorWidget: (_, __, ___) =>
                        const ColoredBox(color: Colors.black),
                  ),
                ),

              if (_isInitialized && _controller != null)
                Positioned.fill(child: _buildVideoPlayer()),

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
  double _progress = 0.0;
  Duration _duration = Duration.zero;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _startProgressTimer();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startProgressTimer() {
    _updateTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (!mounted || _isDragging) return;
      final value = widget.controller.value;
      if (value.duration.inMilliseconds == 0) return;
      final newProgress =
          value.position.inMilliseconds / value.duration.inMilliseconds;
      if ((newProgress - _progress).abs() > 0.005) {
        setState(() {
          _progress = newProgress;
          _duration = value.duration;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final duration = _isDragging ? _duration : widget.controller.value.duration;
    if (duration.inMilliseconds == 0) return const SizedBox.shrink();
    final progress = _isDragging ? _dragValue! : _progress;

    return SafeArea(
      top: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (details) {
          _isDragging = true;
          _duration = widget.controller.value.duration;
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
                (tapPosition.clamp(0.0, 1.0) * duration.inMilliseconds).toInt(),
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
      ),
    );
  }

  void _updateDragPosition(double dx, BuildContext context) {
    final width = MediaQuery.of(context).size.width - 24.w;
    final position = ((dx - 12.w) / width).clamp(0.0, 1.0);
    setState(() => _dragValue = position);
  }
}
