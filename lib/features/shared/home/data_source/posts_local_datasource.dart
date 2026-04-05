import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/utils/hive_service.dart';

/// نتيجة قراءة الكاش
class CachedPostsResult {
  final List<PostModel> posts;
  final double? nextCursor;
  final int lastPage;
  final DateTime cachedAt;

  CachedPostsResult({
    required this.posts,
    required this.nextCursor,
    required this.lastPage,
    required this.cachedAt,
  });
}

/// مصدر البيانات المحلي للبوستات — يستخدم HiveService
class PostsLocalDatasource {
  final HiveService _hiveService;

  // ثوابت مفاتيح الكاش
  static const String _postsKey = 'cached_posts';
  static const String _metadataKey = 'cache_metadata';
  static const String _writeCompleteKey = 'cache_write_complete';

  // أقصى عمر للكاش (7 أيام)
  static const Duration _maxCacheAge = Duration(days: 7);

  // أقصى عدد بوستات في الكاش
  static const int _maxCachedPosts = 50;

  PostsLocalDatasource(this._hiveService);

  /// اسم البوكس مبني على userId — كل مستخدم له كاش منفصل
  String get _boxName {
    final userId = kCurrentUserData?.id;
    if (userId != null && userId.isNotEmpty) {
      return 'posts_cache_$userId';
    }
    return 'posts_cache_guest';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💾 كتابة الكاش (استبدال كامل)
  // ═══════════════════════════════════════════════════════════════════════════

  /// حفظ البوستات في الكاش — يحذف القديم ثم يكتب الجديد
  Future<void> cachePosts(
    List<PostModel> posts, {
    double? nextCursor,
    required int page,
  }) async {
    try {
      // تقليم البوستات — نحتفظ بأحدث 50 فقط
      final trimmedPosts = posts.length > _maxCachedPosts
          ? posts.sublist(posts.length - _maxCachedPosts)
          : posts;

      final box = await _hiveService.openBox(_boxName);

      // علامة بداية الكتابة (لكشف الانقطاع)
      await box.put(_writeCompleteKey, false);

      // حذف القديم
      await box.clear();

      // كتابة علامة الكتابة مرة أخرى بعد المسح
      await box.put(_writeCompleteKey, false);

      // تحويل البوستات لـ JSON
      final postsJson = trimmedPosts.map((p) => p.toJson()).toList();
      await box.put(_postsKey, jsonEncode(postsJson));

      // كتابة البيانات الوصفية
      final metadata = {
        'cachedAt': DateTime.now().toIso8601String(),
        'nextCursor': nextCursor,
        'lastPage': page,
        'userId': kCurrentUserData?.id ?? 'guest',
        'postsCount': trimmedPosts.length,
      };
      await box.put(_metadataKey, jsonEncode(metadata));

      // علامة اكتمال الكتابة
      await box.put(_writeCompleteKey, true);

      debugPrint(
        '✅ PostsLocalDatasource: Cached ${trimmedPosts.length} posts (page $page, limit $_maxCachedPosts)',
      );
    } catch (e) {
      debugPrint('❌ PostsLocalDatasource: Error caching posts: $e');
      // لا نرمي الخطأ — الكاش هو عملية صامتة
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📖 قراءة الكاش
  // ═══════════════════════════════════════════════════════════════════════════

  /// قراءة البوستات المحفوظة — ترجع null لو الكاش فاسد أو فارغ
  Future<CachedPostsResult?> getCachedPosts() async {
    try {
      final box = await _hiveService.openBox(_boxName);

      // فحص اكتمال الكتابة
      final writeComplete = box.get(_writeCompleteKey);
      if (writeComplete != true) {
        debugPrint(
          '⚠️ PostsLocalDatasource: Incomplete cache detected, clearing...',
        );
        await box.clear();
        return null;
      }

      // قراءة البيانات الوصفية
      final metadataRaw = box.get(_metadataKey);
      if (metadataRaw == null) return null;

      final metadata =
          jsonDecode(metadataRaw as String) as Map<String, dynamic>;

      // التحقق من صحة اليوزر
      final cachedUserId = metadata['userId'] as String?;
      final currentUserId = kCurrentUserData?.id ?? 'guest';
      if (cachedUserId != currentUserId) {
        debugPrint(
          '⚠️ PostsLocalDatasource: Cache belongs to different user, clearing...',
        );
        await box.clear();
        return null;
      }

      // التحقق من عمر الكاش
      final cachedAtStr = metadata['cachedAt'] as String?;
      if (cachedAtStr == null) return null;

      final cachedAt = DateTime.tryParse(cachedAtStr);
      if (cachedAt == null) return null;

      if (DateTime.now().difference(cachedAt) > _maxCacheAge) {
        debugPrint('⚠️ PostsLocalDatasource: Cache expired, clearing...');
        await box.clear();
        return null;
      }

      // قراءة البوستات
      final postsRaw = box.get(_postsKey);
      if (postsRaw == null) return null;

      final postsJson = jsonDecode(postsRaw as String) as List<dynamic>;
      final posts = postsJson
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (posts.isEmpty) return null;

      return CachedPostsResult(
        posts: posts,
        nextCursor: (metadata['nextCursor'] as num?)?.toDouble(),
        lastPage: (metadata['lastPage'] as num?)?.toInt() ?? 1,
        cachedAt: cachedAt,
      );
    } catch (e) {
      debugPrint(
        '❌ PostsLocalDatasource: Error reading cache (corrupted?): $e',
      );
      // كاش فاسد — نمسحه
      try {
        final box = await _hiveService.openBox(_boxName);
        await box.clear();
      } catch (_) {}
      return null;
    }
  }

  /// قراءة البوستات المحفوظة مع تقسيم صفحات محلي
  /// يرجع شريحة من البوستات حسب رقم الصفحة وحجمها
  Future<CachedPostsResult?> getCachedPostsPaginated({
    required int page,
    int pageSize = 5,
  }) async {
    final allCached = await getCachedPosts();
    if (allCached == null || allCached.posts.isEmpty) return null;

    final totalPosts = allCached.posts.length;
    final startIndex = (page - 1) * pageSize;

    // لو الـ startIndex أكبر من عدد البوستات → مافيش بيانات
    if (startIndex >= totalPosts) return null;

    final endIndex = (startIndex + pageSize) > totalPosts
        ? totalPosts
        : (startIndex + pageSize);
    final pageSlice = allCached.posts.sublist(startIndex, endIndex);

    final totalPages = (totalPosts / pageSize).ceil();

    return CachedPostsResult(
      posts: pageSlice,
      nextCursor: allCached.nextCursor,
      lastPage: totalPages,
      cachedAt: allCached.cachedAt,
    );
  }

  /// عدد البوستات المحفوظة في الكاش
  Future<int> getCachedPostsCount() async {
    final allCached = await getCachedPosts();
    return allCached?.posts.length ?? 0;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✏️ تعديل بوست واحد (للتفاعلات)
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحديث بوست واحد في الكاش بالـ ID
  Future<void> updateSinglePost(String postId, PostModel updatedPost) async {
    try {
      final box = await _hiveService.openBox(_boxName);

      final postsRaw = box.get(_postsKey);
      if (postsRaw == null) return;

      final postsJson = jsonDecode(postsRaw as String) as List<dynamic>;
      final index = postsJson.indexWhere(
        (e) => (e as Map<String, dynamic>)['id'] == postId,
      );

      if (index == -1) return;

      postsJson[index] = updatedPost.toJson();
      await box.put(_postsKey, jsonEncode(postsJson));

      debugPrint('✅ PostsLocalDatasource: Updated post $postId in cache');
    } catch (e) {
      debugPrint('❌ PostsLocalDatasource: Error updating post: $e');
    }
  }

  /// حذف بوست واحد من الكاش (للحذف/الأرشفة/الإخفاء)
  Future<void> removePost(String postId) async {
    try {
      final box = await _hiveService.openBox(_boxName);

      final postsRaw = box.get(_postsKey);
      if (postsRaw == null) return;

      final postsJson = jsonDecode(postsRaw as String) as List<dynamic>;
      postsJson.removeWhere((e) => (e as Map<String, dynamic>)['id'] == postId);

      await box.put(_postsKey, jsonEncode(postsJson));

      debugPrint('✅ PostsLocalDatasource: Removed post $postId from cache');
    } catch (e) {
      debugPrint('❌ PostsLocalDatasource: Error removing post: $e');
    }
  }

  /// حذف كل بوستات مستخدم معين من الكاش (للحظر)
  Future<void> removePostsByAdvisor(String advisorId) async {
    try {
      final box = await _hiveService.openBox(_boxName);

      final postsRaw = box.get(_postsKey);
      if (postsRaw == null) return;

      final postsJson = jsonDecode(postsRaw as String) as List<dynamic>;
      postsJson.removeWhere(
        (e) => (e as Map<String, dynamic>)['advisorId'] == advisorId,
      );

      await box.put(_postsKey, jsonEncode(postsJson));
    } catch (e) {
      debugPrint('❌ PostsLocalDatasource: Error removing posts by advisor: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🗑️ تنظيف الكاش
  // ═══════════════════════════════════════════════════════════════════════════

  /// مسح كل الكاش للمستخدم الحالي
  Future<void> clearAllCache() async {
    try {
      final box = await _hiveService.openBox(_boxName);
      await box.clear();
      debugPrint('✅ PostsLocalDatasource: Cleared all cache for $_boxName');
    } catch (e) {
      debugPrint('❌ PostsLocalDatasource: Error clearing cache: $e');
    }
  }

  /// هل يوجد كاش محفوظ؟
  Future<bool> hasCachedPosts() async {
    try {
      final box = await _hiveService.openBox(_boxName);
      final writeComplete = box.get(_writeCompleteKey);
      if (writeComplete != true) return false;
      final postsRaw = box.get(_postsKey);
      return postsRaw != null;
    } catch (e) {
      return false;
    }
  }
}
