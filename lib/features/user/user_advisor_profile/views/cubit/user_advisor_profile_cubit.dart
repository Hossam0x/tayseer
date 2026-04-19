import 'dart:async';
import 'dart:developer';
import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/core/utils/post_event_bus.dart';
import 'package:tayseer/core/utils/post_event_listener_mixin.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/shared/profile/widgets/profile_posts_tab.dart';
import 'package:tayseer/features/user/user_advisor_profile/data/models/user_advisor_profile_model.dart';
import 'package:tayseer/features/user/user_advisor_profile/data/repositories/user_advisor_profile_repository.dart';
import 'package:tayseer/my_import.dart';
import 'user_advisor_profile_state.dart';

class UserAdvisorProfileCubit
    extends ProfilePostsCubitContract<UserAdvisorProfileState>
    with PostEventListenerMixin<UserAdvisorProfileState> {
  final UserAdvisorProfileRepository _repository;
  final HomeRepository _homeRepository;
  final String advisorId;
  final int _pageSize = 10;
  Timer? _chatTimeoutTimer;
  final tayseerSocketHelper socketHelper = getIt.get<tayseerSocketHelper>();

  UserAdvisorProfileCubit(
    this._repository,
    this._homeRepository,
    this.advisorId,
  ) : super(const UserAdvisorProfileState()) {
    _initializeProfile();
    subscribeToPostEvents();
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

  @override
  Future<void> close() {
    _chatTimeoutTimer?.cancel();
    socketHelper.offAllForListener('UserAdvisorProfileCubit_$advisorId');
    cancelPostEventSubscription();
    return super.close();
  }

  @override
  List<PostModel> getPostList() => state.posts;

  @override
  void applyUpdatedPosts(List<PostModel> posts) =>
      emit(state.copyWith(posts: posts));

  Future<void> _initializeProfile() async {
    await Future.wait([fetchProfile(), fetchPosts()]);
  }

  Future<void> fetchProfile() async {
    if (state.profileState == CubitStates.loading) return;

    emit(state.copyWith(profileState: CubitStates.loading));

    final result = await _repository.getUserProfile(advisorId);
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          profileState: CubitStates.failure,
          profileErrorMessage: failure.message,
        ),
      ),
      (profileModel) {
        // ⭐ تحديث state بالـ room من الـ profile
        final room = profileModel.room;
        final chatRoomId = room?.chatRoomId;

        emit(
          state.copyWith(
            profileState: CubitStates.success,
            profile: profileModel,
            profileErrorMessage: null,
            chatRoomId: chatRoomId,
            shouldNavigateToChat: false,
          ),
        );
      },
    );
  }

  @override
  Future<void> fetchPosts({
    bool loadMore = false,
    bool isSilent = false,
    bool forceRefresh = false,
  }) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;
      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await _repository.fetchUserPosts(
        advisorId: advisorId,
        page: nextPage,
      );
      if (isClosed) return;

      result.fold((failure) => emit(state.copyWith(isLoadingMore: false)), (
        newPosts,
      ) {
        final updatedList = [...state.posts, ...newPosts];
        emit(
          state.copyWith(
            posts: updatedList,
            currentPage: nextPage,
            hasMore: newPosts.length >= _pageSize,
            isLoadingMore: false,
          ),
        );
      });
      return;
    }

    // ── حالة التحميل الأولي أو force refresh ──
    if (forceRefresh || state.posts.isEmpty) {
      emit(
        state.copyWith(
          postsState: CubitStates.loading,
          posts: [],
          currentPage: 1,
          hasMore: true,
        ),
      );

      final result = await _repository.fetchUserPosts(
        advisorId: advisorId,
        page: 1,
      );
      if (isClosed) return;

      result.fold(
        (failure) => emit(state.copyWith(postsState: CubitStates.failure)),
        (postsList) => emit(
          state.copyWith(
            postsState: CubitStates.success,
            posts: postsList,
            currentPage: 1,
            hasMore: postsList.length >= _pageSize,
          ),
        ),
      );
      return;
    }

    // ── Silent refresh (الحالة الافتراضية لما نرجع للتب) ──
    if (isSilent && state.posts.isNotEmpty) {
      // لا نغير postsState → نبقى success
      // بس نجيب البيانات الجديدة

      final result = await _repository.fetchUserPosts(
        advisorId: advisorId,
        page: 1,
      );
      if (isClosed) return;

      result.fold(
        (failure) {
          // ممكن نعمل log فقط، أو نعرض toast خفيف إذا أردت
          log("Silent refresh failed: ${failure.message}");
        },
        (freshPosts) {
          // نقارن لو فيه تغيير حقيقي ولا لأ (اختياري)
          if (!_listsAreEqual(state.posts, freshPosts)) {
            emit(
              state.copyWith(
                posts: freshPosts,
                currentPage: 1,
                hasMore: freshPosts.length >= _pageSize,
              ),
            );
          }
          // لو نفس البيانات → مفيش داعي نعمل emit
        },
      );
    }
  }

  // مساعدة للمقارنة (اختياري - يمنع flicker غير ضروري)
  bool _listsAreEqual(List<PostModel> a, List<PostModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].postId != b[i].postId ||
          a[i].content != b[i].content ||
          a[i].likesCount != b[i].likesCount ||
          a[i].sharesCount != b[i].sharesCount ||
          a[i].myReaction != b[i].myReaction) {
        return false;
      }
    }
    return true;
  }

  Future<void> refresh() async {
    await Future.wait([
      fetchProfile(),
      fetchPosts(loadMore: false, forceRefresh: true),
    ]);
  }

  Future<void> toggleFollow() async {
    if (state.profile == null || state.profile!.isMe) return;

    // ⭐ إعادة تعيين حالة التحميل إذا كانت معلقة
    if (state.followActionState == CubitStates.loading) {
      emit(state.copyWith(followActionState: CubitStates.initial));
    }

    emit(
      state.copyWith(
        followActionState: CubitStates.loading,
        followMessage: null,
      ),
    );

    // ⭐ استدعاء الـ API
    final result = await _repository.toggleFollowUser(
      advisorId,
      isCurrentlyFollowing: state.profile?.isFollowing ?? false,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            followActionState: CubitStates.failure,
            followMessage: failure.message,
          ),
        );
      },
      (message) {
        final currentFollowState = state.profile?.isFollowing ?? false;
        final newFollowerCount = currentFollowState
            ? (state.profile!.followers - 1).clamp(0, state.profile!.followers)
            : state.profile!.followers + 1;

        final updatedProfile = state.profile?.copyWith(
          isFollowing: !currentFollowState,
          followers: newFollowerCount,
        );

        emit(
          state.copyWith(
            profile: updatedProfile,
            followActionState: CubitStates.success,
            followMessage: message,
            isFollowAdded: !currentFollowState,
          ),
        );
      },
    );
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

    final result = await _repository.sharePost(
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
        firePostEvent(
          PostEvent(
            type: PostEventType.shared,
            postId: postId,
            isRepostedByMe: !isRemoving,
            sharesCount: newSharesCount,
          ),
        );
      },
    );
  }

  void navigateToChat() {
    if (state.profile?.hasRoom == true &&
        state.profile?.room != null &&
        state.profile!.chatRoomId != null) {
      emit(state.copyWith(shouldNavigateToChat: true));
    }
  }

  void createRoom(String receiverId) {
    if (state.profile?.hasRoom == true && state.profile!.chatRoomId != null) {
      navigateToChat();
      return;
    }

    socketHelper.send('joinChatRoom', {'targetId': receiverId}, null);

    // socketHelper.send('create_room', {'reciverId': receiverId}, (ack) {
    //   log("send room create for user: $receiverId");
    // });
  }

  Future<void> startChat() async {
    // ⭐ إلغاء أي timer سابق
    _chatTimeoutTimer?.cancel();

    // ⭐ 2. التأكد من اتصال السوكيت
    bool connected = socketHelper.isConnected;
    if (!connected) {
      log('📡 Socket not connected, attempting to connect...');
      emit(
        state.copyWith(
          isChatLoading: true,
          chatActionState: CubitStates.loading,
        ),
      );
      connected = await socketHelper.connect();

      if (!connected) {
        log('❌ Failed to connect to socket');
        emit(
          state.copyWith(
            isChatLoading: false,
            chatActionState: CubitStates.failure,
            chatErrorMessage:
                'فشل الاتصال بخدمة المحادثة، يرجى المحاولة لاحقاً',
          ),
        );
        return;
      }
      log('✅ Socket connected successfully');
    }

    // ⭐ 2. البدء في عملية إنشاء الـ Room عبر السوكيت
    emit(
      state.copyWith(
        isChatLoading: true,
        chatActionState: CubitStates.loading,
        chatErrorMessage: null,
      ),
    );

    // تنظيف وتهيئة الـ listeners
    final listenerId = 'UserAdvisorProfileCubit_$advisorId';
    socketHelper.offAllForListener(listenerId);

    socketHelper.listenWithId('chatRoomJoined', listenerId, (data) {
      if (!isClosed) _handleRoomCreated(Map<String, dynamic>.from(data as Map));
    });

    socketHelper.listenWithId('fail', listenerId, (data) {
      if (!isClosed) _handleRoomCreationFailed(Map<String, dynamic>.from(data as Map));
    });

    // إرسال طلب إنشاء room
    log("🚀 Sending create_room event for: $advisorId");
    socketHelper.send('joinChatRoom', {'targetId': advisorId}, (ack) {});

    // إضافة timeout
    _chatTimeoutTimer = Timer(const Duration(seconds: 15), () {
      if (!isClosed && state.isChatLoading) {
        log("⏱️ Chat room creation timeout reached");
        if (state.chatActionState == CubitStates.loading) {
          emit(
            state.copyWith(
              isChatLoading: false,
              chatActionState: CubitStates.failure,
              chatErrorMessage:
                  'انتهت مهلة إنشاء المحادثة، يرجى المحاولة مرة أخرى',
            ),
          );
        }
      }
    });
  }

  void _handleRoomCreated(Map<String, dynamic> data) {
    final String chatRoomId = data['chatRoomId']?.toString() ?? '';

    if (chatRoomId.isNotEmpty && !isClosed) {
      log('Socket room created: $chatRoomId');

      // ⭐ إلغاء الـ timeout
      _chatTimeoutTimer?.cancel();

      // ⭐ تحديث الـ profile بالـ room الجديد
      final updatedProfile = state.profile?.copyWith(
        room: RoomInfoModel(
          chatRoomId: chatRoomId,
          isBlocked: false,
          isHaveSession: false,
        ),
      );

      emit(
        state.copyWith(
          profile: updatedProfile,
          chatRoomId: chatRoomId,
          isChatLoading: false,
          chatActionState: CubitStates.success,
          chatErrorMessage: null,
          shouldNavigateToChat: true,
        ),
      );
    }
  }

  void _handleRoomCreationFailed(Map<String, dynamic> data) {
    if (!isClosed) {
      final message = data['message']?.toString() ?? 'فشل إنشاء غرفة المحادثة';
      log('Room creation failed: $message');

      // ⭐ إلغاء الـ timeout
      _chatTimeoutTimer?.cancel();

      emit(
        state.copyWith(
          isChatLoading: false,
          chatActionState: CubitStates.failure,
          chatErrorMessage: message,
        ),
      );

      // ⭐ يمكن إضافة Toast أو snackbar للإخطار
      log('⚠️ Chat room creation failed: $message');
    }
  }

  void resetNavigation() {
    emit(state.copyWith(shouldNavigateToChat: false, isChatLoading: false));
  }

  // ⭐ دالة لتحديث room يدويًا
  void updateRoomInfo(RoomInfoModel roomInfo) {
    if (state.profile == null) return;

    final updatedProfile = state.profile!.copyWith(room: roomInfo);

    emit(
      state.copyWith(profile: updatedProfile, chatRoomId: roomInfo.chatRoomId),
    );
  }

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
            (_) => firePostEvent(
              PostEvent(
                type: PostEventType.pollVoted,
                postId: postId,
                pollModel: newPoll,
              ),
            ),
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

  @override
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
      firePostEvent(
        PostEvent(
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

  @override
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

    final result = await _repository.savedPost(
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

    final result = await _repository.deletePost(postId: postId);
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
        firePostEvent(PostEvent(type: PostEventType.deleted, postId: postId));
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

    final result = await _repository.archivePost(postId: postId);
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
        firePostEvent(PostEvent(type: PostEventType.archived, postId: postId));
      },
    );
  }

  void toggleHidePost({required String postId}) {
    final post = _findPost(postId);
    if (post == null) return;

    final newHideState = !post.isHidden;
    final updatedPost = post.copyWith(isHidden: newHideState);
    _updatePostInList(postId, updatedPost);

    _repository.hidePost(postId: postId, isHide: newHideState);
    firePostEvent(PostEvent(type: PostEventType.hidden, postId: postId));
  }

  Future<void> blockUser({
    String? visiblePostId,
    required String advisorId,
  }) async {
    if (isClosed) return;

    emit(
      state.copyWith(
        blockActionState: visiblePostId == null ? CubitStates.loading : null,
        blockUserActionState: visiblePostId != null
            ? CubitStates.loading
            : null,
        lastBlockedUserId: null, // ✅ Clear old data
      ),
    );

    final result = await _repository.blockUser(advisorId);

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
            } else if (post.advisorId == advisorId) {
              continue;
            } else {
              updatedPosts.add(post);
            }
          }
          // If the blocked user is the same as the profile owner, update the profile state too
          UserAdvisorProfileModel? updatedProfile = state.profile;
          if (advisorId == this.advisorId) {
            updatedProfile = state.profile?.copyWith(
              room:
                  state.profile?.room?.copyWith(isBlocked: true) ??
                  const RoomInfoModel(
                    chatRoomId: '',
                    isBlocked: true,
                    isHaveSession: false,
                  ),
            );
          }

          emit(
            state.copyWith(
              posts: updatedPosts,
              profile: updatedProfile,
              blockUserActionState: CubitStates.success,
              blockUserMessage: message,
              lastBlockedUserId: advisorId,
            ),
          );
          firePostEvent(
            PostEvent(
              type: PostEventType.blocked,
              postId: visiblePostId,
              advisorId: advisorId,
            ),
          );
        } else {
          // التعامل مع الحظر من البروفايل
          final updatedProfile = state.profile?.copyWith(
            room:
                state.profile?.room?.copyWith(isBlocked: true) ??
                const RoomInfoModel(
                  chatRoomId: '',
                  isBlocked: true,
                  isHaveSession: false,
                ),
          );
          emit(
            state.copyWith(
              profile: updatedProfile,
              blockActionState: CubitStates.success,
              blockMessage: message,
              lastBlockedUserId: advisorId, // ✅ Consistent tracking
            ),
          );
        }
      },
    );
  }

  Future<void> unblockUser({required String advisorId}) async {
    if (isClosed) return;

    emit(state.copyWith(blockActionState: CubitStates.loading));

    final result = await _repository.unblockUser(advisorId);

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
          room: state.profile?.room?.copyWith(isBlocked: false),
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
    final result = await _repository.reportUser(
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
}
