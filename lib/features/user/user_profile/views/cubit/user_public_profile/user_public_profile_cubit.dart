import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_public_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_posts_repository.dart';

// في user_public_profile_cubit.dart
// في user_public_profile_cubit.dart
class UserPublicProfileCubit extends Cubit<UserPublicProfileState> {
  final UserPublicProfileRepository _profileRepository;
  final UserPostsRepository _postsRepository;
  final String? userId; // ⭐ ابقاء nullable

  final int _pageSize = 10;

  UserPublicProfileCubit(
    this._profileRepository,
    this._postsRepository, {
    this.userId, // ⭐ nullable
    UserProfileModel? initialProfile,
  }) : super(
         UserPublicProfileState(
           state: CubitStates.initial,
           profile: initialProfile,
           profileState: initialProfile != null
               ? CubitStates.success
               : CubitStates.initial,
         ),
       ) {
    // ⭐ التأكد من وجود userId
    if (userId != null) {
      if (initialProfile != null) {
        fetchPosts();
      } else {
        _initialize();
      }
    } else {
      // ⭐ إذا لم يكن هناك userId، نغير الحالة إلى failure
      emit(
        state.copyWith(
          state: CubitStates.failure,
          profileState: CubitStates.failure,
          profileErrorMessage: 'معرف المستخدم غير متوفر',
        ),
      );
    }
  }

  Future<void> _initialize() async {
    if (userId == null) return;
    await fetchProfile();
    if (state.profile != null) {
      await fetchPosts();
    }
  }

  Future<void> fetchProfile() async {
    if (userId == null) return;

    emit(
      state.copyWith(
        profileState: CubitStates.loading,
        state: CubitStates.loading,
        profileErrorMessage: null,
      ),
    );

    final result = await _profileRepository.getUserPublicProfile(userId!);

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          state: CubitStates.failure,
          profileState: CubitStates.failure,
          profileErrorMessage: failure.message,
        ),
      ),
      (profile) => emit(
        state.copyWith(
          state: CubitStates.success,
          profileState: CubitStates.success,
          profile: profile,
          profileErrorMessage: null,
        ),
      ),
    );
  }

  // ⭐ Posts Methods
  Future<void> fetchPosts({bool loadMore = false}) async {
    final currentUserId = userId ?? state.profile?.id;
    if (currentUserId == null) return;

    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;
      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;

      final result = await _postsRepository.fetchUserPosts(
        userId: state.profile!.isMe ? currentUserId : state.profile!.id,
        page: nextPage,
      );

      if (isClosed) return;
      result.fold(
        (failure) {
          emit(
            state.copyWith(
              isLoadingMore: false,
              postsErrorMessage: failure.message,
            ),
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
              postsErrorMessage: null,
            ),
          );
        },
      );
    } else {
      if (state.postsState == CubitStates.loading) return;

      // لو مفيش profile، مش هنقدر نجيب البوستات
      final profileId = state.profile?.id ?? userId;
      if (profileId == null) return;

      emit(
        state.copyWith(
          postsState: CubitStates.loading,
          posts: [],
          currentPage: 1,
          hasMore: true,
          postsErrorMessage: null,
        ),
      );

      final result = await _postsRepository.fetchUserPosts(
        userId: (state.profile?.isMe == true)
            ? profileId
            : (state.profile?.id ?? profileId),
        page: 1,
      );

      if (isClosed) return;

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              postsState: CubitStates.failure,
              postsErrorMessage: failure.message,
            ),
          );
        },
        (postsList) {
          emit(
            state.copyWith(
              postsState: CubitStates.success,
              posts: postsList,
              currentPage: 1,
              hasMore: postsList.length >= _pageSize,
              postsErrorMessage: null,
            ),
          );
        },
      );
    }
  }

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

    _postsRepository.reactToPost(
      postId: postId,
      reactionType: reactionType,
      isRemove: isRemoving,
    );
  }

  Future<void> toggleSharePost({required String postId}) async {
    if (state.shareActionState == CubitStates.loading) return;

    emit(
      state.copyWith(shareActionState: CubitStates.loading, shareMessage: null),
    );

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

    final result = await _postsRepository.sharePost(
      postId: postId,
      action: isRemoving ? "remove" : "add",
    );

    if (isClosed) return;

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
          ),
        );
      },
    );
  }

  void updatePostLocally(PostModel updatedPost) {
    _updatePostInList(updatedPost.postId, updatedPost);
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
    }
  }

  void _updatePostInList(String postId, PostModel updatedPost) {
    final currentIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (currentIndex == -1) return;

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[currentIndex] = updatedPost;

    emit(state.copyWith(posts: updatedPosts));
  }

  PostModel? _findPost(String postId) {
    final index = state.posts.indexWhere((p) => p.postId == postId);
    return index != -1 ? state.posts[index] : null;
  }

  Future<void> toggleSavePost({required String postId}) async {
    final post = _findPost(postId);
    if (post == null) return;

    final isCurrentlySaved = post.isSaved;

    emit(state.copyWith(saveActionState: CubitStates.initial));

    // Optimistic Update
    final updatedPost = post.copyWith(isSaved: !isCurrentlySaved);
    _updatePostInList(postId, updatedPost);

    final result = await _postsRepository.savedPost(
      postId: postId,
      isRemove: isCurrentlySaved,
    );
    if (isClosed) return;

    result.fold(
      (failure) {
        _updatePostInList(postId, post);
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

  Future<void> deletePost({required String postId}) async {
    final post = _findPost(postId);
    if (post == null) return;

    final originalPosts = List<PostModel>.from(state.posts);
    final updatedPosts = state.posts.where((p) => p.postId != postId).toList();

    emit(
      state.copyWith(
        posts: updatedPosts,
        deletePostActionState: CubitStates.initial,
      ),
    );

    final result = await _postsRepository.deletePost(postId: postId);
    if (isClosed) return;

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
  }

  Future<void> archivePost({required String postId}) async {
    final post = _findPost(postId);
    if (post == null) return;

    final originalPosts = List<PostModel>.from(state.posts);
    final updatedPosts = state.posts.where((p) => p.postId != postId).toList();

    emit(
      state.copyWith(
        posts: updatedPosts,
        archivePostActionState: CubitStates.initial,
      ),
    );

    final result = await _postsRepository.archivePost(postId: postId);
    if (isClosed) return;

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

  void toggleHidePost({required String postId}) {
    final post = _findPost(postId);
    if (post == null) return;

    final newHideState = !post.isHidden;
    final updatedPost = post.copyWith(isHidden: newHideState);
    _updatePostInList(postId, updatedPost);

    _postsRepository.hidePost(postId: postId, isHide: newHideState);
  }

  Future<void> refresh() async {
    await fetchProfile();
    // فقط نجلب البوستات لو الـ profile اتحمل بنجاح
    if (state.profile != null) {
      await fetchPosts(loadMore: false);
    }
  }

  Future<void> deleteUserAccount() async {
    if (state.isLoadingDelete) return;

    emit(state.copyWith(isLoadingDelete: true));

    final result = await _profileRepository.deleteUserAccount();
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingDelete: false,
          profileErrorMessage: failure.message,
        ),
      ),
      (message) => emit(state.copyWith(isLoadingDelete: false)),
    );
  }

  void clearError() {
    emit(state.copyWith(profileErrorMessage: null, postsErrorMessage: null));
  }

  Future<void> blockUser({
    String? visiblePostId,
    required String userId,
  }) async {
    if (isClosed) return;

    emit(
      state.copyWith(
        blockActionState: visiblePostId == null ? CubitStates.loading : null,
        blockUserActionState: visiblePostId != null
            ? CubitStates.loading
            : null,
      ),
    );

    final result = await _profileRepository.blockUser(userId);

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            blockActionState: visiblePostId == null
                ? CubitStates.failure
                : null,
            blockMessage: visiblePostId == null ? failure.message : null,
            blockUserActionState: visiblePostId != null
                ? CubitStates.failure
                : null,
            blockUserMessage: visiblePostId != null ? failure.message : null,
          ),
        );
      },
      (message) {
        if (visiblePostId != null) {
          // التعامل مع الحظر من بوست
          final updatedPosts = <PostModel>[];
          for (final post in state.posts) {
            if (post.postId == visiblePostId) {
              updatedPosts.add(post.copyWith(isBlocked: true));
            } else if (post.advisorId == userId) {
              continue;
            } else {
              updatedPosts.add(post);
            }
          }
          emit(
            state.copyWith(
              posts: updatedPosts,
              blockUserActionState: CubitStates.success,
              blockUserMessage: message,
            ),
          );
        } else {
          // التعامل مع الحظر من البروفايل
          final updatedProfile = state.profile?.copyWith(
            room: Map<String, dynamic>.from(state.profile?.room ?? {})
              ..['isBlocked'] = true,
            isBlocked: [{}], // Add dummy entry to indicate blocked status
          );
          emit(
            state.copyWith(
              profile: updatedProfile,
              blockActionState: CubitStates.success,
              blockMessage: message,
            ),
          );
        }
      },
    );
  }

  Future<void> unblockUser({required String userId}) async {
    if (isClosed) return;

    emit(state.copyWith(blockActionState: CubitStates.loading));

    final result = await _profileRepository.unblockUser(userId);

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            blockActionState: CubitStates.failure,
            blockMessage: failure.message,
          ),
        );
      },
      (message) async {
        final updatedProfile = state.profile?.copyWith(
          room: Map<String, dynamic>.from(state.profile?.room ?? {})
            ..['isBlocked'] = false,
          isBlocked: [], // Clear blocked list
        );
        emit(
          state.copyWith(
            profile: updatedProfile,
            blockActionState: CubitStates.success,
            blockMessage: message,
          ),
        );

        // ✅ Automatically refresh everything after unblocking
        await refresh();
      },
    );
  }

  Future<void> reportUser({
    required String reportedId,
    required String reason,
    required String reasonDetails,
  }) async {
    emit(state.copyWith(reportActionState: CubitStates.loading));
    final result = await _profileRepository.reportUser(
      reportedId: reportedId,
      reason: reason,
      reasonDetails: reasonDetails,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          reportActionState: CubitStates.failure,
          reportMessage: failure.message,
        ),
      ),
      (message) => emit(
        state.copyWith(
          reportActionState: CubitStates.success,
          reportMessage: message,
        ),
      ),
    );
  }

  // في user_public_profile_cubit.dart
  Future<void> sendGreeting({
    required String receiverId,
    required String message,
  }) async {
    if (isClosed) return;

    emit(
      state.copyWith(
        isSendingGreeting: true,
        greetingMessage: null,
        greetingSuccess: false,
      ),
    );

    final result = await _profileRepository.sendGreeting(
      receiverId: receiverId,
      message: message,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSendingGreeting: false,
            greetingMessage: failure.message,
            greetingSuccess: false,
          ),
        );
      },
      (successMessage) {
        emit(
          state.copyWith(
            isSendingGreeting: false,
            greetingMessage: successMessage,
            greetingSuccess: true,
          ),
        );
      },
    );
  }

  void clearGreetingState() {
    emit(
      state.copyWith(
        isSendingGreeting: false,
        greetingMessage: null,
        greetingSuccess: false,
      ),
    );
  }

  Future<void> voteInPoll({
    required String postId,
    required String choiceText,
  }) async {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final originalPost = state.posts[postIndex];
    if (originalPost.pollModel == null) return;

    // Check if already voted
    bool alreadyVoted = originalPost.pollModel!.pollChoices.any(
      (c) => c.isSelected,
    );
    if (alreadyVoted) return;

    // Optimistic Update
    final updatedChoices = originalPost.pollModel!.pollChoices.map((choice) {
      if (choice.choice == choiceText) {
        return choice.copyWith(isSelected: true, votes: choice.votes + 1);
      }
      return choice;
    }).toList();

    final updatedPoll = originalPost.pollModel!.copyWith(
      pollChoices: updatedChoices,
      totalPollVotes: originalPost.pollModel!.totalPollVotes + 1,
    );

    final updatedPost = originalPost.copyWith(pollModel: updatedPoll);
    _updatePostInList(postId, updatedPost);

    final tappedIndex = originalPost.pollModel!.pollChoices.indexWhere(
      (c) => c.choice == choiceText,
    );
    if (tappedIndex == -1) return;

    final result = await _postsRepository.voteInPoll(
      postId: postId,
      choiceIndex: tappedIndex.toString(),
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        // Rollback on failure
        _updatePostInList(postId, originalPost);
        emit(
          state.copyWith(
            pollVoteActionState: CubitStates.failure,
            pollVoteMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            pollVoteActionState: CubitStates.success,
            pollVoteMessage: null,
          ),
        );
      },
    );
  }
}
