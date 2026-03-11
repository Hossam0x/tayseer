import 'package:path_provider/path_provider.dart';
import 'package:tayseer/core/widgets/custom_video_and_edit/add_post_video_editor_view.dart';
import 'package:tayseer/my_import.dart';

class ExistingVideoPreview extends StatefulWidget {
  final String videoUrl;
  final VoidCallback onRemove;
  // ✅ لو المستخدم عدل الفيديو هيرجع XFile بدل الـ URL
  final Function(XFile)? onVideoEdited;

  const ExistingVideoPreview({
    super.key,
    required this.videoUrl,
    required this.onRemove,
    this.onVideoEdited,
  });

  @override
  State<ExistingVideoPreview> createState() => _ExistingVideoPreviewState();
}

class _ExistingVideoPreviewState extends State<ExistingVideoPreview>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;

  late AnimationController _animationController;
  late Animation<double> _fadeScale;

  @override
  void initState() {
    super.initState();
    _initVideo();

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

  Future<void> _initVideo() async {
    try {
      // ✅ تحميل الفيديو من الـ URL
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _controller.initialize();
      _controller.addListener(_videoListener);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('ExistingVideoPreview init error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  void _videoListener() {
    if (mounted) {
      final isPlaying = _controller.value.isPlaying;
      if (isPlaying != _isPlaying) {
        setState(() => _isPlaying = isPlaying);
      }
    }
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
        builder: (_) => _FullScreenNetworkVideo(controller: _controller),
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _isPlaying = _controller.value.isPlaying);
      }
    });
  }

  // ✅ تحميل الفيديو محلياً ثم فتح الإديتور
  Future<void> _openVideoEditor() async {
    await _controller.pause();

    if (!mounted) return;

    // ✅ أولاً نحتاج نحمل الفيديو محلياً لأن الإديتور يحتاج File
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CustomloadingApp()),
    );

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final localPath = '${tempDir.path}/existing_video_$timestamp.mp4';

      // ✅ تحميل الفيديو من الـ URL وحفظه محلياً
      final response = await Dio().download(widget.videoUrl, localPath);

      if (mounted) Navigator.pop(context); // قفل اللودينج

      if (response.statusCode == 200) {
        final localFile = File(localPath);

        if (!mounted) return;

        // ✅ فتح الإديتور بالفيديو المحلي
        final editedFile = await Navigator.push<File>(
          context,
          MaterialPageRoute(
            builder: (_) => VideoEditorView(videoFile: localFile),
          ),
        );

        if (mounted && editedFile != null) {
          debugPrint('✏️ edited video: ${editedFile.path}');
          widget.onVideoEdited?.call(XFile(editedFile.path));
        }
      }
    } catch (e) {
      debugPrint('Download video error: $e');
      if (mounted) {
        Navigator.pop(context); // قفل اللودينج لو في خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            context,
            text: 'فشل تحميل الفيديو للتعديل',
            isError: true,
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeScale,
      child: ScaleTransition(
        scale: _fadeScale,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            height: context.height * 0.7,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.kBlueColor.withOpacity(.4)),
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ════════════════════════════════
                  // 🎬 Video Player
                  // ════════════════════════════════
                  if (_isLoading)
                    const Center(child: CustomloadingApp())
                  else if (_hasError)
                    const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                    )
                  else if (_isInitialized)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final videoSize = _controller.value.size;
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
                    ),

                  // ════════════════════════════════
                  // ▶️ Play / Pause
                  // ════════════════════════════════
                  if (_isInitialized)
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

                  // ════════════════════════════════
                  // ⛶ Fullscreen (TOP LEFT)
                  // ════════════════════════════════
                  if (_isInitialized)
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

                  // ════════════════════════════════
                  // ✏️ Edit Button
                  // ════════════════════════════════
                  if (_isInitialized)
                    Positioned(
                      top: 8,
                      right: 40,
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

                  // ════════════════════════════════
                  // ❌ Remove (TOP RIGHT)
                  // ════════════════════════════════
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
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// FullScreen Network Video
// ════════════════════════════════════════════════════════════
class _FullScreenNetworkVideo extends StatefulWidget {
  final VideoPlayerController controller;
  const _FullScreenNetworkVideo({required this.controller});

  @override
  State<_FullScreenNetworkVideo> createState() =>
      _FullScreenNetworkVideoState();
}

class _FullScreenNetworkVideoState extends State<_FullScreenNetworkVideo> {
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
      setState(() => _isPlaying = widget.controller.value.isPlaying);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => setState(() => _showControls = !_showControls),
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: widget.controller.value.aspectRatio,
                  child: VideoPlayer(widget.controller),
                ),
              ),
              if (_showControls)
                Center(
                  child: GestureDetector(
                    onTap: _togglePlay,
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
              if (_showControls)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: VideoProgressIndicator(
                    widget.controller,
                    allowScrubbing: true,
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
