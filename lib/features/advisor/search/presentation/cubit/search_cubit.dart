// features/shared/search/presentation/cubit/search_cubit.dart
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

  Future<void> search({
    required String query,
    String type = 'all',
    bool debounce = true,
    bool showLoading = true,
  }) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    _searchDebounce?.cancel();

    if (!debounce) {
      _emitLoading(query, showLoading);
      await _executeSearch(query, type);
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      _emitLoading(query, showLoading);
      await _executeSearch(query, type);
    });
  }

  void _emitLoading(String query, bool showLoading) {
    if (showLoading) {
      emit(
        state.copyWith(
          query: query,
          searchStatus: CubitStates.loading,
          errorMessage: null,
        ),
      );
    } else {
      // Just update query and reset error to start silent loading
      emit(
        state.copyWith(
          query: query,
          errorMessage: null,
        ),
      );
    }
  }

  Future<void> _executeSearch(String query, String type) async {
    try {
      final results = await _searchRepository.search(
        query: query,
        type: type,
        page: 1,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          searchStatus: CubitStates.success,
          lastSearchType: type,
          advisors: results.advisors,
          posts: results.posts,
          users: results.users,
          events: results.events,
          hasMore: results.hasMore,
          currentPage: results.currentPage,
          totalPages: results.totalPages,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          searchStatus: CubitStates.failure,
          errorMessage: 'حدث خطأ أثناء البحث: $e',
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.searchStatus == CubitStates.loading ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    if (state.lastSearchType == 'all') return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = state.currentPage + 1;
      final results = await _searchRepository.search(
        query: state.query,
        type: state.lastSearchType,
        page: nextPage,
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          isLoadingMore: false,
          advisors: state.lastSearchType == 'advisors'
              ? [...state.advisors, ...results.advisors]
              : state.advisors,
          posts: state.lastSearchType == 'posts'
              ? [...state.posts, ...results.posts]
              : state.posts,
          users: state.lastSearchType == 'users'
              ? [...state.users, ...results.users]
              : state.users,
          events: state.lastSearchType == 'events'
              ? [...state.events, ...results.events]
              : state.events,
          currentPage: results.currentPage,
          hasMore: results.hasMore,
          totalPages: results.totalPages,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  void clearSearch() {
    emit(const SearchState(query: '', searchStatus: CubitStates.initial));
  }

  Future<void> loadInitialData() async {
    // We can load hot search or recent searches here if needed
    emit(state.copyWith(searchStatus: CubitStates.initial));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 👥 FOLLOW LOGIC
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
    final currentAdvisors = List<SearchAdvisor>.from(state.advisors);
    final advisorIndex = currentAdvisors.indexWhere((a) => a.id == advisorId);

    if (advisorIndex >= 0) {
      final advisor = currentAdvisors[advisorIndex];
      final isCurrentlyFollowing = advisor.isFollowing;

      // Optimistic Update for Advisors list
      final updatedAdvisor = advisor.copyWith(
        isFollowing: !isCurrentlyFollowing,
        followersCount:
            (advisor.followersCount ?? 0) + (isCurrentlyFollowing ? -1 : 1),
      );
      currentAdvisors[advisorIndex] = updatedAdvisor;

      // Also update in posts if exists
      final updatedPosts = state.posts.map((post) {
        if (post.advisorId == advisorId) {
          return post.copyWith(isFollowing: !isCurrentlyFollowing);
        }
        return post;
      }).toList();

      emit(state.copyWith(advisors: currentAdvisors, posts: updatedPosts));

      final result = await _followersRepository.toggleFollow(advisorId);
      result.fold(
        (failure) {
          // Rollback
          final rollbackAdvisors = List<SearchAdvisor>.from(state.advisors);
          rollbackAdvisors[advisorIndex] = advisor;
          final rollbackPosts = state.posts.map((post) {
            if (post.advisorId == advisorId) {
              return post.copyWith(isFollowing: isCurrentlyFollowing);
            }
            return post;
          }).toList();
          emit(
            state.copyWith(advisors: rollbackAdvisors, posts: rollbackPosts),
          );
        },
        (message) {
          // Success code if needed
        },
      );
    }
  }

  Future<void> _toggleFollowUser(String userId) async {
    // For now, let's just call the API.

    final result = await _userFollowingsRepository.toggleFollow(userId);
    result.fold(
      (failure) => log('Follow user failed: ${failure.message}'),
      (message) => log('Follow user success: $message'),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ❤️ POST REACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  void reactToPost({required String postId, ReactionType? reactionType}) {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];
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

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[postIndex] = post.copyWith(
      likesCount: newLikesCount,
      topReactions: newTopReactions,
      myReaction: reactionType,
      clearMyReaction: isRemoving,
    );

    emit(state.copyWith(posts: updatedPosts));

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
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];
    final isCurrentlySaved = post.isSaved;

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[postIndex] = post.copyWith(isSaved: !isCurrentlySaved);

    emit(
      state.copyWith(posts: updatedPosts, actionStatus: CubitStates.initial),
    );

    final result = await _homeRepository.savedPost(
      postId: postId,
      isRemove: isCurrentlySaved,
    );

    result.fold(
      (failure) {
        final rollbackPosts = List<PostModel>.from(state.posts);
        rollbackPosts[postIndex] = post;
        emit(
          state.copyWith(
            posts: rollbackPosts,
            actionStatus: CubitStates.failure,
            actionMessage: failure.message,
          ),
        );
      },
      (message) {
        emit(
          state.copyWith(
            actionStatus: CubitStates.success,
            actionMessage: message,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🗑 DELETE & ARCHIVE
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> deletePost({required String postId}) async {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];
    final updatedPosts = state.posts.where((p) => p.postId != postId).toList();

    emit(
      state.copyWith(posts: updatedPosts, actionStatus: CubitStates.initial),
    );

    final result = await _homeRepository.deletePost(postId: postId);
    result.fold(
      (failure) {
        final rollbackPosts = List<PostModel>.from(state.posts);
        rollbackPosts.insert(postIndex, post);
        emit(
          state.copyWith(
            posts: rollbackPosts,
            actionStatus: CubitStates.failure,
            actionMessage: failure.message,
          ),
        );
      },
      (message) {
        emit(
          state.copyWith(
            actionStatus: CubitStates.success,
            actionMessage: message,
          ),
        );
      },
    );
  }

  Future<void> archivePost({required String postId}) async {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];
    final updatedPosts = state.posts.where((p) => p.postId != postId).toList();

    emit(
      state.copyWith(posts: updatedPosts, actionStatus: CubitStates.initial),
    );

    final result = await _homeRepository.archivePost(postId: postId);
    result.fold(
      (failure) {
        final rollbackPosts = List<PostModel>.from(state.posts);
        rollbackPosts.insert(postIndex, post);
        emit(
          state.copyWith(
            posts: rollbackPosts,
            actionStatus: CubitStates.failure,
            actionMessage: failure.message,
          ),
        );
      },
      (message) {
        emit(
          state.copyWith(
            actionStatus: CubitStates.success,
            actionMessage: message,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 👁️ HIDE & BLOCK
  // ═══════════════════════════════════════════════════════════════════════════

  void toggleHidePost({required String postId}) {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];
    final newHideState = !post.isHidden;

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[postIndex] = post.copyWith(isHidden: newHideState);

    emit(state.copyWith(posts: updatedPosts));
    _homeRepository.hidePost(postId: postId, isHide: newHideState);
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
      (failure) {
        emit(
          state.copyWith(
            actionStatus: CubitStates.failure,
            actionMessage: failure.message,
          ),
        );
      },
      (message) {
        final updatedPosts = state.posts
            .map((post) {
              if (post.postId == visiblePostId) {
                return post.copyWith(isBlocked: true);
              }
              return post;
            })
            .where((p) => p.advisorId != advisorId || p.postId == visiblePostId)
            .toList();

        emit(
          state.copyWith(
            posts: updatedPosts,
            actionStatus: CubitStates.success,
            actionMessage: message,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 SHARE
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> voteInPoll({
    required String postId,
    required String choiceText,
  }) async {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];
    if (post.pollModel == null) return;

    // البدء بالتحديث اللحظي (Optimistic update) لسرعة تفاعل الواجهة
    final choiceIndex = post.pollModel!.pollChoices.indexWhere(
      (c) => c.choice == choiceText,
    );
    if (choiceIndex == -1) return;

    final result = await _homeRepository.voteInPoll(
      postId: postId,
      choiceIndex: choiceIndex.toString(),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            actionStatus: CubitStates.failure,
            actionMessage: failure.message,
          ),
        );
      },
      (success) {
        final updatedChoices = post.pollModel!.pollChoices.asMap().entries.map((
          entry,
        ) {
          final idx = entry.key;
          final choice = entry.value;
          if (idx == choiceIndex) {
            return choice.copyWith(votes: choice.votes + 1, isSelected: true);
          }
          return choice;
        }).toList();

        final updatedPost = post.copyWith(
          pollModel: post.pollModel!.copyWith(
            pollChoices: updatedChoices,
            totalPollVotes: post.pollModel!.totalPollVotes + 1,
          ),
        );

        final updatedPosts = List<PostModel>.from(state.posts);
        updatedPosts[postIndex] = updatedPost;

        emit(
          state.copyWith(
            posts: updatedPosts,
            actionStatus: CubitStates.success,
            actionMessage: 'تم التصويت بنجاح',
          ),
        );
      },
    );
  }

  Future<void> toggleSharePost({required String postId}) async {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];
    final isRemoving = post.isRepostedByMe;
    final newSharesCount = isRemoving
        ? (post.sharesCount - 1).clamp(0, post.sharesCount)
        : post.sharesCount + 1;

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[postIndex] = post.copyWith(
      sharesCount: newSharesCount,
      isRepostedByMe: !isRemoving,
    );

    emit(
      state.copyWith(posts: updatedPosts, actionStatus: CubitStates.initial),
    );

    final result = await _homeRepository.sharePost(
      postId: postId,
      action: isRemoving ? "remove" : "add",
    );

    result.fold(
      (failure) {
        final rollbackPosts = List<PostModel>.from(state.posts);
        rollbackPosts[postIndex] = post;
        emit(
          state.copyWith(
            posts: rollbackPosts,
            actionStatus: CubitStates.failure,
            actionMessage: failure.message,
          ),
        );
      },
      (message) {
        emit(
          state.copyWith(
            actionStatus: CubitStates.success,
            actionMessage: message,
          ),
        );
      },
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
