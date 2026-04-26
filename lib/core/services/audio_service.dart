import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AudioService - Singleton service for managing sound effects throughout the app
///
/// Features:
/// - Preloads all sound effects for optimal performance
/// - Respects user sound preferences
/// - Handles platform differences automatically
/// - Prevents sound overlap and manages volume
/// - Background-aware (no sounds when app is in background)
class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._();

  AudioService._();

  // Audio players for different sound categories
  // Non-final so they can be recreated after dispose()
  AudioPlayer _effectsPlayer = AudioPlayer();
  AudioPlayer _uiPlayer = AudioPlayer();

  // Sound effect keys
  static const String likeSuccess = 'like_success';
  static const String unlikeSuccess = 'unlike_success';
  static const String followSuccess = 'follow_success';
  static const String unfollowSuccess = 'unfollow_success';
  static const String shareSuccess = 'share_success';
  static const String commentSuccess = 'comment_success';
  static const String uploadSuccess = 'upload_success';
  static const String deleteSuccess = 'delete_success';
  static const String saveSuccess = 'save_success';
  static const String unsaveSuccess = 'unsave_success';
  static const String sendSuccess = 'send_success';
  static const String receiveMessage = 'receive_message';
  static const String buttonTap = 'button_tap';
  static const String navigationTap = 'navigation_tap';
  static const String errorSound = 'error_sound';
  static const String warningSound = 'warning_sound';
  static const String successGeneral = 'success_general';
  static const String sessionAccept = 'session_accept';
  static const String sessionDecline = 'session_decline';
  static const String voteSuccess = 'vote_success';
  static const String archiveSuccess = 'archive_success';
  static const String blockSuccess = 'block_success';
  static const String purchaseSuccess = 'purchase_success';
  static const String notificationReceived = 'notification_received';
  static const String splashSound = 'splash_sound';
  static const String refreshSound = 'refresh_sound';
  static const String toggleSound = 'toggle_sound';
  static const String unblockSuccess = 'unblock_success';

  // Sound file mappings
  final Map<String, String> _soundFiles = {
    likeSuccess: 'assets/sounds/like_success.mp3',
    unlikeSuccess: 'assets/sounds/unlike_success.mp3',
    followSuccess: 'assets/sounds/follow_success.mp3',
    unfollowSuccess: 'assets/sounds/unfollow_success.mp3',
    shareSuccess: 'assets/sounds/share_success.mp3',
    commentSuccess: 'assets/sounds/comment_success.mp3',
    uploadSuccess: 'assets/sounds/upload_success.mp3',
    deleteSuccess: 'assets/sounds/delete_success.mp3',
    saveSuccess: 'assets/sounds/save_success.mp3',
    unsaveSuccess: 'assets/sounds/unsave_success.mp3',
    sendSuccess: 'assets/sounds/send_success.mp3',
    receiveMessage: 'assets/sounds/receive_message.mp3',
    buttonTap: 'assets/sounds/button_tap.mp3',
    navigationTap: 'assets/sounds/navigation_tap.mp3',
    errorSound: 'assets/sounds/error_sound.mp3',
    warningSound: 'assets/sounds/warning_sound.mp3',
    successGeneral: 'assets/sounds/success_general.mp3',
    sessionAccept: 'assets/sounds/session_accept.mp3',
    sessionDecline: 'assets/sounds/session_decline.mp3',
    voteSuccess: 'assets/sounds/vote_success.mp3',
    archiveSuccess: 'assets/sounds/archive_success.mp3',
    blockSuccess: 'assets/sounds/block_success.mp3',
    purchaseSuccess: 'assets/sounds/purchase_success.mp3',
    notificationReceived: 'assets/sounds/notification_received.mp3',
    splashSound: 'assets/sounds/whistle.mp3',
    refreshSound: 'assets/sounds/refresh_sound.mp3',
    toggleSound: 'assets/sounds/toggle_sound.mp3',
    unblockSuccess: 'assets/sounds/unblock_success.mp3',
  };

  // Cache for preloaded sounds
  final Map<String, Source> _preloadedSounds = {};

  // Settings
  bool _soundEffectsEnabled = true;
  bool _isInitialized = false;
  bool _isAppInBackground = false;
  double _volume = 0.7;

  // Getters
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  bool get isInitialized => _isInitialized;
  double get volume => _volume;

  /// Initialize the audio service
  /// Call this in main() or app startup
  Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) print('🔊 AudioService already initialized');
      return;
    }

    if (kDebugMode) print('🔊 Initializing AudioService...');

    try {
      // Recreate players if they were previously disposed
      // AudioPlayer instances become unusable after dispose()
      _effectsPlayer = AudioPlayer();
      _uiPlayer = AudioPlayer();

      // Load user preferences
      await _loadPreferences();

      if (kDebugMode) {
        print(
          '📱 Loaded preferences: enabled=$_soundEffectsEnabled, volume=$_volume',
        );
      }

      // Set volume
      await _effectsPlayer.setVolume(_volume);
      await _uiPlayer.setVolume(_volume * 0.8); // UI sounds slightly quieter

      if (kDebugMode) print('🔊 Volume set to $_volume');

      // Preload critical sounds
      await _preloadCriticalSounds();

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ AudioService initialized successfully');
        print('🎵 Ready to play sounds!');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('❌ AudioService initialization failed: $e');
        print('   Stack: $stack');
      }
    }
  }

  /// Preload critical sounds for better performance
  Future<void> _preloadCriticalSounds() async {
    final criticalSounds = [
      likeSuccess,
      buttonTap,
      errorSound,
      successGeneral,
      commentSuccess,
    ];

    for (final soundKey in criticalSounds) {
      try {
        final filePath = _soundFiles[soundKey];
        if (filePath != null) {
          // Remove 'assets/' prefix for AssetSource
          final assetPath = filePath.replaceFirst('assets/', '');
          _preloadedSounds[soundKey] = AssetSource(assetPath);

          if (kDebugMode) {
            print('✅ Preloaded sound: $soundKey -> $assetPath');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to preload sound $soundKey: $e');
        }
      }
    }
  }

  /// Load user preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEffectsEnabled = prefs.getBool('sound_effects_enabled') ?? false;
      _volume = prefs.getDouble('sound_effects_volume') ?? 0.7;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load audio preferences: $e');
      }
    }
  }

  /// Save user preferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_effects_enabled', _soundEffectsEnabled);
      await prefs.setDouble('sound_effects_volume', _volume);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save audio preferences: $e');
      }
    }
  }

  /// Play a sound effect
  ///
  /// [soundKey] - The sound effect key from AudioService constants
  /// [forcePlay] - Play even if sounds are disabled (for critical alerts)
  /// [customVolume] - Override default volume for this sound
  Future<void> playSound(
    String soundKey, {
    bool forcePlay = false,
    double? customVolume,
  }) async {
    if (kDebugMode) {
      print('🔊 Attempting to play sound: $soundKey');
      print('   - Initialized: $_isInitialized');
      print('   - Background: $_isAppInBackground');
      print('   - Enabled: $_soundEffectsEnabled');
      print('   - Force: $forcePlay');
    }

    // Check if we should play sounds
    if (!_isInitialized) {
      if (kDebugMode)
        print('⚠️ AudioService not initialized, attempting lazy init...');
      await initialize();
      if (!_isInitialized) {
        if (kDebugMode)
          print('❌ AudioService lazy init failed, skipping sound');
        return;
      }
    }

    if (_isAppInBackground) {
      if (kDebugMode) print('❌ App is in background');
      return;
    }

    if (!_soundEffectsEnabled && !forcePlay) {
      if (kDebugMode) print('❌ Sound effects disabled');
      return;
    }

    try {
      // Get the sound source
      Source? source = _preloadedSounds[soundKey];

      if (source == null) {
        final filePath = _soundFiles[soundKey];
        if (filePath == null) {
          if (kDebugMode) {
            print('❌ Sound file not found for key: $soundKey');
          }
          return;
        }
        final assetPath = filePath.replaceFirst('assets/', '');
        source = AssetSource(assetPath);

        if (kDebugMode) {
          print('📁 Loading sound from: $assetPath');
        }
      } else {
        if (kDebugMode) {
          print('⚡ Using preloaded sound: $soundKey');
        }
      }

      // Choose appropriate player based on sound type
      final player = _isUiSound(soundKey) ? _uiPlayer : _effectsPlayer;

      if (kDebugMode) {
        print(
          '🎵 Playing with ${_isUiSound(soundKey) ? "UI" : "Effects"} player',
        );
      }

      // Set custom volume if provided
      if (customVolume != null) {
        await player.setVolume(customVolume);
      }

      // Play the sound
      await player.play(source);

      if (kDebugMode) {
        print('✅ Sound played successfully: $soundKey');
      }

      // Reset volume if it was customized
      if (customVolume != null) {
        final defaultVolume = _isUiSound(soundKey) ? _volume * 0.8 : _volume;
        await player.setVolume(defaultVolume);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to play sound $soundKey: $e');
      }
    }
  }

  /// Check if a sound is a UI sound (quieter volume)
  bool _isUiSound(String soundKey) {
    return soundKey == buttonTap || soundKey == navigationTap;
  }

  /// Enable or disable sound effects
  Future<void> setSoundEffectsEnabled(bool enabled) async {
    _soundEffectsEnabled = enabled;
    await _savePreferences();
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);

    if (_isInitialized) {
      await _effectsPlayer.setVolume(_volume);
      await _uiPlayer.setVolume(_volume * 0.8);
    }

    await _savePreferences();
  }

  /// Call when app goes to background
  void onAppPaused() {
    _isAppInBackground = true;
    if (kDebugMode) print('🔇 AudioService: app paused');
  }

  /// Call when app comes to foreground
  void onAppResumed() {
    _isAppInBackground = false;
    if (kDebugMode) print('🔊 AudioService: app resumed');
    // Re-initialize if needed (e.g., after audio session interruption)
    if (!_isInitialized) {
      initialize();
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _effectsPlayer.dispose();
    await _uiPlayer.dispose();
    _preloadedSounds.clear();
    _isInitialized = false;
  }

  // Convenience methods for common actions

  /// Play like/reaction sound
  Future<void> playLikeSound({bool isLiked = true}) async {
    await playSound(isLiked ? likeSuccess : unlikeSuccess);
  }

  /// Play follow sound
  Future<void> playFollowSound({bool isFollowing = true}) async {
    await playSound(isFollowing ? followSuccess : unfollowSuccess);
  }

  /// Play save sound
  Future<void> playSaveSound({bool isSaved = true}) async {
    await playSound(isSaved ? saveSuccess : unsaveSuccess);
  }

  /// Play error sound (always plays regardless of settings)
  Future<void> playErrorSound() async {
    await playSound(errorSound, forcePlay: true);
  }

  /// Play success sound
  Future<void> playSuccessSound() async {
    await playSound(successGeneral);
  }

  /// Play button tap sound
  Future<void> playButtonTap() async {
    await playSound(buttonTap);
  }

  /// Play navigation sound
  Future<void> playNavigationTap() async {
    await playSound(navigationTap);
  }

  /// Play comment sound
  Future<void> playCommentSound() async {
    await playSound(commentSuccess);
  }

  /// Play share sound
  Future<void> playShareSound() async {
    await playSound(shareSuccess);
  }

  /// Play upload success sound
  Future<void> playUploadSound() async {
    await playSound(uploadSuccess);
  }

  /// Play delete sound
  Future<void> playDeleteSound() async {
    await playSound(deleteSuccess);
  }

  /// Play session accept sound
  Future<void> playSessionAcceptSound() async {
    await playSound(sessionAccept);
  }

  /// Play session decline sound
  Future<void> playSessionDeclineSound() async {
    await playSound(sessionDecline);
  }

  /// Play vote success sound
  Future<void> playVoteSound() async {
    await playSound(voteSuccess);
  }

  /// Play archive sound
  Future<void> playArchiveSound() async {
    await playSound(archiveSuccess);
  }

  /// Play block sound
  Future<void> playBlockSound() async {
    await playSound(blockSuccess);
  }

  /// Play purchase success sound
  Future<void> playPurchaseSound() async {
    await playSound(purchaseSuccess);
  }

  /// Play notification received sound
  Future<void> playNotificationSound() async {
    await playSound(notificationReceived);
  }

  /// Play send message sound
  Future<void> playSendSound() async {
    await playSound(sendSuccess);
  }

  /// Play receive message sound
  Future<void> playReceiveSound() async {
    await playSound(receiveMessage);
  }

  /// Play refresh sound
  Future<void> playRefreshSound() async {
    HapticFeedback.mediumImpact();
    await playSound(refreshSound);
  }

  /// Play toggle sound
  Future<void> playToggleSound() async {
    await playSound(toggleSound);
  }

  /// Play unblock sound
  Future<void> playUnblockSound() async {
    await playSound(unblockSuccess);
  }
}
