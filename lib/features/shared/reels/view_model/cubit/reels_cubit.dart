// reels_cubit.dart
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:tayseer/core/functions/calculate_top_reactions.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/my_import.dart';

part 'reels_state.dart';

class ReelsCubit extends Cubit<ReelsState> {
  final HomeRepository homeRepo;
  final PostModel? initialPost;

  ReelsCubit(this.homeRepo, {this.initialPost}) : super(const ReelsState());

  static const int _pageSize = 7;

  /// ✅ Safe emit to prevent emitting after close
  void _safeEmit(ReelsState newState) {
    if (!isClosed) emit(newState);
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH REELS
  // ═══════════════════════════════════════════════════════════

  Future<void> fetchReels() async {
    try {
      if (initialPost != null) {
        _safeEmit(
          state.copyWith(
            reels: [initialPost!],
            reelsState: CubitStates.loading,
            errorMessage: null,
          ),
        );
      } else {
        _safeEmit(
          state.copyWith(reelsState: CubitStates.loading, errorMessage: null),
        );
      }

      final result = await homeRepo.getReels(page: 1, limit: _pageSize);

      result.fold(
        (failure) {
          if (initialPost != null) {
            _safeEmit(
              state.copyWith(
                reelsState: CubitStates.success,
                errorMessage: failure.message,
              ),
            );
          } else {
            _safeEmit(
              state.copyWith(
                reelsState: CubitStates.failure,
                errorMessage: failure.message,
              ),
            );
          }
        },
        (reelsList) {
          final mergedReels = _mergeReels(reelsList);
          _safeEmit(
            state.copyWith(
              reelsState: CubitStates.success,
              reels: mergedReels,
              currentPage: 1,
              hasMore: reelsList.length >= _pageSize,
              errorMessage: null,
            ),
          );
        },
      );
      log('🎬 Fetched reels: ${state.reels.length} items');
    } catch (e) {
      _safeEmit(
        state.copyWith(
          reelsState: initialPost != null
              ? CubitStates.success
              : CubitStates.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> fetchMoreReels() async {
    if (state.isLoadingMore || !state.hasMore) return;

    try {
      _safeEmit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await homeRepo.getReels(page: nextPage, limit: _pageSize);

      result.fold(
        (failure) {
          _safeEmit(
            state.copyWith(isLoadingMore: false, errorMessage: failure.message),
          );
        },
        (reelsList) {
          final existingIds = state.reels.map((r) => r.postId).toSet();
          final newReels = reelsList
              .where((r) => !existingIds.contains(r.postId))
              .toList();

          final updatedReels = [...state.reels, ...newReels];

          _safeEmit(
            state.copyWith(
              reels: updatedReels,
              currentPage: nextPage,
              hasMore: reelsList.length >= _pageSize,
              isLoadingMore: false,
              errorMessage: null,
            ),
          );
        },
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(isLoadingMore: false, errorMessage: e.toString()),
      );
    }
  }

  List<PostModel> _mergeReels(List<PostModel> fetchedReels) {
    if (initialPost == null) return fetchedReels;

    final filteredReels = fetchedReels
        .where((reel) => reel.postId != initialPost!.postId)
        .toList();

    return [initialPost!, ...filteredReels];
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 REACT TO REEL
  // ═══════════════════════════════════════════════════════════

  void reactToReel({required String postId, ReactionType? reactionType}) {
    // 1️⃣ إيجاد الـ Reel
    final reelIndex = state.reels.indexWhere((reel) => reel.postId == postId);
    if (reelIndex == -1) return;

    final reel = state.reels[reelIndex];

    // لا تغيير - نفس الريأكشن
    if (reel.myReaction == reactionType && reactionType != null) return;

    // لو مفيش تغيير (null و null)
    if (reel.myReaction == null && reactionType == null) return;

    // 2️⃣ تحديد الحالة
    final isRemoving = reactionType == null;
    final oldReaction = reel.myReaction;

    // 3️⃣ حساب العدد
    int newLikesCount = reel.likesCount;
    if (isRemoving) {
      newLikesCount = (reel.likesCount - 1).clamp(0, reel.likesCount);
    } else if (oldReaction == null) {
      newLikesCount = reel.likesCount + 1;
    }

    // 4️⃣ حساب التوب ريأكشنز
    final newTopReactions = calculateTopReactions(
      currentTopReactions: reel.topReactions,
      oldReaction: oldReaction,
      newReaction: reactionType,
      newLikesCount: newLikesCount,
    );

    // 5️⃣ التحديث
    final updatedReel = reel.copyWith(
      likesCount: newLikesCount,
      topReactions: newTopReactions,
      myReaction: reactionType,
      clearMyReaction: isRemoving,
    );

    _updateReelInList(postId, updatedReel);

    // 6️⃣ API Call
    homeRepo.reactToPost(
      postId: postId,
      reactionType: reactionType,
      isRemove: isRemoving,
    );

    log('🎬 React to Reel: $postId - ${reactionType?.name ?? "removed"}');
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 SHARE REEL
  // ═══════════════════════════════════════════════════════════

  Future<void> toggleShareReel({required String postId}) async {
    // ✅ Reset أول حاجة
    _safeEmit(state.copyWith(shareActionState: CubitStates.initial));

    // 1️⃣ إيجاد الـ Reel
    final reelIndex = state.reels.indexWhere((reel) => reel.postId == postId);
    if (reelIndex == -1) return;

    final originalReel = state.reels[reelIndex];
    final bool isRemoving = originalReel.isRepostedByMe;

    // 2️⃣ حساب العدد الجديد
    final int newSharesCount = isRemoving
        ? (originalReel.sharesCount - 1).clamp(0, originalReel.sharesCount)
        : originalReel.sharesCount + 1;

    // 3️⃣ ✅ Optimistic Update
    final updatedReel = originalReel.copyWith(
      sharesCount: newSharesCount,
      isRepostedByMe: !originalReel.isRepostedByMe,
    );

    _updateReelInList(postId, updatedReel);

    // 4️⃣ API Call
    final result = await homeRepo.sharePost(
      postId: postId,
      action: isRemoving ? "remove" : "add",
    );

    // 5️⃣ معالجة النتيجة
    result.fold(
      (failure) {
        log('❌ Share Reel Failed: ${failure.message}');
        _updateReelInList(postId, originalReel); // Rollback
        _safeEmit(
          state.copyWith(
            shareActionState: CubitStates.failure,
            shareMessage: failure.message,
          ),
        );
      },
      (message) {
        log('✅ Share Reel Success: $message');
        _safeEmit(
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
  // 📌 SAVE REEL
  // ═══════════════════════════════════════════════════════════

  Future<void> toggleSaveReel({required String postId}) async {
    final reelIndex = state.reels.indexWhere((reel) => reel.postId == postId);
    if (reelIndex == -1) return;

    final reel = state.reels[reelIndex];
    final updatedReel = reel.copyWith(isSaved: !reel.isSaved);

    _updateReelInList(postId, updatedReel);

    log('🎬 ${updatedReel.isSaved ? "Saved" : "Unsaved"} Reel: $postId');

    // 3. استدعاء السيرفر
    final result = await homeRepo.savedPost(
      postId: postId,
      isRemove: !updatedReel.isSaved,
    );

    // 4. التعامل مع النتيجة
    result.fold(
      (failure) {
        log('❌ Save Reel Failed: ${failure.message}');
        _updateReelInList(postId, reel); // Rollback
        _safeEmit(
          state.copyWith(
            saveActionState: CubitStates.failure,
            saveMessage: failure.message,
          ),
        );
      },
      (message) {
        log('>>>>>>>>>>>>>>>>> Save Post Success: $message');

        _safeEmit(
          state.copyWith(
            saveActionState: CubitStates.success,
            saveMessage: message,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 FOLLOW/UNFOLLOW ADVISOR
  // ✅ يحدث كل الريلز اللي للـ Advisor ده
  // ═══════════════════════════════════════════════════════════

  Future<void> toggleFollowAdvisor({required String advisorId}) async {
    // 1️⃣ حفظ الـ reference القديمة للـ Rollback (PostModel immutable لا داعي للـ copy)
    final originalReels = state.reels;
    _safeEmit(state.copyWith(followActionState: CubitStates.loading));
    // 2️⃣ تحديد الحالة الحالية قبل التغيير
    final currentReel = state.reels.firstWhere(
      (r) => r.advisorId == advisorId,
      orElse: () => throw StateError('No reel found for advisor $advisorId'),
    );
    final isAdding =
        !currentReel.isFollowing; // true = follow, false = unfollow

    // 3️⃣ Optimistic Update - تحديث لوكال فوراً
    final updatedReels = state.reels.map((reel) {
      if (reel.advisorId == advisorId) {
        return reel.copyWith(isFollowing: isAdding);
      }
      return reel;
    }).toList();

    _safeEmit(state.copyWith(reels: updatedReels));

    final affectedCount = updatedReels
        .where((r) => r.advisorId == advisorId)
        .length;

    log(
      '🎬 [Optimistic] ${isAdding ? "Followed" : "Unfollowed"} Advisor: $advisorId ($affectedCount reels updated)',
    );

    // 4️⃣ API Call
    final result = await homeRepo.followAdvisor(
      advisorId: advisorId,
      isAdding: isAdding,
    );

    result.fold(
      (failure) {
        // ❌ فشل - Rollback للحالة القديمة
        _safeEmit(
          state.copyWith(
            reels: originalReels,
            followActionState: CubitStates.failure,
            followMessage: failure.message,
          ),
        );
        log('❌ Follow Advisor Failed: ${failure.message} - Rolled back');
      },
      (message) {
        // ✅ نجح - خلي التغييرات اللوكال زي ما هي
        log('✅ Follow Advisor Success: $message');
      },
    );
  }
  // ═══════════════════════════════════════════════════════════
  // ✏️ UPDATE EDITED REEL (بعد تعديل ريل من صفحة التعديل)
  // ═══════════════════════════════════════════════════════════
  void updateEditedReel(PostModel updatedPost) {
    _updateReelInList(updatedPost.postId, updatedPost);
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  /// ✅ Helper Method لتحديث ريل واحد في الليست
  void _updateReelInList(String postId, PostModel updatedReel) {
    final currentIndex = state.reels.indexWhere((r) => r.postId == postId);
    if (currentIndex == -1) return;

    final updatedReels = List<PostModel>.from(state.reels);
    updatedReels[currentIndex] = updatedReel;

    _safeEmit(state.copyWith(reels: updatedReels));
  }

  /// ✅ الحصول على ريل بالـ ID
  PostModel? getReelById(String postId) {
    try {
      return state.reels.firstWhere((reel) => reel.postId == postId);
    } catch (_) {
      return null;
    }
  }

  /// ✅ الحصول على كل ريلز الـ Advisor
  List<PostModel> getReelsByAdvisor(String advisorId) {
    return state.reels.where((reel) => reel.advisorId == advisorId).toList();
  }
}
