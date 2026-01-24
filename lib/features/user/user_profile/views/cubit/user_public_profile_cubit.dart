import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_public_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_posts_repository.dart';

class UserPublicProfileCubit extends Cubit<UserPublicProfileState> {
  final UserPublicProfileRepository _profileRepository;
  final UserPostsRepository _postsRepository;
  final String? userId;
  final UserProfileModel? initialProfile;
  final int _pageSize = 10;

  UserPublicProfileCubit(
    this._profileRepository,
    this._postsRepository, {
    this.userId,
    this.initialProfile,
  }) : super(
         UserPublicProfileState(
           state: CubitStates.success,
           profile: initialProfile,
           profileState: initialProfile != null
               ? CubitStates.success
               : CubitStates.initial,
         ),
       ) {
    // إذا كان لدينا بيانات أولية، لا نحتاج لتحميلها
    if (initialProfile != null) {
      fetchPosts();
    } else if (userId != null) {
      _initialize();
    }
  }

  Future<void> _initialize() async {
    await Future.wait([fetchProfile(), fetchPosts()]);
  }

  Future<void> fetchProfile() async {
    if (userId == null) return;

    emit(
      state.copyWith(
        profileState: CubitStates.loading,
        profileErrorMessage: null,
      ),
    );

    final result = await _profileRepository.getUserPublicProfile(userId!);

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
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
        userId: currentUserId,
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
        userId: currentUserId,
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

  void _updatePostInList(String postId, PostModel updatedPost) {
    final currentIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (currentIndex == -1) return;

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[currentIndex] = updatedPost;

    emit(state.copyWith(posts: updatedPosts));
  }

  Future<void> refresh() async {
    await Future.wait([
      if (userId != null) fetchProfile(),
      fetchPosts(loadMore: false),
    ]);
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
}
