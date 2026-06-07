// lib/core/services/video_cache_manager.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

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
      maxNrOfCacheObjects: 50, // تقليص من 200 إلى 50
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
    } on SocketException catch (e) {
      debugPrint('⚠️ Network unavailable for video download: $e');
      _failedDownloads[url] = (_failedDownloads[url] ?? 0) + 1;
      completer.complete(null);
    } on HttpException catch (e) {
      debugPrint('⚠️ HTTP error for video download: $e');
      _failedDownloads[url] = (_failedDownloads[url] ?? 0) + 1;
      completer.complete(null);
    } catch (e) {
      // Catch ClientException from http package and all other errors
      final msg = e.toString();
      if (msg.contains('SocketException') ||
          msg.contains('ClientException') ||
          msg.contains('Failed host lookup') ||
          msg.contains('Connection refused') ||
          msg.contains('timed out')) {
        debugPrint('⚠️ Network error downloading video (silent): $e');
      } else {
        debugPrint(
          '❌ Download failed (${(_failedDownloads[url] ?? 0) + 1}/$_maxDownloadRetries): $e',
        );
      }
      _failedDownloads[url] = (_failedDownloads[url] ?? 0) + 1;
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
                  _silentNetworkError('Background download', url, e);
                  _failedDownloads[url] = (_failedDownloads[url] ?? 0) + 1;
                  _activeDownloads.remove(url);
                  completer.complete(null);
                });
          }
        })
        .catchError((e) {
          _silentNetworkError('Cache check', url, e);
          _activeDownloads.remove(url);
          completer.complete(null);
        });
  }

  /// Silently log network errors without rethrowing.
  void _silentNetworkError(String context, String url, Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') ||
        msg.contains('ClientException') ||
        msg.contains('Failed host lookup') ||
        msg.contains('Connection refused') ||
        msg.contains('HttpException') ||
        msg.contains('timed out')) {
      debugPrint(
        '⚠️ $context offline/network error (silent): ${_getFileName(url)}',
      );
    } else {
      debugPrint('❌ $context error for ${_getFileName(url)}: $e');
    }
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

  /// يرجع مجلد الـ disk cache الخاص بالـ videoCache key (لحساب حجمه)
  Future<Directory?> getCacheDirectory() async {
    try {
      final base = await getTemporaryDirectory();
      // flutter_cache_manager يضع ملفاته في مجلد باسم الـ key داخل tmp
      final keyDir = Directory('${base.path}/$key');
      if (await keyDir.exists()) return keyDir;
      return base;
    } catch (e) {
      debugPrint('⚠️ VideoCacheManager.getCacheDirectory: $e');
      return null;
    }
  }

  /// تحقق من إجمالي حجم الـ disk cache — إذا تجاوز [maxBytes] يُفرغه
  Future<void> trimCacheIfNeeded({
    int maxBytes = 500 * 1024 * 1024, // 500 MB default
  }) async {
    try {
      final dir = await getCacheDirectory();
      if (dir == null) return;
      int total = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          try {
            total += await entity.length();
          } catch (_) {}
        }
      }
      if (total > maxBytes) {
        debugPrint(
          '🧹 VideoCacheManager: cache ${(total / (1024 * 1024)).toStringAsFixed(1)} MB > ${maxBytes ~/ (1024 * 1024)} MB — clearing',
        );
        await clearCache();
      }
    } catch (e) {
      debugPrint('⚠️ VideoCacheManager.trimCacheIfNeeded: $e');
    }
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
