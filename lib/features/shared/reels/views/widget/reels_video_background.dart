import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/video/reels_video_preloader.dart';
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
  // ignore: unused_field
  bool _showSpeedIndicator = false;

  // ✅ هل الـ controller جاي من الـ parent's sharedController (مش بنعمله dispose)
  // الـ preloaded controllers بنعمل transfer of ownership — بنعمله dispose هنا
  bool _isExternalController = false;

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
    // ✅ استمع لـ VideoManager عشان لو فيديو تاني اشتغل نوقف الريل ده
    VideoManager.instance.currentlyPlayingPostId.addListener(
      _onVideoManagerChanged,
    );
    if (widget.shouldInitialize) {
      _initializeVideo();
    }
  }

  /// ✅ لو VideoManager شغّل فيديو تاني — وقّف الريل ده فوراً
  void _onVideoManagerChanged() {
    if (_isDisposed || _controller == null) return;
    final playingId = VideoManager.instance.currentlyPlayingPostId.value;
    if (playingId != null && playingId != _videoId) {
      try {
        if (_controller!.value.isPlaying) {
          _controller!.setVolume(0.0);
          _controller!.pause();
          debugPrint('⏸️ Reel paused by VideoManager: $_videoId');
        }
      } catch (e) {
        debugPrint('⚠️ Cannot pause reel in VideoManager listener: $e');
      }
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

    final completer = Completer<void>();
    _initCompleter = completer;

    void safeComplete() {
      if (!completer.isCompleted) completer.complete();
    }

    // ─── FAST PATH 1: sharedController من الـ parent (home feed controller) ───
    if (widget.sharedController != null) {
      bool isValid = false;
      try {
        void probe() {}
        widget.sharedController!.addListener(probe);
        widget.sharedController!.removeListener(probe);
        isValid = widget.sharedController!.value.isInitialized;
      } catch (_) {
        isValid = false;
      }

      if (!isValid) {
        // الـ controller مش valid — روح للـ slow path
        safeComplete();
        _initCompleter = null;
        // لا نعمل recursive call — نبدأ slow path مباشرة
        _startSlowPath();
        return;
      }

      _controller = widget.sharedController;
      _isExternalController = true;
      try {
        await _controller!.setVolume(_volume);
        if (!mounted || _controller == null || _isDisposed) {
          safeComplete();
          return;
        }
        _isInitialized = true;
        _hasError = false;
        await _controller!.setLooping(true);
        await _restorePosition();
        if (widget.shouldPlay) {
          VideoManager.instance.playVideo(_videoId);
          _controller!.play();
        }
        _attachListener();
        widget.onControllerCreated?.call(_controller!);
        if (mounted && !_isDisposed) setState(() {});
      } catch (e) {
        debugPrint('⚠️ Error setting up shared controller: $e');
        _controller = null;
        _isExternalController = false;
      }
      safeComplete();
      return;
    }

    // ─── FAST PATH 2: preloaded controller من الـ ReelsVideoPreloader ───
    if (_videoId.isNotEmpty) {
      final preloaded = ReelsVideoPreloader.instance.claimController(_videoId);
      if (preloaded != null) {
        debugPrint('⚡ Reel claimed preloaded controller: $_videoId');
        _controller = preloaded;
        _isExternalController = false;
        bool fastPathOk = false;
        try {
          await _controller!.setVolume(_volume);
          if (!mounted || _isDisposed) {
            try {
              _controller!.dispose();
            } catch (_) {}
            _controller = null;
            safeComplete();
            return;
          }
          await _controller!.setLooping(true);
          await _restorePosition();
          _attachListener();
          widget.onControllerCreated?.call(_controller!);
          setState(() {
            _isInitialized = true;
            _hasError = false;
          });
          if (widget.shouldPlay) {
            VideoManager.instance.playVideo(_videoId);
            _controller!.play();
          }
          fastPathOk = true;
        } catch (e) {
          debugPrint('⚠️ Error setting up preloaded reel controller: $e');
          try {
            _controller?.dispose();
          } catch (_) {}
          _controller = null;
          _isExternalController = false;
        }
        safeComplete();
        // لو فشل الـ fast path، ابدأ slow path في الـ frame الجاي
        if (!fastPathOk && mounted && !_isDisposed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isDisposed && !_isInitialized) {
              _initCompleter = null;
              _startSlowPath();
            }
          });
        }
        return;
      }
    }

    // ─── SLOW PATH ───
    safeComplete();
    _initCompleter = null;
    _startSlowPath();
  }

  /// ✅ Slow path منفصل — بيتعمل call مباشرة بدون Completer موروث
  Future<void> _startSlowPath() async {
    if (_isDisposed || (_controller != null && _isInitialized)) return;

    final completer = Completer<void>();
    _initCompleter = completer;

    void safeComplete() {
      if (!completer.isCompleted) completer.complete();
    }

    try {
      if (widget.videoUrl.isEmpty) {
        safeComplete();
        return;
      }

      final cachedFile = await _videoCacheManager.getCachedFile(
        widget.videoUrl,
      );
      if (!mounted || _isDisposed) {
        safeComplete();
        return;
      }

      if (cachedFile != null) {
        _controller = VideoPlayerController.file(
          cachedFile,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: false,
            allowBackgroundPlayback: false,
          ),
        );
      } else {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: false,
            allowBackgroundPlayback: false,
          ),
        );
        _videoCacheManager.preloadVideoInBackground(widget.videoUrl);
      }
      _isExternalController = false;

      await _controller!.initialize();

      if (!mounted || _isDisposed) {
        try {
          _controller?.dispose();
        } catch (_) {}
        _controller = null;
        safeComplete();
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

      if (widget.shouldPlay) {
        VideoManager.instance.playVideo(_videoId);
        _controller!.play();
      }

      safeComplete();
    } catch (e) {
      debugPrint('❌ Error initializing video: $e');
      if (!mounted || _isDisposed) {
        safeComplete();
        return;
      }

      try {
        _detachListener();
        if (!_isExternalController) _controller?.dispose();
      } catch (_) {}
      _controller = null;
      _isInitialized = false;
      _isExternalController = false;

      if (_retryCount < _maxRetries && _stateManager.canRetry(_videoId)) {
        _retryCount++;
        _stateManager.recordError(_videoId);
        safeComplete();
        _initCompleter = null;

        final delay = Duration(milliseconds: 800 * _retryCount);
        _autoRetryTimer?.cancel();
        _autoRetryTimer = Timer(delay, () {
          if (mounted && !_isDisposed) {
            _startSlowPath();
          }
        });
      } else {
        _scheduleSetState(() {
          _hasError = true;
          _isInitialized = false;
        });
        safeComplete();
      }
    }
  }

  Future<void> _restorePosition() async {
    return;
  }

  void _savePosition() {
    if (_controller == null) return;

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

  // ✅ CHANGED: حفظ كل 5 ثواني بدل كل ثانية
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

      // ✅ CHANGED: كل 5 ثواني بدل كل ثانية
      final currentSecond = value.position.inSeconds;
      if (_isInitialized &&
          !_isDragging &&
          currentSecond > 0 &&
          currentSecond % 5 == 0 && // ✅ أضفنا % 5
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
        if (!_isExternalController) {
          _controller?.dispose();
        }
      } catch (_) {}
      _controller = null;
      _isInitialized = false;
      _isExternalController = false;
      _initCompleter = null;

      final delay = Duration(milliseconds: 800 * _retryCount);
      _autoRetryTimer?.cancel();
      _autoRetryTimer = Timer(delay, () {
        if (mounted && !_isDisposed) {
          _startSlowPath();
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

    // ✅ لو الـ sharedController اتغير — استخدمه لو مش initialized
    if (widget.sharedController != oldWidget.sharedController &&
        widget.sharedController != null &&
        !_isInitialized) {
      // تخلص من أي controller قديم بنيناه بنفسنا
      if (_controller != null && !_isExternalController) {
        try {
          _detachListener();
          _controller!.setVolume(0.0);
          _controller!.pause();
          _controller!.dispose();
        } catch (_) {}
        _controller = null;
        _isInitialized = false;
        _initCompleter = null;
      }
      _initializeVideo();
      return;
    }

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
      // تحقق إن الـ controller لسه valid
      if (!_isControllerValid()) {
        _controller = null;
        _isInitialized = false;
        _isExternalController = false;
        _initCompleter = null;
        if (widget.shouldInitialize) {
          setState(() {});
          _initializeVideo();
        }
        return;
      }

      try {
        if (widget.shouldPlay && !oldWidget.shouldPlay) {
          _attachListener();
          VideoManager.instance.playVideo(_videoId);
          _controller!.setVolume(_volume);
          _controller!.play();
        } else if (!widget.shouldPlay && oldWidget.shouldPlay) {
          _savePosition();
          _controller!.setVolume(0.0);
          _controller!.pause();
          _detachListener();
        }
      } catch (e) {
        debugPrint('⚠️ Controller disposed in didUpdateWidget: $e');
        _controller = null;
        _isInitialized = false;
        _isExternalController = false;
        _initCompleter = null;
        if (widget.shouldInitialize) _initializeVideo();
      }
    }
  }

  /// ✅ تحقق إن الـ controller لسه valid وغير disposed
  bool _isControllerValid() {
    final ctrl = _controller;
    if (ctrl == null) return false;
    try {
      void probe() {}
      ctrl.addListener(probe);
      ctrl.removeListener(probe);
      return ctrl.value.isInitialized;
    } catch (_) {
      return false;
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
      _controller!.setVolume(0.0);
      _controller!.pause();
    } catch (_) {}
    _detachListener();
    // ✅ لو الـ controller جاي من الـ parent (sharedController)، مش بنعمله dispose
    // لو جاي من الـ preloader (claimed) أو بنيناه بنفسنا، نعمله dispose
    if (!_isExternalController) {
      try {
        _controller!.dispose();
      } catch (_) {}
    }
    _controller = null;
    _isInitialized = false;
    _isExternalController = false;
    _initCompleter = null;
    if (mounted && !_isDisposed) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_controller?.value.isPlaying == true) {
        _controller?.setVolume(0.0);
        _controller?.pause();
        _savePosition();
      }
    } else if (state == AppLifecycleState.resumed) {
      _videoCacheManager.resetAllFailedStatuses();
      if (widget.shouldPlay && _controller?.value.isInitialized == true) {
        _controller?.setVolume(_volume);
        _controller?.play();
      }
    }
  }

  @override
  void didPushNext() {
    // ✅ وقّف الريل وامسح تسجيله من VideoManager لما نروح لصفحة تانية
    if (_controller?.value.isPlaying == true) {
      _controller?.setVolume(0.0);
      _controller?.pause();
      _savePosition();
    }
    // لو الريل ده كان مسجّل في VideoManager، امسحه
    if (VideoManager.instance.currentlyPlayingPostId.value == _videoId) {
      VideoManager.instance.currentlyPlayingPostId.value = null;
    }
  }

  @override
  void didPopNext() {
    if (widget.shouldPlay && _controller?.value.isInitialized == true) {
      VideoManager.instance.playVideo(_videoId);
      _controller?.setVolume(_volume);
      _controller?.play();
    }
  }

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

    // ✅ وقّف الصوت فوراً قبل أي حاجة تانية
    try {
      _controller?.setVolume(0.0);
      if (_controller?.value.isPlaying == true) {
        _controller?.pause();
      }
    } catch (_) {}

    // ✅ لو الريل ده كان مسجّل في VideoManager، امسحه
    if (VideoManager.instance.currentlyPlayingPostId.value == _videoId) {
      VideoManager.instance.currentlyPlayingPostId.value = null;
    }

    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      _initCompleter!.complete();
    }

    _muteManager.isMuted.removeListener(_onGlobalMuteChanged);
    VideoManager.instance.currentlyPlayingPostId.removeListener(
      _onVideoManagerChanged,
    );
    videoRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);

    final controller = _controller;
    if (controller != null) {
      _detachListener();
      // ✅ لو الـ controller جاي من الـ parent (sharedController)، مش بنعمله dispose
      // لو جاي من الـ preloader (claimed) أو بنيناه بنفسنا، نعمله dispose
      if (!_isExternalController) {
        try {
          controller.dispose();
        } catch (_) {}
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

    if (!_isExternalController && _controller != null) {
      _detachListener();
      try {
        _controller!.dispose();
      } catch (_) {}
    }
    _controller = null;
    _isExternalController = false;
    _startSlowPath();
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
    final ctrl = _controller;
    if (ctrl == null) return const SizedBox.shrink();

    // ✅ Guard: تحقق إن الـ controller لسه valid قبل ما نبني VideoPlayer
    bool isAlive = false;
    try {
      void probe() {}
      ctrl.addListener(probe);
      ctrl.removeListener(probe);
      isAlive = ctrl.value.isInitialized;
    } catch (_) {
      isAlive = false;
    }

    if (!isAlive) {
      // الـ controller اتعمله dispose من الخارج — reset في الـ frame الجاي
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed && _controller != null) {
          _detachListener();
          _controller = null;
          _isInitialized = false;
          _isExternalController = false;
          _initCompleter = null;
          if (widget.shouldInitialize) {
            setState(() {});
            _initializeVideo();
          }
        }
      });
      return const SizedBox.shrink();
    }

    final videoSize = ctrl.value.size;
    if (videoSize.width == 0 || videoSize.height == 0) {
      return const SizedBox.shrink();
    }

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: videoSize.width,
        height: videoSize.height,
        child: VideoPlayer(ctrl),
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

  /// Returns true if the controller is still alive and initialized.
  bool _isControllerValid() {
    try {
      void probe() {}
      widget.controller.addListener(probe);
      widget.controller.removeListener(probe);
      return widget.controller.value.isInitialized;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    // Guard: only attach if the controller is still alive
    if (_isControllerValid()) {
      widget.controller.addListener(_onVideoProgress);
    }
  }

  @override
  void dispose() {
    // Guard: removeListener can throw on a disposed controller
    try {
      widget.controller.removeListener(_onVideoProgress);
    } catch (_) {}
    super.dispose();
  }

  void _onVideoProgress() {
    if (!mounted || _isDragging) return;

    // Guard: the controller may have been disposed between frames
    VideoPlayerValue value;
    try {
      value = widget.controller.value;
    } catch (_) {
      return;
    }
    if (value.duration.inMilliseconds == 0) return;

    final newProgress =
        value.position.inMilliseconds / value.duration.inMilliseconds;

    if ((newProgress - _progress).abs() > 0.005) {
      setState(() {
        _progress = newProgress;
        _duration = value.duration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Guard: do not render if the controller has been disposed
    if (!_isControllerValid()) return const SizedBox.shrink();

    Duration duration;
    try {
      duration = _isDragging ? _duration : widget.controller.value.duration;
    } catch (_) {
      return const SizedBox.shrink();
    }
    if (duration.inMilliseconds == 0) return const SizedBox.shrink();
    final progress = _isDragging ? _dragValue! : _progress;

    return SafeArea(
      top: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (details) {
          _isDragging = true;
          // Guard: controller may have been disposed between frames
          try {
            _duration = widget.controller.value.duration;
          } catch (_) {
            _isDragging = false;
            return;
          }
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
