import 'package:tayseer/core/widgets/custom_app_video.dart';
import 'package:tayseer/my_import.dart';

class VideoSection extends StatefulWidget {
  final String? videoUrl; // ⭐ خليها nullable
  final VoidCallback? onDelete; // ⭐ NEW
  final VoidCallback? onUpload; // ⭐ NEW
  final bool showControls;

  const VideoSection({
    super.key,
    required this.videoUrl,
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

  bool get hasValidVideo {
    return widget.videoUrl != null &&
        widget.videoUrl!.isNotEmpty &&
        (widget.videoUrl!.startsWith('http://') ||
            widget.videoUrl!.startsWith('https://'));
  }

  @override
  Widget build(BuildContext context) {
    if (!hasValidVideo) {
      return _buildVideoUploadButton(context);
    }

    return VisibilityDetector(
      key: Key(widget.videoUrl!),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction > 0.6) {
          if (_controller != null &&
              !_controller!.value.isPlaying &&
              _controller!.value.isInitialized) {
            _controller?.play();
            if (mounted) {
              setState(() {
                isPlaying = true;
                showOverlay = false;
              });
            }
          }
        } else {
          if (_controller != null && _controller!.value.isPlaying) {
            _controller?.pause();
            if (mounted) {
              setState(() {
                isPlaying = false;
                showOverlay = true;
              });
            }
          }
        }
      },
      child: Container(
        height: 250.h,
        width: context.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. The Video Component
              AppVideo(
                widget.videoUrl!,
                fit: BoxFit.cover,
                autoPlay: false,
                muted: false,
                onControllerReady: (controller) {
                  setState(() {
                    _controller = controller;
                  });
                  _controller?.addListener(() {
                    if (mounted) {
                      setState(() {
                        isPlaying = _controller!.value.isPlaying;
                      });
                    }
                  });
                },
              ),

              // 2. Transparent Control Layer 
              // This is moved BEFORE the delete button so it doesn't block it
              GestureDetector(
                onTap: () {
                  setState(() {
                    showOverlay = !showOverlay;
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

              // 3. Playback Controls (Play/Pause/Forward/Backward)
              if (widget.showControls && (showOverlay || !isPlaying))
                _buildPlaybackControls(),

              // 4. ⭐ Delete Button (Positioned at the end of the stack to be on TOP)
              if (widget.onDelete != null)
                Positioned(
                  top: 10.h, 
                  right: 10.w, 
                  child: _buildDeleteButton(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Updated Delete Button with propagation check
  Widget _buildDeleteButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onDelete, // Executes your deletion logic
        customBorder: const CircleBorder(),
        child: Container(
          width: 40.w,
          height: 40.w,
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
          child: Icon(Icons.close, color: Colors.white, size: 20.sp),
        ),
      ),
    );
  }

  // ... (Keep _buildUploadButton, _buildPlaybackControls, and dispose as they were)

  // ════════════════════════════════════════════════════════════════
  // ⭐ زر الرفع (لما مافيش فيديو)
  // ════════════════════════════════════════════════════════════════
    Widget _buildVideoUploadButton(BuildContext context) {
    return GestureDetector(
    onTap: widget.onUpload,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.secondary50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary200, width: 1.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ارفاق فيديو تعريفي', style: Styles.textStyle16),
                Gap(4.h),
                Text(
                  'الحد الأقصى 50 ميجا',
                  style: Styles.textStyle12.copyWith(color: Colors.grey),
                ),
              ],
            ),
            Icon(
              Icons.play_circle_outline,
              color: AppColors.primary200,
              size: 30.w,
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: widget.onUpload,
      child: Container(
        height: 180.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.secondary50,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.primary200.withOpacity(0.3),
            width: 2.w,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.primary200.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.videocam_outlined,
                size: 48.sp,
                color: AppColors.primary200,
              ),
            ),
            Gap(16.h),
            Text(
              'ارفاق فيديو تعريفي',
              style: Styles.textStyle16.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary200,
              ),
            ),
            Gap(4.h),
            Text(
              'الحد الأقصى 50 ميجا',
              style: Styles.textStyle12.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }


  // أزرار التشغيل (Play/Pause/Forward/Backward)
  // ════════════════════════════════════════════════════════════════
  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircleButton(
          icon: Icons.replay_10_rounded,
          onTap: () async {
            if (_controller == null || !_controller!.value.isInitialized) {
              return;
            }
            final currentPos = _controller!.value.position;
            final newPos = currentPos - const Duration(seconds: 10);

            await _controller!.seekTo(
              newPos < Duration.zero ? Duration.zero : newPos,
            );
          },
        ),
        Gap(20.w),
        GestureDetector(
          onTap: () {
            if (_controller == null || !_controller!.value.isInitialized) {
              return;
            }

            if (_controller!.value.isPlaying) {
              _controller!.pause();
              setState(() => showOverlay = true);
            } else {
              _controller!.play();

              Future.delayed(const Duration(seconds: 2), () {
                if (mounted && _controller!.value.isPlaying && showOverlay) {
                  setState(() => showOverlay = false);
                }
              });
            }
          },
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
          onTap: () async {
            if (_controller == null || !_controller!.value.isInitialized) {
              return;
            }

            final currentPos = _controller!.value.position;
            final totalDuration = _controller!.value.duration;
            final newPos = currentPos + const Duration(seconds: 10);

            await _controller!.seekTo(
              newPos > totalDuration ? totalDuration : newPos,
            );
          },
        ),
      ],
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
