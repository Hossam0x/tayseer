import 'package:tayseer/features/shared/home/model/comment_model.dart';
import 'package:tayseer/features/advisor/profille/data/models/reply_comment_model.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/comments_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/comments_state.dart';
import 'package:tayseer/my_import.dart';

class CommentsCubit extends Cubit<CommentsState> {
  final CommentsRepository _commentsRepository;
  final int _pageSize = 10;

  CommentsCubit(this._commentsRepository) : super(const CommentsState()) {
    fetchComments();
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH COMMENTS
  // ═══════════════════════════════════════════════════════════
  Future<void> fetchComments({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;

      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await _commentsRepository.getAdvisorComments(
        page: nextPage,
        limit: _pageSize,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(isLoadingMore: false, errorMessage: failure.message),
          );
        },
        (response) {
          final updatedComments = [...state.comments, ...response.comments];
          emit(
            state.copyWith(
              comments: updatedComments,
              currentPage: nextPage,
              // hasMore: response.hasMore,
              isLoadingMore: false,
              // isMe: response.isMe,
              errorMessage: null,
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(
          state: CubitStates.loading,
          comments: [],
          currentPage: 1,
          hasMore: true,
          errorMessage: null,
        ),
      );

      final result = await _commentsRepository.getAdvisorComments(
        page: 1,
        limit: _pageSize,
      );

      if (isClosed) return;

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              state: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (response) {
          emit(
            state.copyWith(
              state: CubitStates.success,
              comments: response.comments,
              currentPage: 1,
              // hasMore: response.hasMore,
              // isMe: response.isMe,
              errorMessage: null,
            ),
          );
        },
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 TOGGLE LIKE COMMENT
  // ═══════════════════════════════════════════════════════════
  Future<void> toggleLikeComment(String commentId) async {
    final index = state.comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return;

    final oldComment = state.comments[index];
    final newComment = CommentModel(
      id: oldComment.id,
      comment: oldComment.comment,
      likes: oldComment.isLiked ? oldComment.likes - 1 : oldComment.likes + 1,
      repliesNumber: oldComment.repliesNumber,
      timeAgo: oldComment.timeAgo,
      createdAt: oldComment.createdAt,
      isLiked: !oldComment.isLiked,
      isOwner: oldComment.isOwner,
      isFollowing: oldComment.isFollowing,
      commenter: oldComment.commenter,
    );

    final updatedComments = List<CommentModel>.from(state.comments);
    updatedComments[index] = newComment;

    emit(state.copyWith(comments: updatedComments));

    final result = await _commentsRepository.toggleLikeComment(commentId);
    result.fold(
      (failure) {
        // Revert on error
        updatedComments[index] = oldComment;
        emit(state.copyWith(comments: updatedComments));
      },
      (_) {
        // Success - already updated
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 DELETE COMMENT
  // ═══════════════════════════════════════════════════════════
  Future<void> deleteComment(String commentId) async {
    final updatedComments = state.comments
        .where((c) => c.id != commentId)
        .toList();
    emit(state.copyWith(comments: updatedComments));

    final result = await _commentsRepository.deleteComment(commentId);
    result.fold(
      (failure) {
        // TODO: إعادة التعليق في حالة الخطأ
      },
      (_) {
        // Success
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 REFRESH COMMENTS
  // ═══════════════════════════════════════════════════════════
  Future<void> refresh() async {
    await fetchComments(loadMore: false);
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 CLEAR ERROR
  // ═══════════════════════════════════════════════════════════
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}

// Cubit للردود
class RepliesCubit extends Cubit<RepliesState> {
  final CommentsRepository _commentsRepository;
  final int _pageSize = 10;

  RepliesCubit(this._commentsRepository, String commentId)
    : super(RepliesState(commentId: commentId)) {
    fetchReplies();
  }

  Future<void> fetchReplies({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;

      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await _commentsRepository.getCommentReplies(
        commentId: state.commentId,
        page: nextPage,
        limit: _pageSize,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(isLoadingMore: false, errorMessage: failure.message),
          );
        },
        (response) {
          final updatedReplies = [...state.replies, ...response.replies];
          emit(
            state.copyWith(
              replies: updatedReplies,
              currentPage: nextPage,
              hasMore: response.hasMore,
              isLoadingMore: false,
              errorMessage: null,
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(
          state: CubitStates.loading,
          replies: [],
          currentPage: 1,
          hasMore: true,
          errorMessage: null,
        ),
      );

      final result = await _commentsRepository.getCommentReplies(
        commentId: state.commentId,
        page: 1,
        limit: _pageSize,
      );

      if (isClosed) return;

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              state: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (response) {
          emit(
            state.copyWith(
              state: CubitStates.success,
              replies: response.replies,
              currentPage: 1,
              hasMore: response.hasMore,
              errorMessage: null,
            ),
          );
        },
      );
    }
  }

  Future<void> createReply(String reply) async {
    final result = await _commentsRepository.createReply(
      commentId: state.commentId,
      reply: reply,
    );

    result.fold(
      (failure) {
        // TODO: معالجة الخطأ
      },
      (_) {
        fetchReplies(); // إعادة تحميل الردود
      },
    );
  }

  Future<void> toggleLikeReply(String replyId) async {
    final index = state.replies.indexWhere((r) => r.id == replyId);
    if (index == -1) return;

    final oldReply = state.replies[index];
    final newReply = ReplyModel(
      id: oldReply.id,
      comment: oldReply.comment,
      likes: oldReply.isLiked ? oldReply.likes - 1 : oldReply.likes + 1,
      timeAgo: oldReply.timeAgo,
      createdAt: oldReply.createdAt,
      isLiked: !oldReply.isLiked,
      isOwner: oldReply.isOwner,
      isFollowing: oldReply.isFollowing,
      commenter: oldReply.commenter,
    );

    final updatedReplies = List<ReplyModel>.from(state.replies);
    updatedReplies[index] = newReply;

    emit(state.copyWith(replies: updatedReplies));

    final result = await _commentsRepository.toggleLikeReply(replyId);
    result.fold(
      (failure) {
        // Revert on error
        updatedReplies[index] = oldReply;
        emit(state.copyWith(replies: updatedReplies));
      },
      (_) {
        // Success
      },
    );
  }

  Future<void> deleteReply(String replyId) async {
    final result = await _commentsRepository.deleteReply(replyId);
    result.fold(
      (failure) {
        // TODO: معالجة الخطأ
      },
      (_) {
        final updatedReplies = state.replies
            .where((r) => r.id != replyId)
            .toList();
        emit(state.copyWith(replies: updatedReplies));
      },
    );
  }

  void refresh() {
    fetchReplies();
  }
}
