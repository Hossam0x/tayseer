import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/profile_repository.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/my_import.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  final int _pageSize = 10;

  ProfileCubit(this._profileRepository) : super(const ProfileState()) {
    _initializeProfile();
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 INITIALIZE PROFILE
  // ═══════════════════════════════════════════════════════════
  Future<void> _initializeProfile() async {
    await Future.wait([fetchProfile(), fetchPosts()]);
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH PROFILE
  // ═══════════════════════════════════════════════════════════
  Future<void> fetchProfile() async {
    if (state.profileState == CubitStates.loading) return;

    emit(state.copyWith(profileState: CubitStates.loading));

    final result = await _profileRepository.getAdvisorProfile();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          profileState: CubitStates.failure,
          profileErrorMessage: failure.message,
        ),
      ),
      (profileModel) => emit(
        state.copyWith(
          profileState: CubitStates.success,
          profile: profileModel,
          profileErrorMessage: null, // تنظيف رسالة الخطأ عند النجاح
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH POSTS
  // ═══════════════════════════════════════════════════════════
  Future<void> fetchPosts({bool loadMore = false}) async {
    if (loadMore) {
      // لا تسمح بتحميل المزيد إذا كان التحميل جارياً أو لا يوجد المزيد
      if (state.isLoadingMore || !state.hasMore) return;
      if (isClosed) return;
      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;

      // ⭐️ استخدم ProfileRepository بدل HomeRepository
      final result = await _profileRepository.fetchSavedPosts(
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
      if (isClosed) return;
      // التحميل الأولي
      emit(
        state.copyWith(
          postsState: CubitStates.loading,
          posts: [],
          currentPage: 1,
          hasMore: true,
          postsErrorMessage: null,
        ),
      );

      final result = await _profileRepository.fetchSavedPosts(page: 1);

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

  // ═══════════════════════════════════════════════════════════
  // 📌 REFRESH ALL DATA
  // ═══════════════════════════════════════════════════════════
  Future<void> refresh() async {
    await Future.wait([fetchProfile(), fetchPosts(loadMore: false)]);
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 UPDATE PROFILE PICTURE (إذا كان مطلوباً)
  // ═══════════════════════════════════════════════════════════
  void updateProfileImage(String newImageUrl) {
    if (state.profile != null) {
      final updatedProfile = state.profile!.copyWith(image: newImageUrl);
      if (isClosed) return;
      emit(state.copyWith(profile: updatedProfile));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 CLEAR ERRORS
  // ═══════════════════════════════════════════════════════════
  void clearProfileError() {
    if (isClosed) return;
    emit(state.copyWith(profileErrorMessage: null));
  }

  void clearPostsError() {
    if (isClosed) return;
    emit(state.copyWith(postsErrorMessage: null));
  }

  void reactToPost({required String postId, ReactionType? reactionType}) {
    // 1. إيجاد الـ Post
    final postIndex = state.posts.indexWhere((post) => post.postId == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];

    // لا تغيير
    if (post.myReaction == reactionType) return;
    if (post.myReaction == null && reactionType == null) return;

    // 2. تحديد الحالة
    final isRemoving = reactionType == null;
    final oldReaction = post.myReaction;

    // 3. حساب العدد
    int newLikesCount = post.likesCount;
    if (isRemoving) {
      newLikesCount = (post.likesCount - 1).clamp(0, post.likesCount);
    } else if (oldReaction == null) {
      newLikesCount = post.likesCount + 1;
    }

    // 4. حساب التوب ريأكشنز
    final newTopReactions = calculateTopReactions(
      currentTopReactions: post.topReactions,
      oldReaction: oldReaction,
      newReaction: reactionType,
      newLikesCount: newLikesCount,
    );

    // 5. التحديث
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
    _profileRepository.reactToPost(
      postId: postId,
      reactionType: reactionType,
      isRemove: isRemoving,
    );
  }

  Future<void> toggleSharePost({required String postId}) async {
    // Reset أول حاجة
    emit(state.copyWith(shareActionState: CubitStates.initial));

    // 1. إيجاد الـ Post
    final postIndex = state.posts.indexWhere((post) => post.postId == postId);
    if (postIndex == -1) return;

    final originalPost = state.posts[postIndex];
    final bool isRemoving = originalPost.isRepostedByMe;

    // 2. حساب العدد الجديد
    final int newSharesCount = isRemoving
        ? (originalPost.sharesCount - 1).clamp(0, originalPost.sharesCount)
        : originalPost.sharesCount + 1;

    // 3. Optimistic Update
    final updatedPost = originalPost.copyWith(
      sharesCount: newSharesCount,
      isRepostedByMe: !originalPost.isRepostedByMe,
    );

    _updatePostInList(postId, updatedPost);

    // 4. API Call
    final result = await _profileRepository.sharePost(
      postId: postId,
      action: isRemoving ? "remove" : "add",
    );

    // 5. معالجة النتيجة
    result.fold(
      // فشل -> Rollback
      (failure) {
        _updatePostInList(postId, originalPost);
        emit(
          state.copyWith(
            shareActionState: CubitStates.failure,
            shareMessage: failure.message,
          ),
        );
      },
      // نجاح
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

  // Helper Method لتحديث البوست في الليست
  void _updatePostInList(String postId, PostModel updatedPost) {
    final currentIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (currentIndex == -1) return;

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[currentIndex] = updatedPost;

    emit(state.copyWith(posts: updatedPosts));
  }
}
