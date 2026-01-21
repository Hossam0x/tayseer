import 'package:tayseer/core/widgets/custom_app_video.dart';
import 'package:tayseer/my_import.dart';

class VideoSection extends StatefulWidget {
  final String videoUrl;

  const VideoSection({super.key, required this.videoUrl});

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  VideoPlayerController? _controller;
  bool isPlaying = false;
  bool showOverlay = true;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (VisibilityInfo info) {
        // تشغيل تلقائي إذا ظهر 60% من الفيديو
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
          // إيقاف إذا اختفى الفيديو
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
              AppVideo(
                widget.videoUrl,
                fit: BoxFit.cover,
                autoPlay: false, // التحكم يدوي وعن طريق السكرول
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

              // 2. طبقة شفافة لاستقبال اللمس لإظهار/إخفاء التحكم
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

              // 3. أزرار التحكم
              if (showOverlay || !isPlaying)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCircleButton(
                      icon: Icons.replay_10_rounded,
                      onTap: () async {
                        if (_controller == null ||
                            !_controller!.value.isInitialized)
                          return;
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
                        if (_controller == null ||
                            !_controller!.value.isInitialized)
                          return;

                        if (_controller!.value.isPlaying) {
                          _controller!.pause();
                          setState(() => showOverlay = true);
                        } else {
                          _controller!.play();

                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted &&
                                _controller!.value.isPlaying &&
                                showOverlay) {
                              setState(() => showOverlay = false);
                            }
                          });
                        }
                      },
                      child: Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 35.sp,
                        ),
                      ),
                    ),

                    Gap(20.w),

                    _buildCircleButton(
                      icon: Icons.forward_10_rounded,
                      onTap: () async {
                        if (_controller == null ||
                            !_controller!.value.isInitialized)
                          return;

                        final currentPos = _controller!.value.position;
                        final totalDuration = _controller!.value.duration;
                        final newPos = currentPos + const Duration(seconds: 10);

                        await _controller!.seekTo(
                          newPos > totalDuration ? totalDuration : newPos,
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
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
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24.sp),
        ),
      ),
    );
  }
}
