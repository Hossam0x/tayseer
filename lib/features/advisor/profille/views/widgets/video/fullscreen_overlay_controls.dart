import 'package:tayseer/my_import.dart';

class FullscreenOverlayControls extends StatelessWidget {
  final bool showControls;
  final bool isEnded;
  final bool isDragging;
  final double? dragValue;
  final VideoPlayerController controller;
  final bool isLandscape;
  final bool isMuted;
  final VoidCallback onClose;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleOrientation;
  final VoidCallback onTogglePlay;
  final VoidCallback onReplay;
  final VoidCallback onSeekForward;
  final VoidCallback onSeekBackward;
  final VoidCallback onTap;
  final ValueChanged<double> onSliderChangeStart;
  final ValueChanged<double> onSliderChanged;
  final ValueChanged<double> onSliderChangeEnd;
  final Widget muteButton;

  const FullscreenOverlayControls({
    super.key,
    required this.showControls,
    required this.isEnded,
    required this.isDragging,
    required this.dragValue,
    required this.controller,
    required this.isLandscape,
    required this.isMuted,
    required this.onClose,
    required this.onToggleMute,
    required this.onToggleOrientation,
    required this.onTogglePlay,
    required this.onReplay,
    required this.onSeekForward,
    required this.onSeekBackward,
    required this.onTap,
    required this.onSliderChangeStart,
    required this.onSliderChanged,
    required this.onSliderChangeEnd,
    required this.muteButton,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0)
      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  @override
  Widget build(BuildContext context) {
    final duration = controller.value.duration;
    final position = controller.value.position;

    final double sliderValue = isDragging
        ? dragValue!
        : (duration.inMilliseconds > 0
              ? position.inMilliseconds / duration.inMilliseconds
              : 0.0);

    final displayPosition = isDragging
        ? Duration(milliseconds: (dragValue! * duration.inMilliseconds).toInt())
        : position;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: AnimatedOpacity(
        opacity: showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !showControls,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopBar(context),
                  _buildCenterControls(context),
                  _buildSeekBar(
                    context,
                    sliderValue,
                    displayPosition,
                    duration,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
          Row(
            children: [
              muteButton,
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: onToggleOrientation,
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    isLandscape
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls(BuildContext context) {
    if (isEnded) {
      return GestureDetector(
        onTap: onReplay,
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: const BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.replay, color: Colors.white, size: 32.sp),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onSeekBackward,
          child: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.forward_10
                : Icons.replay_10,
            color: Colors.white,
            size: 28.sp,
          ),
        ),
        SizedBox(width: 30.w),
        GestureDetector(
          onTap: onTogglePlay,
          child: Container(
            padding: EdgeInsets.all(10.r),
            decoration: const BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: Icon(
              controller.value.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 36.sp,
            ),
          ),
        ),
        SizedBox(width: 30.w),
        GestureDetector(
          onTap: onSeekForward,
          child: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.replay_10
                : Icons.forward_10,
            color: Colors.white,
            size: 28.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildSeekBar(
    BuildContext context,
    double sliderValue,
    Duration displayPosition,
    Duration duration,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Text(
            _formatDuration(displayPosition),
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3.h,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: isDragging ? 7.r : 5.r,
                ),
                overlayShape: RoundSliderOverlayShape(overlayRadius: 14.r),
                activeTrackColor: AppColors.kprimaryColor,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: AppColors.kprimaryColor,
                overlayColor: AppColors.kprimaryColor.withOpacity(0.2),
              ),
              child: Slider(
                value: sliderValue.clamp(0.0, 1.0),
                onChangeStart: onSliderChangeStart,
                onChanged: onSliderChanged,
                onChangeEnd: onSliderChangeEnd,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            _formatDuration(duration),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}
