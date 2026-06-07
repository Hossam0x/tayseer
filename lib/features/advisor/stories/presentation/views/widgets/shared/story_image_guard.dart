import 'package:story_view/story_view.dart';
import 'package:tayseer/my_import.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StoryImageGuard — loads story images via CachedNetworkImage (disk + memory
// cache) and shows a spinning ring while loading, then fires onReady.
// ─────────────────────────────────────────────────────────────────────────────
class StoryImageGuard extends StatefulWidget {
  final String url;
  final StoryController storyController;
  final VoidCallback onReady;

  const StoryImageGuard({
    super.key,
    required this.url,
    required this.storyController,
    required this.onReady,
  });

  @override
  State<StoryImageGuard> createState() => _StoryImageGuardState();
}

class _StoryImageGuardState extends State<StoryImageGuard> {
  bool _readyFired = false;
  bool _disposed = false;

  // Guard: keep progress bar paused until image is ready.
  late final _guardSub = widget.storyController.playbackNotifier.listen((s) {
    if (_disposed || !mounted) return;
    if (s == PlaybackState.play && !_readyFired) {
      Future.microtask(() {
        if (!_disposed && mounted && !_readyFired) {
          widget.storyController.pause();
        }
      });
    }
  });

  @override
  void initState() {
    super.initState();
    widget.storyController.pause();
    // Start listening immediately
    _guardSub; // initialise the late field
  }

  @override
  void dispose() {
    _disposed = true;
    _guardSub.cancel();
    super.dispose();
  }

  void _onImageReady() {
    if (_readyFired || _disposed || !mounted) return;
    _readyFired = true;
    widget.storyController.play();
    widget.onReady();
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.url,
      fit: BoxFit.contain,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      imageBuilder: (_, imageProvider) {
        // Image is in memory — fire onReady on next frame
        WidgetsBinding.instance.addPostFrameCallback((_) => _onImageReady());
        return Image(image: imageProvider, fit: BoxFit.contain);
      },
      // Task 3.2: no loading shimmer — solid black placeholder while image loads
      progressIndicatorBuilder: (_, __, ___) =>
          const ColoredBox(color: Colors.black),
      errorWidget: (_, __, ___) {
        // Even on error, unblock the progress bar
        WidgetsBinding.instance.addPostFrameCallback((_) => _onImageReady());
        return const ColoredBox(color: Colors.black);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StoryLoadingRing — spinning ring identical to the upload ring in AddStoryItem
// ─────────────────────────────────────────────────────────────────────────────
class _StoryLoadingRing extends StatelessWidget {
  final double? value; // null = indeterminate (spinning), 0-1 = progress

  const _StoryLoadingRing({this.value});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: SizedBox(
          width: 52,
          height: 52,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: 2.5,
            color: Colors.white,
            backgroundColor: Colors.white24,
          ),
        ),
      ),
    );
  }
}

/// Public version used by StoryVideoMuted and story_page_widget as a
/// consistent loading placeholder across all story media types.
class StoryLoadingRing extends StatelessWidget {
  final double? value;

  const StoryLoadingRing({super.key, this.value});

  @override
  Widget build(BuildContext context) => _StoryLoadingRing(value: value);
}
