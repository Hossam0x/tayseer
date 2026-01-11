import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/core/video/video_state_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReelsVideoBackground extends StatefulWidget {
  final String videoUrl;
  final String? videoId; // إضافة videoId للتتبع
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

class _ReelsVideoBackgroundState extends State<ReelsVideoBackground> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isBuffering = false;
  bool _isDragging = false;
  bool _isDisposed = false;
  final _videoCacheManager = VideoCacheManager();
  final _stateManager = VideoStateManager();

  // لتتبع محاولات إعادة التحميل
  int _retryCount = 0;
  static const int _maxRetries = 3;

  String get _videoId => widget.videoId ?? widget.videoUrl.hashCode.toString();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (_isDisposed) return;

    // 1. Shared Controller Logic
    if (widget.sharedController != null) {
      _controller = widget.sharedController;

      // بنقوله لو جاي من بره (حتى لو كان صامت)، علي الصوت للآخر
      await _controller!.setVolume(1.0);

      // الحماية من التدمير أثناء الـ await
      if (!mounted || _controller == null || _isDisposed) return;

      if (_controller!.value.isInitialized) {
        _isInitialized = true;
        _hasError = false;

        // استرجاع آخر موضع
        await _restorePosition();

        // Auto-play if shouldPlay is true
        if (widget.shouldPlay) {
          _controller!.play();
        }
      }
      _controller!.addListener(_videoListener);
      widget.onControllerCreated?.call(_controller!);
      if (mounted && !_isDisposed) setState(() {});
      return;
    }

    try {
      final cachedFile = await _videoCacheManager.getCachedFile(
        widget.videoUrl,
      );
      if (!mounted || _isDisposed) return;

      if (cachedFile != null) {
        _controller = VideoPlayerController.file(cachedFile);
        debugPrint('📁 Reels: Loading from cache');
      } else {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        _videoCacheManager.preloadVideoInBackground(widget.videoUrl);
        debugPrint('🌐 Reels: Loading from network');
      }

      _controller!.addListener(_videoListener);
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setVolume(1.0);

      if (mounted && !_isDisposed) {
        widget.onControllerCreated?.call(_controller!);

        // استرجاع آخر موضع
        await _restorePosition();

        setState(() {
          _isInitialized = true;
          _hasError = false;
        });

        // تسجيل نجاح التحميل
        _stateManager.markAsLoaded(_videoId);
        _retryCount = 0;

        if (widget.shouldPlay) _controller!.play();
      }
    } catch (e) {
      debugPrint('❌ Error initializing video: $e');
      if (mounted && !_isDisposed) {
        // تسجيل الخطأ وإعادة المحاولة تلقائياً
        if (_retryCount < _maxRetries && _stateManager.canRetry(_videoId)) {
          _retryCount++;
          _stateManager.recordError(_videoId);
          debugPrint('🔄 Auto-retrying... (${_retryCount}/$_maxRetries)');
          await Future.delayed(Duration(milliseconds: 500 * _retryCount));
          if (mounted && !_isDisposed) {
            _initializeVideo();
          }
        } else {
          setState(() {
            _hasError = true;
            _isInitialized = false;
          });
        }
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
    if (_controller == null || !mounted || _isDisposed) return;

    try {
      final value = _controller!.value;

      // تتبع حالة التخزين المؤقت
      final isBuffering = value.isBuffering;
      if (isBuffering != _isBuffering) {
        // تأخير setState لتجنب خطأ build scope
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDisposed)
            setState(() => _isBuffering = isBuffering);
        });
      }

      // حفظ الموضع دورياً (كل 5 ثواني تقريباً)
      if (_isInitialized &&
          !_isDragging &&
          value.position.inSeconds % 5 == 0 &&
          value.position.inSeconds > 0) {
        _savePosition();
      }
    } catch (e) {
      debugPrint('⚠️ Controller disposed in listener');
    }
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
  void dispose() {
    _isDisposed = true;

    // حفظ الموضع قبل التدمير
    _savePosition();

    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      // Protection: Don't dispose if shared
      if (widget.sharedController == null) {
        _controller!.dispose();
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTapDown: (details) =>
          widget.onDoubleTap?.call(details.globalPosition),
      child: Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
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
              Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),

            // Error
            if (_hasError)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white54,
                      size: 48,
                    ),
                    TextButton.icon(
                      onPressed: _retryInitialization,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

            // Progress Bar
            if (widget.showProgressBar && _isInitialized && _controller != null)
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
                  // Gray background
                  Container(
                    height: _isDragging ? 6.h : 3.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                  // White progress
                  AnimatedContainer(
                    duration: _isDragging
                        ? Duration.zero
                        : const Duration(milliseconds: 100),
                    height: _isDragging ? 6.h : 3.h,
                    width:
                        (MediaQuery.of(context).size.width - 24.w) *
                        progress.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3.r),
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
