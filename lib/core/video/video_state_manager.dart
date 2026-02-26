import 'package:flutter/foundation.dart';

/// يدير حالة الفيديوهات ويحتفظ بالمواضع والأخطاء
class VideoStateManager {
  static final VideoStateManager _instance = VideoStateManager._internal();
  factory VideoStateManager() => _instance;
  VideoStateManager._internal();

  // تخزين آخر موضع للفيديو
  final Map<String, Duration> _videoPositions = {};

  // تخزين حالة التحميل الناجح
  final Map<String, bool> _loadedVideos = {};

  // تخزين الأخطاء لتجنب إعادة المحاولة المتكررة
  final Map<String, int> _errorCounts = {};

  // تخزين timestamp آخر تحميل ناجح
  final Map<String, DateTime> _lastSuccessfulLoad = {};

  static const int _maxRetries = 5;

  // مدة صلاحية الحالة المخزنة (15 دقيقة)
  static const Duration _stateValidityDuration = Duration(minutes: 15);

  // الحد الأقصى لعدد المواضع المخزنة
  static const int _maxPositionEntries = 200;

  /// حفظ موضع الفيديو قبل الـ dispose
  void savePosition(String videoId, Duration position) {
    if (position.inSeconds > 0) {
      _videoPositions[videoId] = position;

      // FIFO eviction لمنع تراكم الذاكرة
      if (_videoPositions.length > _maxPositionEntries) {
        final firstKey = _videoPositions.keys.first;
        _videoPositions.remove(firstKey);
      }
    }
  }

  /// استرجاع آخر موضع
  Duration? getLastPosition(String videoId) {
    final position = _videoPositions[videoId];
    if (position != null) {
      debugPrint('📍 Retrieved position for $videoId: ${position.inSeconds}s');
    }
    return position;
  }

  /// مسح موضع معين (عند إعادة المشاهدة من البداية)
  void clearPosition(String videoId) {
    _videoPositions.remove(videoId);
  }

  /// تسجيل نجاح التحميل
  void markAsLoaded(String videoId) {
    _loadedVideos[videoId] = true;
    _errorCounts.remove(videoId);
    _lastSuccessfulLoad[videoId] = DateTime.now();
    debugPrint('✅ Marked as loaded: $videoId');
  }

  /// تسجيل فشل التحميل
  /// يرجع true إذا يمكن إعادة المحاولة
  bool recordError(String videoId) {
    _errorCounts[videoId] = (_errorCounts[videoId] ?? 0) + 1;
    final canRetry = _errorCounts[videoId]! < _maxRetries;
    debugPrint(
      '❌ Error recorded for $videoId (${_errorCounts[videoId]}/$_maxRetries) - Can retry: $canRetry',
    );
    return canRetry;
  }

  /// هل يمكن إعادة المحاولة؟
  bool canRetry(String videoId) {
    return (_errorCounts[videoId] ?? 0) < _maxRetries;
  }

  /// إعادة تعيين عداد الأخطاء (عند الضغط على زر إعادة المحاولة يدوياً)
  void resetErrorCount(String videoId) {
    _errorCounts.remove(videoId);
    debugPrint('🔄 Reset error count for: $videoId');
  }

  /// هل الفيديو تم تحميله من قبل؟
  bool wasLoadedBefore(String videoId) {
    if (!_loadedVideos.containsKey(videoId)) return false;

    // تحقق من صلاحية الحالة
    final lastLoad = _lastSuccessfulLoad[videoId];
    if (lastLoad != null) {
      final isValid =
          DateTime.now().difference(lastLoad) < _stateValidityDuration;
      if (!isValid) {
        // الحالة منتهية الصلاحية
        _loadedVideos.remove(videoId);
        _lastSuccessfulLoad.remove(videoId);
        return false;
      }
    }

    return _loadedVideos[videoId] ?? false;
  }

  /// عدد الأخطاء لفيديو معين
  int getErrorCount(String videoId) {
    return _errorCounts[videoId] ?? 0;
  }

  /// تنظيف حالة فيديو معين
  void clearVideoState(String videoId) {
    _videoPositions.remove(videoId);
    _loadedVideos.remove(videoId);
    _errorCounts.remove(videoId);
    _lastSuccessfulLoad.remove(videoId);
  }

  /// تنظيف كامل
  void clear() {
    _videoPositions.clear();
    _loadedVideos.clear();
    _errorCounts.clear();
    _lastSuccessfulLoad.clear();
    debugPrint('🧹 VideoStateManager cleared');
  }

  /// تنظيف الحالات القديمة (أكثر من 5 دقائق)
  void cleanupOldStates() {
    final now = DateTime.now();
    final toRemove = <String>[];

    _lastSuccessfulLoad.forEach((videoId, timestamp) {
      if (now.difference(timestamp) > _stateValidityDuration) {
        toRemove.add(videoId);
      }
    });

    for (final videoId in toRemove) {
      clearVideoState(videoId);
    }

    if (toRemove.isNotEmpty) {
      debugPrint('🧹 Cleaned up ${toRemove.length} old video states');
    }
  }
}
