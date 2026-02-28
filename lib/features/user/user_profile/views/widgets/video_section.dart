import 'package:tayseer/my_import.dart';


// ════════════════════════════════════════════════════════════════
// Video Section Classes (same as before - no changes needed)
// ════════════════════════════════════════════════════════════════

class AppVideo extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final bool muted;
  final Function(VideoPlayerController)? onControllerReady;
  final Function(String)? onError;

  const AppVideo(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.autoPlay = false,
    this.looping = true,
    this.showControls = false,
    this.muted = false,
    this.onControllerReady,
    this.onError,
  });

  @override
  State<AppVideo> createState() => _AppVideoState();
}

class _AppVideoState extends State<AppVideo> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    if (widget.url.isEmpty || !widget.url.startsWith('http')) {
      setState(() {
        _hasError = true;
        _errorMessage = context.tr("video_load_error");
      });
      if (widget.onError != null) {
        widget.onError!(_errorMessage!);
      }
      return;
    }

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize()
            .then((_) {
              if (mounted) {
                setState(() => _isInitialized = true);
                _controller!.setLooping(widget.looping);
                _controller!.setVolume(widget.muted ? 0 : 1);

                if (widget.autoPlay) {
                  _controller!.play();
                }

                if (widget.onControllerReady != null) {
                  widget.onControllerReady!(_controller!);
                }
              }
            })
            .catchError((error) {
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _errorMessage =
                      '${context.tr("video_load_error")}: ${error.toString()}';
                });
                if (widget.onError != null) {
                  widget.onError!(_errorMessage!);
                }
              }
            });

      _controller?.addListener(() {
        if (_controller!.value.hasError && mounted) {
          setState(() {
            _hasError = true;
            _errorMessage =
                _controller!.value.errorDescription ??
                context.tr("error_play_video");
          });
          if (widget.onError != null) {
            widget.onError!(_errorMessage!);
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'خطأ في إنشاء مشغل الفيديو: ${e.toString()}';
        });
        if (widget.onError != null) {
          widget.onError!(_errorMessage!);
        }
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _errorMessage ?? context.tr("otp_error_general"),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade300, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
              const SizedBox(height: 12),
              Text(
                context.tr("loading_video"),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: widget.fit,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}

class VideoSection extends StatefulWidget {
  final String? videoUrl;
  final VoidCallback? onDelete;
  final VoidCallback? onUpload;
  final bool showControls;

  const VideoSection({
    super.key,
    this.videoUrl,
    this.onDelete,
    this.onUpload,
    this.showControls = true,
  });

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  VideoPlayerController? _controller;
  bool isPlaying = false;
  bool showOverlay = true;
  bool hasError = false;
  bool isInitializing = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    if (hasValidVideo) {
      _initializeVideo();
    } else {
      isInitializing = false;
    }
  }

  @override
  void didUpdateWidget(VideoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      if (hasValidVideo) {
        setState(() {
          isInitializing = true;
          hasError = false;
          errorMessage = null;
        });
        _initializeVideo();
      }
    }
  }

  bool get hasValidVideo {
    return widget.videoUrl != null &&
        widget.videoUrl!.isNotEmpty &&
        (widget.videoUrl!.startsWith('http://') ||
            widget.videoUrl!.startsWith('https://'));
  }

  void _initializeVideo() async {
    if (!hasValidVideo) {
      setState(() {
        isInitializing = false;
        hasError = true;
        errorMessage = 'رابط الفيديو غير صالح';
      });
      return;
    }

    try {
      _disposeController();

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl!),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      _controller!.addListener(_videoListener);

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          isInitializing = false;
          hasError = false;
        });

        _controller!.setLooping(true);
        _controller!.setVolume(1.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isInitializing = false;
          hasError = true;
          errorMessage = 'فشل في تحميل الفيديو: ${e.toString()}';
        });
      }
      debugPrint('❌ Video initialization error: $e');
    }
  }

  void _videoListener() {
    if (!mounted) return;

    if (_controller!.value.hasError) {
      setState(() {
        hasError = true;
        errorMessage =
            _controller!.value.errorDescription ?? 'خطأ في تشغيل الفيديو';
      });
      debugPrint(
        '❌ Video playback error: ${_controller!.value.errorDescription}',
      );
    }

    if (isPlaying != _controller!.value.isPlaying) {
      setState(() {
        isPlaying = _controller!.value.isPlaying;
      });
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        showOverlay = true;
      } else {
        _controller!.play();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _controller!.value.isPlaying) {
            setState(() => showOverlay = false);
          }
        });
      }
    });
  }

  void _seek(Duration duration) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final currentPos = _controller!.value.position;
    final totalDuration = _controller!.value.duration;
    final newPos = currentPos + duration;

    _controller!.seekTo(
      newPos < Duration.zero
          ? Duration.zero
          : (newPos > totalDuration ? totalDuration : newPos),
    );
  }

  void _disposeController() {
    _controller?.removeListener(_videoListener);
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!hasValidVideo) {
      return _buildEmptyState();
    }

    if (hasError) {
      return _buildErrorState();
    }

    if (isInitializing) {
      return _buildLoadingState();
    }

    return _buildVideoPlayer();
  }

  Widget _buildEmptyState() {
    return Container(
      height: 250.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off_outlined,
            size: 60.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 12.h),
          Text(
            'لم يتم رفع فيديو بعد',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.onUpload != null) ...[
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: widget.onUpload,
              icon: const Icon(Icons.upload),
              label: const Text('رفع فيديو'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 250.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60.sp, color: Colors.red.shade400),
          SizedBox(height: 12.h),
          Text(
            'فشل تحميل الفيديو',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (errorMessage != null) ...[
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp, color: Colors.red.shade600),
              ),
            ),
          ],
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                hasError = false;
                errorMessage = null;
                isInitializing = true;
              });
              _initializeVideo();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 250.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.black87,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 3.w),
            SizedBox(height: 12.h),
            Text(
              context.tr("loading_video"),
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return VisibilityDetector(
      key: Key(widget.videoUrl!),
      onVisibilityChanged: (info) {
        if (!mounted ||
            _controller == null ||
            !_controller!.value.isInitialized) {
          return;
        }

        if (info.visibleFraction > 0.6) {
          if (!_controller!.value.isPlaying) {
            _controller!.play();
          }
        } else {
          if (_controller!.value.isPlaying) {
            _controller!.pause();
            setState(() => showOverlay = true);
          }
        }
      },
      child: Container(
        height: 250.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_controller != null && _controller!.value.isInitialized)
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

              if (widget.onDelete != null)
                Positioned(top: 10.h, right: 10.w, child: _buildDeleteButton()),

              GestureDetector(
                onTap: () {
                  setState(() => showOverlay = !showOverlay);
                },
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

              if (widget.showControls && (showOverlay || !isPlaying))
                _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: const Text('تأكيد الحذف'),
              content: const Text('هل تريد حذف هذا الفيديو؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child:  Text(context.tr("cancel")),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child:  Text(context.tr("delete"), style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );

          if (confirm == true && widget.onDelete != null) {
            widget.onDelete!();
          }
        },
        customBorder: const CircleBorder(),
        child: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.delete_outline, color: Colors.white, size: 20.sp),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleButton(
              icon: Icons.replay_10_rounded,
              onTap: () => _seek(const Duration(seconds: -10)),
            ),
            Gap(20.w),
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.black87,
                  size: 35.sp,
                ),
              ),
            ),
            Gap(20.w),
            _buildCircleButton(
              icon: Icons.forward_10_rounded,
              onTap: () => _seek(const Duration(seconds: 10)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 45.w,
          height: 45.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.black87, size: 24.sp),
        ),
      ),
    );
  }
}
