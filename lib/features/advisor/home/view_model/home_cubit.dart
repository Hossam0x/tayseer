import 'dart:developer';

import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/home/model/Image_and_name_model.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/advisor/home/view_model/home_state.dart';
import 'package:tayseer/features/user/my_space/data/model/session_start_model.dart';
import '../../../../my_import.dart';
import '../reposiotry/home_repository.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository homeRepository;
  final int pageSize = 10;

  HomeCubit(this.homeRepository) : super(HomeState()) {
    _loadCachedData();
    sessionStart();
  }

  // Load cached data immediately
  void _loadCachedData() {
    final cachedImage = CachNetwork.getStringData(key: kMyProfileImage);
    final cachedName = CachNetwork.getStringData(key: kMyProfileName);

    if (cachedImage.isNotEmpty || cachedName.isNotEmpty) {
      emit(
        state.copyWith(
          homeInfo: ImageAndNameModel(
            image: cachedImage,
            name: cachedName,
            notifications: 0,
          ),
          fetchNameAndImageState: CubitStates.success,
        ),
      );
    }
  }

  void setInitialPost(PostModel post) {
    emit(state.copyWith(posts: [post], postsState: CubitStates.success));
  }

  // fetch name and image

  Future<void> fetchNameAndImage() async {
    // Show loading only if we don't have cached data
    if (state.homeInfo == null) {
      emit(state.copyWith(fetchNameAndImageState: CubitStates.loading));
    }

    final result = await homeRepository.fetchNameAndImage();

    result.fold(
      (failure) {
        // Only emit failure if we don't have cached data
        if (state.homeInfo == null) {
          emit(
            state.copyWith(
              fetchNameAndImageState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (imageAndNameModel) {
        // Save to cache
        CachNetwork.setData(
          key: kMyProfileImage,
          value: imageAndNameModel.image,
        );
        CachNetwork.setData(key: kMyProfileName, value: imageAndNameModel.name);

        // Update state only if data changed
        if (state.homeInfo?.image != imageAndNameModel.image ||
            state.homeInfo?.name != imageAndNameModel.name ||
            state.homeInfo?.notifications != imageAndNameModel.notifications) {
          emit(
            state.copyWith(
              fetchNameAndImageState: CubitStates.success,
              homeInfo: imageAndNameModel,
            ),
          );
        }
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH POSTS
  // ═══════════════════════════════════════════════════════════
  Future<void> fetchPosts({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;
      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await homeRepository.fetchPosts(page: nextPage);

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
              hasMore: newPosts.length >= pageSize,
              isLoadingMore: false,
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(
          postsState: CubitStates.loading,
          posts: [],
          currentPage: 1,
          hasMore: true,
        ),
      );
      final result = await homeRepository.fetchPosts(page: 1);
      result.fold(
        (failure) {
          emit(
            state.copyWith(
              postsState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (postsList) {
          emit(
            state.copyWith(
              postsState: CubitStates.success,
              posts: postsList,
              currentPage: 1,
              hasMore: postsList.length >= pageSize,
            ),
          );
        },
      );
    }
  }

  void reactToPost({required String postId, ReactionType? reactionType}) {
    // 1️⃣ إيجاد الـ Post
    final postIndex = state.posts.indexWhere((post) => post.postId == postId);
    if (postIndex == -1) return;

    final post = state.posts[postIndex];

    // لا تغيير
    if (post.myReaction == reactionType) {
      // لو نفس الريأكشن ومطلوب إزالته (لو الزرار بيعمل toggle)
      // لكن بناء على اللوجيك بتاعك انت بتبعت null للإزالة
      if (reactionType != null) return;
    }

    // لو مفيش تغيير (null و null)
    if (post.myReaction == null && reactionType == null) return;

    // 2️⃣ تحديد الحالة
    final isRemoving = reactionType == null;
    final oldReaction = post.myReaction;

    // 3️⃣ حساب العدد
    int newLikesCount = post.likesCount;
    if (isRemoving) {
      newLikesCount = (post.likesCount - 1).clamp(0, post.likesCount);
    } else if (oldReaction == null) {
      newLikesCount = post.likesCount + 1;
    }
    // في حالة التغيير (Change) العدد بيفضل ثابت

    // 4️⃣ حساب التوب ريأكشنز
    final newTopReactions = calculateTopReactions(
      currentTopReactions: post.topReactions,
      oldReaction: oldReaction,
      newReaction: reactionType,
      newLikesCount: newLikesCount,
    );

    // 5️⃣ التحديث
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
    homeRepository.reactToPost(
      postId: postId,
      reactionType: reactionType,
      isRemove: isRemoving,
    );
  }

  Future<void> toggleSharePost({required String postId}) async {
    // ✅ Reset أول حاجة عشان الـ listener يشتغل كل مرة
    emit(state.copyWith(shareActionState: CubitStates.initial));
    // 1️⃣ إيجاد الـ Post
    final postIndex = state.posts.indexWhere((post) => post.postId == postId);
    if (postIndex == -1) return;

    final originalPost = state.posts[postIndex]; // ✅ احتفظ بالأصلي للـ Rollback
    final bool isRemoving = originalPost.isRepostedByMe;

    // 2️⃣ حساب العدد الجديد
    final int newSharesCount = isRemoving
        ? (originalPost.sharesCount - 1).clamp(0, originalPost.sharesCount)
        : originalPost.sharesCount + 1;

    // 3️⃣ ✅ Optimistic Update - تحديث فوري محلي
    final updatedPost = originalPost.copyWith(
      sharesCount: newSharesCount,
      isRepostedByMe: !originalPost.isRepostedByMe,
    );

    _updatePostInList(postId, updatedPost);

    // 4️⃣ API Call
    final result = await homeRepository.sharePost(
      postId: postId,
      action: isRemoving ? "remove" : "add",
    );

    // 5️⃣ معالجة النتيجة
    result.fold(
      // ❌ فشل -> Rollback + Failure Toast
      (failure) {
        log('>>>>>>>>>>>>>>>>>Share Post Failed: ${failure.message}');
        _updatePostInList(postId, originalPost); // ✅ إرجاع للأصل
        emit(
          state.copyWith(
            shareActionState: CubitStates.failure,
            shareMessage: failure.message,
          ),
        );
      },
      // ✅ نجاح -> Success Toast فقط (الـ UI متحدث بالفعل)
      (message) {
        log('>>>>>>>>>>>>>>>>>Share Post Success: $message');
        emit(
          state.copyWith(
            shareActionState: CubitStates.success,
            shareMessage: message,
            isShareAdded: !isRemoving, // ✅ عشان تعرف في الـ Listener
          ),
        );
      },
    );
  }

  // ✅ Helper Method لتحديث البوست في الليست
  void _updatePostInList(String postId, PostModel updatedPost) {
    final currentIndex = state.posts.indexWhere((p) => p.postId == postId);
    if (currentIndex == -1) return;

    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[currentIndex] = updatedPost;

    emit(state.copyWith(posts: updatedPosts));
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 SAVE POST (Local Only)
  // ═══════════════════════════════════════════════════════════
  void toggleSavePost({required String postId}) {
    final postIndex = state.posts.indexWhere((post) => post.postId == postId);

    if (postIndex == -1) return;

    final post = state.posts[postIndex];

    // تحديث الـ Post
    final updatedPost = post.copyWith(isSaved: !post.isSaved);

    // تحديث القائمة
    final updatedPosts = List<PostModel>.from(state.posts);
    updatedPosts[postIndex] = updatedPost;

    emit(state.copyWith(posts: updatedPosts));

    // homeRepository.toggleSavePost(postId: postId, isSaved: updatedPost.isSaved);
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 FOLLOW/UNFOLLOW ADVISOR (Local Only)
  // ═══════════════════════════════════════════════════════════
  void toggleFollowAdvisor({required String advisorId}) {
    final updatedPosts = state.posts.map((post) {
      if (post.advisorId == advisorId) {
        return post.copyWith(isFollowing: !post.isFollowing);
      }
      return post;
    }).toList();

    emit(state.copyWith(posts: updatedPosts));
  }

  final tayseerSocketHelper socketHelper = getIt.get<tayseerSocketHelper>();

  void sessionStart() {
    log('📡 Setting up Session Start Listener');
    socketHelper.listen('sessionStarted', (data) {
      log('📡 Session Started Event Received: $data');

      final response = SessionStartModel.fromJson(data);

      // Emit جديد مع event
      emit(state.copyWith(sessionStartModel: response));

      // بعد لحظة نصفره عشان listener يتريجر لكل حدث جديد
      Future.delayed(Duration(milliseconds: 100), () {
        emit(state.copyWith(sessionStartModel: null));
      });
    });
  }
}
