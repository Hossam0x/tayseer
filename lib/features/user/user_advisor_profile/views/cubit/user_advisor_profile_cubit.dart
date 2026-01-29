import 'dart:async';
import 'dart:developer';
import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/user/user_advisor_profile/data/models/user_advisor_profile_model.dart';
import 'package:tayseer/features/user/user_advisor_profile/data/repositories/user_advisor_profile_repository.dart';
import 'package:tayseer/my_import.dart';
import 'user_advisor_profile_state.dart';

class UserAdvisorProfileCubit extends Cubit<UserAdvisorProfileState> {
  final UserAdvisorProfileRepository _repository;
  final String advisorId;
  final int _pageSize = 10;
  Timer? _chatTimeoutTimer;
  final tayseerSocketHelper socketHelper = getIt.get<tayseerSocketHelper>();

  UserAdvisorProfileCubit(this._repository, this.advisorId)
    : super(const UserAdvisorProfileState()) {
    _initializeProfile();
    _setupSocketListeners();
  }

  @override
  Future<void> close() {
    _chatTimeoutTimer?.cancel();
    socketHelper.off('room_created');
    socketHelper.off('fail');
    return super.close();
  }

  void _setupSocketListeners() {
    // ⭐ تنظيف أي listeners سابقين
    socketHelper.off('room_created');

    // ⭐ الاستماع لإنشاء الروم من السوكيت
    socketHelper.listen('room_created', (data) {
      final String chatRoomId = data['ChatRoomId']?.toString() ?? '';

      if (chatRoomId.isNotEmpty) {
        log('Socket room created: $chatRoomId');

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
            shouldNavigateToChat: true,
          ),
        );
      }
    });
  }

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

  Future<void> fetchPosts({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;
      if (isClosed) return;
      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;

      final result = await _repository.fetchUserPosts(
        advisorId: advisorId,
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
      emit(
        state.copyWith(
          postsState: CubitStates.loading,
          posts: [],
          currentPage: 1,
          hasMore: true,
          postsErrorMessage: null,
        ),
      );

      final result = await _repository.fetchUserPosts(
        advisorId: advisorId,
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

  Future<void> refresh() async {
    await Future.wait([fetchProfile(), fetchPosts(loadMore: false)]);
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

    final currentFollowState = state.profile!.isFollowing;
    final newFollowerCount = currentFollowState
        ? (state.profile!.followers - 1).clamp(0, state.profile!.followers)
        : state.profile!.followers + 1;

    // ⭐ تحديث مؤقت للواجهة
    final optimisticProfile = state.profile!.copyWith(
      isFollowing: !currentFollowState,
      followers: newFollowerCount,
    );

    emit(
      state.copyWith(
        profile: optimisticProfile,
        followActionState: CubitStates.loading,
      ),
    );

    // ⭐ استدعاء الـ API
    final result = await _repository.toggleFollowUser(advisorId);

    if (isClosed) return;

    result.fold(
      (failure) {
        // ⭐ الرجوع للحالة السابقة عند الفشل
        emit(
          state.copyWith(
            profile: state.profile?.copyWith(
              isFollowing: currentFollowState,
              followers: state.profile!.followers,
            ),
            followActionState: CubitStates.failure,
            followMessage: failure.message,
          ),
        );
      },
      (message) {
        emit(
          state.copyWith(
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

    socketHelper.send('create_room', {'reciverId': receiverId}, (ack) {
      log("send room create for user: $receiverId");
    });
  }

  Future<void> startChat() async {
    // ⭐ إلغاء أي timer سابق
    _chatTimeoutTimer?.cancel();

    // ⭐ إذا كان هناك room بالفعل
    if (state.profile?.hasRoom == true &&
        state.profile!.chatRoomId != null &&
        state.profile!.chatRoomId!.isNotEmpty) {
      // ⭐ تحديث حالة التحميل والتنقل
      emit(state.copyWith(isChatLoading: true, shouldNavigateToChat: true));
      return;
    }

    // ⭐ إذا لم يكن هناك room، ننشئ واحد
    emit(state.copyWith(isChatLoading: true));

    // ⭐ تنظيف أي listeners سابقين
    socketHelper.off('room_created');
    socketHelper.off('fail');

    // ⭐ الاستماع لإنشاء الروم بنجاح
    socketHelper.listen('room_created', (data) {
      _handleRoomCreated(data);
    });

    // ⭐ الاستماع لفشل إنشاء الروم
    socketHelper.listen('fail', (data) {
      _handleRoomCreationFailed(data);
    });

    // ⭐ إرسال طلب إنشاء room
    socketHelper.send('create_room', {'reciverId': advisorId}, (ack) {
      log("send room create for user: $advisorId");
    });

    // ⭐ إضافة timeout في حالة عدم الرد
    _chatTimeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!isClosed && state.isChatLoading) {
        emit(state.copyWith(isChatLoading: false));
        // ⭐ يمكن إضافة toast خطأ هنا
        log("Chat room creation timeout");
      }
    });
  }

  void _handleRoomCreated(Map<String, dynamic> data) {
    final String chatRoomId = data['ChatRoomId']?.toString() ?? '';

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

      emit(state.copyWith(isChatLoading: false));

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

  void _updatePostInList(String postId, PostModel updatedPost) {
    final currentIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (currentIndex == -1) return;

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[currentIndex] = updatedPost;

    emit(state.copyWith(posts: updatedPosts));
  }
}
