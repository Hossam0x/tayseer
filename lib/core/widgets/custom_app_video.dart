import 'dart:io';
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

class _AppVideoState extends State<AppVideo> with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }

  void _initializeVideo() {
    debugPrint('📹 [AppVideo] Starting initialization: ${widget.url}');
    debugPrint('📹 [AppVideo] Platform: Android=${Platform.isAndroid}, iOS=${Platform.isIOS}');
    
    try {
      final uri = Uri.parse(widget.url);
      debugPrint('📹 [AppVideo] Parsed URI successfully: $uri');
      
      _controller = VideoPlayerController.networkUrl(
        uri,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );
      
      debugPrint('📹 [AppVideo] Controller created, starting initialize...');
      _controller.initialize().then((_) {
        debugPrint('📹 [AppVideo] Controller initialized successfully');
        if (mounted) {
          setState(() => _isInitialized = true);
          _controller.setLooping(widget.looping);
          _controller.setVolume(widget.muted ? 0 : 1);

          if (widget.autoPlay) {
            debugPrint('📹 [AppVideo] AutoPlay enabled, starting playback');
            _controller.play();
          }

          // نرسل الكنترولر للأب بمجرد ما يجهز
          if (widget.onControllerReady != null) {
            widget.onControllerReady!(_controller);
          }
        }
      }).catchError((error) {
        debugPrint('❌ [AppVideo] Initialization error: $error');
        if (mounted) {
          setState(() => _isInitialized = false);
        }
      });
    } catch (e, stackTrace) {
      debugPrint('❌ [AppVideo] Error during initialization: $e');
      debugPrint('❌ [AppVideo] Stack trace: $stackTrace');
    }
  }

  // Pause video when app goes to background to prevent audio leaking
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_controller.value.isPlaying) {
        _controller.pause();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Pause before dispose to immediately stop audio output
    _controller.pause();
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
          child: _controller.value.isInitialized
              ? VideoPlayer(_controller)
              : Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(Icons.error_outline, color: Colors.red),
                  ),
                ),
        ),
      ),
    );
  }
}
