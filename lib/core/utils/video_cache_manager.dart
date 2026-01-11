// lib/core/services/video_cache_manager.dart

import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart';

class VideoCacheManager {
  static const key = 'videoCache';

  static final VideoCacheManager _instance = VideoCacheManager._internal();
  factory VideoCacheManager() => _instance;
  VideoCacheManager._internal();

  // لتتبع الفيديوهات اللي بتتحمل حالياً
  final Set<String> _downloadingUrls = {};

  // Memory cache للمسارات المحملة (لتجنب البحث في الـ disk كل مرة)
  final Map<String, String> _pathCache = {};

  // تتبع الفيديوهات التي فشل تحميلها
  final Map<String, int> _failedDownloads = {};
  static const int _maxDownloadRetries = 2;

  final CacheManager _cacheManager = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 50, // زدنا العدد قليلاً
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
          debugPrint('✅ Video found in memory cache: ${_getFileName(url)}');
          return file;
        }
        // الملف لم يعد موجوداً، أزله من الذاكرة
        _pathCache.remove(url);
      }

      // تحقق من disk cache
      final fileInfo = await _cacheManager.getFileFromCache(url);
      if (fileInfo != null && await fileInfo.file.exists()) {
        // أضفه للـ memory cache
        _pathCache[url] = fileInfo.file.path;
        debugPrint('✅ Video found in disk cache: ${_getFileName(url)}');
        return fileInfo.file;
      }
    } catch (e) {
      debugPrint('❌ Error checking cache: $e');
    }
    return null;
  }

  /// تحميل الفيديو والحصول على الملف (من الكاش أو تحميله)
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

    try {
      debugPrint('🔄 Downloading video: ${_getFileName(url)}');
      final file = await _cacheManager.getSingleFile(url);
      _pathCache[url] = file.path;
      _failedDownloads.remove(url); // نجح، أزل من قائمة الفشل
      return file;
    } catch (e) {
      _failedDownloads[url] = (_failedDownloads[url] ?? 0) + 1;
      debugPrint('❌ Download failed: $e');
      return null;
    }
  }

  void preloadVideoInBackground(String url) {
    if (url.isEmpty || _downloadingUrls.contains(url)) return;

    // تحقق من عدد محاولات الفشل
    if ((_failedDownloads[url] ?? 0) >= _maxDownloadRetries) {
      return;
    }

    _downloadingUrls.add(url);

    _cacheManager.getFileFromCache(url).then((fileInfo) {
      if (fileInfo == null) {
        debugPrint('🔄 Background download started: ${_getFileName(url)}');
        _cacheManager
            .downloadFile(url)
            .then((fileInfo) {
              debugPrint(
                '✅ Background download complete: ${_getFileName(url)}',
              );
              _pathCache[url] = fileInfo.file.path;
              _downloadingUrls.remove(url);
              _failedDownloads.remove(url);
            })
            .catchError((e) {
              debugPrint('❌ Background download failed: $e');
              _downloadingUrls.remove(url);
              _failedDownloads[url] = (_failedDownloads[url] ?? 0) + 1;
            });
      } else {
        _pathCache[url] = fileInfo.file.path;
        _downloadingUrls.remove(url);
      }
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
    return _downloadingUrls.contains(url);
  }

  /// هل الفيديو موجود في الكاش (memory check فقط)
  bool isCachedInMemory(String url) {
    return _pathCache.containsKey(url);
  }

  /// إعادة تعيين حالة الفشل لفيديو معين
  void resetFailedStatus(String url) {
    _failedDownloads.remove(url);
  }

  /// مسح الكاش
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
    _downloadingUrls.clear();
    _pathCache.clear();
    _failedDownloads.clear();
    debugPrint('🧹 Video cache cleared');
  }

  String _getFileName(String url) {
    return url.split('/').last.split('?').first;
  }
}
