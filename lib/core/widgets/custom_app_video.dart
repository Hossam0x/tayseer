import 'package:tayseer/my_import.dart';

class AppVideo extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final bool autoPlay; // جعلناها false افتراضياً عشان نتحكم احنا
  final bool looping;
  final bool showControls;
  final bool muted;
  // هذا الكول باك مهم عشان نبعت الكنترولر للأب (VideoSection)
  final Function(VideoPlayerController)? onControllerReady;

  const AppVideo(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.autoPlay = false,
    this.looping = true,
    this.showControls = false, // هنخليها false عشان هنعمل احنا UI خاص بينا
    this.muted = false,
    this.onControllerReady,
  });

  @override
  State<AppVideo> createState() => _AppVideoState();
}

class _AppVideoState extends State<AppVideo> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          _controller.setLooping(widget.looping);
          _controller.setVolume(widget.muted ? 0 : 1);

          if (widget.autoPlay) {
            _controller.play();
          }

          // نرسل الكنترولر للأب بمجرد ما يجهز
          if (widget.onControllerReady != null) {
            widget.onControllerReady!(_controller);
          }
        }
      });
  }

  @override
  void dispose() {
    // ملحوظة: لو الكنترولر هيدار من الخارج يفضل عدم عمل dispose هنا
    // لكن في حالتنا هنا الـ Widget هو اللي خلقه فهنعمله dispose عادي
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: widget.fit,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
