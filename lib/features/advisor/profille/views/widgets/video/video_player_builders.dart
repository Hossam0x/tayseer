import 'package:tayseer/features/advisor/profille/views/cubit/video/video_player_cubit.dart';
import 'package:tayseer/my_import.dart';

/// Loading / error state for the video player
class VideoLoadingState extends StatelessWidget {
  final VideoPlayerState state;
  final VoidCallback onRetry;

  const VideoLoadingState({
    super.key,
    required this.state,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: state.hasError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 40.w),
                  SizedBox(height: 10.h),
                  Text(
                    context.tr('retry'),
                    style: Styles.textStyle14.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: Text(context.tr('retry')),
                  ),
                ],
              )
            : const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
      ),
    );
  }
}

/// The actual video player with controls overlay
class VideoPlayerContent extends StatelessWidget {
  final VideoPlayerController controller;
  final VideoPlayerState state;
  final String videoUrl;
  final bool showFullScreenButton;
  final VoidCallback onToggleControls;
  final VoidCallback onSkipBackward;
  final VoidCallback onSkipForward;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onOpenFullscreen;
  final VoidCallback onToggleMute;

  const VideoPlayerContent({
    super.key,
    required this.controller,
    required this.state,
    required this.videoUrl,
    required this.showFullScreenButton,
    required this.onToggleControls,
    required this.onSkipBackward,
    required this.onSkipForward,
    required this.onTogglePlayPause,
    required this.onOpenFullscreen,
    required this.onToggleMute,
  });

  @override
  Widget build(BuildContext context) {
    final videoSize = controller.value.size;

    return SizedBox(
      width: double.infinity,
      height: 400.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Hero(
              tag: 'video_$videoUrl',
              child: AspectRatio(
                aspectRatio: videoSize.width / videoSize.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
          if (state.showControls)
            Positioned.fill(
              child: GestureDetector(
                onTap: onToggleControls,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: onSkipBackward,
                        icon: Icon(
                          Directionality.of(context) == TextDirection.rtl
                              ? Icons.forward_10
                              : Icons.replay_10,
                          color: Colors.white,
                          size: 35.w,
                        ),
                      ),
                      Gap(16.w),
                      IconButton(
                        onPressed: onTogglePlayPause,
                        icon: Icon(
                          state.isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: Colors.white,
                          size: 45.w,
                        ),
                      ),
                      Gap(16.w),
                      IconButton(
                        onPressed: onSkipForward,
                        icon: Icon(
                          Directionality.of(context) == TextDirection.rtl
                              ? Icons.replay_10
                              : Icons.forward_10,
                          color: Colors.white,
                          size: 35.w,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: onToggleMute,
                    icon: Icon(
                      state.isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 26.w,
                    ),
                  ),
                  if (showFullScreenButton)
                    IconButton(
                      onPressed: onOpenFullscreen,
                      icon: Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 30.w,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!state.showControls && !state.isBuffering)
            Positioned.fill(
              child: GestureDetector(
                onTap: onToggleControls,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),
          if (state.isBuffering)
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
