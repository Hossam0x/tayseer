import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';
import 'package:video_player/video_player.dart';

/// ✅ Lazy video widget — لا يشغّل ExoPlayer إلا لما المستخدم يضغط
/// هذا يحل مشكلة "Failed to allocate buffers" على أجهزة Huawei
/// لأن كل فيديو في القائمة كان يفتح ExoPlayer instance منفصل
class VideoMessageWidget extends StatefulWidget {
  final String videoUrl;
  final double maxWidth;
  final bool isLocal;

  const VideoMessageWidget({
    super.key,
    required this.videoUrl,
    required this.maxWidth,
    this.isLocal = false,
  });

  @override
  State<VideoMessageWidget> createState() => _VideoMessageWidgetState();
}

class _VideoMessageWidgetState extends State<VideoMessageWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _hasError = false;
  bool _isLoading = false; // ✅ يتحول true فقط لما المستخدم يضغط

  final _videoCacheManager = VideoCacheManager();

  @override
  void didUpdateWidget(VideoMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ لو الـ URL اتغيّر (من local path لـ server URL)، أعد تهيئة الـ player
    // بس لو كان شغّال بالفعل
    if ((oldWidget.videoUrl != widget.videoUrl ||
            oldWidget.isLocal != widget.isLocal) &&
        _isInitialized) {
      _disposeController();
      setState(() {
        _isInitialized = false;
        _isPlaying = false;
        _hasError = false;
        _isLoading = false;
      });
    }
  }

  void _disposeController() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _isLoading = false; // ✅ منع أي async operation من الاكتمال بعد dispose
    _disposeController();
    super.dispose();
  }

  /// ✅ يُستدعى فقط لما المستخدم يضغط على الفيديو
  Future<void> _initializeAndPlay() async {
    if (_isLoading || _isInitialized) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      debugPrint('📹 [DEBUG] Platform: Android=${Platform.isAndroid}, iOS=${Platform.isIOS}');
      debugPrint('📹 [DEBUG] Starting video initialization: ${widget.videoUrl}');

      if (widget.isLocal) {
        debugPrint('📹 Using local video: ${widget.videoUrl}');
        _controller = VideoPlayerController.file(
          File(widget.videoUrl),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      } else {
        // ✅ على Android نستخدم network URL مباشرة بدون cache
        // لأن Huawei Kirin codec (OMX.hisi) بيفشل مع cached files
        // بسبب مشكلة buffer allocation في SynchronousMediaCodecAdapter
        if (Platform.isAndroid) {
          debugPrint('📹 Android: Loading video from network directly: ${widget.videoUrl}');
          try {
            final uri = Uri.parse(widget.videoUrl);
            debugPrint('📹 [DEBUG] Parsed URI: $uri');
            _controller = VideoPlayerController.networkUrl(
              uri,
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
            );
            debugPrint('📹 [DEBUG] Controller created successfully');
          } catch (e) {
            debugPrint('❌ [DEBUG] Error creating controller: $e');
            rethrow;
          }
        } else {
          final cachedFile = await _videoCacheManager.getCachedFile(
            widget.videoUrl,
          );

          if (!mounted) return;

          if (cachedFile != null) {
            debugPrint('📹 iOS: Using cached video: ${widget.videoUrl}');
            _controller = VideoPlayerController.file(
              cachedFile,
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
            );
          } else {
            debugPrint('📹 iOS: Loading video from network: ${widget.videoUrl}');
            _controller = VideoPlayerController.networkUrl(
              Uri.parse(widget.videoUrl),
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
            );
            _videoCacheManager.preloadVideoInBackground(widget.videoUrl);
          }
        }
      }

      debugPrint('📹 [DEBUG] Initializing controller...');
      await _controller!.initialize();
      debugPrint('📹 [DEBUG] Controller initialized successfully');

      if (!mounted) {
        debugPrint('📹 [DEBUG] Widget not mounted after initialize, disposing');
        _disposeController();
        return;
      }

      debugPrint('📹 [DEBUG] Starting playback...');
      await _controller!.play();
      debugPrint('📹 [DEBUG] Playback started');

      setState(() {
        _isInitialized = true;
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing video: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _togglePlay() {
    if (_controller == null) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  Future<void> _openFullScreenVideo() async {
    if (!_isInitialized || _controller == null) return;

    final currentPosition = _controller!.value.position;
    final wasPlaying = _controller!.value.isPlaying;

    _controller!.pause();
    setState(() => _isPlaying = false);

    final result = await Navigator.of(context).push<FullScreenResult>(
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(
          videoUrl: widget.videoUrl,
          isLocal: widget.isLocal,
          startPosition: currentPosition,
          wasPlaying: wasPlaying,
        ),
      ),
    );

    if (result != null && mounted && _controller != null) {
      await _controller!.seekTo(result.position);
      if (result.wasPlaying) {
        _controller!.play();
        setState(() => _isPlaying = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ حالة الخطأ
    if (_hasError) {
      return Container(
        width: widget.maxWidth,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(ChatDimensions.bubbleRadiusSmall),
        ),
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.red, size: 40),
        ),
      );
    }

    // ✅ حالة التحميل (بعد الضغط)
    if (_isLoading) {
      return Container(
        width: widget.maxWidth,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(ChatDimensions.bubbleRadiusSmall),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // ✅ حالة الـ player شغّال
    if (_isInitialized && _controller != null) {
      final aspectRatio = _controller!.value.aspectRatio;
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
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
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

    // ✅ الحالة الافتراضية: placeholder بدون ExoPlayer
    // المستخدم يضغط عشان يشغّل
    return GestureDetector(
      onTap: _initializeAndPlay,
      child: Container(
        width: widget.maxWidth,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(ChatDimensions.bubbleRadiusSmall),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // أيقونة الفيديو في الخلفية
            Icon(
              Icons.videocam,
              color: Colors.white.withOpacity(0.2),
              size: 60,
            ),
            // زر التشغيل
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Result returned from fullscreen video player
class FullScreenResult {
  final Duration position;
  final bool wasPlaying;

  FullScreenResult({required this.position, required this.wasPlaying});
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool isLocal;
  final Duration startPosition;
  final bool wasPlaying;

  const FullScreenVideoPlayer({
    super.key,
    required this.videoUrl,
    this.isLocal = false,
    this.startPosition = Duration.zero,
    this.wasPlaying = false,
  });

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = true;

  final _videoCacheManager = VideoCacheManager();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      if (widget.isLocal) {
        debugPrint('📹 FullScreen: Using local video');
        _controller = VideoPlayerController.file(
          File(widget.videoUrl),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      } else {
        // ✅ على Android نستخدم network URL مباشرة — Huawei Kirin codec issue
        if (Platform.isAndroid) {
          debugPrint('📹 FullScreen Android: Loading from network directly');
          _controller = VideoPlayerController.networkUrl(
            Uri.parse(widget.videoUrl),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );
        } else {
          final cachedFile = await _videoCacheManager.getCachedFile(
            widget.videoUrl,
          );

          if (!mounted) return;

          if (cachedFile != null) {
            debugPrint('📹 FullScreen iOS: Using cached video');
            _controller = VideoPlayerController.file(
              cachedFile,
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
            );
          } else {
            debugPrint('📹 FullScreen iOS: Loading video from network');
            _controller = VideoPlayerController.networkUrl(
              Uri.parse(widget.videoUrl),
              videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
            );
          }
        }
      }

      await _controller!.initialize();

      if (mounted) {
        await _controller!.seekTo(widget.startPosition);
        _controller!.play();

        setState(() {
          _isInitialized = true;
          _isPlaying = true;
        });
      }

      _controller!.addListener(_videoListener);
    } catch (e) {
      debugPrint('❌ Error initializing fullscreen video: $e');
    }
  }

  void _videoListener() {
    if (mounted && _controller != null) {
      setState(() {
        _isPlaying = _controller!.value.isPlaying;
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller == null) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _exitFullscreen() {
    final result = FullScreenResult(
      position: _controller?.value.position ?? Duration.zero,
      wasPlaying: _isPlaying,
    );
    Navigator.of(context).pop(result);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _exitFullscreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _showControls
            ? AppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _exitFullscreen,
                ),
              )
            : null,
        body: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isInitialized && _controller != null)
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
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
              if (_showControls && _isInitialized && _controller != null)
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
                          _controller!,
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
                              valueListenable: _controller!,
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
                              _formatDuration(_controller!.value.duration),
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
      ),
    );
  }
}
