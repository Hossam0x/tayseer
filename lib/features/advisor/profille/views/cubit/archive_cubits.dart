import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/archive_repository.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/my_import.dart';
import 'archive_states.dart';

// ============================================
// 📌 ARCHIVED CHATS CUBIT
// ============================================
class ArchivedChatsCubit extends Cubit<ArchivedChatsState> {
  final ArchiveRepository _archiveRepository;
  final int _pageSize = 20;

  ArchivedChatsCubit(this._archiveRepository)
    : super(const ArchivedChatsState()) {
    fetchArchivedChats();
  }

  Future<void> fetchArchivedChats({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;

      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await _archiveRepository.getArchivedChats(
        page: nextPage,
        limit: _pageSize,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(isLoadingMore: false, errorMessage: failure.message),
          );
        },
        (response) {
          final updatedChats = [...state.chatRooms, ...response.chatRooms];
          emit(
            state.copyWith(
              chatRooms: updatedChats,
              currentPage: nextPage,
              hasMore: response.hasMore,
              isLoadingMore: false,
              state: CubitStates.success,
              errorMessage: null,
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(
          state: CubitStates.loading,
          chatRooms: [],
          currentPage: 1,
          hasMore: true,
          errorMessage: null,
        ),
      );

      final result = await _archiveRepository.getArchivedChats(
        page: 1,
        limit: _pageSize,
      );

      if (isClosed) return;

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              state: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (response) {
          emit(
            state.copyWith(
              state: CubitStates.success,
              chatRooms: response.chatRooms,
              currentPage: 1,
              hasMore: response.hasMore,
              errorMessage: null,
            ),
          );
        },
      );
    }
  }

  Future<void> unarchiveChat(String chatId) async {
    final result = await _archiveRepository.unarchiveChat(chatId);

    result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
      },
      (_) {
        // إزالة المحادثة من القائمة
        final updatedChats = state.chatRooms
            .where((chat) => chat.id != chatId)
            .toList();
        emit(state.copyWith(chatRooms: updatedChats));
      },
    );
  }

  Future<void> refresh() async {
    await fetchArchivedChats();
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}

// ============================================
// 📌 ARCHIVED POSTS CUBIT
// ============================================
// في features/advisor/profille/views/cubit/archive_cubits.dart
// عدل class ArchivedPostsCubit:

class ArchivedPostsCubit extends Cubit<ArchivedPostsState> {
  final ArchiveRepository _archiveRepository;
  final int _pageSize = 10; // قللت من 20 لـ 10 لأنه أحسن للتجربة

  ArchivedPostsCubit(this._archiveRepository)
    : super(const ArchivedPostsState()) {
    fetchArchivedPosts();
  }

  Future<void> fetchArchivedPosts({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;

      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await _archiveRepository.getArchivedPosts(
        page: nextPage,
        limit: _pageSize,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(isLoadingMore: false, errorMessage: failure.message),
          );
        },
        (newPosts) {
          final updatedPosts = [...state.posts, ...newPosts];
          emit(
            state.copyWith(
              posts: updatedPosts,
              currentPage: nextPage,
              hasMore: newPosts.length >= _pageSize,
              isLoadingMore: false,
              state: CubitStates.success,
              errorMessage: null,
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(
          state: CubitStates.loading,
          posts: [],
          currentPage: 1,
          hasMore: true,
          errorMessage: null,
        ),
      );

      final result = await _archiveRepository.getArchivedPosts(
        page: 1,
        limit: _pageSize,
      );

      if (isClosed) return;

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              state: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (postsList) {
          emit(
            state.copyWith(
              state: CubitStates.success,
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

  Future<void> toggleSharePost({required String postId}) async {
    final postIndex = state.posts.indexWhere(
      (post) => post.postId == postId,
    ); // ⭐️ post.postId
    if (postIndex == -1) return;

    final originalPost = state.posts[postIndex];
    final bool isRemoving =
        originalPost.isRepostedByMe; // ⭐️ مباشرة من originalPost

    final int newSharesCount = isRemoving
        ? (originalPost.sharesCount - 1).clamp(0, originalPost.sharesCount)
        : originalPost.sharesCount + 1;

    final updatedPost = originalPost.copyWith(
      sharesCount: newSharesCount,
      isRepostedByMe: !originalPost.isRepostedByMe,
    );

    _updatePostInList(postId, updatedPost);

    final result = await _archiveRepository.shareArchivedPost(
      postId: postId,
      action: isRemoving ? "remove" : "add",
    );

    result.fold(
      (failure) {
        _updatePostInList(postId, originalPost); // Rollback
      },
      (message) {
        // Success - لا حاجة لتحديث إضافي
      },
    );
  }

  Future<void> unarchivePost(String postId) async {
    final postIndex = state.posts.indexWhere(
      (post) => post.postId == postId,
    ); // ⭐️ post.postId
    if (postIndex == -1) return;

    final removedPost = state.posts[postIndex];
    final updatedPosts = List<PostModel>.from(
      state.posts,
    ); // ⭐️ PostModel بدلاً من ArchivePostModel
    updatedPosts.removeAt(postIndex);

    emit(state.copyWith(posts: updatedPosts));

    try {
      await _archiveRepository.unarchivePost(postId: postId);
    } catch (e) {
      // Rollback
      updatedPosts.insert(postIndex, removedPost);
      emit(state.copyWith(posts: updatedPosts));
      rethrow;
    }
  }

  void _updatePostInList(String postId, PostModel updatedPost) {
    // ⭐️ PostModel بدلاً من ArchivePostModel
    final currentIndex = state.posts.indexWhere(
      (p) => p.postId == postId,
    ); // ⭐️ p.postId
    if (currentIndex == -1) return;

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[currentIndex] = updatedPost;

    emit(state.copyWith(posts: updatedPosts));
  }

  // ⭐️ أضف هذه الوظيفة إذا لم تكن موجودة
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

    // API Call
    _archiveRepository.reactToArchivedPost(
      postId: postId,
      reactionType: reactionType,
      isRemove: isRemoving,
    );
  }

  Future<void> refresh() async {
    await fetchArchivedPosts();
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}

// ============================================
// 📌 ARCHIVED STORIES CUBIT
// ============================================
class ArchivedStoriesCubit extends Cubit<ArchivedStoriesState> {
  final ArchiveRepository _archiveRepository;
  final int _pageSize = 20;

  ArchivedStoriesCubit(this._archiveRepository)
    : super(const ArchivedStoriesState()) {
    fetchArchivedStories();
  }

  // archive_cubits.dart
  Future<void> fetchArchivedStories({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;

      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await _archiveRepository.getArchivedStories(
        page: nextPage,
        limit: _pageSize,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(isLoadingMore: false, errorMessage: failure.message),
          );
        },
        (stories) {
          final updatedStories = [...state.stories, ...stories];
          emit(
            state.copyWith(
              stories: updatedStories,
              currentPage: nextPage,
              hasMore: stories.length == _pageSize,
              isLoadingMore: false,
              state: CubitStates.success,
              errorMessage: null,
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(
          state: CubitStates.loading,
          stories: [],
          currentPage: 1,
          hasMore: true,
          errorMessage: null,
        ),
      );

      final result = await _archiveRepository.getArchivedStories(
        page: 1,
        limit: _pageSize,
      );

      if (isClosed) return;

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              state: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (stories) {
          emit(
            state.copyWith(
              state: CubitStates.success,
              stories: stories,
              currentPage: 1,
              hasMore: stories.length == _pageSize,
              errorMessage: null,
            ),
          );
        },
      );
    }
  }

  Future<void> refresh() async {
    await fetchArchivedStories();
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
