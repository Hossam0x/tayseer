import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/archive_repository.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/advisor/stories/stories.dart';
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
  final int _pageSize = 10;

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

  // 📢 SHARE POST
  Future<void> toggleSharePost({required String postId}) async {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
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

    final result = await _archiveRepository.shareArchivedPost(
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

  // 💾 SAVE POST
  Future<void> toggleSavePost({required String postId}) async {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final originalPost = state.posts[postIndex];
    final isCurrentlySaved = originalPost.isSaved;

    final updatedPost = originalPost.copyWith(isSaved: !isCurrentlySaved);
    _updatePostInList(postId, updatedPost);

    final result = await _archiveRepository.toggleSavePost(
      postId: postId,
      isRemove: isCurrentlySaved,
    );

    result.fold(
      (failure) {
        _updatePostInList(postId, originalPost);
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

    _archiveRepository.deletePost(postId: postId).then((result) {
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

  // 📦 UNARCHIVE POST
  Future<void> unarchivePost(String postId) async {
    final postIndex = state.posts.indexWhere((post) => post.postId == postId);
    if (postIndex == -1) return;

    final originalPosts = List<PostModel>.from(state.posts);
    final updatedPosts = state.posts.where((p) => p.postId != postId).toList();

    emit(state.copyWith(posts: updatedPosts));

    final result = await _archiveRepository.archivePost(
      postId: postId,
      isRemove: true,
    );
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
  }

  // 🚫 BLOCK USER
  void blockUser({required String visiblePostId, required String advisorId}) {
    emit(state.copyWith(blockUserActionState: CubitStates.loading));

    _archiveRepository.blockUser(userId: advisorId).then((result) {
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

    _archiveRepository.toggleHidePost(postId: postId, isHide: true);
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

    _archiveRepository.reactToArchivedPost(
      postId: postId,
      reactionType: reactionType,
      isRemove: isRemoving,
    );
  }

  void _updatePostInList(String postId, PostModel updatedPost) {
    final currentIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (currentIndex == -1) return;

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[currentIndex] = updatedPost;

    emit(state.copyWith(posts: updatedPosts));
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
  final StoriesRepository _storiesRepository;
  final int _pageSize = 20;

  ArchivedStoriesCubit(this._archiveRepository, this._storiesRepository)
    : super(const ArchivedStoriesState()) {
    fetchArchivedStories();
  }

  void likeStory({required String storyId, required String userId}) {
    final userStoryIndex = state.stories.indexWhere(
      (us) => us.userId == userId,
    );
    if (userStoryIndex == -1) return;

    final userStory = state.stories[userStoryIndex];
    final storyIndex = userStory.stories.indexWhere((s) => s.id == storyId);
    if (storyIndex == -1) return;

    final story = userStory.stories[storyIndex];
    final updatedStories = List<StoryModel>.from(userStory.stories);
    updatedStories[storyIndex] = story.copyWith(
      isLiked: !story.isLiked,
      likesCount: story.isLiked ? story.likesCount - 1 : story.likesCount + 1,
    );

    final updatedList = List<UserStoriesModel>.from(state.stories);
    updatedList[userStoryIndex] = userStory.copyWith(stories: updatedStories);

    emit(state.copyWith(stories: updatedList));
    _storiesRepository.likeStory(storyId: storyId);
  }

  Future<void> deleteStory({
    required String storyId,
    required String userId,
  }) async {
    final result = await _storiesRepository.deleteStory(storyId: storyId);

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        final userStoryIndex = state.stories.indexWhere(
          (us) => us.userId == userId,
        );
        if (userStoryIndex == -1) return;

        final userStory = state.stories[userStoryIndex];
        final updatedStories = userStory.stories
            .where((s) => s.id != storyId)
            .toList();

        final updatedList = List<UserStoriesModel>.from(state.stories);
        if (updatedStories.isEmpty) {
          updatedList.removeAt(userStoryIndex);
        } else {
          updatedList[userStoryIndex] = userStory.copyWith(
            stories: updatedStories,
            storiesCount: updatedStories.length,
          );
        }
        emit(state.copyWith(stories: updatedList));
      },
    );
  }

  Future<void> unarchiveStory({
    required String storyId,
    required String userId,
  }) async {
    final result = await _storiesRepository.toggleArchiveStory(
      storyId: storyId,
      isArchive: false,
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) {
        final userStoryIndex = state.stories.indexWhere(
          (us) => us.userId == userId,
        );
        if (userStoryIndex == -1) return;

        final userStory = state.stories[userStoryIndex];
        final updatedStories = userStory.stories
            .where((s) => s.id != storyId)
            .toList();

        final updatedList = List<UserStoriesModel>.from(state.stories);
        if (updatedStories.isEmpty) {
          updatedList.removeAt(userStoryIndex);
        } else {
          updatedList[userStoryIndex] = userStory.copyWith(
            stories: updatedStories,
            storiesCount: updatedStories.length,
          );
        }
        emit(state.copyWith(stories: updatedList));
      },
    );
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
