import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:tayseer/my_import.dart';

class CustomUploadedVideoPreview extends StatefulWidget {
  final XFile video;
  final VoidCallback onRemove;

  const CustomUploadedVideoPreview({
    super.key,
    required this.video,
    required this.onRemove,
  });

  @override
  State<CustomUploadedVideoPreview> createState() =>
      _CustomUploadedVideoPreviewState();
}

class _CustomUploadedVideoPreviewState extends State<CustomUploadedVideoPreview>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;

  late AnimationController _animationController;
  late Animation<double> _fadeScale;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(File(widget.video.path))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeScale = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_isInitialized) return;

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _openFullScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenVideoPlayer(file: File(widget.video.path)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeScale,
      child: ScaleTransition(
        scale: _fadeScale,
        child: Container(
          height: context.height * 0.25,
          width: context.width * 0.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.kBlueColor.withOpacity(.4)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                /// 🎬 Mini Video Player
                _isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : Container(color: Colors.black12),

                /// ▶️ Play / Pause (CENTER)
                GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),

                /// ⛶ Maximize (TOP LEFT)
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: _openFullScreen,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.fullscreen,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                /// ❌ Remove (TOP RIGHT)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: widget.onRemove,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final File file;

  const FullScreenVideoPlayer({super.key, required this.file});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(),
            ),

            Positioned(
              top: 20,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UploadVideoWidget extends StatelessWidget {
  final VoidCallback onTap;

  const UploadVideoWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: context.height * 0.2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.kprimaryColor.withOpacity(.3)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppImage(AssetsData.kvideoIcon),
              const SizedBox(height: 8),
              Text(
                context.tr('upload_Video'),
                style: Styles.textStyle12.copyWith(
                  color: AppColors.kprimaryColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
