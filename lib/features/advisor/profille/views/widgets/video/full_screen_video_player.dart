import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/video/fullscreen_video_cubit.dart';

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
  late FullscreenVideoCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = FullscreenVideoCubit(widget.isMuted);
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        // if (mounted) {
        //   _controller.seekTo(widget.startPosition);
        //   _controller.setVolume(widget.isMuted ? 0.0 : 1.0);
        //   _controller.play();
        //   // No setState needed, but controller needs to notify listeners
        // }

        // Wait, the video player widget needs to rebuild to show the video
        // But since we use simple VideoPlayer(_controller), it relies on _controller notifications? NO.
        // VideoPlayer widget itself listens to controller? No, we usually wrap it in specific widget or use setState on controller change.
        // The original code called setState() after initialize.
        // However, I can't call setState.
        // I will rely on the Cubit to trigger rebuild.
        if (mounted) {
          _controller.seekTo(widget.startPosition);
          _controller.setVolume(widget.isMuted ? 0.0 : 1.0);
          _controller.play();
          // Force rebuild by toggling something unrelated or just rely on the fact that build is called.
          // Actually, VideoPlayer needs explicit rebuilds usually if AspectRatio changes.
          // I'll emit a dummy state change or just use the initial state.
          // But `_controller.value.isInitialized` is used in build.
          // So I MUST rebuild.
          // I'll use a local ValueNotifier or just modify cubit state slightly?
          // I'll just emit a toggle on controls to force rebuild.
          _cubit.toggleControls(); // Hack to trigger rebuild
          _cubit.toggleControls(); // Revert
        }
      });
    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    // Monitor completion or other stuff if needed
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    // Pause before dispose to immediately stop audio output
    _controller.pause();
    _controller.dispose();
    _cubit.close();
    super.dispose();
  }

  void _seekRelative(Duration offset) {
    if (!_controller.value.isInitialized) return;
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
    return BlocProvider.value(
      value: _cubit, // Provide local cubit
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: BlocBuilder<FullscreenVideoCubit, FullscreenVideoState>(
            builder: (context, state) {
              return Stack(
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
                  if (state.showControls)
                    GestureDetector(
                      onTap: () => _cubit.toggleControls(),
                      child: Container(
                        color: Colors.black54,
                        child: Column(
                          children: [
                            // Top Bar
                            AppBar(
                              backgroundColor: Colors.transparent,
                              leading: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(
                                  context,
                                  FullscreenResult(
                                    position: _controller.value.position,
                                    wasPlaying: _controller.value.isPlaying,
                                    isMuted: state.isMuted,
                                  ),
                                ),
                              ),
                              title: const Text(
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
                                      icon: const Icon(
                                        Icons.replay_10,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      onPressed: () => _seekRelative(
                                        const Duration(seconds: -10),
                                      ),
                                    ),
                                    const SizedBox(width: 40),
                                    IconButton(
                                      icon: Icon(
                                        state.isPlaying
                                            ? Icons.pause_circle_filled
                                            : Icons.play_circle_filled,
                                        color: Colors.white,
                                        size: 60,
                                      ),
                                      onPressed: () {
                                        if (state.isPlaying) {
                                          _controller.pause();
                                        } else {
                                          _controller.play();
                                        }
                                        context
                                            .read<FullscreenVideoCubit>()
                                            .togglePlayPause();
                                      },
                                    ),
                                    const SizedBox(width: 40),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.forward_10,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      onPressed: () => _seekRelative(
                                        const Duration(seconds: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Bottom Controls
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      state.isMuted
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      final newMute = !state.isMuted;
                                      _controller.setVolume(
                                        newMute ? 0.0 : 1.0,
                                      );
                                      context
                                          .read<FullscreenVideoCubit>()
                                          .toggleMute();
                                    },
                                  ),
                                  Expanded(
                                    child: VideoProgressIndicator(
                                      _controller,
                                      allowScrubbing: true,
                                      colors: const VideoProgressColors(
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

                  // Tap to show/hide controls
                  if (!state.showControls)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => _cubit.toggleControls(),
                        behavior: HitTestBehavior.opaque,
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
