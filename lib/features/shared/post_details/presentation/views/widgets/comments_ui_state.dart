import 'package:equatable/equatable.dart';
import 'package:tayseer/core/models/comment_model.dart';

class CommentsUIState extends Equatable {
  final List<CommentModel> comments;
  final bool isLoading;
  final bool hasMore;
  final bool isLoadingMore;
  final String? error;
  final String? editingCommentId;
  final String? activeReplyId;
  final bool isEditLoading;
  final bool isReplyLoading;

  const CommentsUIState({
    required this.comments,
    required this.isLoading,
    required this.hasMore,
    required this.isLoadingMore,
    this.error,
    this.editingCommentId,
    this.activeReplyId,
    this.isEditLoading = false,
    this.isReplyLoading = false,
  });

  @override
  List<Object?> get props => [
    comments,
    isLoading,
    hasMore,
    isLoadingMore,
    error,
    editingCommentId,
    activeReplyId,
    isEditLoading,
    isReplyLoading,
  ];
}
