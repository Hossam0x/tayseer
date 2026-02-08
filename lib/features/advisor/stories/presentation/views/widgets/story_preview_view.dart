import 'dart:math' as math;
import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/my_import.dart';
import 'package:video_player/video_player.dart';

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
  bool _isVideoInitialized = false;

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
        await _videoController!.setLooping(true);
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

  @override
  void dispose() {
    _videoController?.pause();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full screen preview (image or video)
        Positioned.fill(
          child: widget.isVideo
              ? (_isVideoInitialized
                    ? Transform(
                        alignment: Alignment.center,
                        transform: widget.isFrontCamera
                            ? Matrix4.rotationY(
                                math.pi,
                              ) // Mirror if front camera
                            : Matrix4.identity(),
                        child: VideoPlayer(_videoController!),
                      )
                    : Container(color: Colors.black))
              : Image.file(widget.file, fit: BoxFit.cover),
        ),

        // Loading indicator for video
        if (widget.isVideo && !_isVideoInitialized)
          const Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),

        // Close Button (Top Left)
        Positioned(
          top: 40.h,
          left: 16.w,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),

        // Publish Button (Bottom Right)
        Positioned(
          bottom: 40.h,
          right: 16.w,
          child: CustomBotton(
            width: 120.w,
            height: 45.h,
            title: context.tr('to_publish'),
            useGradient: true,
            onPressed: () async {
              final addStoryCubit = context.read<AddStoryCubit>();
              final storiesCubit = context.read<StoriesCubit>();

              final media = await addStoryCubit.getMediaToUpload();
              final content = addStoryCubit.contentController.text;

              if (context.mounted) {
                // Close the Add Story screen completely
                Navigator.of(context).pop();

                // Trigger upload in background
                storiesCubit.createStory(
                  content: content,
                  images: media.images,
                  videos: media.videos,
                );
              }
            },
          ),
        ),

        // Video controls indicator
        if (widget.isVideo && _isVideoInitialized)
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                    } else {
                      _videoController!.play();
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
