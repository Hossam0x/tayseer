import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/features/shared/home/data_source/posts_local_datasource.dart';

/// خدمة تنظيف الكاش عند تسجيل الخروج
class CacheCleanupService {
  final PostsLocalDatasource _postsLocalDatasource;

  CacheCleanupService(this._postsLocalDatasource);

  /// مسح كل بيانات الكاش للمستخدم الحالي
  Future<void> clearAllUserCache() async {
    try {
      // 1. مسح كاش البوستات من Hive
      await _postsLocalDatasource.clearAllCache();

      // 2. مسح كاش الفيديو
      try {
        await VideoCacheManager().clearCache();
      } catch (e) {
        debugPrint('⚠️ CacheCleanupService: Error clearing video cache: $e');
      }

      // 3. مسح كاش الصور
      try {
        await DefaultCacheManager().emptyCache();
      } catch (e) {
        debugPrint('⚠️ CacheCleanupService: Error clearing image cache: $e');
      }

      debugPrint('✅ CacheCleanupService: All user cache cleared');
    } catch (e) {
      debugPrint('❌ CacheCleanupService: Error during cleanup: $e');
    }
  }
}
