import 'dart:async';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/core/utils/router/route_observers.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/video/video_state_manager.dart';
import 'package:tayseer/my_import.dart';

class RealVideoPlayer extends StatefulWidget {
  final String postId;
  final String videoUrl;
  final VideoModel? videoData;
  final VideoPlayerController? videoController;
  final Function(VideoPlayerController)? onControllerCreated;
  final Function(VideoPlayerController controller)? onReelTap;

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

class _RealVideoPlayerState extends State<RealVideoPlayer> with RouteAware {
  VideoPlayerController? _controller;
  final _videoCacheManager = VideoCacheManager();
  final _stateManager = VideoStateManager();
  final _muteManager = GlobalMuteManager.instance;

  bool _isInitialized = false;
  bool _hasError = false;
  bool _isBuffering = false;
  bool _isEnded = false;
  bool _isDisposed = false;

  // ✅ الإضافة الجديدة: منع الـ ping-pong بين فيديوهات بنفس اللينك
  bool _isInPlayZone = false;

  // Completer لمنع التهيئة المتكررة
  Completer<void>? _initCompleter;

  int _retryCount = 0;
  int _lastSavedSecond = -1;
  static const int _maxRetries = 5;

  // Auto-retry timer للفشل الصامت
  Timer? _autoRetryTimer;

  // Delayed disposal timer — ينتظر 2 ثانية قبل dispose عند الخروج من الشاشة
  Timer? _disposeDelayTimer;

  @override
  void initState() {
    super.initState();
    VideoManager.instance.currentlyPlayingPostId.addListener(
      _videoManagerListener,
    );
    _muteManager.isMuted.addListener(_onGlobalMuteChanged);
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

  void _videoManagerListener() {
    final controller = _controller;
    if (_isDisposed || controller == null) return;

    if (VideoManager.instance.currentlyPlayingPostId.value != widget.postId) {
      try {
        if (controller.value.isPlaying) {
          _savePosition();
          controller.pause();
          _scheduleSetState(() {});
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
    if (widget.videoController != oldWidget.videoController &&
        widget.videoController != null) {
      try {
        // Access .value to verify the controller isn't disposed
        final _ = widget.videoController!.value;
        _disposeLocalController();
        _controller = widget.videoController;
        _setupController();
      } catch (e) {
        debugPrint('⚠️ Received disposed controller, ignoring');
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoRetryTimer?.cancel();
    _disposeDelayTimer?.cancel();
    _savePosition();
    VideoManager.instance.currentlyPlayingPostId.removeListener(
      _videoManagerListener,
    );
    _muteManager.isMuted.removeListener(_onGlobalMuteChanged);
    videoRouteObserver.unsubscribe(this);
    _disposeLocalController();
    super.dispose();
  }

  @override
  void didPushNext() => _pauseAndSave();

  @override
  void didPopNext() {
    // ✅ عند pop — رجّع الفيديو بشكل هادي بدل ما كل الـ VisibilityDetector
    // يشتغلوا مرة واحدة ويسببوا jank
    if (_isDisposed || !mounted) return;
    final controller = _controller;
    if (controller != null &&
        _isInitialized &&
        !_hasError &&
        VideoManager.instance.currentlyPlayingPostId.value == widget.postId) {
      try {
        if (!controller.value.isPlaying) {
          controller.play();
        }
      } catch (e) {
        debugPrint('⚠️ Cannot resume on pop: $e');
      }
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

  void _pauseAndSave() {
    final controller = _controller;
    if (controller == null) return;
    try {
      if (controller.value.isPlaying) {
        _savePosition();
        controller.pause();
      }
    } catch (e) {
      debugPrint('⚠️ Cannot pause, controller disposed');
    }
  }

  // ─── Position Management ─────────────────────────────────────────────

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

  // ─── Controller Lifecycle ────────────────────────────────────────────

  void _disposeLocalController() {
    final controller = _controller;
    if (controller != null) {
      controller.removeListener(_videoListener);
      if (widget.videoController == null) {
        controller.dispose();
      } else {
        controller.pause();
      }
    }
    _controller = null;
    _isInitialized = false;
    _isBuffering = false;
  }

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;

    // Completer guard — لو التهيئة شغالة بالفعل، استنى عليها
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      return _initCompleter!.future;
    }

    if (_controller != null && _isInitialized) return;

    _initCompleter = Completer<void>();

    try {
      if (widget.videoController != null) {
        _controller = widget.videoController;
        _setupController();
        _initCompleter?.complete();
        return;
      }

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
              videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: true,
                allowBackgroundPlayback: false,
              ),
            );

      // ابدأ تحميل الكاش في الخلفية بالتوازي
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

      await _controller!.setLooping(true);
      _controller!.setVolume(_muteManager.isMuted.value ? 0.0 : 1.0);
      _setupController();
      widget.onControllerCreated?.call(_controller!);
      await _restorePosition();

      _stateManager.markAsLoaded(widget.postId);
      _retryCount = 0;
      _autoRetryTimer?.cancel();

      if (VideoManager.instance.currentlyPlayingPostId.value == widget.postId) {
        _controller!.play();
      }

      _initCompleter?.complete();
    } catch (e) {
      debugPrint("❌ Error initializing video: $e");
      if (!mounted || _isDisposed) {
        _initCompleter?.complete();
        return;
      }

      // التخلص من الـ controller الفاشل
      try {
        _controller?.dispose();
      } catch (_) {}
      _controller = null;
      _isInitialized = false;

      if (_retryCount < _maxRetries && _stateManager.canRetry(widget.postId)) {
        _retryCount++;
        _stateManager.recordError(widget.postId);
        _initCompleter?.complete();

        // Auto-retry صامت — بدون إظهار خطأ للمستخدم
        final delay = Duration(milliseconds: 800 * _retryCount);
        _autoRetryTimer?.cancel();
        _autoRetryTimer = Timer(delay, () {
          if (mounted && !_isDisposed) {
            _initializeVideo();
          }
        });
      } else {
        // بعد استنفاد كل المحاولات فقط، أظهر الخطأ
        _scheduleSetState(() => _hasError = true);
        _initCompleter?.complete();
      }
    }
  }

  void _setupController() {
    final controller = _controller;
    if (controller == null) return;

    try {
      _isInitialized = controller.value.isInitialized;
      _isBuffering = controller.value.isBuffering;
      controller.addListener(_videoListener);
      controller.setVolume(_muteManager.isMuted.value ? 0.0 : 1.0);
      if (mounted && !_isDisposed) setState(() {});
    } catch (e) {
      debugPrint('⚠️ Controller disposed during setup: $e');
      _controller = null;
      _isInitialized = false;
    }
  }

  // ─── Video Listener ──────────────────────────────────────────────────

  void _videoListener() {
    final controller = _controller;
    if (!mounted || controller == null || _isDisposed) return;

    try {
      final value = controller.value;

      // كشف خطأ أثناء التشغيل — auto-retry صامت
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

      // Debounced position save — only once per 5-second mark
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

  /// Auto-retry صامت بدون إظهار خطأ للمستخدم
  void _handleSilentRetry() {
    if (_isDisposed || !mounted) return;

    if (_retryCount < _maxRetries) {
      _retryCount++;
      debugPrint('🔄 Silent auto-retry #$_retryCount for ${widget.postId}');

      // تخلص من الـ controller الحالي وأعد التهيئة
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
        if (mounted && !_isDisposed) {
          _initializeVideo();
        }
      });
    } else {
      _scheduleSetState(() => _hasError = true);
    }
  }

  void _scheduleSetState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) setState(fn);
    });
  }

  // ─── Visibility & Interaction ────────────────────────────────────────

  // ✅ التعديل الرئيسي هنا — حل مشكلة الفيديو اللي بيفضل شغال في الخلفية
  void _handleVisibility(VisibilityInfo info) {
    if (!mounted || _isDisposed) return;

    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;

    final visibleFraction = info.visibleFraction;

    if (visibleFraction > 0.7) {
      // ألغِ أي timer dispose — الفيديو لسه في الشاشة
      _disposeDelayTimer?.cancel();
      _disposeDelayTimer = null;

      // ✅ فقط لما يدخل منطقة التشغيل لأول مرة
      // لو كان فيها أصلاً (_isInPlayZone == true) → ما نعملش حاجة
      // ده بيمنع الـ ping-pong بين بوستين بنفس لينك الفيديو
      if (!_isInPlayZone) {
        _isInPlayZone = true;

        if (_controller == null && !_hasError) {
          _initializeVideo().then((_) {
            if (mounted && !_isDisposed && _isInitialized) {
              VideoManager.instance.playVideo(widget.postId);
              _controller?.play();
            }
          });
        } else if (_controller != null &&
            _isInitialized &&
            !_isEnded &&
            !_hasError) {
          try {
            VideoManager.instance.playVideo(widget.postId);
            if (!_controller!.value.isPlaying) {
              _controller!.play();
            }
          } catch (e) {
            debugPrint('⚠️ Cannot play, controller disposed');
          }
        }
      }
      // ✅ لو _isInPlayZone == true بالفعل → SKIP تماماً
      // ده بيمنع الفيديو الأول من إعادة تشغيل نفسه لما التاني يوقفه
    } else if (visibleFraction > 0.0) {
      // ظاهر جزئياً — إيقاف مؤقت فقط بدون dispose
      _isInPlayZone = false; // ✅ خرج من منطقة التشغيل
      _disposeDelayTimer?.cancel();
      _disposeDelayTimer = null;
      _pauseAndSave();
    } else {
      // خرج من الشاشة تماماً — إيقاف مؤقت + dispose بعد 2 ثانية
      _isInPlayZone = false; // ✅ خرج من منطقة التشغيل
      _pauseAndSave();
      _disposeDelayTimer?.cancel();
      _disposeDelayTimer = Timer(const Duration(seconds: 2), () {
        if (mounted && !_isDisposed && _controller != null) {
          debugPrint('♻️ Delayed dispose for ${widget.postId}');
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
      widget.onReelTap?.call(_controller!);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────

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
    final maxAllowedHeight = context.responsiveHeight(500);

    return VisibilityDetector(
      key: Key('${widget.postId}_${widget.videoUrl}'),
      onVisibilityChanged: _handleVisibility,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: maxAllowedHeight),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: DecoratedBox(
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
                    if (thumbnail != null && thumbnail.isNotEmpty)
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: thumbnail,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              const ColoredBox(color: Colors.black),
                          errorWidget: (_, __, ___) =>
                              const ColoredBox(color: Colors.black),
                        ),
                      ),

                    if (_isInitialized && _controller != null)
                      Positioned.fill(
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

                    // لا نظهر loading indicator — الـ thumbnail يكفي (زي فيسبوك)
                    if (_isInitialized && _isBuffering)
                      _buildBufferingIndicator(),

                    if (_isInitialized && _controller != null)
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

// ═══════════════════════════════════════════════════════════════════════════════

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
