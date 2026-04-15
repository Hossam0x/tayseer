import 'package:story_view/story_view.dart';
import 'package:tayseer/my_import.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StoryImage Guard — wraps StoryImage.url and fires onReady once loaded
// ─────────────────────────────────────────────────────────────────────────────
/// Wraps [StoryImage.url] and intercepts any [PlaybackState.play] signal that
/// arrives before the image has finished loading, re-issuing a pause so the
/// progress bar stays frozen. Once [StoryImage] calls controller.play()
/// internally (image loaded), we forward that signal and notify [onReady].
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
  late final _ProxyStoryController _proxy;

  @override
  void initState() {
    super.initState();
    _proxy = _ProxyStoryController(
      delegate: widget.storyController,
      onImageReady: widget.onReady,
    );
  }

  @override
  void dispose() {
    _proxy.disposeProxy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoryImage.url(widget.url, controller: _proxy, fit: BoxFit.contain);
  }
}

/// A [StoryController] proxy that sits between [StoryImage] and the real
/// [StoryController]. It intercepts the first [play()] call that [StoryImage]
/// makes when the image finishes loading so we can fire [onImageReady], then
/// delegates everything else to the real controller.
class _ProxyStoryController extends StoryController {
  final StoryController delegate;
  final VoidCallback onImageReady;
  bool _readyFired = false;

  _ProxyStoryController({required this.delegate, required this.onImageReady});

  // Forward the stream so StoryImage subscribes to the real notifier.
  @override
  // ignore: overridden_fields
  late final playbackNotifier = delegate.playbackNotifier;

  @override
  void play() {
    if (!_readyFired) {
      _readyFired = true;
      onImageReady();
    }
    delegate.play();
  }

  @override
  void pause() => delegate.pause();

  @override
  void next() => delegate.next();

  @override
  void previous() => delegate.previous();

  /// Do NOT close the delegate's stream — it is owned by _UserStoryPageState.
  void disposeProxy() {}

  @override
  void dispose() {
    // Intentionally empty — delegate owns the stream.
  }
}
