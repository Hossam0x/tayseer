// lib/core/services/video_cache_manager.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart';

class VideoCacheManager {
  static const key = 'videoCache';

  static final VideoCacheManager _instance = VideoCacheManager._internal();
  factory VideoCacheManager() => _instance;
  VideoCacheManager._internal();

  // لتتبع الفيديوهات اللي بتتحمل حالياً — Completer dedup
  final Map<String, Completer<File?>> _activeDownloads = {};

  // Memory cache للمسارات المحملة (لتجنب البحث في الـ disk كل مرة)
  final Map<String, String> _pathCache = {};

  // تتبع الفيديوهات التي فشل تحميلها
  final Map<String, int> _failedDownloads = {};
  static const int _maxDownloadRetries = 5;

  final CacheManager _cacheManager = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 14),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  /// التحقق إذا الفيديو موجود في الكاش (بدون تحميل)
  Future<File?> getCachedFile(String url) async {
    if (url.isEmpty) return null;

    try {
      // تحقق من Memory cache أولاً (الأسرع)
      if (_pathCache.containsKey(url)) {
        final cachedPath = _pathCache[url]!;
        final file = File(cachedPath);
        if (await file.exists()) {
          return file;
        }
        // الملف لم يعد موجوداً، أزله من الذاكرة
        _pathCache.remove(url);
      }

      // تحقق من disk cache
      final fileInfo = await _cacheManager.getFileFromCache(url);
      if (fileInfo != null && await fileInfo.file.exists()) {
        // أضفه للـ memory cache + امسح أي حالة فشل قديمة
        _pathCache[url] = fileInfo.file.path;
        _failedDownloads.remove(url);
        return fileInfo.file;
      }
    } catch (e) {
      debugPrint('❌ Error checking cache: $e');
    }
    return null;
  }

  /// تحميل الفيديو والحصول على الملف (من الكاش أو تحميله)
  /// يستخدم Completer لمنع التحميل المتكرر لنفس الـ URL
  Future<File?> getVideoFile(String url) async {
    if (url.isEmpty) return null;

    // تحقق من الكاش أولاً
    final cached = await getCachedFile(url);
    if (cached != null) return cached;

    // تحقق من عدد محاولات الفشل
    if ((_failedDownloads[url] ?? 0) >= _maxDownloadRetries) {
      debugPrint('⚠️ Max retries exceeded for: ${_getFileName(url)}');
      return null;
    }

    // هل فيه تحميل جاري بالفعل؟ استنى عليه بدل ما تبدأ واحد جديد
    if (_activeDownloads.containsKey(url)) {
      return _activeDownloads[url]!.future;
    }

    final completer = Completer<File?>();
    _activeDownloads[url] = completer;

    try {
      debugPrint('🔄 Downloading video: ${_getFileName(url)}');
      final file = await _cacheManager
          .getSingleFile(url)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw TimeoutException('Video download timed out');
            },
          );
      _pathCache[url] = file.path;
      _failedDownloads.remove(url);
      completer.complete(file);
    } catch (e) {
      _failedDownloads[url] = (_failedDownloads[url] ?? 0) + 1;
      debugPrint(
        '❌ Download failed (${_failedDownloads[url]}/$_maxDownloadRetries): $e',
      );
      completer.complete(null);
    } finally {
      _activeDownloads.remove(url);
    }

    return completer.future;
  }

  /// تحميل فيديو في الخلفية مع Completer dedup
  void preloadVideoInBackground(String url) {
    if (url.isEmpty) return;

    // تحقق من عدد محاولات الفشل
    if ((_failedDownloads[url] ?? 0) >= _maxDownloadRetries) {
      return;
    }

    // لو بالفعل بيتحمل أو موجود في الكاش، اتجاهل
    if (_activeDownloads.containsKey(url) || _pathCache.containsKey(url)) {
      return;
    }

    final completer = Completer<File?>();
    _activeDownloads[url] = completer;

    _cacheManager
        .getFileFromCache(url)
        .then((fileInfo) {
          if (fileInfo != null) {
            _pathCache[url] = fileInfo.file.path;
            _failedDownloads.remove(url);
            _activeDownloads.remove(url);
            completer.complete(fileInfo.file);
          } else {
            debugPrint('🔄 Background download started: ${_getFileName(url)}');
            _cacheManager
                .downloadFile(url)
                .timeout(
                  const Duration(seconds: 60),
                  onTimeout: () {
                    throw TimeoutException('Background download timed out');
                  },
                )
                .then((fileInfo) {
                  debugPrint(
                    '✅ Background download complete: ${_getFileName(url)}',
                  );
                  _pathCache[url] = fileInfo.file.path;
                  _failedDownloads.remove(url);
                  _activeDownloads.remove(url);
                  completer.complete(fileInfo.file);
                })
                .catchError((e) {
                  debugPrint('❌ Background download failed: $e');
                  _failedDownloads[url] = (_failedDownloads[url] ?? 0) + 1;
                  _activeDownloads.remove(url);
                  completer.complete(null);
                });
          }
        })
        .catchError((e) {
          _activeDownloads.remove(url);
          completer.complete(null);
        });
  }

  /// تحميل قائمة فيديوهات في الخلفية
  void preloadVideosInBackground(List<String> urls) {
    for (final url in urls) {
      if (url.isNotEmpty) {
        preloadVideoInBackground(url);
      }
    }
  }

  /// هل الفيديو قيد التحميل؟
  bool isDownloading(String url) {
    return _activeDownloads.containsKey(url);
  }

  /// هل الفيديو موجود في الكاش (memory check فقط)
  bool isCachedInMemory(String url) {
    return _pathCache.containsKey(url);
  }

  /// إعادة تعيين حالة الفشل لفيديو معين
  void resetFailedStatus(String url) {
    _failedDownloads.remove(url);
  }

  /// إعادة تعيين كل حالات الفشل (تُستدعى عند العودة للتطبيق)
  void resetAllFailedStatuses() {
    _failedDownloads.clear();
  }

  /// مسح الكاش
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
    _activeDownloads.clear();
    _pathCache.clear();
    _failedDownloads.clear();
    debugPrint('🧹 Video cache cleared');
  }

  String _getFileName(String url) {
    return url.split('/').last.split('?').first;
  }
}
