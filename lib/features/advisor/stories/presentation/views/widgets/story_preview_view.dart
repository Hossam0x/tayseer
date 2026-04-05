import 'dart:async';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/my_import.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class StoryPreviewView extends StatefulWidget {
  final File file;
  final bool isVideo;
  final bool isFrontCamera;
  final VoidCallback onClose;

  const StoryPreviewView({
    super.key,
    required this.file,
    required this.isVideo,
    this.isFrontCamera = false,
    required this.onClose,
  });

  @override
  State<StoryPreviewView> createState() => _StoryPreviewViewState();
}

class _StoryPreviewViewState extends State<StoryPreviewView> {
  VideoPlayerController? _videoController;
  ProVideoController? _proVideoController;
  TrimDurationSpan? _durationSpan;
  TrimDurationSpan? _tempDurationSpan;
  bool _isVideoInitialized = false;
  bool _isSeeking = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (widget.isVideo) {
      try {
        _videoController = VideoPlayerController.file(widget.file);
        await _videoController!.initialize();
        await _videoController!.setLooping(false);
        await _videoController!.setVolume(100);

        _proVideoController = ProVideoController(
          videoPlayer: Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.size.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
          initialResolution: _videoController!.value.size,
          videoDuration: _videoController!.value.duration,
          fileSize: widget.file.lengthSync(),
        );

        _videoController!.addListener(_onDurationChange);
        await _videoController!.play();

        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      } catch (e) {
        debugPrint('Error initializing video: $e');
        if (mounted) {
          setState(() {
            _isVideoInitialized = false;
          });
        }
      }
    }
  }

  void _onDurationChange() {
    if (_videoController == null || _proVideoController == null) return;
    var duration = _videoController!.value.position;
    _proVideoController!.playTimeNotifier.value = duration;

    final totalVideoDuration = _videoController!.value.duration;
    if (_durationSpan != null && duration >= _durationSpan!.end) {
      _seekToPosition(_durationSpan!);
    } else if (duration >= totalVideoDuration) {
      _seekToPosition(
        TrimDurationSpan(start: Duration.zero, end: totalVideoDuration),
      );
    }
  }

  Future<void> _seekToPosition(TrimDurationSpan span) async {
    _durationSpan = span;

    if (_isSeeking) {
      _tempDurationSpan = span;
      return;
    }
    _isSeeking = true;

    _proVideoController?.isPlayingNotifier.value = false;
    _proVideoController?.playTimeNotifier.value = span.start;

    await _videoController?.pause();
    await _videoController?.seekTo(span.start);

    _isSeeking = false;

    if (_tempDurationSpan != null) {
      TrimDurationSpan nextSeek = _tempDurationSpan!;
      _tempDurationSpan = null;
      await _seekToPosition(nextSeek);
    }
  }

  @override
  void dispose() {
    _videoController?.pause();
    _videoController?.removeListener(_onDurationChange);
    _videoController?.dispose();
    super.dispose();
  }

  // ✅ Called when DONE is pressed for IMAGE stories
  Future<void> _onImageEditingComplete(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/edited_story_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(bytes);

    if (mounted) {
      _publishStory(imageFile: file);
    }
  }

  // ✅ Called when DONE is pressed for VIDEO stories - receives full export parameters
  Future<void> _onVideoEditingComplete(CompleteParameters parameters) async {
    if (!mounted) return;

    // Show loading while rendering video (this can take time)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CustomloadingApp(),
    );

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${tempDir.path}/edited_story_$timestamp.mp4';

      Uint8List? overlayImage = parameters.layers.isNotEmpty
          ? parameters.image
          : null;
      if (widget.isFrontCamera && overlayImage != null) {
        final decodedOverlay = img.decodeImage(overlayImage);
        if (decodedOverlay != null) {
          final flippedOverlay = img.flipHorizontal(decodedOverlay);
          overlayImage = Uint8List.fromList(img.encodePng(flippedOverlay));
        }
      }

      final renderModel = VideoRenderData(
        video: EditorVideo.file(widget.file.path),
        outputFormat: VideoOutputFormat.mp4,
        enableAudio: !_isMuted,
        // Apply overlay image (stickers, text, drawings rendered on top of video)
        imageBytes: overlayImage,
        // Apply blur if any
        blur: parameters.blur,
        // Apply color filters if any
        colorMatrixList: parameters.colorFilters,
        // Apply crop/rotate/flip transforms
        transform: parameters.isTransformed
            ? ExportTransform(
                width: parameters.cropWidth,
                height: parameters.cropHeight,
                rotateTurns: parameters.rotateTurns,
                x: parameters.cropX,
                y: parameters.cropY,
                flipX: parameters.flipX || widget.isFrontCamera,
                flipY: parameters.flipY,
              )
            : (widget.isFrontCamera
                  ? const ExportTransform(flipX: true)
                  : null),
        // Apply trim if any
        startTime: parameters.startTime,
        endTime: parameters.endTime,
      );

      final renderedPath = await ProVideoEditor.instance.renderVideoToFile(
        outputPath,
        renderModel,
      );

      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        _publishStory(videoFile: File(renderedPath));
      }
    } catch (e) {
      debugPrint('Video render error: $e');
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        // Fallback to original file if rendering fails
        _publishStory(videoFile: widget.file);
      }
    }
  }

  Future<bool> _handleCloseWarning() async {
    final completer = Completer<bool>();
    CustomshowDialogWithImage(
      context,
      title: context.tr('story_unsaved_changes_title'),
      supTitle: context.tr('story_unsaved_changes_message'),
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.white,
      iconBackgroundColor: AppColors.kprimaryColor,
      bottonText: context.tr('story_discard_and_exit'),
      showCancelButton: true,
      cancelText: context.tr('story_keep_editing'),
      onPressed: () {
        if (!completer.isCompleted) completer.complete(true);
      },
      onCancel: () {
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    return completer.future;
  }

  void _publishStory({File? imageFile, File? videoFile}) {
    final storiesCubit = context.read<StoriesCubit>();

    double? videoDuration;
    if (videoFile != null && _videoController != null) {
      final Duration duration = _durationSpan != null
          ? (_durationSpan!.end - _durationSpan!.start)
          : _videoController!.value.duration;
      videoDuration = duration.inMilliseconds / 1000.0;
    }

    // Close the Add Story screen completely
    Navigator.of(context).pop();

    // Trigger upload in background
    storiesCubit.createStory(
      images: imageFile != null ? [imageFile] : null,
      videos: videoFile != null ? [XFile(videoFile.path)] : null,
      videoDuration: videoDuration,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final callbacks = ProImageEditorCallbacks(
      // For images: called with just bytes
      onImageEditingComplete: widget.isVideo ? null : _onImageEditingComplete,
      // For videos: called with full parameters including layers, transforms, blur, etc.
      onCompleteWithParameters: widget.isVideo ? _onVideoEditingComplete : null,
      onCloseEditor: (mode) => widget.onClose(),
      videoEditorCallbacks: widget.isVideo && _videoController != null
          ? VideoEditorCallbacks(
              onPause: _videoController!.pause,
              onPlay: _videoController!.play,
              onMuteToggle: (isMuted) {
                _isMuted = isMuted;
                _videoController!.setVolume(isMuted ? 0 : 100);
              },
              onTrimSpanUpdate: (span) {
                if (_videoController!.value.isPlaying) {
                  _proVideoController?.isPlayingNotifier.value = false;
                  _videoController!.pause();
                }
              },
              onTrimSpanEnd: _seekToPosition,
            )
          : null,
    );

    final configs = ProImageEditorConfigs(
      i18n: I18n(done: context.tr('to_publish')),
      designMode: ImageEditorDesignMode.material,
      imageGeneration: const ImageGenerationConfigs(),
      mainEditor: MainEditorConfigs(
        enableZoom: true,
        widgets: MainEditorWidgets(
          closeWarningDialog: (editor) async {
            return await _handleCloseWarning();
          },
          appBar: (editor, rebuildStream) => ReactiveAppbar(
            stream: rebuildStream,
            builder: (_) => AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => editor.closeEditor(),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  child: CustomBotton(
                    width: 100.w,
                    height: 35.h,
                    title: context.tr('to_publish'),
                    useGradient: true,
                    titleColor: Colors.white,
                    onPressed: () => editor.doneEditing(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.isVideo) {
      if (!_isVideoInitialized || _proVideoController == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return ProImageEditor.video(
        _proVideoController!,
        callbacks: callbacks,
        configs: configs,
      ).animate().fadeIn(duration: 400.ms);
    }

    return ProImageEditor.file(
      widget.file,
      callbacks: callbacks,
      configs: configs,
    ).animate().fadeIn(duration: 400.ms);
  }
}
