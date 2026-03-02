import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:tayseer/my_import.dart';

class VideoEditorView extends StatefulWidget {
  final File videoFile;

  const VideoEditorView({super.key, required this.videoFile});

  @override
  State<VideoEditorView> createState() => _VideoEditorViewState();
}

class _VideoEditorViewState extends State<VideoEditorView> {
  VideoPlayerController? _videoController;
  ProVideoController? _proVideoController;

  TrimDurationSpan? _durationSpan;
  TrimDurationSpan? _tempDurationSpan;

  bool _isVideoInitialized = false;
  bool _isSeeking = false;
  bool _editorPopped = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.file(widget.videoFile);
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
        fileSize: widget.videoFile.lengthSync(),
      );

      _videoController!.addListener(_onDurationChange);
      await _videoController!.play();

      if (mounted) {
        setState(() => _isVideoInitialized = true);
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() => _isVideoInitialized = false);
      }
    }
  }

  void _onDurationChange() {
    if (_videoController == null || _proVideoController == null) return;

    final duration = _videoController!.value.position;
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
      final nextSeek = _tempDurationSpan!;
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

  // ✅ نفس منطق الاستوري — Full render with parameters
  Future<void> _onVideoEditingComplete(CompleteParameters parameters) async {
    if (!mounted || _editorPopped) return;
    _editorPopped = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: const CustomloadingApp()),
    );

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${tempDir.path}/edited_post_$timestamp.mp4';

      final renderModel = VideoRenderData(
        video: EditorVideo.file(widget.videoFile.path),
        outputFormat: VideoOutputFormat.mp4,

        // ✅ layers (stickers / text / draw)
        imageBytes: parameters.layers.isNotEmpty ? parameters.image : null,

        // ✅ blur
        blur: parameters.blur,

        // ✅ filters
        colorMatrixList: parameters.colorFilters,

        // ✅ transform
        transform: parameters.isTransformed
            ? ExportTransform(
                width: parameters.cropWidth,
                height: parameters.cropHeight,
                rotateTurns: parameters.rotateTurns,
                x: parameters.cropX,
                y: parameters.cropY,
                flipX: parameters.flipX,
                flipY: parameters.flipY,
              )
            : null,

        // ✅ trim
        startTime: parameters.startTime,
        endTime: parameters.endTime,

        shouldOptimizeForNetworkUse: true,
      );

      final renderedPath = await ProVideoEditor.instance.renderVideoToFile(
        outputPath,
        renderModel,
      );

      if (mounted) {
        Navigator.pop(context); // dismiss loading
        Navigator.of(context).pop(File(renderedPath));
      }
    } catch (e) {
      debugPrint('Video render error: $e');
      if (mounted) {
        Navigator.pop(context);
        Navigator.of(context).pop(widget.videoFile);
      }
    }
  }

  Future<bool> _handleCloseWarning() async {
    final completer = Completer<bool>();

    CustomshowDialogWithImage(
      context,
      title: context.tr('unsaved_changes_title'),
      supTitle: context.tr('unsaved_changes_message'),
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.white,
      iconBackgroundColor: AppColors.kprimaryColor,
      bottonText: context.tr('discard_and_exit'),
      showCancelButton: true,
      cancelText: context.tr('keep_editing'),
      onPressed: () {
        if (!completer.isCompleted) completer.complete(true);
      },
      onCancel: () {
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVideoInitialized || _proVideoController == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final callbacks = ProImageEditorCallbacks(
      onImageEditingComplete: null,
      onCompleteWithParameters: _onVideoEditingComplete,
      onCloseEditor: (mode) {
        if (_editorPopped) return;
        _editorPopped = true;
        Navigator.of(context).pop();
      },
      videoEditorCallbacks: VideoEditorCallbacks(
        onPause: _videoController!.pause,
        onPlay: _videoController!.play,
        onMuteToggle: (isMuted) {
          _videoController!.setVolume(isMuted ? 0 : 100);
        },
        onTrimSpanUpdate: (span) {
          if (_videoController!.value.isPlaying) {
            _proVideoController?.isPlayingNotifier.value = false;
            _videoController!.pause();
          }
        },
        onTrimSpanEnd: _seekToPosition,
      ),
    );

    final configs = ProImageEditorConfigs(
      i18n: I18n(done: context.tr('done')),
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
                    title: context.tr('done'),
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

    return ProImageEditor.video(
      _proVideoController!,
      callbacks: callbacks,
      configs: configs,
    ).animate().fadeIn(duration: 400.ms);
  }
}
