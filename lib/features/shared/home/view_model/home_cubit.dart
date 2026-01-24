import 'dart:developer';

import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/features/shared/home/model/Image_and_name_model.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
import '../../../../my_import.dart';
import '../reposiotry/home_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository homeRepository;
  static const int _pageSize = 5;

  HomeCubit(this.homeRepository) : super(const HomeState()) {
    _loadCachedUserData();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 INITIALIZATION & REFRESH
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحميل بيانات اليوزر من الكاش عند البداية
  void _loadCachedUserData() {
    final cachedImage = CachNetwork.getStringData(key: kMyProfileImage);
    final cachedName = CachNetwork.getStringData(key: kMyProfileName);

    if (cachedImage.isNotEmpty || cachedName.isNotEmpty) {
      emit(
        state.copyWith(
          homeInfo: ImageAndNameModel(
            image: cachedImage,
            name: cachedName,
            notifications: 0,
          ),
          fetchNameAndImageState: CubitStates.success,
        ),
      );
    }
  }

  /// ريفريش كامل للصفحة - يعيد كل شيء للقيم الأولية ويحمل من جديد
  Future<void> refreshHome() async {
    // إعادة تعيين كل شيء للقيم الأولية (مع الحفاظ على بيانات اليوزر المخزنة)
    emit(state.reset());

    // تحميل كل البيانات من جديد بالتوازي
    await Future.wait([
      fetchNameAndImage(),
      fetchCategories(),
      _fetchPostsForCategory(null),
    ]);
  }

  /// تحميل البيانات الأولية للهوم
  Future<void> initHome() async {
    await Future.wait([
      fetchNameAndImage(),
      fetchCategories(),
      _fetchPostsForCategory(null),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 👤 USER INFO
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> fetchNameAndImage() async {
    if (state.homeInfo == null) {
      emit(state.copyWith(fetchNameAndImageState: CubitStates.loading));
    }

    final result = await homeRepository.fetchNameAndImage();

    result.fold(
      (failure) {
        if (state.homeInfo == null) {
          emit(state.copyWith(fetchNameAndImageState: CubitStates.failure));
        }
      },
      (data) {
        // حفظ في الكاش
        CachNetwork.setData(key: kMyProfileImage, value: data.image);
        CachNetwork.setData(key: kMyProfileName, value: data.name);

        // تحديث الـ State فقط لو البيانات اتغيرت
        if (_isUserInfoChanged(data)) {
          emit(
            state.copyWith(
              fetchNameAndImageState: CubitStates.success,
              homeInfo: data,
            ),
          );
        }
      },
    );
  }

  bool _isUserInfoChanged(ImageAndNameModel newData) {
    return state.homeInfo?.image != newData.image ||
        state.homeInfo?.name != newData.name ||
        state.homeInfo?.notifications != newData.notifications;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📂 CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> fetchCategories({bool loadMore = false}) async {
    if (loadMore) {
      await _loadMoreCategories();
    } else {
      await _fetchInitialCategories();
    }
  }

  Future<void> _fetchInitialCategories() async {
    emit(
      state.copyWith(
        categoriesState: CubitStates.loading,
        categories: [],
        categoriesCurrentPage: 1,
        categoriesHasMore: true,
      ),
    );

    final result = await homeRepository.fetchAllCategories(1);

    result.fold(
      (failure) => emit(
        state.copyWith(
          categoriesState: CubitStates.failure,
          categoriesErrorMessage: failure.message,
        ),
      ),
      (response) {
        final cats = response.data?.categories ?? [];
        final serverPageSize = response.data?.pagination?.pageSize ?? _pageSize;
        emit(
          state.copyWith(
            categoriesState: CubitStates.success,
            categories: cats,
            categoriesCurrentPage: 1,
            categoriesHasMore: cats.length >= serverPageSize,
          ),
        );
      },
    );
  }

  Future<void> _loadMoreCategories() async {
    if (state.categoriesIsLoadingMore || !state.categoriesHasMore) return;

    emit(state.copyWith(categoriesIsLoadingMore: true));

    final nextPage = state.categoriesCurrentPage + 1;
    final result = await homeRepository.fetchAllCategories(nextPage);

    result.fold(
      (failure) => emit(
        state.copyWith(
          categoriesIsLoadingMore: false,
          categoriesErrorMessage: failure.message,
        ),
      ),
      (response) {
        final newCats = response.data?.categories ?? [];
        final serverPageSize = response.data?.pagination?.pageSize ?? _pageSize;
        emit(
          state.copyWith(
            categories: [...state.categories, ...newCats],
            categoriesCurrentPage: nextPage,
            categoriesHasMore: newCats.length >= serverPageSize,
            categoriesIsLoadingMore: false,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📝 POSTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// تغيير الكاتيجوري المختارة وتحميل البوستات
  Future<void> selectCategory(String? categoryId) async {
    // لو نفس الكاتيجوري، لا تفعل شيء
    if (categoryId == state.selectedCategoryId) return;

    // تغيير الكاتيجوري المختارة
    emit(
      state.copyWith(
        selectedCategoryId: categoryId,
        resetSelectedCategory: categoryId == null,
      ),
    );

    // لو البيانات موجودة ومحملة، لا تحمل من جديد
    final categoryData = state.categoryPostsMap[categoryId];
    if (categoryData != null && categoryData.isLoaded) return;

    // تحميل البوستات للكاتيجوري الجديدة
    await _fetchPostsForCategory(categoryId);
  }

  /// تحميل المزيد من البوستات للكاتيجوري الحالية
  Future<void> loadMorePosts() async {
    final categoryId = state.selectedCategoryId;
    final currentData = state.currentCategoryPosts;

    if (currentData.isLoadingMore || !currentData.hasMore) return;

    // تحديث حالة الـ loading more
    emit(
      state.updateCategoryPosts(
        categoryId,
        (data) => data.copyWith(isLoadingMore: true),
      ),
    );

    final nextPage = currentData.currentPage + 1;
    final result = await homeRepository.fetchPosts(
      page: nextPage,
      categoryId: categoryId,
    );

    result.fold(
      (failure) => emit(
        state.updateCategoryPosts(
          categoryId,
          (data) => data.copyWith(
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
        ),
      ),
      (newPosts) => emit(
        state.updateCategoryPosts(
          categoryId,
          (data) => data.copyWith(
            posts: [...data.posts, ...newPosts],
            currentPage: nextPage,
            hasMore: newPosts.length >= _pageSize,
            isLoadingMore: false,
          ),
        ),
      ),
    );
  }

  /// تحميل البوستات لكاتيجوري معينة (داخلي)
  Future<void> _fetchPostsForCategory(String? categoryId) async {
    // تحديث حالة الـ loading
    emit(
      state.updateCategoryPosts(
        categoryId,
        (data) => data.copyWith(
          state: CubitStates.loading,
          posts: [],
          currentPage: 1,
          hasMore: true,
        ),
      ),
    );

    final result = await homeRepository.fetchPosts(
      page: 1,
      categoryId: categoryId,
    );

    result.fold(
      (failure) => emit(
        state.updateCategoryPosts(
          categoryId,
          (data) => data.copyWith(
            state: CubitStates.failure,
            errorMessage: failure.message,
          ),
        ),
      ),
      (postsList) => emit(
        state.updateCategoryPosts(
          categoryId,
          (data) => data.copyWith(
            state: CubitStates.success,
            posts: postsList,
            currentPage: 1,
            hasMore: postsList.length >= _pageSize,
          ),
        ),
      ),
    );
  }

  /// تعيين بوست ابتدائي (للاستخدام عند فتح بوست من مكان آخر)
  void setInitialPost(PostModel post) {
    emit(
      state.updateCategoryPosts(
        state.selectedCategoryId,
        (data) => data.copyWith(posts: [post], state: CubitStates.success),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ❤️ REACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  void reactToPost({required String postId, ReactionType? reactionType}) {
    final post = _findPost(postId);
    if (post == null) return;

    // لا تغيير لو نفس الريأكشن
    if (post.myReaction == reactionType && reactionType != null) return;
    if (post.myReaction == null && reactionType == null) return;

    final isRemoving = reactionType == null;
    final oldReaction = post.myReaction;

    // حساب العدد الجديد
    int newLikesCount = post.likesCount;
    if (isRemoving) {
      newLikesCount = (post.likesCount - 1).clamp(0, post.likesCount);
    } else if (oldReaction == null) {
      newLikesCount = post.likesCount + 1;
    }

    // حساب التوب ريأكشنز
    final newTopReactions = calculateTopReactions(
      currentTopReactions: post.topReactions,
      oldReaction: oldReaction,
      newReaction: reactionType,
      newLikesCount: newLikesCount,
    );

    // التحديث في كل الكاتيجوريز
    emit(
      state.updatePostInAllCategories(
        postId,
        (p) => p.copyWith(
          likesCount: newLikesCount,
          topReactions: newTopReactions,
          myReaction: reactionType,
          clearMyReaction: isRemoving,
        ),
      ),
    );

    // API Call (Fire and forget)
    homeRepository.reactToPost(
      postId: postId,
      reactionType: reactionType,
      isRemove: isRemoving,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 SHARE POST
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> toggleSharePost({required String postId}) async {
    // Reset حالة الشير
    emit(state.copyWith(shareActionState: CubitStates.initial));

    final post = _findPost(postId);
    if (post == null) return;

    final isRemoving = post.isRepostedByMe;
    final newSharesCount = isRemoving
        ? (post.sharesCount - 1).clamp(0, post.sharesCount)
        : post.sharesCount + 1;

    // Optimistic Update في كل الكاتيجوريز
    emit(
      state.updatePostInAllCategories(
        postId,
        (p) => p.copyWith(
          sharesCount: newSharesCount,
          isRepostedByMe: !p.isRepostedByMe,
        ),
      ),
    );

    // API Call
    final result = await homeRepository.sharePost(
      postId: postId,
      action: isRemoving ? "remove" : "add",
    );

    result.fold(
      (failure) {
        log('>>>>>>>>>>>>>>>>>Share Post Failed: ${failure.message}');
        // Rollback في كل الكاتيجوريز
        emit(
          state.updatePostInAllCategories(
            postId,
            (p) => p.copyWith(
              sharesCount: post.sharesCount,
              isRepostedByMe: post.isRepostedByMe,
            ),
          ),
        );
        emit(
          state.copyWith(
            shareActionState: CubitStates.failure,
            shareMessage: failure.message,
          ),
        );
      },
      (message) {
        log('>>>>>>>>>>>>>>>>>Share Post Success: $message');
        emit(
          state.copyWith(
            shareActionState: CubitStates.success,
            shareMessage: message,
            isShareAdded: !isRemoving,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💾 SAVE POST
  // ═══════════════════════════════════════════════════════════════════════════

  void toggleSavePost({required String postId}) {
    final post = _findPost(postId);
    if (post == null) return;

    emit(
      state.updatePostInCurrentCategory(
        postId,
        (p) => p.copyWith(isSaved: !p.isSaved),
      ),
    );

    // TODO: API Call
    // homeRepository.toggleSavePost(postId: postId, isSaved: !post.isSaved);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 👥 FOLLOW ADVISOR
  // ═══════════════════════════════════════════════════════════════════════════

  void toggleFollowAdvisor({required String advisorId}) {
    final currentPosts = state.posts;
    final updatedPosts = currentPosts.map((post) {
      if (post.advisorId == advisorId) {
        return post.copyWith(isFollowing: !post.isFollowing);
      }
      return post;
    }).toList();

    emit(
      state.updateCategoryPosts(
        state.selectedCategoryId,
        (data) => data.copyWith(posts: updatedPosts),
      ),
    );

    // TODO: API Call
    // homeRepository.toggleFollowAdvisor(advisorId: advisorId);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔧 HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  PostModel? _findPost(String postId) {
    final posts = state.posts;
    final index = posts.indexWhere((p) => p.postId == postId);
    return index != -1 ? posts[index] : null;
  }
}
