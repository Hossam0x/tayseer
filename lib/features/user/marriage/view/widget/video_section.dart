import 'package:tayseer/core/widgets/custom_app_video.dart';
import 'package:tayseer/my_import.dart';

class VideoSection extends StatefulWidget {
  final String? videoUrl;
  final VoidCallback? onDelete;
  final VoidCallback? onUpload;
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
      key: const ValueKey('video_section'),
      onVisibilityChanged: _handleVisibility,
      child: Container(
        height: 250.h,
        width: context.width,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// ================= Video =================
              AppVideo(
                widget.videoUrl!,
                fit: BoxFit.cover,
                autoPlay: false,
                muted: false,
                onControllerReady: _onControllerReady,
              ),

              /// ================= Overlay Detector =================
              GestureDetector(
                onTap: () {
                  if (!mounted) return;
                  setState(() => showOverlay = !showOverlay);
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              ),

              /// ================= Controls =================
              if (widget.showControls && (showOverlay || !isPlaying))
                _buildPlaybackControls(),

              /// ================= Delete Button =================
              if (widget.onDelete != null)
                Positioned(top: 10.h, right: 10.w, child: _buildDeleteButton()),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Controller Ready
  // ════════════════════════════════════════════════════════════════
  void _onControllerReady(VideoPlayerController controller) {
    if (!mounted) return;

    _controller = controller;

    _controller?.addListener(() {
      if (!mounted || _controller == null) return;

      final playing = _controller!.value.isPlaying;
      if (playing != isPlaying) {
        setState(() => isPlaying = playing);
      }
    });
  }

  // ════════════════════════════════════════════════════════════════
  // Visibility Handler
  // ════════════════════════════════════════════════════════════════
  void _handleVisibility(VisibilityInfo info) {
    if (!mounted || _controller == null) return;

    if (info.visibleFraction > 0.6) {
      if (_controller!.value.isInitialized && !_controller!.value.isPlaying) {
        _controller!.play();
        setState(() {
          isPlaying = true;
          showOverlay = false;
        });
      }
    } else {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        setState(() {
          isPlaying = false;
          showOverlay = true;
        });
      }
    }
  }

  // ════════════════════════════════════════════════════════════════
  // Delete Button
  // ════════════════════════════════════════════════════════════════
  Widget _buildDeleteButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onDelete,
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

  // ════════════════════════════════════════════════════════════════
  // Upload Button (No Video)
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

  // ════════════════════════════════════════════════════════════════
  // Playback Controls
  // ════════════════════════════════════════════════════════════════
  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleButton(Icons.replay_10_rounded, () async {
          if (_controller == null || !_controller!.value.isInitialized) return;

          final pos = _controller!.value.position - const Duration(seconds: 10);
          await _controller!.seekTo(pos < Duration.zero ? Duration.zero : pos);
        }),
        Gap(20.w),
        GestureDetector(
          onTap: () {
            if (_controller == null || !_controller!.value.isInitialized)
              return;

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
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 35.sp,
              color: Colors.black87,
            ),
          ),
        ),
        Gap(20.w),
        _circleButton(Icons.forward_10_rounded, () async {
          if (_controller == null || !_controller!.value.isInitialized) return;

          final pos = _controller!.value.position + const Duration(seconds: 10);
          final total = _controller!.value.duration;

          await _controller!.seekTo(pos > total ? total : pos);
        }),
      ],
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
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
          ),
          child: Icon(icon, size: 24.sp),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }
}
