import 'package:flutter/services.dart';
import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/my_import.dart';

class ProfileFullscreenResult {
  final Duration position;
  final bool isMuted; // ✅ أبقيناه للـ backward compatibility
  final bool wasPlaying;

  ProfileFullscreenResult({
    required this.position,
    required this.isMuted,
    required this.wasPlaying,
  });
}

class ProfileFullscreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final Duration startPosition;
  final bool? isMuted; // ✅ Optional - لو null يستخدم GlobalMuteManager
  final VideoPlayerController?
  controller; // ✅ Optional - reuse existing controller

  const ProfileFullscreenVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.startPosition,
    this.isMuted, // ✅ Optional parameter
    this.controller,
  });

  @override
  State<ProfileFullscreenVideoPlayer> createState() =>
      _ProfileFullscreenVideoPlayerState();
}

class _ProfileFullscreenVideoPlayerState
    extends State<ProfileFullscreenVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isDragging = false;
  double? _dragValue;
  bool _isEnded = false;
  bool _isBuffering = false;
  bool _isLandscape = false;

  final _videoCacheManager = VideoCacheManager();
  final _muteManager = GlobalMuteManager.instance;

  // ✅ Local mute state للـ legacy mode
  late bool _localIsMuted;

  // ✅ هل نستخدم الـ Global Mute ولا الـ Local؟
  bool get _useGlobalMute => widget.isMuted == null;

  // ✅ الـ Mute State الفعلي
  bool get _isMuted =>
      _useGlobalMute ? _muteManager.isMuted.value : _localIsMuted;

  @override
  void initState() {
    super.initState();

    // ✅ Initialize local mute state
    _localIsMuted = widget.isMuted ?? false;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // ✅ استمع لتغييرات الـ Global Mute فقط لو مش في legacy mode
    if (_useGlobalMute) {
      _muteManager.isMuted.addListener(_onGlobalMuteChanged);
    }

    if (widget.controller != null) {
      _controller = widget.controller;
      _isInitialized = true;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
      _controller!.addListener(_videoListener);
      _controller!.play();
      _autoHideControls();
    } else {
      _initializeVideo();
    }
  }

  void _onGlobalMuteChanged() {
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.setVolume(_muteManager.isMuted.value ? 0.0 : 1.0);
      if (mounted) setState(() {});
    }
  }

  Future<void> _initializeVideo() async {
    try {
      final cachedFile = await _videoCacheManager.getCachedFile(
        widget.videoUrl,
      );

      if (!mounted) return;

      if (cachedFile != null) {
        _controller = VideoPlayerController.file(cachedFile);
      } else {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: false,
            allowBackgroundPlayback: false,
          ),
        );
      }

      await _controller!.initialize();

      // ✅ استخدم الـ Mute State المناسب
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
      _controller!.addListener(_videoListener);

      await _controller!.seekTo(widget.startPosition);
      _controller!.play();

      if (mounted) {
        setState(() => _isInitialized = true);
        _autoHideControls();
      }
    } catch (e) {
      debugPrint("❌ Error initializing fullscreen video: $e");
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;

    final value = _controller!.value;

    if (value.isBuffering != _isBuffering) {
      setState(() => _isBuffering = value.isBuffering);
    }

    if (value.isInitialized &&
        !value.isPlaying &&
        value.position >= value.duration &&
        value.duration != Duration.zero) {
      if (!_isEnded) {
        setState(() {
          _isEnded = true;
          _showControls = true;
        });
      }
    } else {
      if (_isEnded && value.position < value.duration) {
        setState(() => _isEnded = false);
      }
    }

    if (!_isDragging && _showControls && !_isEnded) {
      setState(() {});
    }
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

  // ✅ Toggle Mute - يشتغل بالنظامين
  void _toggleMute() {
    if (_useGlobalMute) {
      // ✅ Global Mode: يأثر على كل الفيديوهات
      _muteManager.toggleMute();
    } else {
      // ✅ Legacy Mode: يأثر على هذا الفيديو فقط
      setState(() {
        _localIsMuted = !_localIsMuted;
        _controller?.setVolume(_localIsMuted ? 0.0 : 1.0);
      });
    }
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
    });

    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  void _replayVideo() {
    _controller?.seekTo(Duration.zero);
    _controller?.play();
    setState(() {
      _isEnded = false;
      _showControls = false;
    });
  }

  void _seekForward() {
    if (_controller == null) return;
    final pos = _controller!.value.position;
    final dur = _controller!.value.duration;
    final newPos = pos + const Duration(seconds: 10);
    _controller!.seekTo(newPos < dur ? newPos : dur);
  }

  void _seekBackward() {
    if (_controller == null) return;
    final pos = _controller!.value.position;
    final newPos = pos - const Duration(seconds: 10);
    _controller!.seekTo(newPos > Duration.zero ? newPos : Duration.zero);
  }

  void _onClosePage() {
    final result = ProfileFullscreenResult(
      position: _controller?.value.position ?? Duration.zero,
      isMuted: _isMuted, // ✅ يرجع الـ Mute State الحالي
      wasPlaying: _controller?.value.isPlaying ?? false,
    );
    Navigator.pop(context, result);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (_useGlobalMute) {
      _muteManager.isMuted.removeListener(_onGlobalMuteChanged);
    }

    _controller?.removeListener(_videoListener);

    // ✅ Dispose only if we created the controller internally
    if (widget.controller == null) {
      _controller?.dispose();
    }
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onClosePage();
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
                  child: Hero(
                    tag: 'video_${widget.videoUrl}',
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
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
            if (_isInitialized && _controller != null) _buildOverlayControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayControls() {
    final duration = _controller!.value.duration;
    final position = _controller!.value.position;

    final double sliderValue = _isDragging
        ? _dragValue!
        : (duration.inMilliseconds > 0
              ? position.inMilliseconds / duration.inMilliseconds
              : 0.0);

    final displayPosition = _isDragging
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
                  // Top Bar
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: _onClosePage,
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
                        // Mute + Orientation buttons
                        Row(
                          children: [
                            // ✅ زرار الـ Mute - يشتغل بالنظامين
                            _buildMuteButton(),
                            SizedBox(width: 12.w),
                            // Orientation button
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

                  // Center Controls
                  _isEnded
                      ? GestureDetector(
                          onTap: _replayVideo,
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

                  // Seek Bar
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
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
                              value: sliderValue.clamp(0.0, 1.0),
                              onChangeStart: (value) {
                                setState(() {
                                  _isDragging = true;
                                  _dragValue = value;
                                });
                              },
                              onChanged: (value) {
                                setState(() => _dragValue = value);
                              },
                              onChangeEnd: (value) {
                                final newPosition = Duration(
                                  milliseconds:
                                      (value * duration.inMilliseconds).toInt(),
                                );
                                _controller!.seekTo(newPosition);
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
                          _formatDuration(duration),
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

  // ✅ زرار الـ Mute - يشتغل بالنظامين
  Widget _buildMuteButton() {
    if (_useGlobalMute) {
      // ✅ Global Mode: يستخدم ValueListenableBuilder
      return ValueListenableBuilder<bool>(
        valueListenable: _muteManager.isMuted,
        builder: (context, isMuted, child) {
          return _muteButtonUI(isMuted);
        },
      );
    } else {
      // ✅ Legacy Mode: يستخدم الـ local state
      return _muteButtonUI(_localIsMuted);
    }
  }

  Widget _muteButtonUI(bool isMuted) {
    return GestureDetector(
      onTap: _toggleMute,
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          isMuted ? Icons.volume_off : Icons.volume_up,
          color: Colors.white,
          size: 20.sp,
        ),
      ),
    );
  }
}
