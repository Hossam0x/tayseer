import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/saved_posts_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/saved_posts_state.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
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

  // ⭐️⭐️⭐️ أضف وظائف Like و Share
  void reactToPost({required String postId, ReactionType? reactionType}) {
    final postIndex = state.posts.indexWhere((post) => post.postId == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];

    if (post.myReaction == reactionType) return;
    if (post.myReaction == null && reactionType == null) return;

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

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[postIndex] = updatedPost;

    emit(state.copyWith(posts: updatedPosts));

    // ⭐️ TODO: API call للـ Like (إذا كان الـ endpoint مختلف)
    // _repository.reactToPost(postId: postId, reactionType: reactionType, isRemove: isRemoving);
  }

  Future<void> toggleSharePost({required String postId}) async {
    emit(state.copyWith(shareActionState: CubitStates.initial));

    final postIndex = state.posts.indexWhere((post) => post.postId == postId);
    if (postIndex == -1) return;

    final originalPost = state.posts[postIndex];
    final bool isRemoving = originalPost.isRepostedByMe;

    final int newSharesCount = isRemoving
        ? (originalPost.sharesCount - 1).clamp(0, originalPost.sharesCount)
        : originalPost.sharesCount + 1;

    final updatedPost = originalPost.copyWith(
      sharesCount: newSharesCount,
      isRepostedByMe: !originalPost.isRepostedByMe,
    );

    _updatePostInList(postId, updatedPost);

    // ⭐️ TODO: API call للـ Share (إذا كان الـ endpoint مختلف)
    // final result = await _repository.sharePost(
    //   postId: postId,
    //   action: isRemoving ? "remove" : "add",
    // );

    // محاكاة النجاح مؤقتاً
    emit(
      state.copyWith(
        shareActionState: CubitStates.success,
        shareMessage: isRemoving ? 'تم إلغاء المشاركة' : 'تمت المشاركة بنجاح',
        isShareAdded: !isRemoving,
      ),
    );
  }

  Future<void> removeFromSaved(String postId) async {
    final postIndex = state.posts.indexWhere((post) => post.postId == postId);
    if (postIndex == -1) return;

    final removedPost = state.posts[postIndex];
    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts.removeAt(postIndex);

    emit(state.copyWith(posts: updatedPosts));

    try {
      await _repository.removeFromSaved(postId: postId);
    } catch (e) {
      // Rollback
      updatedPosts.insert(postIndex, removedPost);
      emit(state.copyWith(posts: updatedPosts));
      rethrow;
    }
  }

  // ⭐️ أضف save/unsave toggle
  void toggleSavePost({required String postId}) {
    final postIndex = state.posts.indexWhere((post) => post.postId == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];
    final updatedPost = post.copyWith(isSaved: !post.isSaved);

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[postIndex] = updatedPost;

    emit(state.copyWith(posts: updatedPosts));

    // ⭐️ TODO: API call للـ Save/Unsave
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
