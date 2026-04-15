import 'dart:async';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:story_view/story_view.dart';
import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/my_import.dart';

/// Custom video widget for stories that integrates with [GlobalMuteManager].
/// Replaces [StoryVideo.url] so the mute button works the same as in posts.
class StoryVideoMuted extends StatefulWidget {
  final String url;
  final StoryController storyController;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const StoryVideoMuted({
    super.key,
    required this.url,
    required this.storyController,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<StoryVideoMuted> createState() => _StoryVideoMutedState();
}

class _StoryVideoMutedState extends State<StoryVideoMuted> {
  VideoPlayerController? _controller;
  StreamSubscription? _playbackSub;
  bool _isInitialized = false;
  bool _hasError = false;

  final _muteManager = GlobalMuteManager.instance;

  @override
  void initState() {
    super.initState();
    _muteManager.isMuted.addListener(_onMuteChanged);
    _loadVideo();
  }

  @override
  void dispose() {
    _muteManager.isMuted.removeListener(_onMuteChanged);
    _playbackSub?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _onMuteChanged() {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    try {
      ctrl.setVolume(_muteManager.isMuted.value ? 0.0 : 1.0);
    } catch (_) {}
  }

  Future<void> _loadVideo() async {
    try {
      // Use flutter_cache_manager (same as StoryVideo internally)
      final fileInfo = await DefaultCacheManager().getSingleFile(widget.url);

      if (!mounted) return;

      _controller = VideoPlayerController.file(fileInfo);

      await _controller!.initialize();

      if (!mounted) {
        _controller?.dispose();
        return;
      }

      await _controller!.setLooping(true);
      _controller!.setVolume(_muteManager.isMuted.value ? 0.0 : 1.0);

      // Listen to StoryController play/pause events
      _playbackSub = widget.storyController.playbackNotifier.listen((state) {
        if (!mounted) return;
        if (state == PlaybackState.pause) {
          _controller?.pause();
        } else {
          _controller?.play();
        }
      });

      setState(() => _isInitialized = true);

      // Start playing immediately (StoryController will manage pause/resume)
      widget.storyController.play();
    } catch (e) {
      debugPrint('❌ StoryVideoMuted error: $e');
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ??
          const Center(
            child: Icon(Icons.error_outline, color: Colors.white54, size: 40),
          );
    }

    if (!_isInitialized || _controller == null) {
      return widget.loadingWidget ??
          const Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          );
    }

    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}
