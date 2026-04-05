import 'dart:async';
import 'dart:developer';

import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_advisor_model.dart';
import 'package:tayseer/features/advisor/search/data/repos/search_repository.dart';
import 'package:tayseer/features/shared/followers/data/repositories/followers_repository.dart';
import 'package:tayseer/features/shared/followers/data/repositories/user_followings_repository.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/my_import.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _searchRepository;
  final HomeRepository _homeRepository;
  final FollowersRepository _followersRepository;
  final UserFollowingsRepository _userFollowingsRepository;
  Timer? _searchDebounce;

  SearchCubit(
    this._searchRepository,
    this._homeRepository,
    this._followersRepository,
    this._userFollowingsRepository,
  ) : super(const SearchState());

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔍 SEARCH
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> search({
    required String query,
    String type = 'all',
    bool debounce = true,
  }) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    _searchDebounce?.cancel();

    if (!debounce) {
      await _executeSearch(query, type);
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      await _executeSearch(query, type);
    });
  }

  Future<void> _executeSearch(String query, String type) async {
    if (isClosed) return;

    final isNewQuery = query != state.query;

    // لو query جديد، امسح بيانات كل الـ tabs
    var newState = isNewQuery
        ? state.clearAllTabs().copyWith(
            query: query,
            searchStatus: CubitStates.initial,
            errorMessage: null,
          )
        : state.copyWith(query: query, errorMessage: null);

    // الـ tab الحالي - لو مفيش بيانات قديمة يظهر skeleton، غير كده يظهر البيانات القديمة
    final currentTabData = newState.tabData(type);
    final showSkeleton = !currentTabData.hasFetchedOnce;

    newState = newState.copyWith(
      loadingTabId: type,
      searchStatus: showSkeleton ? CubitStates.loading : newState.searchStatus,
    );
    emit(newState);

    try {
      final results = await _searchRepository.search(
        query: query,
        type: type,
        page: 1,
      );
      if (isClosed) return;

      // تحديث بيانات الـ tab ده بس
      final updatedTabData = TabSearchData(
        advisors: results.advisors,
        posts: results.posts,
        users: results.users,
        events: results.events,
        hasMore: results.hasMore,
        currentPage: results.currentPage,
        totalPages: results.totalPages,
        hasFetchedOnce: true,
      );

      emit(
        state
            .updateTab(type, updatedTabData)
            .copyWith(
              searchStatus: CubitStates.success,
              loadingTabId: '',
              errorMessage: null,
              errorTabId: null,
            ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          searchStatus: CubitStates.failure,
          errorMessage: 'حدث خطأ أثناء البحث: $e',
          errorTabId: type,
          loadingTabId: '',
        ),
      );
    }
  }

  Future<void> loadMore({required String tabId}) async {
    if (isClosed) return;
    final tabData = state.tabData(tabId);
    if (state.isLoading || tabData.isLoadingMore || !tabData.hasMore) return;
    if (tabId == 'all') return;

    emit(state.updateTab(tabId, tabData.copyWith(isLoadingMore: true)));

    try {
      final results = await _searchRepository.search(
        query: state.query,
        type: tabId,
        page: tabData.currentPage + 1,
      );
      if (isClosed) return;

      final updated = tabData.copyWith(
        isLoadingMore: false,
        advisors: tabId == 'advisors'
            ? [...tabData.advisors, ...results.advisors]
            : tabData.advisors,
        posts: tabId == 'posts'
            ? [...tabData.posts, ...results.posts]
            : tabData.posts,
        users: tabId == 'users'
            ? [...tabData.users, ...results.users]
            : tabData.users,
        events: tabId == 'events'
            ? [...tabData.events, ...results.events]
            : tabData.events,
        currentPage: results.currentPage,
        hasMore: results.hasMore,
        totalPages: results.totalPages,
      );
      emit(state.updateTab(tabId, updated));
    } catch (_) {
      if (isClosed) return;
      emit(state.updateTab(tabId, tabData.copyWith(isLoadingMore: false)));
    }
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    emit(const SearchState());
  }

  Future<void> loadInitialData() async {
    emit(state.copyWith(searchStatus: CubitStates.initial));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 👥 FOLLOW
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> toggleFollow({
    required String id,
    required String userType,
  }) async {
    if (userType == 'Advisor') {
      await _toggleFollowAdvisor(id);
    } else {
      await _toggleFollowUser(id);
    }
  }

  Future<void> _toggleFollowAdvisor(String advisorId) async {
    // البحث في advisors tab أو all tab
    final advisorsData = state.tabData('advisors');
    final allData = state.tabData('all');

    int idx = advisorsData.advisors.indexWhere((a) => a.id == advisorId);
    final bool foundInAdvisorsTab = idx >= 0;

    // لو مش موجود في advisors tab، دور في all tab
    int allIdx = allData.advisors.indexWhere((a) => a.id == advisorId);
    if (!foundInAdvisorsTab && allIdx < 0) return;

    // جيب الـ advisor من أي tab موجود فيه
    final advisor = foundInAdvisorsTab
        ? advisorsData.advisors[idx]
        : allData.advisors[allIdx];
    final isFollowing = advisor.isFollowing;
    final updatedAdvisor = advisor.copyWith(
      isFollowing: !isFollowing,
      followersCount: (advisor.followersCount ?? 0) + (isFollowing ? -1 : 1),
    );

    // تحديث في advisors tab لو موجود
    final updatedAdvisors = List<SearchAdvisor>.from(advisorsData.advisors);
    if (foundInAdvisorsTab) {
      updatedAdvisors[idx] = updatedAdvisor;
    }

    // تحديث في all tab لو موجود
    final updatedAllAdvisors = List<SearchAdvisor>.from(allData.advisors);
    if (allIdx >= 0) {
      updatedAllAdvisors[allIdx] = updatedAdvisor;
    }

    // تحديث في posts tab كمان
    final postsData = state.tabData('posts');
    final updatedPosts = postsData.posts.map((p) {
      if (p.advisorId == advisorId) {
        return p.copyWith(isFollowing: !isFollowing);
      }
      return p;
    }).toList();

    var newState = state
        .updateTab('advisors', advisorsData.copyWith(advisors: updatedAdvisors))
        .updateTab('all', allData.copyWith(advisors: updatedAllAdvisors))
        .updateTab('posts', postsData.copyWith(posts: updatedPosts));
    emit(newState);

    final result = await _followersRepository.toggleFollow(
      advisorId,
      isCurrentlyFollowing: isFollowing,
    );
    result.fold((failure) {
      // Rollback
      final rollback = state
          .updateTab('advisors', advisorsData)
          .updateTab('all', allData)
          .updateTab('posts', postsData);
      emit(rollback);
    }, (_) {});
  }

  Future<void> _toggleFollowUser(String userId) async {
    final result = await _userFollowingsRepository.toggleFollow(
      userId,
      isCurrentlyFollowing: false,
    );
    result.fold(
      (f) => log('Follow user failed: ${f.message}'),
      (m) => log('Follow user success: $m'),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🛠 POST HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// يجيب الـ post من posts tab أو all tab، ويرجع (post, postsTabData, allTabData, postsIdx, allIdx)
  ({
    PostModel? post,
    TabSearchData postsData,
    TabSearchData allData,
    int postsIdx,
    int allIdx,
  })
  _findPost(String postId) {
    final postsData = state.tabData('posts');
    final allData = state.tabData('all');
    final postsIdx = postsData.posts.indexWhere((p) => p.postId == postId);
    final allIdx = allData.posts.indexWhere((p) => p.postId == postId);
    final post = postsIdx >= 0
        ? postsData.posts[postsIdx]
        : allIdx >= 0
        ? allData.posts[allIdx]
        : null;
    return (
      post: post,
      postsData: postsData,
      allData: allData,
      postsIdx: postsIdx,
      allIdx: allIdx,
    );
  }

  /// يحدث الـ post في posts tab و all tab معاً
  SearchState _updatePostInBothTabs({
    required TabSearchData postsData,
    required TabSearchData allData,
    required int postsIdx,
    required int allIdx,
    required PostModel updatedPost,
  }) {
    var newState = state;
    if (postsIdx >= 0) {
      final updated = List<PostModel>.from(postsData.posts);
      updated[postsIdx] = updatedPost;
      newState = newState.updateTab(
        'posts',
        postsData.copyWith(posts: updated),
      );
    }
    if (allIdx >= 0) {
      final updated = List<PostModel>.from(allData.posts);
      updated[allIdx] = updatedPost;
      newState = newState.updateTab('all', allData.copyWith(posts: updated));
    }
    return newState;
  }

  /// يحذف الـ post من posts tab و all tab معاً
  SearchState _removePostFromBothTabs({
    required TabSearchData postsData,
    required TabSearchData allData,
    required String postId,
  }) {
    var newState = state;
    newState = newState.updateTab(
      'posts',
      postsData.copyWith(
        posts: postsData.posts.where((p) => p.postId != postId).toList(),
      ),
    );
    newState = newState.updateTab(
      'all',
      allData.copyWith(
        posts: allData.posts.where((p) => p.postId != postId).toList(),
      ),
    );
    return newState;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ❤️ POST REACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  void reactToPost({required String postId, ReactionType? reactionType}) {
    final found = _findPost(postId);
    if (found.post == null) return;
    final post = found.post!;

    if (post.myReaction == reactionType && reactionType != null) return;

    final isRemoving = reactionType == null;
    final oldReaction = post.myReaction;
    int newLikesCount = post.likesCount;
    if (isRemoving) {
      newLikesCount = (post.likesCount - 1).clamp(0, post.likesCount);
    } else if (oldReaction == null) {
      newLikesCount = post.likesCount + 1;
    }

    final newTopReactions = calculateTopReactions(
      currentTopReactions: post.topReactions,
      oldReaction: oldReaction,
      newReaction: reactionType,
      newLikesCount: newLikesCount,
    );

    final updatedPost = post.copyWith(
      likesCount: newLikesCount,
      topReactions: newTopReactions,
      myReaction: reactionType,
      clearMyReaction: isRemoving,
    );

    emit(
      _updatePostInBothTabs(
        postsData: found.postsData,
        allData: found.allData,
        postsIdx: found.postsIdx,
        allIdx: found.allIdx,
        updatedPost: updatedPost,
      ),
    );
    _homeRepository.reactToPost(
      postId: postId,
      reactionType: reactionType,
      isRemove: isRemoving,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 💾 SAVE POST
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> toggleSavePost({required String postId}) async {
    final found = _findPost(postId);
    if (found.post == null) return;
    final post = found.post!;

    final updatedPost = post.copyWith(isSaved: !post.isSaved);
    emit(
      _updatePostInBothTabs(
        postsData: found.postsData,
        allData: found.allData,
        postsIdx: found.postsIdx,
        allIdx: found.allIdx,
        updatedPost: updatedPost,
      ).copyWith(actionStatus: CubitStates.initial),
    );

    final result = await _homeRepository.savedPost(
      postId: postId,
      isRemove: post.isSaved,
    );
    result.fold(
      (f) => emit(
        _updatePostInBothTabs(
          postsData: found.postsData,
          allData: found.allData,
          postsIdx: found.postsIdx,
          allIdx: found.allIdx,
          updatedPost: post, // rollback
        ).copyWith(actionStatus: CubitStates.failure, actionMessage: f.message),
      ),
      (m) => emit(
        state.copyWith(actionStatus: CubitStates.success, actionMessage: m),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🗑 DELETE & ARCHIVE
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> deletePost({required String postId}) async {
    final found = _findPost(postId);
    if (found.post == null) return;
    final post = found.post!;

    emit(
      _removePostFromBothTabs(
        postsData: found.postsData,
        allData: found.allData,
        postId: postId,
      ).copyWith(actionStatus: CubitStates.initial),
    );

    final result = await _homeRepository.deletePost(postId: postId);
    result.fold(
      (f) => emit(
        _updatePostInBothTabs(
          postsData: found.postsData,
          allData: found.allData,
          postsIdx: found.postsIdx,
          allIdx: found.allIdx,
          updatedPost: post, // rollback
        ).copyWith(actionStatus: CubitStates.failure, actionMessage: f.message),
      ),
      (m) => emit(
        state.copyWith(actionStatus: CubitStates.success, actionMessage: m),
      ),
    );
  }

  Future<void> archivePost({required String postId}) async {
    final found = _findPost(postId);
    if (found.post == null) return;
    final post = found.post!;

    emit(
      _removePostFromBothTabs(
        postsData: found.postsData,
        allData: found.allData,
        postId: postId,
      ).copyWith(actionStatus: CubitStates.initial),
    );

    final result = await _homeRepository.archivePost(postId: postId);
    result.fold(
      (f) => emit(
        _updatePostInBothTabs(
          postsData: found.postsData,
          allData: found.allData,
          postsIdx: found.postsIdx,
          allIdx: found.allIdx,
          updatedPost: post, // rollback
        ).copyWith(actionStatus: CubitStates.failure, actionMessage: f.message),
      ),
      (m) => emit(
        state.copyWith(actionStatus: CubitStates.success, actionMessage: m),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 👁️ HIDE & BLOCK
  // ═══════════════════════════════════════════════════════════════════════════

  void toggleHidePost({required String postId}) {
    final found = _findPost(postId);
    if (found.post == null) return;
    final post = found.post!;

    final updatedPost = post.copyWith(isHidden: !post.isHidden);
    emit(
      _updatePostInBothTabs(
        postsData: found.postsData,
        allData: found.allData,
        postsIdx: found.postsIdx,
        allIdx: found.allIdx,
        updatedPost: updatedPost,
      ),
    );
    _homeRepository.hidePost(postId: postId, isHide: !post.isHidden);
  }

  Future<void> blockUser({
    required String visiblePostId,
    required String advisorId,
  }) async {
    if (advisorId.isEmpty) {
      emit(
        state.copyWith(
          actionStatus: CubitStates.failure,
          actionMessage: 'معرف المستخدم غير صحيح',
        ),
      );
      return;
    }

    emit(state.copyWith(actionStatus: CubitStates.loading));

    final result = await _homeRepository.blockUser(userId: advisorId);
    result.fold(
      (f) => emit(
        state.copyWith(
          actionStatus: CubitStates.failure,
          actionMessage: f.message,
        ),
      ),
      (m) {
        // تحديث في posts tab
        final postsData = state.tabData('posts');
        final updatedPostsPosts = postsData.posts
            .map(
              (p) =>
                  p.postId == visiblePostId ? p.copyWith(isBlocked: true) : p,
            )
            .where((p) => p.advisorId != advisorId || p.postId == visiblePostId)
            .toList();

        // تحديث في all tab
        final allData = state.tabData('all');
        final updatedAllPosts = allData.posts
            .map(
              (p) =>
                  p.postId == visiblePostId ? p.copyWith(isBlocked: true) : p,
            )
            .where((p) => p.advisorId != advisorId || p.postId == visiblePostId)
            .toList();

        emit(
          state
              .updateTab('posts', postsData.copyWith(posts: updatedPostsPosts))
              .updateTab('all', allData.copyWith(posts: updatedAllPosts))
              .copyWith(actionStatus: CubitStates.success, actionMessage: m),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📊 POLL & SHARE
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> voteInPoll({
    required String postId,
    required String choiceText,
  }) async {
    final found = _findPost(postId);
    if (found.post == null) return;
    final post = found.post!;
    if (post.pollModel == null) return;

    final choiceIndex = post.pollModel!.pollChoices.indexWhere(
      (c) => c.choice == choiceText,
    );
    if (choiceIndex == -1) return;

    final result = await _homeRepository.voteInPoll(
      postId: postId,
      choiceIndex: choiceIndex.toString(),
    );
    result.fold(
      (f) => emit(
        state.copyWith(
          actionStatus: CubitStates.failure,
          actionMessage: f.message,
        ),
      ),
      (_) {
        final updatedChoices = post.pollModel!.pollChoices.asMap().entries.map((
          e,
        ) {
          if (e.key == choiceIndex) {
            return e.value.copyWith(votes: e.value.votes + 1, isSelected: true);
          }
          return e.value;
        }).toList();

        final updatedPost = post.copyWith(
          pollModel: post.pollModel!.copyWith(
            pollChoices: updatedChoices,
            totalPollVotes: post.pollModel!.totalPollVotes + 1,
          ),
        );

        emit(
          _updatePostInBothTabs(
            postsData: found.postsData,
            allData: found.allData,
            postsIdx: found.postsIdx,
            allIdx: found.allIdx,
            updatedPost: updatedPost,
          ).copyWith(
            actionStatus: CubitStates.success,
            actionMessage: 'تم التصويت بنجاح',
          ),
        );
      },
    );
  }

  Future<void> toggleSharePost({required String postId}) async {
    final found = _findPost(postId);
    if (found.post == null) return;
    final post = found.post!;

    final isRemoving = post.isRepostedByMe;
    final updatedPost = post.copyWith(
      sharesCount: isRemoving
          ? (post.sharesCount - 1).clamp(0, post.sharesCount)
          : post.sharesCount + 1,
      isRepostedByMe: !isRemoving,
    );

    emit(
      _updatePostInBothTabs(
        postsData: found.postsData,
        allData: found.allData,
        postsIdx: found.postsIdx,
        allIdx: found.allIdx,
        updatedPost: updatedPost,
      ).copyWith(actionStatus: CubitStates.initial),
    );

    final result = await _homeRepository.sharePost(
      postId: postId,
      action: isRemoving ? "remove" : "add",
    );
    result.fold(
      (f) => emit(
        _updatePostInBothTabs(
          postsData: found.postsData,
          allData: found.allData,
          postsIdx: found.postsIdx,
          allIdx: found.allIdx,
          updatedPost: post, // rollback
        ).copyWith(actionStatus: CubitStates.failure, actionMessage: f.message),
      ),
      (m) => emit(
        state.copyWith(actionStatus: CubitStates.success, actionMessage: m),
      ),
    );
  }

  void resetActionStatus() {
    emit(
      state.copyWith(actionStatus: CubitStates.initial, actionMessage: null),
    );
  }

  void updatePostLocally(PostModel updatedPost) {
    final found = _findPost(updatedPost.postId);
    if (found.post == null) return;
    emit(
      _updatePostInBothTabs(
        postsData: found.postsData,
        allData: found.allData,
        postsIdx: found.postsIdx,
        allIdx: found.allIdx,
        updatedPost: updatedPost,
      ),
    );
  }

  void markPostAsCommented({
    required String postId,
    required bool isAnonymous,
  }) {
    final found = _findPost(postId);
    if (found.post == null) return;
    final updatedPost = found.post!.copyWith(
      isCommented: true,
      isAnonymous: isAnonymous,
    );
    emit(
      _updatePostInBothTabs(
        postsData: found.postsData,
        allData: found.allData,
        postsIdx: found.postsIdx,
        allIdx: found.allIdx,
        updatedPost: updatedPost,
      ),
    );
  }

  void updateCommentCountByDelta({
    required String postId,
    required int countDelta,
    bool? isCommented,
    bool? isAnonymous,
  }) {
    final found = _findPost(postId);
    if (found.post == null) return;
    final newCount = found.post!.commentsCount + countDelta;
    final updatedPost = found.post!.copyWith(
      commentsCount: newCount < 0 ? 0 : newCount,
      isCommented: isCommented ?? found.post!.isCommented,
      isAnonymous: isAnonymous ?? found.post!.isAnonymous,
    );
    emit(
      _updatePostInBothTabs(
        postsData: found.postsData,
        allData: found.allData,
        postsIdx: found.postsIdx,
        allIdx: found.allIdx,
        updatedPost: updatedPost,
      ),
    );
  }

  void syncCommentCountFromBackend({
    required String postId,
    required int totalCount,
  }) {
    final found = _findPost(postId);
    if (found.post == null) return;
    final updatedPost = found.post!.copyWith(commentsCount: totalCount);
    emit(
      _updatePostInBothTabs(
        postsData: found.postsData,
        allData: found.allData,
        postsIdx: found.postsIdx,
        allIdx: found.allIdx,
        updatedPost: updatedPost,
      ),
    );
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
