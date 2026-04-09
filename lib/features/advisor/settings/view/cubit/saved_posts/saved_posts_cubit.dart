import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/saved_posts_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/saved_posts/saved_posts_state.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/utils/post_event_bus.dart';
import 'package:tayseer/core/utils/post_event_listener_mixin.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/my_import.dart';

class SavedPostsCubit extends Cubit<SavedPostsState>
    with PostEventListenerMixin<SavedPostsState> {
  final SavedPostsRepository _repository;
  final HomeRepository _homeRepository;
  final int _pageSize = 10;

  SavedPostsCubit(this._repository, this._homeRepository)
    : super(const SavedPostsState()) {
    Future.microtask(() => fetchSavedPosts());
    subscribeToPostEvents();
  }

  @override
  List<PostModel> getPostList() => state.posts;

  @override
  void applyUpdatedPosts(List<PostModel> posts) =>
      emit(state.copyWith(posts: posts));

  @override
  Future<void> close() {
    cancelPostEventSubscription();
    return super.close();
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
    firePostEvent(
      PostEvent(
        type: PostEventType.reacted,
        postId: postId,
        reactionType: reactionType,
        likesCount: newLikesCount,
        topReactions: newTopReactions,
      ),
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
        firePostEvent(
          PostEvent(
            type: PostEventType.shared,
            postId: postId,
            isRepostedByMe: !isRemoving,
            sharesCount: updatedPost.sharesCount,
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
        firePostEvent(
          PostEvent(
            type: PostEventType.saved,
            postId: postId,
            isSaved: !isCurrentlySaved,
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
          firePostEvent(PostEvent(type: PostEventType.deleted, postId: postId));
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
          firePostEvent(
            PostEvent(type: PostEventType.archived, postId: postId),
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
          firePostEvent(
            PostEvent(
              type: PostEventType.blocked,
              postId: visiblePostId,
              advisorId: advisorId,
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
    firePostEvent(PostEvent(type: PostEventType.hidden, postId: postId));
  }

  // ═══════════════════════════════════════════════════════════
  // 🗳️ POLL VOTE
  // ═══════════════════════════════════════════════════════════
  void voteInPoll({required String postId, required String choiceText}) {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];
    if (post.pollModel == null) return;

    final oldPoll = post.pollModel!;
    final choices = oldPoll.pollChoices;
    final tappedIndex = choices.indexWhere((c) => c.choice == choiceText);
    if (tappedIndex == -1) return;

    final tappedChoice = choices[tappedIndex];
    final previouslySelectedIndex = choices.indexWhere((c) => c.isSelected);
    final hadPreviousVote = previouslySelectedIndex != -1;
    final isRemovingVote = tappedChoice.isSelected;

    int newTotalVotes = oldPoll.totalPollVotes;
    if (isRemovingVote) {
      newTotalVotes = (newTotalVotes - 1).clamp(0, newTotalVotes);
    } else if (!hadPreviousVote) {
      newTotalVotes = newTotalVotes + 1;
    }

    final myAvatar = kCurrentUserData?.image ?? '';
    final newChoices = <PollChoice>[];
    for (int i = 0; i < choices.length; i++) {
      final choice = choices[i];
      if (isRemovingVote) {
        if (i == tappedIndex) {
          final newVoters = List<String>.from(choice.votersAvatars)
            ..remove(myAvatar);
          newChoices.add(
            choice.copyWith(
              isSelected: false,
              votes: (choice.votes - 1).clamp(0, choice.votes),
              votersAvatars: newVoters,
            ),
          );
        } else {
          newChoices.add(choice);
        }
      } else {
        if (i == tappedIndex) {
          final newVoters = List<String>.from(choice.votersAvatars);
          if (myAvatar.isNotEmpty && !newVoters.contains(myAvatar)) {
            newVoters.insert(0, myAvatar);
          }
          newChoices.add(
            choice.copyWith(
              isSelected: true,
              votes: choice.votes + 1,
              votersAvatars: newVoters,
            ),
          );
        } else if (hadPreviousVote && i == previouslySelectedIndex) {
          final newVoters = List<String>.from(choice.votersAvatars)
            ..remove(myAvatar);
          newChoices.add(
            choice.copyWith(
              isSelected: false,
              votes: (choice.votes - 1).clamp(0, choice.votes),
              votersAvatars: newVoters,
            ),
          );
        } else {
          newChoices.add(choice);
        }
      }
    }

    final updatedChoices = newChoices.map((c) {
      final pct = newTotalVotes > 0
          ? ((c.votes / newTotalVotes) * 100).round()
          : 0;
      return c.copyWith(percentage: pct);
    }).toList();

    final newPoll = oldPoll.copyWith(
      pollChoices: updatedChoices,
      totalPollVotes: newTotalVotes,
    );

    _updatePostInList(postId, post.copyWith(pollModel: newPoll));

    _homeRepository
        .voteInPoll(postId: postId, choiceIndex: tappedIndex.toString())
        .then((result) {
          result.fold(
            (failure) {
              _updatePostInList(postId, post); // rollback
            },
            (_) {
              firePostEvent(
                PostEvent(
                  type: PostEventType.pollVoted,
                  postId: postId,
                  pollModel: newPoll,
                ),
              );
            },
          );
        });
  }

  void _updatePostInList(String postId, PostModel updatedPost) {
    final currentIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (currentIndex == -1) return;

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[currentIndex] = updatedPost;

    emit(state.copyWith(posts: updatedPosts));
  }

  void updatePostLocally(PostModel updatedPost) {
    _updatePostInList(updatedPost.postId, updatedPost);
    firePostEvent(
      PostEvent(
        type: PostEventType.edited,
        postId: updatedPost.postId,
        updatedPost: updatedPost,
      ),
    );
  }

  void markPostAsCommented({
    required String postId,
    required bool isAnonymous,
  }) {
    final index = state.posts.indexWhere((p) => p.postId == postId);
    if (index != -1) {
      _updatePostInList(
        postId,
        state.posts[index].copyWith(
          isCommented: true,
          isAnonymous: isAnonymous,
        ),
      );
      firePostEvent(
        PostEvent(
          type: PostEventType.commented,
          postId: postId,
          isAnonymous: isAnonymous,
        ),
      );
    }
  }

  void updateCommentCountByDelta({
    required String postId,
    required int countDelta,
    bool? isCommented,
    bool? isAnonymous,
  }) {
    final index = state.posts.indexWhere((p) => p.postId == postId);
    if (index != -1) {
      final post = state.posts[index];
      final newCount = post.commentsCount + countDelta;
      _updatePostInList(
        postId,
        post.copyWith(
          commentsCount: newCount < 0 ? 0 : newCount,
          isCommented: isCommented ?? post.isCommented,
          isAnonymous: isAnonymous ?? post.isAnonymous,
        ),
      );
      firePostEvent(
        PostEvent(
          type: PostEventType.commentCountUpdated,
          postId: postId,
          commentCountDelta: countDelta,
          isCommented: isCommented,
          isAnonymous: isAnonymous,
        ),
      );
    }
  }

  void syncCommentCountFromBackend({
    required String postId,
    required int totalCount,
  }) {
    final index = state.posts.indexWhere((p) => p.postId == postId);
    if (index != -1) {
      final post = state.posts[index];
      _updatePostInList(postId, post.copyWith(commentsCount: totalCount));
      firePostEvent(
        PostEvent(
          type: PostEventType.commentCountSynced,
          postId: postId,
          commentCountTotal: totalCount,
        ),
      );
    }
  }

  Future<void> refresh() async {
    await fetchSavedPosts();
  }
}
