import 'package:tayseer/core/widgets/custom_video_and_edit/add_post_video_editor_view.dart';
import 'package:tayseer/my_import.dart';

class CustomUploadedVideoPreview extends StatefulWidget {
  final XFile video;
  final VoidCallback onRemove;
  final VoidCallback onInitialized;
  final double height;
  final double width;
  final bool showEditButton; // ✅ بارامتر للتحكم في إظهار زرار التعديل
  final Function(XFile)? onVideoEdited; // ✅ Callback يرجع XFile

  const CustomUploadedVideoPreview({
    super.key,
    required this.video,
    required this.onRemove,
    required this.onInitialized,
    this.height = 0.25,
    this.width = 0.4,
    this.showEditButton = false, // ✅ افتراضياً مخفي
    this.onVideoEdited,
  });

  @override
  State<CustomUploadedVideoPreview> createState() =>
      _CustomUploadedVideoPreviewState();
}

class _CustomUploadedVideoPreviewState extends State<CustomUploadedVideoPreview>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;

  late AnimationController _animationController;
  late Animation<double> _fadeScale;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(File(widget.video.path))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          widget.onInitialized();
        }
      });

    // ✅ Listen للتغييرات في الـ controller
    _controller.addListener(_videoListener);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeScale = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _animationController.forward();
  }

  // ✅ Listener عشان يتابع حالة الفيديو
  void _videoListener() {
    if (mounted) {
      final isPlaying = _controller.value.isPlaying;
      if (isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = isPlaying;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.pause();
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_isInitialized) return;

    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _openFullScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenVideoPlayer(controller: _controller),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _isPlaying = _controller.value.isPlaying;
        });
      }
    });
  }

  // ✅ فتح شاشة التعديل
  void _openVideoEditor() async {
    // إيقاف الفيديو قبل فتح الإديتور
    await _controller.pause();

    if (!mounted) return;

    // فتح شاشة التعديل
    final editedFile = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) => VideoEditorView(videoFile: File(widget.video.path)),
      ),
    );

    // ✅ لما يرجع من الإديتور مباشرة لصفحة Add Post
    if (mounted && editedFile != null) {
      debugPrint('✏️ [Preview] editedFile returned: ${editedFile.path}');

      // حاول نحدث الـ controller محلياً عشان العرض يتغير فوراً
      try {
        _controller.removeListener(_videoListener);
        await _controller.pause();
        await _controller.dispose();

        _controller = VideoPlayerController.file(File(editedFile.path))
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _isInitialized = true;
              });
            }
          });
        _controller.addListener(_videoListener);
      } catch (e) {
        debugPrint('✏️ [Preview] failed to reinit controller: $e');
      }

      // نبعت الـ callback للـ cubit
      widget.onVideoEdited?.call(XFile(editedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeScale,
      child: ScaleTransition(
        scale: _fadeScale,
        child: Container(
          height: context.height * widget.height,
          width: context.width * widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.kBlueColor.withOpacity(.4)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                /// 🎬 Mini Video Player (fill parent container)
                _isInitialized
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          final videoSize = _controller.value.size;
                          // If controller reports zero size (rare), fallback to AspectRatio
                          if (videoSize.width == 0 || videoSize.height == 0) {
                            return AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            );
                          }

                          return SizedBox(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: videoSize.width,
                                height: videoSize.height,
                                child: VideoPlayer(_controller),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(color: Colors.black12),

                /// ▶️ Play / Pause (CENTER)
                GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),

                /// ⛶ Maximize (TOP LEFT)
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: _openFullScreen,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.fullscreen,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                /// ✏️ Edit Button (TOP RIGHT - قبل زرار الـ X)
                if (widget.showEditButton)
                  Positioned(
                    top: 8,
                    right: 40, // ✅ بعيد عن زرار الـ X
                    child: GestureDetector(
                      onTap: _openVideoEditor,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.edit,
                          size: 18,
                          color: AppColors.kprimaryColor,
                        ),
                      ),
                    ),
                  ),

                /// ❌ Remove (TOP RIGHT)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: widget.onRemove,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  const _FullScreenVideoPlayer({required this.controller});

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.controller.value.isPlaying;
    widget.controller.addListener(_listener);
  }

  void _listener() {
    if (mounted) {
      setState(() {
        _isPlaying = widget.controller.value.isPlaying;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  void _togglePlay() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: _toggleControls,
          child: Stack(
            children: [
              // 🎬 Video Player
              Center(
                child: AspectRatio(
                  aspectRatio: widget.controller.value.aspectRatio,
                  child: VideoPlayer(widget.controller),
                ),
              ),

              // ▶️ Play/Pause Button (CENTER)
              if (_showControls)
                Center(
                  child: GestureDetector(
                    onTap: _togglePlay,
                    child: AnimatedOpacity(
                      opacity: _showControls ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),

              // ← Back Button (TOP RIGHT)
              if (_showControls)
                Positioned(
                  top: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),

              // 🎚️ Video Progress Bar (BOTTOM)
              if (_showControls)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: VideoProgressIndicator(
                    widget.controller,
                    allowScrubbing: true, // ✅ يقدر يتحكم في الـ timeline
                    colors: const VideoProgressColors(
                      playedColor: Colors.white,
                      bufferedColor: Colors.white24,
                      backgroundColor: Colors.white10,
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

class UploadVideoWidget extends StatelessWidget {
  final VoidCallback onTap;

  const UploadVideoWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: context.height * 0.2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.kprimaryColor.withOpacity(.3)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppImage(AssetsData.kvideoIcon),
              const SizedBox(height: 8),
              Text(
                context.tr('upload_Video'),
                style: Styles.textStyle12.copyWith(
                  color: AppColors.kprimaryColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
