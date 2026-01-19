// lib/features/advisor/home/cubit/post_details_cubit.dart

import 'package:equatable/equatable.dart';
import 'package:tayseer/features/shared/home/model/comment_model.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/my_import.dart';

part 'post_details_state.dart';

class PostDetailsCubit extends Cubit<PostDetailsState> {
  final HomeRepository homeRepository;
  final String postId;

  PostDetailsCubit({required this.homeRepository, required this.postId})
    : super(const PostDetailsState()) {
    loadComments();
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH COMMENTS (Load & Refresh)
  // ═══════════════════════════════════════════════════════════
  Future<void> loadComments({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(state.copyWith(commentsState: CubitStates.loading));
    }

    final result = await homeRepository.fetchComments(postId: postId, page: 1);

    result.fold(
      (failure) => emit(
        state.copyWith(
          commentsState: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          commentsState: CubitStates.success,
          comments: response.comments,
          currentPage: response.pagination.currentPage,
          totalPages: response.pagination.totalPages,
          isLoadingMore: false,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 LOAD MORE
  // ═══════════════════════════════════════════════════════════
  Future<void> loadMoreComments() async {
    if (state.isLoadingMore || !state.hasMoreComments) return;

    emit(state.copyWith(isLoadingMore: true));

    final result = await homeRepository.fetchComments(
      postId: postId,
      page: state.currentPage + 1,
    );

    result.fold(
      (failure) => emit(state.copyWith(isLoadingMore: false)),
      (response) => emit(
        state.copyWith(
          isLoadingMore: false,
          comments: [...state.comments, ...response.comments],
          currentPage: response.pagination.currentPage,
          totalPages: response.pagination.totalPages,
        ),
      ),
    );
  }
  // ═══════════════════════════════════════════════════════════
// 📌 ADD COMMENT (Optimistic Update + Auto-Scroll)
// ═══════════════════════════════════════════════════════════

Future<void> addComment(String content) async {
  if (content.trim().isEmpty) return;

  final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

  const currentUser = CommenterModel(
    id: 'current_user_id',
    name: 'أنت',
    userName: 'current_user',
    avatar: null,
    isVerified: false,
    userType: 'user',
  );

  final tempComment = CommentModel.temp(
    tempId: tempId,
    content: content.trim(),
    commenter: currentUser,
  );

  emit(state.copyWith(
    addingCommentState: CubitStates.loading,
    comments: [tempComment, ...state.comments],
    pendingCommentTempId: tempId,
  ));

  final result = await homeRepository.addComment(
    postId: postId,
    comment: content,
  );

  result.fold(
    (failure) {
      final updatedComments = state.comments
          .where((c) => c.id != tempId)
          .toList();

      emit(state.copyWith(
        addingCommentState: CubitStates.failure,
        errorMessage: failure.message,
        comments: updatedComments,
        clearPendingCommentTempId: true,
      ));

      emit(state.copyWith(addingCommentState: CubitStates.initial));
    },
    (newComment) {
      final updatedComments = state.comments.map((c) {
        if (c.id == tempId) return newComment;
        return c;
      }).toList();

      emit(state.copyWith(
        addingCommentState: CubitStates.success,
        comments: updatedComments,
        clearPendingCommentTempId: true,
        // ✅ NEW: Scroll للكومنت الجديد
        scrollToCommentId: newComment.id,
        scrollTrigger: state.scrollTrigger + 1,
      ));

      emit(state.copyWith(addingCommentState: CubitStates.initial));
    },
  );
}

// ═══════════════════════════════════════════════════════════
// 📌 ADD REPLY (with Auto-Scroll)
// ═══════════════════════════════════════════════════════════

Future<void> addReply(String parentCommentId, String content) async {
  if (content.trim().isEmpty) return;

  emit(state.copyWith(addingReplyState: CubitStates.loading));

  final result = await homeRepository.addReply(
    commentId: parentCommentId,
    reply: content,
  );

  result.fold(
    (failure) {
      emit(state.copyWith(
        addingReplyState: CubitStates.failure,
        errorMessage: failure.message,
      ));
      emit(state.copyWith(addingReplyState: CubitStates.initial));
    },
    (newReply) {
      final updatedComments = _updateCommentById(
        state.comments,
        parentCommentId,
        (parentComment) {
          final updatedReplies = [newReply, ...parentComment.replies];

          int newCurrentPage = parentComment.repliesCurrentPage;
          int newTotalPages = parentComment.repliesTotalPages;

          if (newCurrentPage == 0) newCurrentPage = 1;
          if (newTotalPages == 0) newTotalPages = 1;

          return parentComment.copyWith(
            replies: updatedReplies,
            repliesNumber: parentComment.repliesNumber + 1,
            repliesCurrentPage: newCurrentPage,
            repliesTotalPages: newTotalPages,
          );
        },
      );

      emit(state.copyWith(
        addingReplyState: CubitStates.success,
        comments: updatedComments,
        clearActiveReplyId: true,
        // ✅ NEW: Scroll للرد الجديد
        scrollToCommentId: newReply.id,
        scrollTrigger: state.scrollTrigger + 1,
      ));

      emit(state.copyWith(addingReplyState: CubitStates.initial));
    },
  );
}

// ═══════════════════════════════════════════════════════════
// 📌 TOGGLE REPLY (with Auto-Scroll to comment)
// ═══════════════════════════════════════════════════════════

void toggleReply(String commentId) {
  if (state.activeReplyId == commentId) {
    emit(state.copyWith(clearActiveReplyId: true));
  } else {
    emit(state.copyWith(
      activeReplyId: commentId,
      clearEditingCommentId: true,
      // ✅ NEW: Scroll للكومنت اللي هنرد عليه
      scrollToCommentId: commentId,
      scrollTrigger: state.scrollTrigger + 1,
    ));
  }
}

// ═══════════════════════════════════════════════════════════
// 📌 SAVE EDITED COMMENT (with Auto-Scroll)
// ═══════════════════════════════════════════════════════════

Future<void> saveEditedComment({
  required String commentId,
  required String newContent,
  required bool isReply,
}) async {
  if (newContent.trim().isEmpty) return;

  emit(state.copyWith(editingState: CubitStates.loading));

  final result = isReply
      ? await homeRepository.editReply(replyId: commentId, reply: newContent)
      : await homeRepository.editComment(commentId: commentId, comment: newContent);

  result.fold(
    (failure) {
      emit(state.copyWith(
        editingState: CubitStates.failure,
        errorMessage: failure.message,
      ));
      emit(state.copyWith(editingState: CubitStates.initial));
    },
    (successMessage) {
      final updatedComments = _updateCommentById(
        state.comments,
        commentId,
        (comment) => comment.copyWith(comment: newContent),
      );

      emit(state.copyWith(
        editingState: CubitStates.success,
        comments: updatedComments,
        clearEditingCommentId: true,
        // ✅ NEW: Scroll للكومنت اللي اتعدل
        scrollToCommentId: commentId,
        scrollTrigger: state.scrollTrigger + 1,
      ));
      
      emit(state.copyWith(editingState: CubitStates.initial));
    },
  );
}

// ═══════════════════════════════════════════════════════════
// 📌 CLEAR SCROLL (يُستدعى بعد ما الـ UI يعمل scroll)
// ═══════════════════════════════════════════════════════════

void clearScrollTarget() {
  emit(state.copyWith(clearScrollToCommentId: true));
}
 
 
  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH REPLIES & OTHER ACTIONS (كما هي)
  // ═══════════════════════════════════════════════════════════

  Future<void> loadReplies(String commentId) async {
    final targetComment = _findCommentById(state.comments, commentId);
    if (targetComment == null || targetComment.isLoadingReplies) return;

    if (targetComment.repliesCurrentPage > 0 &&
        targetComment.repliesCurrentPage >= targetComment.repliesTotalPages) {
      return;
    }

    final int nextPage = targetComment.repliesCurrentPage + 1;

    emit(
      state.copyWith(
        comments: _updateCommentById(
          state.comments,
          commentId,
          (c) => c.copyWith(isLoadingReplies: true),
        ),
      ),
    );

    final result = await homeRepository.fetchReplies(
      commentId: commentId,
      page: nextPage,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            comments: _updateCommentById(
              state.comments,
              commentId,
              (c) => c.copyWith(isLoadingReplies: false),
            ),
            errorMessage: failure.message,
          ),
        );
      },
      (response) {
        final updatedComments = _updateCommentById(state.comments, commentId, (
          oldComment,
        ) {
          final newRepliesList = [...oldComment.replies, ...response.comments];
          return oldComment.copyWith(
            isLoadingReplies: false,
            replies: newRepliesList,
            repliesCurrentPage: response.pagination.currentPage,
            repliesTotalPages: response.pagination.totalPages,
            repliesNumber: (oldComment.repliesNumber > newRepliesList.length)
                ? oldComment.repliesNumber
                : newRepliesList.length,
          );
        });
        emit(state.copyWith(comments: updatedComments));
      },
    );
  }


  // ═══════════════════════════════════════════════════════════
  // 📌 LIKE
  // ═══════════════════════════════════════════════════════════

  void toggleLike(bool isReply, String commentId) {
    bool? newIsLiked; // نعرّفه برا

    final updatedComments = _updateCommentById(state.comments, commentId, (
      comment,
    ) {
      newIsLiked = !comment.isLiked;
      final newLikes = newIsLiked! ? comment.likes + 1 : comment.likes - 1;

      return comment.copyWith(isLiked: newIsLiked, likes: newLikes);
    });

    emit(state.copyWith(comments: updatedComments));

    homeRepository.likeToggle(
      commentId: isReply ? null : commentId,
      isRemove: !(newIsLiked ?? false),
      replyId: isReply ? commentId : null,
    );
  }



  void cancelReply() {
    emit(state.copyWith(clearActiveReplyId: true));
  }

  void toggleEdit(String commentId) {
    if (state.editingCommentId == commentId) {
      emit(state.copyWith(clearEditingCommentId: true));
    } else {
      emit(
        state.copyWith(editingCommentId: commentId, clearActiveReplyId: true),
      );
    }
  }

  void cancelEdit() {
    emit(state.copyWith(clearEditingCommentId: true));
  }

  void requestInputFocus() {
    emit(
      state.copyWith(
        clearActiveReplyId: true,
        focusInputTrigger: state.focusInputTrigger + 1,
      ),
    );
  }

  // Helpers
  CommentModel? _findCommentById(List<CommentModel> comments, String targetId) {
    for (var comment in comments) {
      if (comment.id == targetId) return comment;
      if (comment.replies.isNotEmpty) {
        final found = _findCommentById(comment.replies, targetId);
        if (found != null) return found;
      }
    }
    return null;
  }

  List<CommentModel> _updateCommentById(
    List<CommentModel> comments,
    String targetId,
    CommentModel Function(CommentModel) update,
  ) {
    return comments.map((comment) {
      if (comment.id == targetId) return update(comment);
      if (comment.replies.isNotEmpty) {
        final updatedReplies = _updateCommentById(
          comment.replies,
          targetId,
          update,
        );
        if (updatedReplies != comment.replies) {
          return comment.copyWith(replies: updatedReplies);
        }
      }
      return comment;
    }).toList();
  }
}
