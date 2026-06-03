import 'dart:async';
import 'dart:convert';
import 'package:tayseer/core/utils/profile_event_bus.dart';
import 'package:tayseer/core/utils/post_event_bus.dart';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/core/functions/set_advisor_status.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/profile_repository.dart';
import 'package:tayseer/features/advisor/profille/data/models/profile_model.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/shared/profile/widgets/profile_posts_tab.dart';
import 'package:tayseer/my_import.dart';
import 'profile_state.dart';

class ProfileCubit extends ProfilePostsCubitContract<ProfileState> {
  final ProfileRepository _profileRepository;
  final HomeRepository _homeRepository;
  final int _pageSize = 10;

  late StreamSubscription<ProfileUpdateEvent> _profileSubscription;
  late StreamSubscription<SubscriptionChangedEvent> _subscriptionSubscription;
  late StreamSubscription<PostEvent> _postEventSubscription;

  ProfileCubit(this._profileRepository, this._homeRepository)
    : super(const ProfileState()) {
    _initializeProfile();
    _listenToProfileUpdates();
    _listenToSubscriptionChanges();
    _listenToPostEvents();
  }

  // ── ProfilePostsCubitContract implementation ──
  @override
  List<PostModel> get posts => state.posts;
  @override
  CubitStates get postsState => state.postsState;
  @override
  String? get postsErrorMessage => state.postsErrorMessage;
  @override
  bool get hasMore => state.hasMore;
  @override
  bool get isLoadingMore => state.isLoadingMore;
  @override
  CubitStates get shareActionState => state.shareActionState;
  @override
  String? get shareMessage => state.shareMessage;
  @override
  bool? get isShareAdded => state.isShareAdded;
  @override
  CubitStates get saveActionState => state.saveActionState;
  @override
  String? get saveMessage => state.saveMessage;
  @override
  CubitStates get deletePostActionState => state.deletePostActionState;
  @override
  String? get deletePostMessage => state.deletePostMessage;
  @override
  CubitStates get archivePostActionState => state.archivePostActionState;
  @override
  String? get archivePostMessage => state.archivePostMessage;
  @override
  CubitStates get blockUserActionState => state.blockUserActionState;
  @override
  String? get blockUserMessage => state.blockUserMessage;

  void _listenToProfileUpdates() {
    _profileSubscription = ProfileEventBus.instance.onProfileUpdated.listen((
      event,
    ) {
      if (event.userType != ProfileEventUserType.advisor) return;
      if (event.userId != null && event.userId != kCurrentUserData?.id) return;

      if (state.profile != null) {
        debugPrint('🔄 ProfileCubit: updating profile image → ${event.image}');

        final updatedProfile = state.profile!.copyWith(
          name: event.name,
          image: event.image,
          username: event.username,
        );

        emit(state.copyWith(profile: updatedProfile));

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
    _subscriptionSubscription.cancel();
    _postEventSubscription.cancel();
    return super.close();
  }

  void _listenToPostEvents() {
    _postEventSubscription = PostEventBus.instance.onPostEvent.listen((event) {
      if (isClosed) return;
      // تجاهل الـ events اللي ProfileCubit نفسه بعتها
      if (event.sourceId == 'ProfileCubit') return;
      _applyExternalPostEvent(event);
    });
  }

  void _applyExternalPostEvent(PostEvent event) {
    final postId = event.postId;
    final idx = state.posts.indexWhere((p) => p.postId == postId);

    switch (event.type) {
      case PostEventType.reacted:
        if (idx == -1) return;
        _updatePostInList(
          postId,
          state.posts[idx].copyWith(
            likesCount: event.likesCount ?? state.posts[idx].likesCount,
            topReactions: event.topReactions ?? state.posts[idx].topReactions,
            myReaction: event.reactionType,
            clearMyReaction: event.reactionType == null,
          ),
        );
        break;
      case PostEventType.shared:
        if (idx == -1) return;
        _updatePostInList(
          postId,
          state.posts[idx].copyWith(
            sharesCount: event.sharesCount ?? state.posts[idx].sharesCount,
            isRepostedByMe:
                event.isRepostedByMe ?? state.posts[idx].isRepostedByMe,
          ),
        );
        break;
      case PostEventType.saved:
        if (idx == -1) return;
        _updatePostInList(
          postId,
          state.posts[idx].copyWith(
            isSaved: event.isSaved ?? state.posts[idx].isSaved,
          ),
        );
        break;
      case PostEventType.deleted:
        if (idx == -1) return;
        emit(
          state.copyWith(
            posts: state.posts.where((p) => p.postId != postId).toList(),
          ),
        );
        break;
      case PostEventType.archived:
        if (idx == -1) return;
        emit(
          state.copyWith(
            posts: state.posts.where((p) => p.postId != postId).toList(),
          ),
        );
        break;
      case PostEventType.hidden:
        if (idx == -1) return;
        _updatePostInList(postId, state.posts[idx].copyWith(isHidden: true));
        break;
      case PostEventType.blocked:
        if (event.advisorId == null) return;
        emit(
          state.copyWith(
            posts: state.posts
                .map((p) {
                  if (p.postId == postId) return p.copyWith(isBlocked: true);
                  if (p.advisorId == event.advisorId) return null;
                  return p;
                })
                .whereType<PostModel>()
                .toList(),
          ),
        );
        break;
      case PostEventType.pollVoted:
        if (idx == -1 || event.pollModel == null) return;
        _updatePostInList(
          postId,
          state.posts[idx].copyWith(pollModel: event.pollModel),
        );
        break;
      case PostEventType.commentCountUpdated:
        if (idx == -1 || event.commentCountDelta == null) return;
        final p = state.posts[idx];
        _updatePostInList(
          postId,
          p.copyWith(
            commentsCount: (p.commentsCount + event.commentCountDelta!).clamp(
              0,
              999999,
            ),
            isCommented: event.isCommented ?? p.isCommented,
            isAnonymous: event.isAnonymous ?? p.isAnonymous,
          ),
        );
        break;
      case PostEventType.commentCountSynced:
        if (idx == -1 || event.commentCountTotal == null) return;
        _updatePostInList(
          postId,
          state.posts[idx].copyWith(commentsCount: event.commentCountTotal),
        );
        break;
      case PostEventType.commented:
        if (idx == -1) return;
        _updatePostInList(
          postId,
          state.posts[idx].copyWith(
            isCommented: true,
            isAnonymous: event.isAnonymous ?? state.posts[idx].isAnonymous,
          ),
        );
        break;
      case PostEventType.edited:
        if (idx == -1 || event.updatedPost == null) return;
        _updatePostInList(postId, event.updatedPost!);
        break;

      case PostEventType.unarchived:
        if (event.unarchivedPost == null) return;
        // لو البوست مش موجود في الـ profile، أضيفه في الأول
        if (idx == -1) {
          emit(state.copyWith(posts: [event.unarchivedPost!, ...state.posts]));
        }
        break;

      case PostEventType.created:
        if (event.createdPost == null) return;
        // أضيف البوست في أول الـ profile لو مش موجود
        final alreadyExists = state.posts.any(
          (p) => p.postId == event.createdPost!.postId,
        );
        if (!alreadyExists) {
          emit(state.copyWith(posts: [event.createdPost!, ...state.posts]));
        }
        break;

      case PostEventType.followToggled:
        // ProfileCubit (advisor's own profile) — حدّث isFollowing في البوستات
        if (event.advisorId == null) return;
        final isNowFollowing = event.isFollowing ?? false;
        emit(
          state.copyWith(
            posts: state.posts.map((p) {
              if (p.advisorId == event.advisorId) {
                return p.copyWith(isFollowing: isNowFollowing);
              }
              return p;
            }).toList(),
          ),
        );
        break;
    }
  }

  void _listenToSubscriptionChanges() {
    _subscriptionSubscription = SubscriptionEventBus
        .instance
        .onSubscriptionChanged
        .listen((_) {
          if (isClosed) return;
          fetchAnalytics();
        });
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
  @override
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
    PostEventBus.instance.fire(
      PostEvent(
        sourceId: 'ProfileCubit',
        type: PostEventType.reacted,
        postId: postId,
        reactionType: reactionType,
        likesCount: newLikesCount,
        topReactions: newTopReactions,
      ),
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
        PostEventBus.instance.fire(
          PostEvent(
            sourceId: 'ProfileCubit',
            type: PostEventType.shared,
            postId: postId,
            isRepostedByMe: !isRemoving,
            sharesCount: newSharesCount,
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
        PostEventBus.instance.fire(
          PostEvent(
            sourceId: 'ProfileCubit',
            type: PostEventType.saved,
            postId: postId,
            isSaved: !isCurrentlySaved,
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
          PostEventBus.instance.fire(
            PostEvent(
              sourceId: 'ProfileCubit',
              type: PostEventType.deleted,
              postId: postId,
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
          PostEventBus.instance.fire(
            PostEvent(
              sourceId: 'ProfileCubit',
              type: PostEventType.archived,
              postId: postId,
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
    PostEventBus.instance.fire(
      PostEvent(
        sourceId: 'ProfileCubit',
        type: PostEventType.hidden,
        postId: postId,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 🚫 BLOCK USER
  // ═══════════════════════════════════════════════════════════
  Future<void> blockUser({
    String? visiblePostId,
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
        PostEventBus.instance.fire(
          PostEvent(
            sourceId: 'ProfileCubit',
            type: PostEventType.blocked,
            postId: visiblePostId ?? '',
            advisorId: advisorId,
          ),
        );
      },
    );
  }

  // Helper Method لتحديث البوست في الليست
  // ═══════════════════════════════════════════════════════════
  // 🗳️ POLL VOTE
  // ═══════════════════════════════════════════════════════════
  @override
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
            (failure) => _updatePostInList(postId, post),
            (_) => PostEventBus.instance.fire(
              PostEvent(
                sourceId: 'ProfileCubit',
                type: PostEventType.pollVoted,
                postId: postId,
                pollModel: newPoll,
              ),
            ),
          );
        });
  }

  // Helper Method لتحديث البوست في الليست
  void _updatePostInList(String postId, PostModel updatedPost) {
    final currentIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (currentIndex == -1) return;

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[currentIndex] = updatedPost;

    emit(state.copyWith(posts: updatedPosts));
  }

  @override
  void updatePostLocally(PostModel updatedPost) {
    _updatePostInList(updatedPost.postId, updatedPost);
    PostEventBus.instance.fire(
      PostEvent(
        sourceId: 'ProfileCubit',
        type: PostEventType.edited,
        postId: updatedPost.postId,
        updatedPost: updatedPost,
      ),
    );
  }

  @override
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
      PostEventBus.instance.fire(
        PostEvent(
          sourceId: 'ProfileCubit',
          type: PostEventType.commented,
          postId: postId,
          isAnonymous: isAnonymous,
        ),
      );
    }
  }

  @override
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
      PostEventBus.instance.fire(
        PostEvent(
          sourceId: 'ProfileCubit',
          type: PostEventType.commentCountUpdated,
          postId: postId,
          commentCountDelta: countDelta,
          isCommented: isCommented,
          isAnonymous: isAnonymous,
        ),
      );
    }
  }

  @override
  void syncCommentCountFromBackend({
    required String postId,
    required int totalCount,
  }) {
    final index = state.posts.indexWhere((p) => p.postId == postId);
    if (index != -1) {
      final post = state.posts[index];
      _updatePostInList(postId, post.copyWith(commentsCount: totalCount));
      PostEventBus.instance.fire(
        PostEvent(
          sourceId: 'ProfileCubit',
          type: PostEventType.commentCountSynced,
          postId: postId,
          commentCountTotal: totalCount,
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 👥 FOLLOW ADVISOR
  // ═══════════════════════════════════════════════════════════
  @override
  void toggleFollowAdvisor({required String advisorId}) {
    final postIndex = state.posts.indexWhere((p) => p.advisorId == advisorId);
    if (postIndex == -1) return;

    final isCurrentlyFollowing = state.posts[postIndex].isFollowing;
    final isAdding = !isCurrentlyFollowing;

    // Optimistic update
    final updatedPosts = state.posts.map((post) {
      if (post.advisorId == advisorId) {
        return post.copyWith(isFollowing: isAdding);
      }
      return post;
    }).toList();
    emit(state.copyWith(posts: updatedPosts));

    // API Call with rollback on failure
    _homeRepository
        .followAdvisor(advisorId: advisorId, isAdding: isAdding)
        .then((result) {
          result.fold(
            (failure) {
              if (!isClosed) {
                final rollback = state.posts.map((post) {
                  if (post.advisorId == advisorId) {
                    return post.copyWith(isFollowing: isCurrentlyFollowing);
                  }
                  return post;
                }).toList();
                emit(state.copyWith(posts: rollback));
              }
            },
            (_) {
              // ✅ نجح - أبلّغ الـ bus
              PostEventBus.instance.fire(
                PostEvent(
                  type: PostEventType.followToggled,
                  postId: '',
                  sourceId: 'ProfileCubit',
                  advisorId: advisorId,
                  isFollowing: isAdding,
                ),
              );
            },
          );
        });
  }
}
