import 'package:flutter/material.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';
import 'package:video_player/video_player.dart';

class VideoMessageWidget extends StatefulWidget {
  final String videoUrl;
  final double maxWidth;

  const VideoMessageWidget({
    super.key,
    required this.videoUrl,
    required this.maxWidth,
  });

  @override
  State<VideoMessageWidget> createState() => _VideoMessageWidgetState();
}

class _VideoMessageWidgetState extends State<VideoMessageWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
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

  void _openFullScreenVideo() {
    _controller.pause();
    setState(() => _isPlaying = false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(videoUrl: widget.videoUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        width: widget.maxWidth,
        height: 150,
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final aspectRatio = _controller.value.aspectRatio;
    final videoHeight = widget.maxWidth / aspectRatio;
    final clampedHeight = videoHeight.clamp(100.0, 300.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(ChatDimensions.bubbleRadiusSmall),
      child: Stack(
        children: [
          GestureDetector(
            onTap: _togglePlay,
            child: SizedBox(
              width: widget.maxWidth,
              height: clampedHeight,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          ),
          if (!_isPlaying)
            Positioned.fill(
              child: GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _openFullScreenVideo,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoPlayer({super.key, required this.videoUrl});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
        _isPlaying = true;
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
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

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showControls
          ? AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
            )
          : null,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            if (_showControls && _isInitialized)
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            if (_showControls && _isInitialized)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: ChatColors.bubbleSender,
                          bufferedColor: Colors.white38,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: _controller,
                            builder: (context, value, child) {
                              return Text(
                                _formatDuration(value.position),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                          Text(
                            _formatDuration(_controller.value.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
