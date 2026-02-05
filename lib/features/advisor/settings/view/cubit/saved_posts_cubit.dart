import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/saved_posts_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/saved_posts_state.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/my_import.dart';

class SavedPostsCubit extends Cubit<SavedPostsState> {
  final SavedPostsRepository _repository;
  final int _pageSize = 10;

  SavedPostsCubit(this._repository) : super(const SavedPostsState()) {
    Future.microtask(() => fetchSavedPosts());
  }

  Future<void> fetchSavedPosts({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;
      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await _repository.fetchSavedPosts(page: nextPage);
      if (isClosed) return;
      result.fold(
        (failure) {
          emit(
            state.copyWith(isLoadingMore: false, errorMessage: failure.message),
          );
        },
        (newPosts) {
          final updatedList = [...state.posts, ...newPosts];
          emit(
            state.copyWith(
              posts: updatedList,
              currentPage: nextPage,
              hasMore: newPosts.length >= _pageSize,
              isLoadingMore: false,
              errorMessage: null,
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(
          status: CubitStates.loading,
          posts: [],
          currentPage: 1,
          hasMore: true,
          errorMessage: null,
        ),
      );

      final result = await _repository.fetchSavedPosts(page: 1);
      if (isClosed) return;
      result.fold(
        (failure) {
          emit(
            state.copyWith(
              status: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (postsList) {
          emit(
            state.copyWith(
              status: CubitStates.success,
              posts: postsList,
              currentPage: 1,
              hasMore: postsList.length >= _pageSize,
              errorMessage: null,
            ),
          );
        },
      );
    }
  }

  // ❤️ REACT TO POST
  void reactToPost({required String postId, ReactionType? reactionType}) {
    final postIndex = state.posts.indexWhere((post) => post.postId == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];
    if (post.myReaction == reactionType) return;

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

    _updatePostInList(postId, updatedPost);

    _repository.reactToPost(
      postId: postId,
      reactionType: reactionType,
      isRemove: isRemoving,
    );
  }

  // 📢 SHARE POST
  Future<void> toggleSharePost({required String postId}) async {
    final postIndex = state.posts.indexWhere((post) => post.postId == postId);
    if (postIndex == -1) return;

    final originalPost = state.posts[postIndex];
    final bool isRemoving = originalPost.isRepostedByMe;

    final updatedPost = originalPost.copyWith(
      sharesCount: isRemoving
          ? (originalPost.sharesCount - 1).clamp(0, originalPost.sharesCount)
          : originalPost.sharesCount + 1,
      isRepostedByMe: !isRemoving,
    );

    _updatePostInList(postId, updatedPost);

    final result = await _repository.sharePost(
      postId: postId,
      action: isRemoving ? "remove" : "add",
    );

    result.fold(
      (failure) {
        _updatePostInList(postId, originalPost);
        emit(
          state.copyWith(
            shareActionState: CubitStates.failure,
            shareMessage: failure.message,
          ),
        );
      },
      (message) {
        emit(
          state.copyWith(
            shareActionState: CubitStates.success,
            shareMessage: message,
            isShareAdded: !isRemoving,
            sharePostId: postId,
          ),
        );
      },
    );
  }

  // 💾 SAVE POST (Toggling it off removes it from this view)
  Future<void> toggleSavePost({required String postId}) async {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final originalPost = state.posts[postIndex];
    final isCurrentlySaved = originalPost.isSaved;

    // Optimistically remove if unsaving
    if (isCurrentlySaved) {
      final updatedPosts = state.posts
          .where((p) => p.postId != postId)
          .toList();
      emit(state.copyWith(posts: updatedPosts));
    } else {
      final updatedPost = originalPost.copyWith(isSaved: true);
      _updatePostInList(postId, updatedPost);
    }

    final result = await _repository.toggleSavePost(
      postId: postId,
      isRemove: isCurrentlySaved,
    );

    result.fold(
      (failure) {
        if (isCurrentlySaved) {
          // Rollback remove
          final updatedPosts = List<PostModel>.from(state.posts);
          updatedPosts.insert(postIndex, originalPost);
          emit(state.copyWith(posts: updatedPosts));
        } else {
          _updatePostInList(postId, originalPost);
        }
        emit(
          state.copyWith(
            saveActionState: CubitStates.failure,
            saveMessage: failure.message,
          ),
        );
      },
      (message) {
        emit(
          state.copyWith(
            saveActionState: CubitStates.success,
            saveMessage: message,
          ),
        );
      },
    );
  }

  // 🗑 DELETE POST
  void deletePost({required String postId}) {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final originalPosts = List<PostModel>.from(state.posts);
    final updatedPosts = state.posts.where((p) => p.postId != postId).toList();

    emit(state.copyWith(posts: updatedPosts));

    _repository.deletePost(postId: postId).then((result) {
      result.fold(
        (failure) {
          emit(
            state.copyWith(
              posts: originalPosts,
              deletePostActionState: CubitStates.failure,
              deletePostMessage: failure.message,
            ),
          );
        },
        (message) {
          emit(
            state.copyWith(
              deletePostActionState: CubitStates.success,
              deletePostMessage: message,
            ),
          );
        },
      );
    });
  }

  // 📦 ARCHIVE POST
  void archivePost({required String postId}) {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final originalPosts = List<PostModel>.from(state.posts);
    final updatedPosts = state.posts.where((p) => p.postId != postId).toList();

    emit(state.copyWith(posts: updatedPosts));

    _repository.archivePost(postId: postId).then((result) {
      result.fold(
        (failure) {
          emit(
            state.copyWith(
              posts: originalPosts,
              archivePostActionState: CubitStates.failure,
              archivePostMessage: failure.message,
            ),
          );
        },
        (message) {
          emit(
            state.copyWith(
              archivePostActionState: CubitStates.success,
              archivePostMessage: message,
            ),
          );
        },
      );
    });
  }

  // 🚫 BLOCK USER
  void blockUser({required String visiblePostId, required String advisorId}) {
    emit(state.copyWith(blockUserActionState: CubitStates.loading));

    _repository.blockUser(userId: advisorId).then((result) {
      result.fold(
        (failure) {
          emit(
            state.copyWith(
              blockUserActionState: CubitStates.failure,
              blockUserMessage: failure.message,
            ),
          );
        },
        (message) {
          final updatedPosts = state.posts
              .where((p) => p.advisorId != advisorId)
              .toList();
          emit(
            state.copyWith(
              posts: updatedPosts,
              blockUserActionState: CubitStates.success,
              blockUserMessage: message,
            ),
          );
        },
      );
    });
  }

  // 👁️ HIDE POST
  void toggleHidePost({required String postId}) {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final updatedPosts = state.posts.where((p) => p.postId != postId).toList();
    emit(state.copyWith(posts: updatedPosts));

    _repository.toggleHidePost(postId: postId, isHide: true);
  }

  void _updatePostInList(String postId, PostModel updatedPost) {
    final currentIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (currentIndex == -1) return;

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[currentIndex] = updatedPost;

    emit(state.copyWith(posts: updatedPosts));
  }

  Future<void> refresh() async {
    await fetchSavedPosts();
  }
}
