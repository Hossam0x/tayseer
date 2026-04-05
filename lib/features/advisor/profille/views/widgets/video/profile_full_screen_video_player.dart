import 'package:flutter/services.dart';
import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/my_import.dart';
import 'fullscreen_overlay_controls.dart';

class ProfileFullscreenResult {
  final Duration position;
  final bool isMuted;
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
  final bool? isMuted;
  final VideoPlayerController? controller;

  const ProfileFullscreenVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.startPosition,
    this.isMuted,
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
  late bool _localIsMuted;

  bool get _useGlobalMute => widget.isMuted == null;
  bool get _isMuted =>
      _useGlobalMute ? _muteManager.isMuted.value : _localIsMuted;

  @override
  void initState() {
    super.initState();
    _localIsMuted = widget.isMuted ?? false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    if (_useGlobalMute) _muteManager.isMuted.addListener(_onGlobalMuteChanged);

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

      _controller = cachedFile != null
          ? VideoPlayerController.file(cachedFile)
          : VideoPlayerController.networkUrl(
              Uri.parse(widget.videoUrl),
              videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: false,
                allowBackgroundPlayback: false,
              ),
            );

      await _controller!.initialize();
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

    if (value.isBuffering != _isBuffering)
      setState(() => _isBuffering = value.isBuffering);

    if (value.isInitialized &&
        !value.isPlaying &&
        value.position >= value.duration &&
        value.duration != Duration.zero) {
      if (!_isEnded)
        setState(() {
          _isEnded = true;
          _showControls = true;
        });
    } else {
      if (_isEnded && value.position < value.duration)
        setState(() => _isEnded = false);
    }

    if (!_isDragging && _showControls && !_isEnded) setState(() {});
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
    if (_showControls && (_controller?.value.isPlaying ?? false))
      _autoHideControls();
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
    if (_useGlobalMute) {
      _muteManager.toggleMute();
    } else {
      setState(() {
        _localIsMuted = !_localIsMuted;
        _controller?.setVolume(_localIsMuted ? 0.0 : 1.0);
      });
    }
  }

  void _toggleOrientation() {
    setState(() => _isLandscape = !_isLandscape);
    SystemChrome.setPreferredOrientations(
      _isLandscape
          ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
          : [DeviceOrientation.portraitUp],
    );
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
    final newPos = _controller!.value.position + const Duration(seconds: 10);
    final dur = _controller!.value.duration;
    _controller!.seekTo(newPos < dur ? newPos : dur);
  }

  void _seekBackward() {
    if (_controller == null) return;
    final newPos = _controller!.value.position - const Duration(seconds: 10);
    _controller!.seekTo(newPos > Duration.zero ? newPos : Duration.zero);
  }

  void _onClosePage() {
    Navigator.pop(
      context,
      ProfileFullscreenResult(
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
    if (_useGlobalMute)
      _muteManager.isMuted.removeListener(_onGlobalMuteChanged);
    _controller?.removeListener(_videoListener);
    if (widget.controller == null) _controller?.dispose();
    super.dispose();
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
            if (_isInitialized && _controller != null)
              FullscreenOverlayControls(
                showControls: _showControls,
                isEnded: _isEnded,
                isDragging: _isDragging,
                dragValue: _dragValue,
                controller: _controller!,
                isLandscape: _isLandscape,
                isMuted: _isMuted,
                onClose: _onClosePage,
                onToggleMute: _toggleMute,
                onToggleOrientation: _toggleOrientation,
                onTogglePlay: _togglePlay,
                onReplay: _replayVideo,
                onSeekForward: _seekForward,
                onSeekBackward: _seekBackward,
                onTap: _toggleControls,
                onSliderChangeStart: (value) => setState(() {
                  _isDragging = true;
                  _dragValue = value;
                }),
                onSliderChanged: (value) => setState(() => _dragValue = value),
                onSliderChangeEnd: (value) {
                  final newPosition = Duration(
                    milliseconds:
                        (value * _controller!.value.duration.inMilliseconds)
                            .toInt(),
                  );
                  _controller!.seekTo(newPosition);
                  setState(() {
                    _isDragging = false;
                    _dragValue = null;
                  });
                },
                muteButton: _buildMuteButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuteButton() {
    if (_useGlobalMute) {
      return ValueListenableBuilder<bool>(
        valueListenable: _muteManager.isMuted,
        builder: (context, isMuted, _) => _muteButtonUI(isMuted),
      );
    }
    return _muteButtonUI(_localIsMuted);
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
