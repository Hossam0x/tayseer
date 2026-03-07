import 'package:equatable/equatable.dart';
import 'package:tayseer/core/models/category_model.dart';
import 'package:tayseer/features/shared/home/model/Image_and_name_model.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/user/my_space/data/model/session_start_model.dart';

import '../../../../my_import.dart';

class HomeState extends Equatable {
  final Map<String?, CategoryPostsData> categoryPostsMap;
  final String? selectedCategoryId;
  final SessionStartModel? sessionStartModel;

  // ─────────────────────────────────────────────────────────────────────────
  // 📦 Categories Data
  // ─────────────────────────────────────────────────────────────────────────
  final CubitStates categoriesState;
  final List<CategoryModel> categories;
  final String? categoriesErrorMessage;
  final int categoriesCurrentPage;
  final bool categoriesHasMore;
  final bool categoriesIsLoadingMore;

  // ─────────────────────────────────────────────────────────────────────────
  // 📦 Share Action State
  // ─────────────────────────────────────────────────────────────────────────
  final CubitStates shareActionState;
  final String? shareMessage;
  final bool? isShareAdded;
  final String? sharePostId;

  // ─────────────────────────────────────────────────────────────────────────
  // 📦 User Info
  // ─────────────────────────────────────────────────────────────────────────
  final ImageAndNameModel? homeInfo;
  final CubitStates fetchNameAndImageState;

  // ─────────────────────────────────────────────────────────────────────────
  // 🔧 Getters - للوصول السهل لبيانات الكاتيجوري الحالية
  // ─────────────────────────────────────────────────────────────────────────
  CategoryPostsData get currentCategoryPosts =>
      categoryPostsMap[selectedCategoryId] ?? const CategoryPostsData();

  CubitStates get postsState => currentCategoryPosts.state;
  List<PostModel> get posts => currentCategoryPosts.posts;
  String? get postsErrorMessage => currentCategoryPosts.errorMessage;
  int get currentPage => currentCategoryPosts.currentPage;
  bool get hasMore => currentCategoryPosts.hasMore;
  bool get isLoadingMore => currentCategoryPosts.isLoadingMore;

  // ─────────────────────────────────────────────────────────────────────────
  // 📦 Save Action State
  // ─────────────────────────────────────────────────────────────────────────
  final CubitStates saveActionState;
  final String? saveMessage;

  // ─────────────────────────────────────────────────────────────────────────
  // 📦 delete post
  // ─────────────────────────────────────────────────────────────────────────
  final String? deletePostMessage;
  final CubitStates deletePostActionState;

  // ─────────────────────────────────────────────────────────────────────────
  // 📦 archive post
  // ─────────────────────────────────────────────────────────────────────────
  final String? archivePostMessage;
  final CubitStates archivePostActionState;

  // ─────────────────────────────────────────────────────────────────────────
  // 📦 hide post
  // ─────────────────────────────────────────────────────────────────────────
  final String? hidePostMessage;
  final CubitStates hidePostActionState;

  // ─────────────────────────────────────────────────────────────────────────
  // 📦 block user
  // ─────────────────────────────────────────────────────────────────────────
  final String? blockUserMessage;
  final CubitStates blockUserActionState;

  // ─────────────────────────────────────────────────────────────────────────  // 📡 Connectivity
  // ───────────────────────────────────────────────────────────────────────
  final bool isOffline;
  final bool isShowingCachedData;

  // ───────────────────────────────────────────────────────────────────────  // 🗳️ Poll Vote
  // ─────────────────────────────────────────────────────────────────────────
  final String? pollVoteMessage;
  final CubitStates pollVoteActionState;

  // ─────────────────────────────────────────────────────────────────────────
  // 🏗️ Constructor
  // ─────────────────────────────────────────────────────────────────────────
  const HomeState({
    // Posts
    this.categoryPostsMap = const {},
    this.selectedCategoryId,
    // Categories
    this.categoriesState = CubitStates.initial,
    this.categories = const [],
    this.categoriesErrorMessage,
    this.categoriesCurrentPage = 1,
    this.categoriesHasMore = true,
    this.categoriesIsLoadingMore = false,
    // Share
    this.shareActionState = CubitStates.initial,
    this.shareMessage,
    this.isShareAdded,
    this.sharePostId,
    // User Info
    this.homeInfo,
    this.fetchNameAndImageState = CubitStates.initial,

    // Save
    this.saveActionState = CubitStates.initial,
    this.saveMessage,

    // delete post
    this.deletePostMessage,
    this.deletePostActionState = CubitStates.initial,

    // hide post
    this.hidePostMessage,
    this.hidePostActionState = CubitStates.initial,

    // block user
    this.blockUserMessage,
    this.blockUserActionState = CubitStates.initial,

    // archive post
    this.archivePostMessage,
    this.archivePostActionState = CubitStates.initial,
    this.sessionStartModel,

    // poll vote
    this.pollVoteMessage,
    this.pollVoteActionState = CubitStates.initial,

    // connectivity
    this.isOffline = false,
    this.isShowingCachedData = false,
  });

  // ─────────────────────────────────────────────────────────────────────────
  // 📋 Copy With
  // ─────────────────────────────────────────────────────────────────────────
  HomeState copyWith({
    // Posts
    Map<String?, CategoryPostsData>? categoryPostsMap,
    String? selectedCategoryId,
    bool resetSelectedCategory = false,
    // Categories
    CubitStates? categoriesState,
    List<CategoryModel>? categories,
    String? categoriesErrorMessage,
    int? categoriesCurrentPage,
    bool? categoriesHasMore,
    bool? categoriesIsLoadingMore,
    // Share
    CubitStates? shareActionState,
    String? shareMessage,
    bool? isShareAdded,
    String? sharePostId,
    // User Info
    ImageAndNameModel? homeInfo,
    CubitStates? fetchNameAndImageState,

    // Save
    CubitStates? saveActionState,
    String? saveMessage,

    // delete post
    String? deletePostMessage,
    CubitStates? deletePostActionState,

    // hide post
    String? hidePostMessage,
    CubitStates? hidePostActionState,

    // block user
    String? blockUserMessage,
    CubitStates? blockUserActionState,

    // archive post
    String? archivePostMessage,
    CubitStates? archivePostActionState,
    SessionStartModel? sessionStartModel,

    // poll vote
    String? pollVoteMessage,
    CubitStates? pollVoteActionState,

    // connectivity
    bool? isOffline,
    bool? isShowingCachedData,
  }) {
    return HomeState(
      // Posts
      categoryPostsMap: categoryPostsMap ?? this.categoryPostsMap,
      selectedCategoryId: resetSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      // Categories
      categoriesState: categoriesState ?? this.categoriesState,
      categories: categories ?? this.categories,
      categoriesErrorMessage:
          categoriesErrorMessage ?? this.categoriesErrorMessage,
      categoriesCurrentPage:
          categoriesCurrentPage ?? this.categoriesCurrentPage,
      categoriesHasMore: categoriesHasMore ?? this.categoriesHasMore,
      categoriesIsLoadingMore:
          categoriesIsLoadingMore ?? this.categoriesIsLoadingMore,
      // Share
      shareActionState: shareActionState ?? this.shareActionState,
      shareMessage: shareMessage ?? this.shareMessage,
      isShareAdded: isShareAdded ?? this.isShareAdded,
      sharePostId: sharePostId ?? this.sharePostId,
      // User Info
      homeInfo: homeInfo ?? this.homeInfo,
      fetchNameAndImageState:
          fetchNameAndImageState ?? this.fetchNameAndImageState,

      // Save
      saveActionState: saveActionState ?? this.saveActionState,
      saveMessage: saveMessage ?? this.saveMessage,

      // delete post
      deletePostMessage: deletePostMessage ?? this.deletePostMessage,
      deletePostActionState:
          deletePostActionState ?? this.deletePostActionState,

      // hide post
      hidePostMessage: hidePostMessage ?? this.hidePostMessage,
      hidePostActionState: hidePostActionState ?? this.hidePostActionState,

      // block user
      blockUserMessage: blockUserMessage ?? this.blockUserMessage,
      blockUserActionState: blockUserActionState ?? this.blockUserActionState,

      // archive post
      archivePostMessage: archivePostMessage ?? this.archivePostMessage,
      archivePostActionState:
          archivePostActionState ?? this.archivePostActionState,
      sessionStartModel: sessionStartModel ?? this.sessionStartModel,

      // poll vote
      pollVoteMessage: pollVoteMessage ?? this.pollVoteMessage,
      pollVoteActionState: pollVoteActionState ?? this.pollVoteActionState,

      // connectivity
      isOffline: isOffline ?? this.isOffline,
      isShowingCachedData: isShowingCachedData ?? this.isShowingCachedData,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔧 Helper Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// إدراج بوست في مكان معين في كاتيجوري معينة (للـ Rollback)
  HomeState insertPostInCategory({
    required String? categoryId,
    required PostModel post,
    required int index,
  }) {
    return updateCategoryPosts(categoryId, (data) {
      final posts = List<PostModel>.from(data.posts);

      // إدراج البوست في مكانه الأصلي
      if (index >= 0 && index <= posts.length) {
        posts.insert(index, post);
      } else {
        posts.insert(0, post);
      }

      return data.copyWith(posts: posts);
    });
  }

  /// تحديث بيانات كاتيجوري معينة
  HomeState updateCategoryPosts(
    String? categoryId,
    CategoryPostsData Function(CategoryPostsData) update,
  ) {
    final currentData =
        categoryPostsMap[categoryId] ?? const CategoryPostsData();
    final newData = update(currentData);
    final newMap = Map<String?, CategoryPostsData>.from(categoryPostsMap);
    newMap[categoryId] = newData;
    return copyWith(categoryPostsMap: newMap);
  }

  /// تحديث بوست معين في الكاتيجوري الحالية
  HomeState updatePostInCurrentCategory(
    String postId,
    PostModel Function(PostModel) update,
  ) {
    final currentPosts = posts;
    final postIndex = currentPosts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return this;

    final updatedPosts = List<PostModel>.from(currentPosts);
    updatedPosts[postIndex] = update(currentPosts[postIndex]);

    return updateCategoryPosts(
      selectedCategoryId,
      (data) => data.copyWith(posts: updatedPosts),
    );
  }

  /// تحديث بوست معين في كل الكاتيجوريز اللي موجود فيها
  HomeState updatePostInAllCategories(
    String postId,
    PostModel Function(PostModel) update,
  ) {
    final newMap = Map<String?, CategoryPostsData>.from(categoryPostsMap);

    for (final entry in newMap.entries) {
      final categoryId = entry.key;
      final categoryData = entry.value;
      final postIndex = categoryData.posts.indexWhere(
        (p) => p.postId == postId,
      );

      if (postIndex != -1) {
        final updatedPosts = List<PostModel>.from(categoryData.posts);
        updatedPosts[postIndex] = update(categoryData.posts[postIndex]);
        newMap[categoryId] = categoryData.copyWith(posts: updatedPosts);
      }
    }

    return copyWith(categoryPostsMap: newMap);
  }

  /// إعادة تعيين كل شيء للقيم الأولية (للريفريش الكامل)
  HomeState reset() {
    return HomeState(
      // الحفاظ على بيانات اليوزر المخزنة
      homeInfo: homeInfo,
      fetchNameAndImageState: fetchNameAndImageState,
      // الحفاظ على حالة الاتصال
      isOffline: isOffline,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 📊 Equatable Props
  // ─────────────────────────────────────────────────────────────────────────
  @override
  List<Object?> get props => [
    // Posts
    categoryPostsMap,
    selectedCategoryId,
    // Categories
    categoriesState,
    categories,
    categoriesErrorMessage,
    categoriesCurrentPage,
    categoriesHasMore,
    categoriesIsLoadingMore,
    // Share
    shareActionState,
    shareMessage,
    isShareAdded,
    sharePostId,
    // User Info
    homeInfo,
    fetchNameAndImageState,
    // Save
    saveActionState,
    saveMessage,

    // delete post
    deletePostMessage,
    deletePostActionState,
    // hide post
    hidePostMessage,
    hidePostActionState,
    // block user
    blockUserMessage,
    blockUserActionState,

    // archive post
    archivePostMessage,
    archivePostActionState,
    sessionStartModel,

    // poll vote
    pollVoteMessage,
    pollVoteActionState,

    // connectivity
    isOffline,
    isShowingCachedData,
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
// 📌 CATEGORY POSTS DATA - بيانات البوستات لكل كاتيجوري
// ═══════════════════════════════════════════════════════════════════════════
class CategoryPostsData extends Equatable {
  final CubitStates state;
  final List<PostModel> posts;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final double? nextCursor;

  const CategoryPostsData({
    this.state = CubitStates.initial,
    this.posts = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.nextCursor,
  });

  /// هل البيانات محملة وجاهزة للعرض
  bool get isLoaded => state == CubitStates.success && posts.isNotEmpty;

  /// هل في حالة تحميل
  bool get isLoading => state == CubitStates.loading;

  /// هل فشل التحميل
  bool get isError => state == CubitStates.failure;

  CategoryPostsData copyWith({
    CubitStates? state,
    List<PostModel>? posts,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    double? nextCursor,
  }) {
    return CategoryPostsData(
      state: state ?? this.state,
      posts: posts ?? this.posts,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      nextCursor: nextCursor ?? this.nextCursor,
    );
  }

  @override
  List<Object?> get props => [
    state,
    posts,
    errorMessage,
    currentPage,
    hasMore,
    isLoadingMore,
    nextCursor,
  ];
}
