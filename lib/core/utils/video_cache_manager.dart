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

  final CacheManager _cacheManager = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 30, // قللنا العدد لأن الفيديوهات كبيرة
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  /// التحقق إذا الفيديو موجود في الكاش (بدون تحميل)
  Future<File?> getCachedFile(String url) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(url);
      if (fileInfo != null && await fileInfo.file.exists()) {
        debugPrint('✅ Video found in cache: ${_getFileName(url)}');
        return fileInfo.file;
      }
    } catch (e) {
      debugPrint('❌ Error checking cache: $e');
    }
    return null;
  }

  void preloadVideoInBackground(String url) {
    if (url.isEmpty || _downloadingUrls.contains(url)) return;

    _downloadingUrls.add(url);

    _cacheManager.getFileFromCache(url).then((fileInfo) {
      if (fileInfo == null) {
        debugPrint('🔄 Background download started: ${_getFileName(url)}');
        _cacheManager
            .downloadFile(url)
            .then((_) {
              debugPrint(
                '✅ Background download complete: ${_getFileName(url)}',
              );
              _downloadingUrls.remove(url);
            })
            .catchError((e) {
              debugPrint('❌ Background download failed: $e');
              _downloadingUrls.remove(url);
            });
      } else {
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

  /// مسح الكاش
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
    _downloadingUrls.clear();
  }

  String _getFileName(String url) {
    return url.split('/').last.split('?').first;
  }
}
