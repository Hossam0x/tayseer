import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/home/model/comment_model.dart';
import 'package:tayseer/features/advisor/home/reposiotry/home_repository.dart';
import 'package:tayseer/my_import.dart';

part 'post_details_state.dart';

class PostDetailsCubit extends Cubit<PostDetailsState> {
  final HomeRepository homeRepository;
  PostDetailsCubit(this.homeRepository) : super(PostDetailsInitial()) {
    _loadComments();
  }

  void _loadComments() {
    emit(PostDetailsLoaded(comments: List.from(dummyComments)));
  }

  void toggleReply(String commentId) {
    final currentState = state;
    if (currentState is PostDetailsLoaded) {
      if (currentState.activeReplyId == commentId) {
        emit(currentState.copyWith(clearActiveReplyId: true));
      } else {
        emit(
          currentState.copyWith(
            activeReplyId: commentId,
            clearEditingCommentId: true,
          ),
        );
      }
    }
  }

  void cancelReply() {
    final currentState = state;
    if (currentState is PostDetailsLoaded) {
      emit(currentState.copyWith(clearActiveReplyId: true));
    }
  }

  void toggleEdit(String commentId) {
    final currentState = state;
    if (currentState is PostDetailsLoaded) {
      if (currentState.editingCommentId == commentId) {
        emit(currentState.copyWith(clearEditingCommentId: true));
      } else {
        emit(
          currentState.copyWith(
            editingCommentId: commentId,
            clearActiveReplyId: true,
          ),
        );
      }
    }
  }

  void cancelEdit() {
    final currentState = state;
    if (currentState is PostDetailsLoaded) {
      emit(currentState.copyWith(clearEditingCommentId: true));
    }
  }

  void requestInputFocus() {
    final currentState = state;
    if (currentState is PostDetailsLoaded) {
      emit(
        currentState.copyWith(
          clearActiveReplyId: true,
          focusInputTrigger: currentState.focusInputTrigger + 1,
        ),
      );
    }
  }

  void saveEditedComment(String commentId, String newContent) {
    final currentState = state;
    if (currentState is PostDetailsLoaded) {
      final updatedComments = _updateCommentInList(
        currentState.comments,
        commentId,
        (comment) => CommentModel(
          id: comment.id,
          name: comment.name,
          userName: comment.userName,
          avatar: comment.avatar,
          isVerified: comment.isVerified,
          content: newContent,
          timeAgo: comment.timeAgo,
          likesCount: comment.likesCount,
          isLiked: comment.isLiked,
          isOwner: comment.isOwner,
          replies: comment.replies,
          isFollowing: comment.isFollowing,
        ),
      );
      emit(
        currentState.copyWith(
          comments: updatedComments,
          clearEditingCommentId: true,
        ),
      );
    }
  }

  void toggleLike(String commentId) {
    final currentState = state;
    if (currentState is PostDetailsLoaded) {
      final updatedComments = _updateCommentInList(
        currentState.comments,
        commentId,
        (comment) {
          final newIsLiked = !comment.isLiked;
          final newLikesCount = newIsLiked
              ? comment.likesCount + 1
              : comment.likesCount - 1;
          return CommentModel(
            id: comment.id,
            name: comment.name,
            userName: comment.userName,
            avatar: comment.avatar,
            isVerified: comment.isVerified,
            content: comment.content,
            timeAgo: comment.timeAgo,
            likesCount: newLikesCount,
            isLiked: newIsLiked,
            isOwner: comment.isOwner,
            replies: comment.replies,
            isFollowing: comment.isFollowing,
          );
        },
      );
      emit(currentState.copyWith(comments: updatedComments));
    }
  }

  List<CommentModel> _updateCommentInList(
    List<CommentModel> list,
    String targetId,
    CommentModel Function(CommentModel) update,
  ) {
    return list.map((comment) {
      if (comment.id == targetId) {
        return update(comment);
      } else if (comment.replies.isNotEmpty) {
        final updatedReplies = _updateCommentInList(
          comment.replies,
          targetId,
          update,
        );
        if (updatedReplies != comment.replies) {
          return CommentModel(
            id: comment.id,
            name: comment.name,
            userName: comment.userName,
            avatar: comment.avatar,
            isVerified: comment.isVerified,
            content: comment.content,
            timeAgo: comment.timeAgo,
            likesCount: comment.likesCount,
            isLiked: comment.isLiked,
            isOwner: comment.isOwner,
            replies: updatedReplies,
            isFollowing: comment.isFollowing,
          );
        }
      }
      return comment;
    }).toList();
  }
}
