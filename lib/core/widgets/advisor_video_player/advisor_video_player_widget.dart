import 'dart:async';
import 'package:tayseer/core/utils/advisor_video_cache.dart';
import 'package:tayseer/core/utils/advisor_video_event_bus.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/my_import.dart';
import 'advisor_video_fullscreen.dart';

/// Widget مشترك لعرض فيديو المستشار في ProfileView و EditPersonalDataView.
/// يستخدم AdvisorVideoCache للـ shared controller وAdvisorVideoEventBus
/// للمزامنة لما يتغير الـ URL.
class AdvisorVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool showFullScreenButton;

  const AdvisorVideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.showFullScreenButton = true,
  });

  @override
  State<AdvisorVideoPlayerWidget> createState() =>
      _AdvisorVideoPlayerWidgetState();
}

class _AdvisorVideoPlayerWidgetState extends State<AdvisorVideoPlayerWidget> {
  final _cache = AdvisorVideoCache.instance;

  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isPlaying = false;
  bool _isMuted = true;
  bool _showControls = true;
  bool _isBuffering = false;
  bool _isEnded = false;

  String _activeUrl = '';
  StreamSubscription<AdvisorVideoUpdatedEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _activeUrl = widget.videoUrl;
    _initVideo(_activeUrl);

    // استمع لأي تحديث للـ URL من EditPersonalDataView
    _eventSub = AdvisorVideoEventBus.instance.onVideoUpdated.listen((event) {
      if (!mounted) return;
      if (event.videoUrl != _activeUrl) {
        setState(() {
          _activeUrl = event.videoUrl;
          _isInitialized = false;
          _isLoading = true;
          _hasError = false;
          _isPlaying = false;
          _isEnded = false;
        });
        _initVideo(_activeUrl);
      }
    });

    VideoManager.instance.currentlyPlayingPostId.addListener(_onManagerChange);
  }

  void _onManagerChange() {
    if (!mounted || _controller == null) return;
    final active = VideoManager.instance.currentlyPlayingPostId.value;
    if (active != _activeUrl && _controller!.value.isPlaying) {
      _controller!.pause();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  Future<void> _initVideo(String url) async {
    if (url.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final ctrl = await _cache.getOrInit(
      url,
      onReady: () {
        if (!mounted) return;
        // استخدم postFrameCallback لتجنب setState أثناء الـ build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _controller = _cache.controller;
          _controller?.addListener(_videoListener);
          setState(() {
            _isInitialized = true;
            _isLoading = false;
            _isMuted = (_controller?.value.volume ?? 0) == 0;
          });
        });
      },
    );

    if (ctrl == null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      });
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;
    final v = _controller!.value;

    final ended =
        v.isInitialized &&
        !v.isPlaying &&
        v.position >= v.duration - const Duration(milliseconds: 500) &&
        v.duration != Duration.zero;

    // postFrameCallback لتجنب setState أثناء الـ build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _isBuffering = v.isBuffering;
        _isPlaying = v.isPlaying;
        if (ended && !_isEnded) {
          _isEnded = true;
          _showControls = true;
        } else if (!ended && _isEnded) {
          _isEnded = false;
        }
      });
    });
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      setState(() => _isPlaying = false);
    } else {
      VideoManager.instance.playVideo(_activeUrl);
      _controller!.play();
      setState(() => _isPlaying = true);
      _autoHideControls();
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls && _isPlaying) _autoHideControls();
  }

  void _autoHideControls() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying && _showControls) {
        setState(() => _showControls = false);
      }
    });
  }

  void _skipBackward() {
    if (_controller == null) return;
    final pos = _controller!.value.position - const Duration(seconds: 10);
    _controller!.seekTo(pos.isNegative ? Duration.zero : pos);
  }

  void _skipForward() {
    if (_controller == null) return;
    final pos = _controller!.value.position + const Duration(seconds: 10);
    final dur = _controller!.value.duration;
    _controller!.seekTo(pos > dur ? dur : pos);
  }

  Future<void> _openFullscreen() async {
    if (_controller == null || !_isInitialized) return;

    final wasPlaying = _controller!.value.isPlaying;

    final result = await Navigator.push<AdvisorVideoFullscreenResult>(
      context,
      // بدون animation عشان مفيش lag ومفيش Hero conflict
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => AdvisorVideoFullscreen(
          videoUrl: _activeUrl,
          startPosition: _controller!.value.position,
          isMuted: _isMuted,
          controller: _controller,
          wasPlaying: wasPlaying,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    );

    if (!mounted) return;
    if (result != null) {
      _controller!.setVolume(result.isMuted ? 0.0 : 1.0);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted)
          setState(() {
            _isMuted = result.isMuted;
            _isPlaying = result.wasPlaying;
          });
      });
    }
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    VideoManager.instance.currentlyPlayingPostId.removeListener(
      _onManagerChange,
    );
    _controller?.removeListener(_videoListener);
    // لا نعمل dispose للـ controller — الـ cache يتحكم فيه
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('advisor_video_$_activeUrl'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0.0 && _isPlaying) {
          _controller?.pause();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isPlaying = false);
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: _isLoading
              ? _buildLoading()
              : _hasError || !_isInitialized || _controller == null
              ? _buildError()
              : _buildPlayer(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 300.h,
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      height: 300.h,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 40.w),
            SizedBox(height: 10.h),
            Text(
              'فشل تحميل الفيديو',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _initVideo(_activeUrl);
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    final size = _controller!.value.size;
    final aspectRatio = size.width > 0 && size.height > 0
        ? size.width / size.height
        : 16 / 9;

    return SizedBox(
      width: double.infinity,
      height: 300.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),

          // Controls overlay
          if (_showControls)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleControls,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _skipBackward,
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
                        onPressed: _togglePlayPause,
                        icon: Icon(
                          _isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: Colors.white,
                          size: 45.w,
                        ),
                      ),
                      Gap(16.w),
                      IconButton(
                        onPressed: _skipForward,
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

          // Bottom bar (mute + fullscreen)
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
                    onPressed: () {
                      final muted = !_isMuted;
                      _controller!.setVolume(muted ? 0.0 : 1.0);
                      setState(() => _isMuted = muted);
                    },
                    icon: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 26.w,
                    ),
                  ),
                  if (widget.showFullScreenButton)
                    IconButton(
                      onPressed: _openFullscreen,
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

          // Tap to show/hide controls
          if (!_showControls && !_isBuffering)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleControls,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),

          // Buffering
          if (_isBuffering)
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

          // Ended — replay
          if (_isEnded)
            Center(
              child: GestureDetector(
                onTap: () {
                  _controller!.seekTo(Duration.zero);
                  _controller!.play();
                  setState(() {
                    _isEnded = false;
                    _isPlaying = true;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.replay, color: Colors.white, size: 32.sp),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
