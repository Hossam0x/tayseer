import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:video_player/video_player.dart';

class StoryPreviewView extends StatefulWidget {
  final File file;
  final VoidCallback onClose;
  const StoryPreviewView({
    super.key,
    required this.file,
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
    final isVideo = context.read<AddStoryCubit>().state.isVideoPreview;
    if (isVideo) {
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
    return BlocBuilder<AddStoryCubit, AddStoryState>(
      builder: (context, state) {
        return Stack(
          children: [
            // Full screen preview (image or video)
            Positioned.fill(
              child: state.isVideoPreview
                  ? (_isVideoInitialized
                        ? VideoPlayer(_videoController!)
                        : Container(
                            color: Colors.black,
                          )) // Show black while loading video
                  : Image.file(widget.file, fit: BoxFit.cover),
            ),

            // Loading indicator for video
            if (state.isVideoPreview && !_isVideoInitialized)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

            // Header with Publish and Back button
            Positioned(
              top: 40.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  CustomBotton(
                    width: 100.w,
                    height: 40.h,
                    title: context.tr('to_publish'),
                    useGradient: true,
                    onPressed: () =>
                        context.read<AddStoryCubit>().createStory(),
                  ),
                ],
              ),
            ),

            // Video controls indicator
            if (state.isVideoPreview && _isVideoInitialized)
              Positioned(
                bottom: 100.h,
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
      },
    );
  }
}
