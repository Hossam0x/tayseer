import 'package:tayseer/my_import.dart';

class AppVideo extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final bool muted;

  const AppVideo(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.autoPlay = true,
    this.looping = true,
    this.showControls = false,
    this.muted = true,
  });

  @override
  State<AppVideo> createState() => _AppVideoState();
}

class _AppVideoState extends State<AppVideo> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() => _isInitialized = true);

              _controller.setLooping(widget.looping);
              _controller.setVolume(widget.muted ? 0 : 1);

              // ✅ تشغيل تلقائي
              if (widget.autoPlay) {
                _controller.play();
              }
            }
          })
          .catchError((error) {
            if (mounted) {
              setState(() => _hasError = true);
            }
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ حالة الخطأ
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.white54, size: 40),
        ),
      );
    }

    // ✅ حالة التحميل
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // ✅ عرض الفيديو
    return GestureDetector(
      onTap: widget.showControls ? _togglePlayPause : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // الفيديو
          FittedBox(
            fit: widget.fit,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),

          // أيقونة الصوت (اختياري)
          if (widget.muted)
            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onTap: _toggleMute,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _controller.value.volume == 0
                        ? Icons.volume_off
                        : Icons.volume_up,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  void _toggleMute() {
    setState(() {
      _controller.setVolume(_controller.value.volume == 0 ? 1 : 0);
    });
  }
}
