import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';

/// Singleton يحتفظ بـ VideoPlayerController واحد مشترك
/// لفيديو المستشار (intro video) بين ProfileView و EditPersonalDataView.
class AdvisorVideoCache {
  AdvisorVideoCache._();
  static final AdvisorVideoCache instance = AdvisorVideoCache._();

  VideoPlayerController? _controller;
  String? _currentUrl;
  bool _isInitializing = false;

  final _videoCacheManager = VideoCacheManager();

  /// الـ URL الحالي المحفوظ
  String? get currentUrl => _currentUrl;

  /// الـ controller الجاهز (null لو لسه بيتهيأ)
  VideoPlayerController? get controller => _controller;

  bool get isInitialized =>
      _controller != null && _controller!.value.isInitialized;

  /// احضر أو هيئ الـ controller للـ URL ده.
  /// لو نفس الـ URL وجاهز، يرجع على طول.
  /// لو URL جديد، يعمل dispose للقديم ويبدأ جديد.
  Future<VideoPlayerController?> getOrInit(
    String url, {
    VoidCallback? onReady,
  }) async {
    if (url.isEmpty) return null;

    // نفس الـ URL وجاهز
    if (_currentUrl == url && isInitialized) {
      onReady?.call();
      return _controller;
    }

    // URL جديد أو لسه مش جاهز
    if (_currentUrl != url) {
      await _disposeController();
      _currentUrl = url;
    }

    if (_isInitializing) return _controller;
    _isInitializing = true;

    try {
      final cachedFile = await _videoCacheManager.getCachedFile(url);
      if (cachedFile != null) {
        _controller = VideoPlayerController.file(
          cachedFile,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: false,
            allowBackgroundPlayback: false,
          ),
        );
      } else {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(url),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: false,
            allowBackgroundPlayback: false,
          ),
          httpHeaders: const {'Range': 'bytes=0-'},
        );
        // preload في الخلفية
        _videoCacheManager.preloadVideoInBackground(url);
      }

      await _controller!.initialize();
      _controller!.setVolume(0.0);
      onReady?.call();
    } catch (e) {
      debugPrint('❌ AdvisorVideoCache init error: $e');
      _controller = null;
    } finally {
      _isInitializing = false;
    }

    return _controller;
  }

  /// استبدل الـ URL بجديد (لما يرفع فيديو جديد من EditPersonalDataView)
  Future<void> updateUrl(String newUrl) async {
    if (newUrl == _currentUrl && isInitialized) return;
    await _disposeController();
    _currentUrl = newUrl;
    // لا نهيئ هنا — الـ widget اللي يحتاجه هيطلبه بـ getOrInit
  }

  Future<void> _disposeController() async {
    try {
      if (_controller != null) {
        await _controller!.pause();
        _controller!.dispose();
        _controller = null;
      }
    } catch (e) {
      debugPrint('⚠️ AdvisorVideoCache dispose error: $e');
    }
  }

  Future<void> dispose() async {
    await _disposeController();
    _currentUrl = null;
  }
}
