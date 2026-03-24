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
    // تحديث في advisors tab
    final advisorsData = state.tabData('advisors');
    final idx = advisorsData.advisors.indexWhere((a) => a.id == advisorId);
    if (idx < 0) return;

    final advisor = advisorsData.advisors[idx];
    final isFollowing = advisor.isFollowing;

    final updatedAdvisors = List<SearchAdvisor>.from(advisorsData.advisors);
    updatedAdvisors[idx] = advisor.copyWith(
      isFollowing: !isFollowing,
      followersCount: (advisor.followersCount ?? 0) + (isFollowing ? -1 : 1),
    );

    // تحديث في posts tab كمان
    final postsData = state.tabData('posts');
    final updatedPosts = postsData.posts.map((p) {
      if (p.advisorId == advisorId)
        return p.copyWith(isFollowing: !isFollowing);
      return p;
    }).toList();

    var newState = state
        .updateTab('advisors', advisorsData.copyWith(advisors: updatedAdvisors))
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
  // ❤️ POST REACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  void reactToPost({required String postId, ReactionType? reactionType}) {
    final postsData = state.tabData('posts');
    final idx = postsData.posts.indexWhere((p) => p.postId == postId);
    if (idx == -1) return;

    final post = postsData.posts[idx];
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

    final updatedPosts = List<PostModel>.from(postsData.posts);
    updatedPosts[idx] = post.copyWith(
      likesCount: newLikesCount,
      topReactions: newTopReactions,
      myReaction: reactionType,
      clearMyReaction: isRemoving,
    );

    emit(state.updateTab('posts', postsData.copyWith(posts: updatedPosts)));
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
    final postsData = state.tabData('posts');
    final idx = postsData.posts.indexWhere((p) => p.postId == postId);
    if (idx == -1) return;

    final post = postsData.posts[idx];
    final updatedPosts = List<PostModel>.from(postsData.posts);
    updatedPosts[idx] = post.copyWith(isSaved: !post.isSaved);

    emit(
      state
          .updateTab('posts', postsData.copyWith(posts: updatedPosts))
          .copyWith(actionStatus: CubitStates.initial),
    );

    final result = await _homeRepository.savedPost(
      postId: postId,
      isRemove: post.isSaved,
    );
    result.fold(
      (f) => emit(
        state
            .updateTab('posts', postsData)
            .copyWith(
              actionStatus: CubitStates.failure,
              actionMessage: f.message,
            ),
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
    final postsData = state.tabData('posts');
    final idx = postsData.posts.indexWhere((p) => p.postId == postId);
    if (idx == -1) return;

    final post = postsData.posts[idx];
    final filtered = postsData.posts.where((p) => p.postId != postId).toList();

    emit(
      state
          .updateTab('posts', postsData.copyWith(posts: filtered))
          .copyWith(actionStatus: CubitStates.initial),
    );

    final result = await _homeRepository.deletePost(postId: postId);
    result.fold(
      (f) {
        final rollback = List<PostModel>.from(state.tabData('posts').posts);
        rollback.insert(idx, post);
        emit(
          state
              .updateTab('posts', postsData.copyWith(posts: rollback))
              .copyWith(
                actionStatus: CubitStates.failure,
                actionMessage: f.message,
              ),
        );
      },
      (m) => emit(
        state.copyWith(actionStatus: CubitStates.success, actionMessage: m),
      ),
    );
  }

  Future<void> archivePost({required String postId}) async {
    final postsData = state.tabData('posts');
    final idx = postsData.posts.indexWhere((p) => p.postId == postId);
    if (idx == -1) return;

    final post = postsData.posts[idx];
    final filtered = postsData.posts.where((p) => p.postId != postId).toList();

    emit(
      state
          .updateTab('posts', postsData.copyWith(posts: filtered))
          .copyWith(actionStatus: CubitStates.initial),
    );

    final result = await _homeRepository.archivePost(postId: postId);
    result.fold(
      (f) {
        final rollback = List<PostModel>.from(state.tabData('posts').posts);
        rollback.insert(idx, post);
        emit(
          state
              .updateTab('posts', postsData.copyWith(posts: rollback))
              .copyWith(
                actionStatus: CubitStates.failure,
                actionMessage: f.message,
              ),
        );
      },
      (m) => emit(
        state.copyWith(actionStatus: CubitStates.success, actionMessage: m),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 👁️ HIDE & BLOCK
  // ═══════════════════════════════════════════════════════════════════════════

  void toggleHidePost({required String postId}) {
    final postsData = state.tabData('posts');
    final idx = postsData.posts.indexWhere((p) => p.postId == postId);
    if (idx == -1) return;

    final post = postsData.posts[idx];
    final updated = List<PostModel>.from(postsData.posts);
    updated[idx] = post.copyWith(isHidden: !post.isHidden);

    emit(state.updateTab('posts', postsData.copyWith(posts: updated)));
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
        final postsData = state.tabData('posts');
        final updated = postsData.posts
            .map(
              (p) =>
                  p.postId == visiblePostId ? p.copyWith(isBlocked: true) : p,
            )
            .where((p) => p.advisorId != advisorId || p.postId == visiblePostId)
            .toList();
        emit(
          state
              .updateTab('posts', postsData.copyWith(posts: updated))
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
    final postsData = state.tabData('posts');
    final idx = postsData.posts.indexWhere((p) => p.postId == postId);
    if (idx == -1) return;

    final post = postsData.posts[idx];
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
          if (e.key == choiceIndex)
            return e.value.copyWith(votes: e.value.votes + 1, isSelected: true);
          return e.value;
        }).toList();

        final updatedPost = post.copyWith(
          pollModel: post.pollModel!.copyWith(
            pollChoices: updatedChoices,
            totalPollVotes: post.pollModel!.totalPollVotes + 1,
          ),
        );

        final updated = List<PostModel>.from(postsData.posts);
        updated[idx] = updatedPost;
        emit(
          state
              .updateTab('posts', postsData.copyWith(posts: updated))
              .copyWith(
                actionStatus: CubitStates.success,
                actionMessage: 'تم التصويت بنجاح',
              ),
        );
      },
    );
  }

  Future<void> toggleSharePost({required String postId}) async {
    final postsData = state.tabData('posts');
    final idx = postsData.posts.indexWhere((p) => p.postId == postId);
    if (idx == -1) return;

    final post = postsData.posts[idx];
    final isRemoving = post.isRepostedByMe;
    final updated = List<PostModel>.from(postsData.posts);
    updated[idx] = post.copyWith(
      sharesCount: isRemoving
          ? (post.sharesCount - 1).clamp(0, post.sharesCount)
          : post.sharesCount + 1,
      isRepostedByMe: !isRemoving,
    );

    emit(
      state
          .updateTab('posts', postsData.copyWith(posts: updated))
          .copyWith(actionStatus: CubitStates.initial),
    );

    final result = await _homeRepository.sharePost(
      postId: postId,
      action: isRemoving ? "remove" : "add",
    );
    result.fold(
      (f) => emit(
        state
            .updateTab('posts', postsData)
            .copyWith(
              actionStatus: CubitStates.failure,
              actionMessage: f.message,
            ),
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

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
