import 'dart:async';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/core/utils/router/route_observers.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/video/feed_video_preloader.dart';
import 'package:tayseer/core/video/video_state_manager.dart';
import 'package:tayseer/my_import.dart';

class RealVideoPlayer extends StatefulWidget {
  final String postId;
  final String videoUrl;
  final VideoModel? videoData;
  final VideoPlayerController? videoController;
  final Function(VideoPlayerController)? onControllerCreated;
  final Function(VideoPlayerController? controller)? onReelTap;

  const RealVideoPlayer({
    super.key,
    required this.postId,
    required this.videoUrl,
    this.videoData,
    this.videoController,
    this.onControllerCreated,
    this.onReelTap,
  });

  @override
  State<RealVideoPlayer> createState() => _RealVideoPlayerState();
}

class _RealVideoPlayerState extends State<RealVideoPlayer>
    with RouteAware, WidgetsBindingObserver {
  VideoPlayerController? _controller;
  final _videoCacheManager = VideoCacheManager();
  final _stateManager = VideoStateManager();
  final _muteManager = GlobalMuteManager.instance;

  bool _isInitialized = false;
  bool _hasError = false;
  bool _isBuffering = false;
  bool _isEnded = false;
  bool _isDisposed = false;
  bool _isInPlayZone = false;
  bool _isPageActive = true;

  // ✅ Incremented every time _controller is replaced.
  // Used as the key for _SafeVideoPlayer so Flutter remounts the VideoPlayer
  // widget (and its internal platform listener) instead of calling
  // didUpdateWidget with a stale/disposed controller reference — which is the
  // root cause of "Bad state: No active player with ID X".
  int _controllerVersion = 0;

  // ✅ NEW: حفظ حالة الـ play zone قبل الانتقال لصفحة تانية
  bool _wasInPlayZoneBeforeNav = false;

  // ✅ NEW: هل الفيديو كان شغال قبل ما التطبيق يروح للخلفية؟
  bool _wasPlayingBeforeBackground = false;

  // ✅ NEW: هل التطبيق في الخلفية حالياً؟ (لمنع الـ VideoManager من إيقاف الفيديو أثناء الـ resume)
  bool _isAppInBackground = false;

  // ✅ NEW: هل الـ controller جاي من الـ FeedVideoPreloader؟
  bool _isUsingPreloadedController = false;

  Completer<void>? _initCompleter;

  int _retryCount = 0;
  int _lastSavedSecond = -1;
  static const int _maxRetries = 5;

  Timer? _autoRetryTimer;
  Timer? _disposeDelayTimer;

  // ═══════════════════════════════════════════════════════════════════
  // Lifecycle
  // ═══════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    VideoManager.instance.currentlyPlayingPostId.addListener(
      _videoManagerListener,
    );
    VideoManager.instance.evictionGeneration.addListener(_onEviction);
    _muteManager.isMuted.addListener(_onGlobalMuteChanged);
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
    if (widget.videoController != oldWidget.videoController &&
        widget.videoController != null) {
      final newController = widget.videoController!;

      // ✅ Guard: skip if this is the same controller we already have
      if (_controller == newController) return;

      // ✅ Guard: verify the new controller is not disposed before using it
      bool isNewControllerValid = false;
      try {
        final testValue = newController.value;
        // A disposed controller throws in addListener, not in .value,
        // so we do a lightweight addListener/removeListener probe.
        void probe() {}
        newController.addListener(probe);
        newController.removeListener(probe);
        isNewControllerValid = testValue.isInitialized;
      } catch (e) {
        debugPrint(
          '⚠️ Received disposed controller in didUpdateWidget, ignoring: $e',
        );
        return;
      }

      if (!isNewControllerValid) {
        // Controller exists but isn't initialized yet — ignore for now;
        // the parent will push another update once it's ready.
        return;
      }

      // Tear down the old controller
      if (_controller != null) {
        _controller!.removeListener(_videoListener);
        if (oldWidget.videoController == null && !_isUsingPreloadedController) {
          try {
            _controller!.dispose();
          } catch (_) {}
        }
        _controller = null;
        _isInitialized = false;
        _isBuffering = false;
        _isUsingPreloadedController = false;
      }

      _controller = newController;
      _setupController();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isPageActive = false;
    _autoRetryTimer?.cancel();
    _disposeDelayTimer?.cancel();
    _savePosition();

    // ✅ iOS fix: إيقاف الصوت والفيديو قبل dispose
    final controller = _controller;
    if (controller != null && widget.videoController == null) {
      try {
        if (controller.value.isInitialized) {
          controller.setVolume(0.0);
          if (controller.value.isPlaying) {
            controller.pause();
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error stopping in dispose: $e');
      }
    }

    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      _initCompleter!.complete();
    }

    VideoManager.instance.currentlyPlayingPostId.removeListener(
      _videoManagerListener,
    );
    VideoManager.instance.evictionGeneration.removeListener(_onEviction);
    _muteManager.isMuted.removeListener(_onGlobalMuteChanged);
    videoRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    _disposeLocalController();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // Route Awareness — ✅ FIXED
  // ═══════════════════════════════════════════════════════════════════

  @override
  void didPushNext() {
    _isPageActive = false;
    _wasInPlayZoneBeforeNav = _isInPlayZone; // ✅ حفظ الحالة قبل الانتقال
    // ✅ إلغاء أي dispose timer شغال — منع dispose الـ controller أثناء الانتقال
    _disposeDelayTimer?.cancel();
    _disposeDelayTimer = null;
    _pauseAndSave();
    _controller?.removeListener(_videoListener);
    VideoManager.instance.currentlyPlayingPostId.removeListener(
      _videoManagerListener,
    );
    VideoManager.instance.evictionGeneration.removeListener(_onEviction);
  }

  // ✅ FIXED: addPostFrameCallback + استعادة play zone
  @override
  void didPopNext() {
    _isPageActive = true;

    if (_isDisposed || !mounted) return;

    // ✅ إلغاء أي dispose timer شغال — منع dispose الـ controller بعد الرجوع
    _disposeDelayTimer?.cancel();
    _disposeDelayTimer = null;

    // إعادة توصيل الـ listeners
    VideoManager.instance.currentlyPlayingPostId.addListener(
      _videoManagerListener,
    );
    VideoManager.instance.evictionGeneration.addListener(_onEviction);
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller!.addListener(_videoListener);
    }

    // ✅ FIXED: ننتظر الـ frame يخلص عشان الصفحة المتقفلة تعمل dispose الأول
    // نستخدم delay أطول شوية عشان الـ dispose timer (500ms) يخلص لو كان شغال
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted || _isDisposed || !_isPageActive) return;

      // ✅ FIXED: نستخدم الحالة المحفوظة قبل الانتقال
      final shouldResume = _wasInPlayZoneBeforeNav || _isInPlayZone;
      // ✅ استعادة _isInPlayZone عشان _canPlay يشتغل صح
      if (shouldResume) _isInPlayZone = true;

      final controller = _controller;

      if (controller != null &&
          _isInitialized &&
          !_hasError &&
          shouldResume &&
          !VideoManager.instance.isRefreshing) {
        VideoManager.instance.playVideo(widget.postId);

        _restorePosition().then((_) {
          if (mounted && !_isDisposed && _isPageActive) {
            try {
              controller.setVolume(_muteManager.isMuted.value ? 0.0 : 1.0);
              if (!controller.value.isPlaying) {
                controller.play();
              }
            } catch (e) {
              debugPrint('⚠️ Cannot resume on pop: $e');
            }
          }
        });
      } else if (shouldResume && _controller == null && !_hasError) {
        // ✅ الـ controller اتعمله dispose — ابدأ initialize من الأول
        // _isInPlayZone = true بالفعل فوق، فـ _canPlay هيشتغل صح
        _initializeVideo().then((_) {
          if (mounted && !_isDisposed && _isPageActive && _isInitialized) {
            final ctrl = _controller;
            if (ctrl != null && !ctrl.value.isPlaying) {
              try {
                VideoManager.instance.playVideo(widget.postId);
                ctrl.setVolume(_muteManager.isMuted.value ? 0.0 : 1.0);
                ctrl.play();
              } catch (e) {
                debugPrint('⚠️ Cannot play after re-init on pop: $e');
              }
            }
          }
        });
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // App Lifecycle — Pause on background, resume on foreground
  // ═══════════════════════════════════════════════════════════════════

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      // ✅ inactive = نزول الستارة / App Switcher على iOS
      // ✅ paused / hidden = التطبيق راح للخلفية فعلاً
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _isAppInBackground = true;
        final controller = _controller;
        if (controller != null &&
            controller.value.isInitialized &&
            controller.value.isPlaying) {
          // حفظ الحالة بس لو مش محفوظة بالفعل (inactive بييجي قبل paused)
          if (!_wasPlayingBeforeBackground) {
            _wasPlayingBeforeBackground = true;
            _savePosition();
          }
          controller.setVolume(0.0);
          controller.pause();
          debugPrint('⏸️ App inactive/backgrounded — paused ${widget.postId}');
        }
        break;

      case AppLifecycleState.resumed:
        if (_wasPlayingBeforeBackground && !_isDisposed && mounted) {
          _wasPlayingBeforeBackground = false;

          final controller = _controller;
          if (controller != null && controller.value.isInitialized) {
            controller.setVolume(_muteManager.isMuted.value ? 0.0 : 1.0);
            if (!controller.value.isPlaying) {
              controller.play();
              VideoManager.instance.playVideo(widget.postId);
              debugPrint('▶️ App resumed — resumed ${widget.postId}');
            }
          }

          // ✅ نرجع نفعّل الـ VisibilityDetector و VideoManager listener
          // بعد فترة كافية عشان الـ VisibilityDetector يبعت events صحيحة
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted && !_isDisposed) {
              _isAppInBackground = false;
            }
          });
        } else {
          _isAppInBackground = false;
          _wasPlayingBeforeBackground = false;
        }
        break;

      case AppLifecycleState.detached:
        _isAppInBackground = false;
        break;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Listeners
  // ═══════════════════════════════════════════════════════════════════

  /// Called when VideoManager.stopAll() is about to dispose all controllers.
  /// Immediately null our reference so no pending build frame passes a dead
  /// controller to _SafeVideoPlayer / VideoPlayer.
  void _onEviction() {
    if (_isDisposed || !mounted) return;

    // Only act if we own the controller (not a shared parent controller).
    // Preloaded and self-created controllers are all disposed by disposeAll().
    if (widget.videoController != null) return; // parent-owned, skip

    final hadController = _controller != null;
    if (hadController) {
      // Detach listener first to silence any in-flight callbacks.
      try {
        _controller!.removeListener(_videoListener);
      } catch (_) {}
      // ✅ Null the reference and bump version BEFORE the next frame renders.
      // This guarantees _SafeVideoPlayer sees _controller == null and returns
      // SizedBox.shrink() instead of building VideoPlayer with a dead ID.
      _controller = null;
      _controllerVersion++;
      _isInitialized = false;
      _isBuffering = false;
      _isUsingPreloadedController = false;
      _initCompleter = null;
      debugPrint('🧹 Eviction: cleared controller ref for ${widget.postId}');
      // Trigger a rebuild so the placeholder shows immediately.
      _scheduleSetState(() {});
    }
  }

  void _onGlobalMuteChanged() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isDisposed) {
      return;
    }
    try {
      // ✅ استخدام synchronous setVolume
      final volume = _muteManager.isMuted.value ? 0.0 : 1.0;
      controller.setVolume(volume);
      debugPrint('🔊 Volume changed to $volume for ${widget.postId}');
    } catch (e) {
      debugPrint('⚠️ Cannot change volume: $e');
    }
  }

  void _videoManagerListener() {
    final controller = _controller;
    if (_isDisposed || controller == null) return;

    // ✅ لو التطبيق بيرجع من الخلفية، تجاهل أي pause من الـ VideoManager
    if (_isAppInBackground) return;

    // ✅ لو الـ VideoManager بيعمل refresh/stopAll، تجاهل — الـ controllers
    // هتتعمل dispose من disposeAll() مباشرة، مش من هنا
    if (VideoManager.instance.isRefreshing) return;

    if (VideoManager.instance.currentlyPlayingPostId.value != widget.postId) {
      try {
        // ✅ تحقق إن الـ controller لسه valid قبل أي عملية
        if (!controller.value.isInitialized) return;
        if (controller.value.isPlaying) {
          _savePosition();
          controller.setVolume(0.0);
          controller.pause();
          debugPrint('⏸️ Paused by VideoManager: ${widget.postId}');
          _scheduleSetState(() {});
        }
      } catch (e) {
        debugPrint('⚠️ Cannot pause in listener, controller disposed');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════════════

  void _pauseAndSave() {
    final controller = _controller;
    if (controller == null) return;
    try {
      // ✅ تحقق إن الـ controller لسه valid قبل أي عملية
      if (!controller.value.isInitialized) return;
      if (controller.value.isPlaying) {
        _savePosition();
        // ✅ إيقاف الصوت والفيديو (synchronous)
        controller.setVolume(0.0);
        controller.pause();
        debugPrint('⏸️ Paused and muted ${widget.postId}');
      }
    } catch (e) {
      debugPrint('⚠️ Cannot pause, controller disposed');
    }
  }

  void _scheduleSetState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) setState(fn);
    });
  }

  bool get _canPlay =>
      _isPageActive && _isInPlayZone && !_isDisposed && mounted && !_hasError;

  // ═══════════════════════════════════════════════════════════════════
  // Position Management
  // ═══════════════════════════════════════════════════════════════════

  void _savePosition() {
    final controller = _controller;
    if (controller == null || widget.videoController != null) return;
    try {
      if (controller.value.isInitialized) {
        final position = controller.value.position;
        if (position.inSeconds > 0) {
          _stateManager.savePosition(widget.postId, position);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Cannot save position, controller disposed');
    }
  }

  Future<void> _restorePosition() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final lastPosition = _stateManager.getLastPosition(widget.postId);
    if (lastPosition != null && lastPosition.inSeconds > 0) {
      final duration = controller.value.duration;
      if (lastPosition < duration - const Duration(seconds: 2)) {
        await controller.seekTo(lastPosition);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Controller Lifecycle — ✅ FIXED
  // ═══════════════════════════════════════════════════════════════════

  // ✅ FIXED: Controller Lifecycle
  void _disposeLocalController() {
    final controller = _controller;
    _controller = null;
    _controllerVersion++; // ← forces _SafeVideoPlayer to remount on next build
    _isInitialized = false;
    _isBuffering = false;

    if (controller == null) return;

    controller.removeListener(_videoListener);

    // shared من parent → مش بنعمله dispose
    if (widget.videoController != null) return;

    // preloaded من FeedVideoPreloader → مش بنعمله dispose هنا
    // الـ FeedVideoPreloader هو المسؤول عن lifecycle الـ controller ده
    if (_isUsingPreloadedController) {
      _isUsingPreloadedController = false;
      debugPrint('♻️ Releasing preloaded controller ref: ${widget.postId}');
      return;
    }

    try {
      if (controller.value.isInitialized) {
        controller.setVolume(0.0);
        if (controller.value.isPlaying) {
          controller.pause();
        }
      }
      controller.dispose();
      debugPrint('🗑️ Disposed local controller for ${widget.postId}');
    } catch (e) {
      debugPrint('⚠️ Error disposing controller: $e');
    }
  }

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;

    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      return _initCompleter!.future;
    }

    if (_controller != null && _isInitialized) return;

    // ✅ إعادة تعيين الـ completer دايماً
    _initCompleter = Completer<void>();
    final completer = _initCompleter!;

    void safeComplete() {
      if (!completer.isCompleted) completer.complete();
    }

    try {
      if (widget.videoController != null) {
        _controller = widget.videoController;
        _setupController();
        safeComplete();
        return;
      }

      if (widget.videoUrl.isEmpty) {
        safeComplete();
        return;
      }

      // ✅ FAST PATH: استخدم الـ pre-initialized controller من الـ FeedVideoPreloader
      final preloadedController = FeedVideoPreloader.instance
          .getReadyController(widget.postId);
      if (preloadedController != null) {
        debugPrint('⚡ Using preloaded controller for ${widget.postId}');
        _controller = preloadedController;
        _isUsingPreloadedController = true;
        await _controller!.setVolume(_muteManager.isMuted.value ? 0.0 : 1.0);
        _setupController();
        widget.onControllerCreated?.call(_controller!);
        await _restorePosition();
        _stateManager.markAsLoaded(widget.postId);
        _retryCount = 0;
        _autoRetryTimer?.cancel();
        if (_canPlay) {
          VideoManager.instance.playVideo(widget.postId);
          _controller!.play();
        }
        safeComplete();
        return;
      }

      // ✅ SLOW PATH: تحميل عادي من الكاش أو الشبكة
      final cachedFile = await _videoCacheManager.getCachedFile(
        widget.videoUrl,
      );
      if (!mounted || _isDisposed) {
        safeComplete();
        return;
      }

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
            );

      if (cachedFile == null) {
        _videoCacheManager.preloadVideoInBackground(widget.videoUrl);
      }

      await _controller!.initialize();
      if (!mounted || _isDisposed) {
        try {
          _controller?.dispose();
        } catch (_) {}
        _controller = null;
        safeComplete();
        return;
      }

      await _controller!.setLooping(true);
      await _controller!.setVolume(_muteManager.isMuted.value ? 0.0 : 1.0);

      _setupController();
      widget.onControllerCreated?.call(_controller!);
      await _restorePosition();

      _stateManager.markAsLoaded(widget.postId);
      _retryCount = 0;
      _autoRetryTimer?.cancel();

      if (_canPlay) {
        VideoManager.instance.playVideo(widget.postId);
        _controller!.play();
      }

      safeComplete();
    } catch (e) {
      debugPrint("❌ Error initializing video: $e");
      if (!mounted || _isDisposed) {
        safeComplete();
        return;
      }

      try {
        _controller?.dispose();
      } catch (_) {}
      _controller = null;
      _isInitialized = false;

      if (_retryCount < _maxRetries && _stateManager.canRetry(widget.postId)) {
        _retryCount++;
        _stateManager.recordError(widget.postId);
        safeComplete();

        final delay = Duration(milliseconds: 800 * _retryCount);
        _autoRetryTimer?.cancel();
        _autoRetryTimer = Timer(delay, () {
          if (mounted && !_isDisposed && _isPageActive) {
            _initializeVideo();
          }
        });
      } else {
        _scheduleSetState(() => _hasError = true);
        safeComplete();
      }
    }
  }

  void _setupController() {
    final controller = _controller;
    if (controller == null) return;

    try {
      // ✅ اختبار إن الـ controller مش disposed قبل أي عملية
      final value = controller.value;
      _isInitialized = value.isInitialized;
      _isBuffering = value.isBuffering;
      controller.removeListener(_videoListener); // منع double-attach
      controller.addListener(_videoListener);

      // ✅ Bump version so _SafeVideoPlayer remounts with the new controller
      // instead of Flutter calling didUpdateWidget on the existing VideoPlayer
      // state with a different controller — which is what causes the crash.
      _controllerVersion++;

      // ✅ تعيين volume بشكل synchronous
      final volume = _muteManager.isMuted.value ? 0.0 : 1.0;
      controller.setVolume(volume);
      debugPrint('🔊 Initial volume set to $volume for ${widget.postId}');

      if (mounted && !_isDisposed) setState(() {});
    } catch (e) {
      debugPrint('⚠️ Controller disposed during setup: $e');
      // ✅ لو الـ controller جاي من parent، مش بنعمله dispose — بس بنشيله
      _controller = null;
      _controllerVersion++;
      _isInitialized = false;
      _isBuffering = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Video Listener
  // ═══════════════════════════════════════════════════════════════════

  void _videoListener() {
    final controller = _controller;
    if (!mounted || controller == null || _isDisposed) return;

    try {
      final value = controller.value;

      if (value.hasError && !_hasError) {
        debugPrint('⚠️ Video error during playback: ${value.errorDescription}');
        _handleSilentRetry();
        return;
      }

      if (value.isBuffering != _isBuffering) {
        _scheduleSetState(() => _isBuffering = value.isBuffering);
      }

      final isAtEnd =
          value.isInitialized &&
          !value.isPlaying &&
          value.duration > Duration.zero &&
          value.position >= value.duration;

      if (isAtEnd != _isEnded) {
        _scheduleSetState(() => _isEnded = isAtEnd);
      }

      final currentSecond = value.position.inSeconds;
      if (_isInitialized &&
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

  void _handleSilentRetry() {
    if (_isDisposed || !mounted) return;

    if (_retryCount < _maxRetries) {
      _retryCount++;
      debugPrint('🔄 Silent auto-retry #$_retryCount for ${widget.postId}');

      try {
        _controller?.removeListener(_videoListener);
        if (widget.videoController == null) {
          _controller?.dispose();
        }
      } catch (_) {}
      _controller = null;
      _isInitialized = false;
      _initCompleter = null;

      final delay = Duration(milliseconds: 800 * _retryCount);
      _autoRetryTimer?.cancel();
      _autoRetryTimer = Timer(delay, () {
        if (mounted && !_isDisposed && _isPageActive) {
          _initializeVideo();
        }
      });
    } else {
      _scheduleSetState(() => _hasError = true);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Visibility & Interaction
  // ═══════════════════════════════════════════════════════════════════

  void _handleVisibility(VisibilityInfo info) {
    if (!mounted || _isDisposed) return;

    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;

    // ✅ تجاهل أي visibility events لما التطبيق في الخلفية أو بيرجع منها
    // الـ VisibilityDetector بيبعت visibleFraction = 0 خطأ في اللحظة دي
    if (_isAppInBackground) return;

    // ✅ تجاهل أي visibility events أثناء الـ refresh — الـ controllers بتتعمل
    // dispose من disposeAll() مباشرة، ومحاولة pause هنا بتسبب crash
    if (VideoManager.instance.isRefreshing) return;

    final visibleFraction = info.visibleFraction;

    if (visibleFraction > 0.7) {
      _disposeDelayTimer?.cancel();
      _disposeDelayTimer = null;

      if (!_isInPlayZone) {
        _isInPlayZone = true;

        // ✅ لا تشغل أثناء الـ refresh
        if (!_isPageActive || VideoManager.instance.isRefreshing) return;

        if (_controller == null && !_hasError) {
          _initializeVideo().then((_) {
            if (!_canPlay || _isDisposed || VideoManager.instance.isRefreshing)
              return;
            final ctrl = _controller;
            if (ctrl == null || !_isInitialized) return;
            try {
              if (!ctrl.value.isInitialized) return;
              VideoManager.instance.playVideo(widget.postId);
              if (!ctrl.value.isPlaying) ctrl.play();
            } catch (e) {
              debugPrint('⚠️ Cannot play after init, controller disposed');
            }
          });
        } else {
          final ctrl = _controller;
          if (ctrl != null && _isInitialized && !_isEnded && !_hasError) {
            try {
              if (!ctrl.value.isInitialized) return;
              if (_isPageActive && !VideoManager.instance.isRefreshing) {
                VideoManager.instance.playVideo(widget.postId);
                if (!ctrl.value.isPlaying) ctrl.play();
              }
            } catch (e) {
              debugPrint('⚠️ Cannot play, controller disposed');
            }
          }
        }
      }
    } else if (visibleFraction > 0.0) {
      _isInPlayZone = false;
      _disposeDelayTimer?.cancel();
      _disposeDelayTimer = null;
      _pauseAndSave();
    } else {
      // ✅ الفيديو خرج من الشاشة تماماً
      _isInPlayZone = false;
      _pauseAndSave();

      // ✅ تدمير فوري للـ controller عشان نمنع تراكم الأصوات
      // لكن بس لو الصفحة active — مش لما نكون في صفحة تانية
      _disposeDelayTimer?.cancel();
      _disposeDelayTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted && !_isDisposed && _controller != null && _isPageActive) {
          debugPrint('♻️ Immediate dispose for ${widget.postId}');
          _savePosition();
          _disposeLocalController();
          _initCompleter = null;
          if (mounted && !_isDisposed) setState(() {});
        }
      });
    }
  }

  void _retryInitialization() {
    if (_isDisposed) return;

    _stateManager.resetErrorCount(widget.postId);
    _videoCacheManager.resetFailedStatus(widget.videoUrl);
    _retryCount = 0;
    _lastSavedSecond = -1;
    _isEnded = false;
    _initCompleter = null;

    setState(() {
      _hasError = false;
      _isInitialized = false;
    });
    _disposeLocalController();
    _initializeVideo();
  }

  void _handleTap() {
    if (_isInitialized && _controller != null) {
      try {
        if (_controller!.value.isPlaying) {
          _savePosition();
          // ✅ iOS fix: إيقاف الصوت قبل pause
          _controller!.setVolume(0.0);
          _controller!.pause();
        }
      } catch (_) {}
    }

    widget.onReelTap?.call(
      (_isInitialized && _controller != null) ? _controller : null,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Build
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final videoData = widget.videoData;
    final double aspectRatio;
    if (videoData != null && videoData.width > 0 && videoData.height > 0) {
      aspectRatio = videoData.aspectRatio.clamp(0.5, 2.5);
    } else {
      aspectRatio = 4 / 5;
    }

    final thumbnail = videoData?.thumbnail;
    final maxAllowedHeight = context.responsiveHeight(720);

    final isLoading = !_isInitialized && !_hasError && _controller != null;

    return VisibilityDetector(
      key: Key('${widget.postId}_${widget.videoUrl}'),
      onVisibilityChanged: _handleVisibility,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: maxAllowedHeight),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: DecoratedBox(
            decoration: const BoxDecoration(color: Colors.black),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0.r),
              child: GestureDetector(
                onTap: _handleTap,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ✅ FIXED: Thumbnail يختفي لما الفيديو يكون initialized
                    if (!_isInitialized &&
                        thumbnail != null &&
                        thumbnail.isNotEmpty)
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: thumbnail,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const ColoredBox(color: Colors.black),
                          errorWidget: (context, url, error) =>
                              const ColoredBox(color: Colors.black),
                        ),
                      ),

                    // Video Player
                    if (_isInitialized && _controller != null)
                      Positioned.fill(
                        child: _SafeVideoPlayer(
                          // ✅ ValueKey forces a full remount whenever the
                          // controller is replaced (version incremented in
                          // _setupController / _disposeLocalController).
                          // This prevents Flutter from calling didUpdateWidget
                          // on the existing VideoPlayer state with a stale
                          // platform-disposed controller — the root cause of
                          // "Bad state: No active player with ID X".
                          key: ValueKey(
                            '${widget.postId}_v$_controllerVersion',
                          ),
                          controller: _controller!,
                        ),
                      ),

                    // Error State
                    if (_hasError) _buildErrorState(),

                    // Buffering أثناء التشغيل
                    if (_isInitialized && _isBuffering)
                      _buildBufferingIndicator(),

                    // Loading أثناء التحميل الأولي
                    if (isLoading) _buildBufferingIndicator(),

                    // Mute Button
                    Positioned(
                      bottom: 12.h,
                      right: 12.w,
                      child: _MuteButton(
                        onTap: () => _muteManager.toggleMute(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.r),
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

class _SafeVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const _SafeVideoPlayer({super.key, required this.controller});

  @override
  State<_SafeVideoPlayer> createState() => _SafeVideoPlayerState();
}

class _SafeVideoPlayerState extends State<_SafeVideoPlayer> {
  bool _isAlive = false;

  /// Returns true if [ctrl] is still usable (not disposed, still initialized).
  static bool _probe(VideoPlayerController ctrl) {
    try {
      void noop() {}
      ctrl.addListener(noop);
      ctrl.removeListener(noop);
      return ctrl.value.isInitialized;
    } catch (_) {
      return false;
    }
  }

  void _onControllerUpdate() {
    // Called by the VideoPlayerController's ChangeNotifier.
    // If the controller is unexpectedly torn down, the next value access may
    // throw — so we re-probe and hide the widget before that happens.
    if (!mounted) return;
    final alive = _probe(widget.controller);
    if (alive != _isAlive) {
      setState(() => _isAlive = alive);
    }
  }

  @override
  void initState() {
    super.initState();
    _isAlive = _probe(widget.controller);
    if (_isAlive) {
      widget.controller.addListener(_onControllerUpdate);
    }
  }

  @override
  void didUpdateWidget(_SafeVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The parent sets a ValueKey tied to _controllerVersion so this widget is
    // always remounted (not updated) when the controller changes. But guard
    // defensively anyway.
    if (oldWidget.controller != widget.controller) {
      try {
        oldWidget.controller.removeListener(_onControllerUpdate);
      } catch (_) {}
      _isAlive = _probe(widget.controller);
      if (_isAlive) {
        widget.controller.addListener(_onControllerUpdate);
      }
    }
  }

  @override
  void dispose() {
    try {
      widget.controller.removeListener(_onControllerUpdate);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAlive) return const SizedBox.shrink();

    // Extra safety: re-probe in build in case the controller was disposed
    // between the listener firing and this frame being rendered.
    if (!_probe(widget.controller)) return const SizedBox.shrink();

    final size = widget.controller.value.size;
    if (size.width == 0 || size.height == 0) return const SizedBox.shrink();

    try {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.width,
          height: size.height,
          // ✅ ValueKey on the controller ensures Flutter creates a brand-new
          // VideoPlayer element when the controller instance changes, rather
          // than reusing the existing platform texture registration.
          child: VideoPlayer(widget.controller),
        ),
      );
    } catch (e) {
      // Catches "Bad state: No active player with ID X" if the platform
      // texture was destroyed between the probe and the VideoPlayer build.
      debugPrint('⚠️ _SafeVideoPlayer caught crash, hiding: $e');
      // Schedule a state update so the widget rebuilds as SizedBox next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isAlive = false);
      });
      return const SizedBox.shrink();
    }
  }
}

class _MuteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MuteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: GlobalMuteManager.instance.isMuted,
      builder: (context, isMuted, _) {
        return GestureDetector(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(8.r),
              child: Icon(
                isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),
        );
      },
    );
  }
}
