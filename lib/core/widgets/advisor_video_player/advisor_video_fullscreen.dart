import 'package:flutter/services.dart';
import 'package:tayseer/my_import.dart';

class AdvisorVideoFullscreenResult {
  final Duration position;
  final bool isMuted;
  final bool wasPlaying;
  AdvisorVideoFullscreenResult({
    required this.position,
    required this.isMuted,
    required this.wasPlaying,
  });
}

class AdvisorVideoFullscreen extends StatefulWidget {
  final String videoUrl;
  final Duration startPosition;
  final bool isMuted;
  final VideoPlayerController? controller;
  final bool wasPlaying; // ⭐ احترم حالة التشغيل عند الفتح

  const AdvisorVideoFullscreen({
    super.key,
    required this.videoUrl,
    required this.startPosition,
    this.isMuted = true,
    this.controller,
    this.wasPlaying = false,
  });

  @override
  State<AdvisorVideoFullscreen> createState() => _AdvisorVideoFullscreenState();
}

class _AdvisorVideoFullscreenState extends State<AdvisorVideoFullscreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isDragging = false;
  double? _dragValue;
  bool _isEnded = false;
  bool _isBuffering = false;
  bool _isLandscape = false;
  late bool _isMuted;

  @override
  void initState() {
    super.initState();
    _isMuted = widget.isMuted;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    if (widget.controller != null) {
      _controller = widget.controller;
      _isInitialized = true;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
      _controller!.addListener(_videoListener);
      // ⭐ العب بس لو كان شغال — لو كان pause يفضل pause
      if (widget.wasPlaying) {
        _controller!.play();
        _autoHideControls();
      }
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;
    final v = _controller!.value;
    final ended =
        v.isInitialized &&
        !v.isPlaying &&
        v.position >= v.duration &&
        v.duration != Duration.zero;

    setState(() {
      _isBuffering = v.isBuffering;
      if (ended && !_isEnded) {
        _isEnded = true;
        _showControls = true;
      } else if (!ended && _isEnded) {
        _isEnded = false;
      }
    });
  }

  void _autoHideControls() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && (_controller?.value.isPlaying ?? false) && !_isDragging) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls && (_controller?.value.isPlaying ?? false)) {
      _autoHideControls();
    }
  }

  void _togglePlay() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
      _autoHideControls();
    }
    setState(() {});
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller?.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _toggleOrientation() {
    setState(() => _isLandscape = !_isLandscape);
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  void _seekForward() {
    if (_controller == null) return;
    final pos = _controller!.value.position + const Duration(seconds: 10);
    final dur = _controller!.value.duration;
    _controller!.seekTo(pos < dur ? pos : dur);
  }

  void _seekBackward() {
    if (_controller == null) return;
    final pos = _controller!.value.position - const Duration(seconds: 10);
    _controller!.seekTo(pos > Duration.zero ? pos : Duration.zero);
  }

  void _onClose() {
    // ⭐ بس نرجع الـ mute state — الـ position والـ playing بيتحكم فيهم الـ controller مباشرة
    Navigator.pop(
      context,
      AdvisorVideoFullscreenResult(
        position: _controller?.value.position ?? Duration.zero,
        isMuted: _isMuted,
        wasPlaying: _controller?.value.isPlaying ?? false,
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller?.removeListener(_videoListener);
    // لا نعمل dispose — الـ cache يتحكم فيه
    super.dispose();
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? '${two(h)}:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onClose();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_isInitialized && _controller != null)
              GestureDetector(
                onTap: _toggleControls,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            if (!_isInitialized)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            if (_isInitialized && _isBuffering)
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
            if (_isInitialized && _controller != null) _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    final duration = _controller!.value.duration;
    final position = _controller!.value.position;
    final sliderVal = _isDragging
        ? _dragValue!
        : (duration.inMilliseconds > 0
              ? position.inMilliseconds / duration.inMilliseconds
              : 0.0);
    final displayPos = _isDragging
        ? Duration(
            milliseconds: (_dragValue! * duration.inMilliseconds).toInt(),
          )
        : position;

    return GestureDetector(
      onTap: _toggleControls,
      behavior: HitTestBehavior.translucent,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !_showControls,
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
                  // Top bar
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _onClose,
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
                            GestureDetector(
                              onTap: _toggleMute,
                              child: Container(
                                padding: EdgeInsets.all(6.r),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  _isMuted ? Icons.volume_off : Icons.volume_up,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            GestureDetector(
                              onTap: _toggleOrientation,
                              child: Container(
                                padding: EdgeInsets.all(6.r),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  _isLandscape
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
                  ),

                  // Center controls
                  _isEnded
                      ? GestureDetector(
                          onTap: () {
                            _controller!.seekTo(Duration.zero);
                            _controller!.play();
                            setState(() => _isEnded = false);
                          },
                          child: Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: const BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.replay,
                              color: Colors.white,
                              size: 32.sp,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _seekBackward,
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
                              onTap: _togglePlay,
                              child: Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _controller!.value.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 36.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 30.w),
                            GestureDetector(
                              onTap: _seekForward,
                              child: Icon(
                                Directionality.of(context) == TextDirection.rtl
                                    ? Icons.replay_10
                                    : Icons.forward_10,
                                color: Colors.white,
                                size: 28.sp,
                              ),
                            ),
                          ],
                        ),

                  // Seek bar
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    child: Row(
                      children: [
                        Text(
                          _fmt(displayPos),
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
                                enabledThumbRadius: _isDragging ? 7.r : 5.r,
                              ),
                              overlayShape: RoundSliderOverlayShape(
                                overlayRadius: 14.r,
                              ),
                              activeTrackColor: AppColors.kprimaryColor,
                              inactiveTrackColor: Colors.white.withOpacity(0.3),
                              thumbColor: AppColors.kprimaryColor,
                              overlayColor: AppColors.kprimaryColor.withOpacity(
                                0.2,
                              ),
                            ),
                            child: Slider(
                              value: sliderVal.clamp(0.0, 1.0),
                              onChangeStart: (v) => setState(() {
                                _isDragging = true;
                                _dragValue = v;
                              }),
                              onChanged: (v) => setState(() => _dragValue = v),
                              onChangeEnd: (v) {
                                final pos = Duration(
                                  milliseconds: (v * duration.inMilliseconds)
                                      .toInt(),
                                );
                                _controller!.seekTo(pos);
                                setState(() {
                                  _isDragging = false;
                                  _dragValue = null;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          _fmt(duration),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
