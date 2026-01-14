import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:tayseer/core/widgets/comment_card/comment_card.dart';
import 'package:tayseer/features/advisor/home/model/comment_model.dart';
import 'package:tayseer/features/advisor/home/view_model/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/my_import.dart';

/// CommentItemWidget - Wrapper that connects CommentCard to PostDetailsCubit
///
/// Performance optimized with BlocSelector for granular rebuilds
class CommentItemWidget extends StatelessWidget {
  final CommentModel comment;
  final bool isReply;

  const CommentItemWidget({
    super.key,
    required this.comment,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    log(">>>>>>>${comment.comment}");
    return BlocSelector<PostDetailsCubit, PostDetailsState, _CommentState>(
      selector: (state) => _CommentState(
        isEditing: state.editingCommentId == comment.id,
        isReplying: state.activeReplyId == comment.id,
        isEditLoading:
            state.editingCommentId == comment.id &&
            state.editingState == CubitStates.loading,
        isReplyLoading:
            state.activeReplyId == comment.id &&
            state.addingReplyState == CubitStates.loading,
      ),
      builder: (context, uiState) {
        final cubit = context.read<PostDetailsCubit>();

        return CommentCard(
          comment: comment,
          isReply: isReply,
          isEditing: uiState.isEditing,
          isReplying: uiState.isReplying,
          isEditLoading: uiState.isEditLoading,
          isReplyLoading: uiState.isReplyLoading,
          isLoadingReplies: comment.isLoadingReplies,

          // Callbacks
          onLikeTap: () => cubit.toggleLike(isReply, comment.id),
          onReplyTap: () => cubit.toggleReply(comment.id),
          onEditTap: () => cubit.toggleEdit(comment.id),
          onCancelEdit: () => cubit.cancelEdit(),
          onCancelReply: () => cubit.cancelReply(),
          onSaveEdit: (newContent) => cubit.saveEditedComment(
            commentId: comment.id,
            newContent: newContent,
            isReply: isReply,
          ),
          onSendReply: (text) => cubit.addReply(comment.id, text),
          onLoadReplies: () => cubit.loadReplies(comment.id),
        );
      },
    );
  }
}

/// State model for BlocSelector optimization
class _CommentState extends Equatable {
  final bool isEditing;
  final bool isReplying;
  final bool isEditLoading;
  final bool isReplyLoading;

  const _CommentState({
    required this.isEditing,
    required this.isReplying,
    required this.isEditLoading,
    required this.isReplyLoading,
  });

  @override
  List<Object?> get props => [
    isEditing,
    isReplying,
    isEditLoading,
    isReplyLoading,
  ];
}
