import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullscreenResult {
  final Duration position;
  final bool wasPlaying;
  final bool isMuted;

  FullscreenResult({
    required this.position,
    required this.wasPlaying,
    required this.isMuted,
  });
}

class FullscreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final Duration startPosition;
  final bool isMuted;

  const FullscreenVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.startPosition,
    required this.isMuted,
  });

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;
  late bool _isMuted;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _isMuted = widget.isMuted;
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.seekTo(widget.startPosition);
          _controller.setVolume(_isMuted ? 0.0 : 1.0);
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.play();
      } else {
        _controller.pause();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  void _seekRelative(Duration offset) {
    final newPosition = _controller.value.position + offset;
    if (newPosition < Duration.zero) {
      _controller.seekTo(Duration.zero);
    } else if (newPosition > _controller.value.duration) {
      _controller.seekTo(_controller.value.duration);
    } else {
      _controller.seekTo(newPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video Player Full Screen
            Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : const CircularProgressIndicator(),
            ),

            // Controls
            if (_showControls)
              GestureDetector(
                onTap: _toggleControls,
                child: Container(
                  color: Colors.black54,
                  child: Column(
                    children: [
                      // Top Bar
                      AppBar(
                        backgroundColor: Colors.transparent,
                        leading: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(
                            context,
                            FullscreenResult(
                              position: _controller.value.position,
                              wasPlaying: _controller.value.isPlaying,
                              isMuted: _isMuted,
                            ),
                          ),
                        ),
                        title: Text(
                          'Full Screen',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      // Play/Pause Controls
                      Expanded(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.replay_10,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                onPressed: () =>
                                    _seekRelative(Duration(seconds: -10)),
                              ),
                              SizedBox(width: 40),
                              IconButton(
                                icon: Icon(
                                  _isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: Colors.white,
                                  size: 60,
                                ),
                                onPressed: _togglePlayPause,
                              ),
                              SizedBox(width: 40),
                              IconButton(
                                icon: Icon(
                                  Icons.forward_10,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                onPressed: () =>
                                    _seekRelative(Duration(seconds: 10)),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Controls
                      Container(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isMuted ? Icons.volume_off : Icons.volume_up,
                                color: Colors.white,
                              ),
                              onPressed: _toggleMute,
                            ),
                            Expanded(
                              child: VideoProgressIndicator(
                                _controller,
                                allowScrubbing: true,
                                colors: VideoProgressColors(
                                  playedColor: Colors.red,
                                  bufferedColor: Colors.grey,
                                  backgroundColor: Colors.white24,
                                ),
                              ),
                            ),
                          ],
                        ),
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
