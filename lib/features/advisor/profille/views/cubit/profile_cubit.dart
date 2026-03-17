import 'dart:async';
import 'dart:convert';
import 'package:tayseer/core/utils/profile_event_bus.dart';
import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/core/functions/set_advisor_status.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/profile_repository.dart';
import 'package:tayseer/features/advisor/profille/data/models/profile_model.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/my_import.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  final int _pageSize = 10;

  late StreamSubscription<ProfileUpdateEvent> _profileSubscription;

  ProfileCubit(this._profileRepository) : super(const ProfileState()) {
    _initializeProfile();
    _listenToProfileUpdates();
  }

  void _listenToProfileUpdates() {
    _profileSubscription = ProfileEventBus.instance.onProfileUpdated.listen((
      event,
    ) {
      // فقط نستجيب لأحداث الـ advisor — أحداث الـ user لا تخص هذه الشاشة
      if (event.userType != ProfileEventUserType.advisor) return;

      // لو الـ event فيه userId، تأكد إنه بتاع نفس الـ advisor الحالي
      if (event.userId != null && event.userId != kCurrentUserData?.id) return;

      if (state.profile != null) {
        // تحديث بيانات البروفايل فقط — الـ posts لا تتحدث هنا (تتحدث عند refresh فقط)
        final updatedProfile = state.profile!.copyWith(
          name: event.name,
          image: event.image,
          username: event.username,
        );

        emit(state.copyWith(profile: updatedProfile));

        // تحديث الكاش المحلي أيضاً لضمان الثبات
        try {
          CachNetwork.setData(
            key: kAdvisorProfileCache,
            value: jsonEncode(updatedProfile.toJson()),
          );
        } catch (e) {
          debugPrint('❌ Error updating cached profile: $e');
        }
      }
    });
  }

  @override
  Future<void> close() {
    _profileSubscription.cancel();
    return super.close();
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 INITIALIZE PROFILE
  // ═══════════════════════════════════════════════════════════
  Future<void> _initializeProfile() async {
    _loadCachedProfile();
    await Future.wait([
      fetchProfile(),
      fetchPosts(),
      fetchAnalytics(), // ⭐ جديد: جلب الإحصائيات
    ]);
  }

  void _loadCachedProfile() {
    final cachedData = CachNetwork.getStringData(key: kAdvisorProfileCache);
    if (cachedData.isNotEmpty) {
      try {
        var profile = ProfileModel.fromJson(jsonDecode(cachedData));

        // أولوية الصورة: لو kMyProfileImage فيه صورة أحدث، استخدمها
        final cachedImage = CachNetwork.getStringData(key: kMyProfileImage);
        if (cachedImage.isNotEmpty && cachedImage != profile.image) {
          profile = profile.copyWith(image: cachedImage);
        }

        emit(
          state.copyWith(profile: profile, profileState: CubitStates.success),
        );
      } catch (e) {
        debugPrint('❌ Error loading cached advisor profile: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH ANALYTICS
  // ═══════════════════════════════════════════════════════════
  Future<void> fetchAnalytics() async {
    if (state.analyticsState == CubitStates.loading) return;

    emit(state.copyWith(analyticsState: CubitStates.loading));

    final result = await _profileRepository.getAnalytics();
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          analyticsState: CubitStates.failure,
          analyticsErrorMessage: failure.message,
        ),
      ),
      (analyticsModel) => emit(
        state.copyWith(
          analyticsState: CubitStates.success,
          analytics: analyticsModel,
          analyticsErrorMessage: null,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 REFRESH ALL DATA
  // ═══════════════════════════════════════════════════════════
  Future<void> refresh() async {
    await Future.wait([
      fetchProfile(),
      fetchPosts(loadMore: false),
      fetchAnalytics(),
    ]);
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH PROFILE
  // ═══════════════════════════════════════════════════════════
  Future<void> fetchProfile() async {
    if (state.profileState == CubitStates.loading) return;

    // لا تظهر Loading إذا كان هناك بيانات كاش بالفعل (silent update)
    if (state.profile == null) {
      emit(state.copyWith(profileState: CubitStates.loading));
    }

    final result = await _profileRepository.getAdvisorProfile();
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          profileState: state.profile != null
              ? CubitStates.success
              : CubitStates.failure,
          profileErrorMessage: failure.message,
        ),
      ),
      (profileModel) {
        // أولوية الصورة: لو kMyProfileImage فيه صورة أحدث من الـ API، استخدمها
        final cachedImage = CachNetwork.getStringData(key: kMyProfileImage);
        final finalModel =
            (cachedImage.isNotEmpty && cachedImage != profileModel.image)
            ? profileModel.copyWith(image: cachedImage)
            : profileModel;

        // حفظ في الكاش
        try {
          CachNetwork.setData(
            key: kAdvisorProfileCache,
            value: jsonEncode(finalModel.toJson()),
          );
        } catch (e) {
          debugPrint('❌ Error caching advisor profile: $e');
        }
        setAdvisorStatus(finalModel.approvalKey);
        emit(
          state.copyWith(
            profileState: CubitStates.success,
            profile: finalModel,
            profileErrorMessage: null,
          ),
        );
      },
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
      final result = await _profileRepository.fetchSavedPosts(page: nextPage);

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
  // 📌 UPDATE PROFILE DATA (تحديث البيانات من الكاش)
  // ═══════════════════════════════════════════════════════════
  void updateProfileData({
    String? image,
    String? name,
    String? username,
    String? aboutYou,
    String? professionalSpecialization,
    String? jobGrade,
    String? yearsOfExperience,
    String? location,
  }) {
    if (state.profile != null) {
      final updatedProfile = state.profile!.copyWith(
        image: image,
        name: name,
        username: username,
        aboutYou: aboutYou,
        professionalSpecialization: professionalSpecialization,
        jobGrade: jobGrade,
        yearsOfExperience: yearsOfExperience,
        location: location,
      );
      if (isClosed) return;
      emit(state.copyWith(profile: updatedProfile));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 UPDATE PROFILE FROM CACHE (تحديث كامل من الكاش)
  // ═══════════════════════════════════════════════════════════
  void updateProfileFromCache(ProfileModel updatedProfile) {
    if (isClosed) return;
    emit(state.copyWith(profile: updatedProfile));
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 REFRESH PROFILE FROM CACHE ONLY (no API call)
  // ═══════════════════════════════════════════════════════════
  void refreshProfileFromCache() {
    final cachedData = CachNetwork.getStringData(key: kAdvisorProfileCache);
    if (cachedData.isNotEmpty) {
      try {
        final profile = ProfileModel.fromJson(jsonDecode(cachedData));
        if (isClosed) return;
        emit(
          state.copyWith(profile: profile, profileState: CubitStates.success),
        );
      } catch (e) {
        debugPrint('❌ Error refreshing profile from cache: $e');
      }
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

  // ═══════════════════════════════════════════════════════════
  // 💾 SAVE POST
  // ═══════════════════════════════════════════════════════════
  Future<void> toggleSavePost({required String postId}) async {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final originalPost = state.posts[postIndex];
    final isCurrentlySaved = originalPost.isSaved;

    // Optimistic Update
    final updatedPost = originalPost.copyWith(isSaved: !isCurrentlySaved);
    _updatePostInList(postId, updatedPost);
    emit(state.copyWith(saveActionState: CubitStates.initial));

    final result = await _profileRepository.toggleSavePost(
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

  // ═══════════════════════════════════════════════════════════
  // 🗑 DELETE POST
  // ═══════════════════════════════════════════════════════════
  void deletePost({required String postId}) {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final originalPosts = List<PostModel>.from(state.posts);

    // Optimistic Update
    final updatedPosts = state.posts.where((p) => p.postId != postId).toList();
    emit(
      state.copyWith(
        posts: updatedPosts,
        deletePostActionState: CubitStates.initial,
      ),
    );

    _profileRepository.deletePost(postId: postId).then((result) {
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

  // ═══════════════════════════════════════════════════════════
  // 📦 ARCHIVE POST
  // ═══════════════════════════════════════════════════════════
  void archivePost({required String postId}) {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final originalPosts = List<PostModel>.from(state.posts);

    // Optimistic Update
    final updatedPosts = state.posts.where((p) => p.postId != postId).toList();
    emit(
      state.copyWith(
        posts: updatedPosts,
        archivePostActionState: CubitStates.initial,
      ),
    );

    _profileRepository.archivePost(postId: postId).then((result) {
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

  // ═══════════════════════════════════════════════════════════
  // 👁️ HIDE POST
  // ═══════════════════════════════════════════════════════════
  void toggleHidePost({required String postId}) {
    final postIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];
    final newHideState = !post.isHidden;

    final updatedPost = post.copyWith(isHidden: newHideState);
    _updatePostInList(postId, updatedPost);

    _profileRepository.toggleHidePost(postId: postId, isHide: newHideState);
  }

  // ═══════════════════════════════════════════════════════════
  // 🚫 BLOCK USER
  // ═══════════════════════════════════════════════════════════
  Future<void> blockUser({
    required String visiblePostId,
    required String advisorId,
  }) async {
    emit(state.copyWith(blockUserActionState: CubitStates.loading));

    final result = await _profileRepository.blockUser(userId: advisorId);

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
        final updatedPosts = <PostModel>[];
        for (final post in state.posts) {
          if (post.postId == visiblePostId) {
            updatedPosts.add(post.copyWith(isBlocked: true));
          } else if (post.advisorId == advisorId) {
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
