import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/archive_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archived_posts_state.dart';
import 'package:tayseer/core/utils/post_event_bus.dart';
import 'package:tayseer/core/utils/post_event_listener_mixin.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/my_import.dart';

class ArchivedPostsCubit extends Cubit<ArchivedPostsState>
    with PostEventListenerMixin<ArchivedPostsState> {
  final ArchiveRepository _archiveRepository;
  final HomeRepository _homeRepository;
  final int _pageSize = 10;

  ArchivedPostsCubit(this._archiveRepository, this._homeRepository)
    : super(const ArchivedPostsState()) {
    fetchArchivedPosts();
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
        (failure) => emit(
          state.copyWith(isLoadingMore: false, errorMessage: failure.message),
        ),
        (newPosts) => emit(
          state.copyWith(
            posts: [...state.posts, ...newPosts],
            currentPage: nextPage,
            hasMore: newPosts.length >= _pageSize,
            isLoadingMore: false,
            state: CubitStates.success,
            errorMessage: null,
          ),
        ),
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
        (failure) => emit(
          state.copyWith(
            state: CubitStates.failure,
            errorMessage: failure.message,
          ),
        ),
        (postsList) => emit(
          state.copyWith(
            state: CubitStates.success,
            posts: postsList,
            currentPage: 1,
            hasMore: postsList.length >= _pageSize,
            errorMessage: null,
          ),
        ),
      );
    }
  }

  Future<void> toggleSharePost({required String postId}) async {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final originalPost = state.posts[postIndex];
    final bool isRemoving = originalPost.isRepostedByMe;

    _updatePostInList(
      postId,
      originalPost.copyWith(
        sharesCount: isRemoving
            ? (originalPost.sharesCount - 1).clamp(0, originalPost.sharesCount)
            : originalPost.sharesCount + 1,
        isRepostedByMe: !isRemoving,
      ),
    );

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
        firePostEvent(
          PostEvent(
            type: PostEventType.shared,
            postId: postId,
            isRepostedByMe: !isRemoving,
            sharesCount: isRemoving
                ? (originalPost.sharesCount - 1).clamp(
                    0,
                    originalPost.sharesCount,
                  )
                : originalPost.sharesCount + 1,
          ),
        );
      },
    );
  }

  Future<void> toggleSavePost({required String postId}) async {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final originalPost = state.posts[postIndex];
    _updatePostInList(
      postId,
      originalPost.copyWith(isSaved: !originalPost.isSaved),
    );

    final result = await _archiveRepository.toggleSavePost(
      postId: postId,
      isRemove: originalPost.isSaved,
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
        firePostEvent(
          PostEvent(
            type: PostEventType.saved,
            postId: postId,
            isSaved: !originalPost.isSaved,
          ),
        );
      },
    );
  }

  void deletePost({required String postId}) {
    final originalPosts = List<PostModel>.from(state.posts);
    emit(
      state.copyWith(
        posts: state.posts.where((p) => p.postId != postId).toList(),
      ),
    );

    _archiveRepository.deletePost(postId: postId).then((result) {
      result.fold(
        (failure) => emit(
          state.copyWith(
            posts: originalPosts,
            deletePostActionState: CubitStates.failure,
            deletePostMessage: failure.message,
          ),
        ),
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

  Future<void> unarchivePost(String postId) async {
    final post = state.posts.where((p) => p.postId == postId).firstOrNull;
    final originalPosts = List<PostModel>.from(state.posts);
    emit(
      state.copyWith(
        posts: state.posts.where((p) => p.postId != postId).toList(),
        archivePostActionState: CubitStates.loading,
      ),
    );

    final result = await _archiveRepository.archivePost(
      postId: postId,
      isRemove: true,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          posts: originalPosts,
          archivePostActionState: CubitStates.failure,
          archivePostMessage: failure.message,
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            archivePostActionState: CubitStates.success,
            archivePostMessage: 'post_unarchived_success',
          ),
        );
        // بعت الـ post عشان يتضاف في أول الـ feeds التانية
        if (post != null) {
          firePostEvent(
            PostEvent(
              type: PostEventType.unarchived,
              postId: postId,
              unarchivedPost: post,
            ),
          );
        }
      },
    );
  }

  void blockUser({required String visiblePostId, required String advisorId}) {
    emit(state.copyWith(blockUserActionState: CubitStates.loading));

    _archiveRepository.blockUser(userId: advisorId).then((result) {
      result.fold(
        (failure) => emit(
          state.copyWith(
            blockUserActionState: CubitStates.failure,
            blockUserMessage: failure.message,
          ),
        ),
        (message) {
          emit(
            state.copyWith(
              posts: state.posts
                  .where((p) => p.advisorId != advisorId)
                  .toList(),
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

  void toggleHidePost({required String postId}) {
    emit(
      state.copyWith(
        posts: state.posts.where((p) => p.postId != postId).toList(),
      ),
    );
    _archiveRepository.toggleHidePost(postId: postId, isHide: true);
    firePostEvent(PostEvent(type: PostEventType.hidden, postId: postId));
  }

  void reactToPost({required String postId, ReactionType? reactionType}) {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
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

    _updatePostInList(
      postId,
      post.copyWith(
        likesCount: newLikesCount,
        topReactions: calculateTopReactions(
          currentTopReactions: post.topReactions,
          oldReaction: oldReaction,
          newReaction: reactionType,
          newLikesCount: newLikesCount,
        ),
        myReaction: reactionType,
        clearMyReaction: isRemoving,
      ),
    );

    _archiveRepository.reactToArchivedPost(
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
        topReactions: calculateTopReactions(
          currentTopReactions: post.topReactions,
          oldReaction: oldReaction,
          newReaction: reactionType,
          newLikesCount: newLikesCount,
        ),
      ),
    );
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
    final index = state.posts.indexWhere((p) => p.postId == postId);
    if (index == -1) return;
    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[index] = updatedPost;
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

  void resetArchivePostState() => emit(
    state.copyWith(
      archivePostActionState: CubitStates.initial,
      archivePostMessage: null,
    ),
  );

  void resetSharePostActionState() => emit(
    state.copyWith(shareActionState: CubitStates.initial, shareMessage: null),
  );

  void resetSavePostActionState() => emit(
    state.copyWith(saveActionState: CubitStates.initial, saveMessage: null),
  );

  void resetDeletePostActionState() => emit(
    state.copyWith(
      deletePostActionState: CubitStates.initial,
      deletePostMessage: null,
    ),
  );

  void resetBlockUserActionState() => emit(
    state.copyWith(
      blockUserActionState: CubitStates.initial,
      blockUserMessage: null,
    ),
  );

  Future<void> refresh() => fetchArchivedPosts();

  void clearError() => emit(state.copyWith(errorMessage: null));
}
