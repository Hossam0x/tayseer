import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

/// Manages audio for the story screen.
///
/// Any [VideoPlayerController] that plays inside a story must register itself
/// here. When the story screen is closed (or another route is pushed on top),
/// [silenceAll] is called and every registered controller is paused + muted so
/// no audio leaks into the rest of the app.
///
/// Usage:
///   // In StoryVideoMuted.initState / _loadVideo:
///   StoryAudioManager.instance.register(controller);
///
///   // In StoryVideoMuted.dispose:
///   StoryAudioManager.instance.unregister(controller);
///
///   // In _UserStoryPageState.didPushNext / dispose:
///   StoryAudioManager.instance.silenceAll();
class StoryAudioManager {
  StoryAudioManager._();
  static final StoryAudioManager instance = StoryAudioManager._();

  final Set<VideoPlayerController> _controllers = {};

  /// Register a controller so it can be silenced on navigation.
  void register(VideoPlayerController ctrl) {
    _controllers.add(ctrl);
    debugPrint(
      '🎵 StoryAudioManager: registered (${_controllers.length} total)',
    );
  }

  /// Unregister when the widget is disposed.
  void unregister(VideoPlayerController ctrl) {
    _controllers.remove(ctrl);
    debugPrint(
      '🎵 StoryAudioManager: unregistered (${_controllers.length} left)',
    );
  }

  /// Pause + mute every registered controller immediately.
  /// Call this in didPushNext and dispose of the story page.
  void silenceAll() {
    for (final ctrl in _controllers) {
      try {
        if (ctrl.value.isInitialized) {
          ctrl.setVolume(0);
          ctrl.pause();
        }
      } catch (_) {}
    }
    debugPrint(
      '🔇 StoryAudioManager: silenced ${_controllers.length} controllers',
    );
  }

  /// Clear all registrations (call when the story screen is fully disposed).
  void clear() {
    silenceAll();
    _controllers.clear();
    debugPrint('🧹 StoryAudioManager: cleared');
  }
}
