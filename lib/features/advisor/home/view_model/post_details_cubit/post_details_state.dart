part of 'post_details_cubit.dart';

sealed class PostDetailsState extends Equatable {
  const PostDetailsState();

  @override
  List<Object?> get props => [];
}

final class PostDetailsInitial extends PostDetailsState {}

final class PostDetailsLoaded extends PostDetailsState {
  final List<CommentModel> comments;
  final String? activeReplyId;
  final String? editingCommentId;
  final int focusInputTrigger;

  const PostDetailsLoaded({
    required this.comments,
    this.activeReplyId,
    this.editingCommentId,
    this.focusInputTrigger = 0,
  });

  PostDetailsLoaded copyWith({
    List<CommentModel>? comments,
    String? activeReplyId,
    String? editingCommentId,
    bool clearActiveReplyId = false,
    bool clearEditingCommentId = false,
    int? focusInputTrigger,
  }) {
    return PostDetailsLoaded(
      comments: comments ?? this.comments,
      activeReplyId:
          clearActiveReplyId ? null : (activeReplyId ?? this.activeReplyId),
      editingCommentId:
          clearEditingCommentId
              ? null
              : (editingCommentId ?? this.editingCommentId),
      focusInputTrigger: focusInputTrigger ?? this.focusInputTrigger,
    );
  }

  @override
  List<Object?> get props => [
    comments,
    activeReplyId,
    editingCommentId,
    focusInputTrigger,
  ];
}
