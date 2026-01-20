import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/shared/home/model/comment_model.dart';
import 'package:tayseer/features/advisor/profille/data/models/reply_comment_model.dart';

class CommentsState extends Equatable {
  final CubitStates state;
  final List<CommentModel> comments;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isMe;

  const CommentsState({
    this.state = CubitStates.initial,
    this.comments = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isMe = false,
  });

  CommentsState copyWith({
    CubitStates? state,
    List<CommentModel>? comments,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isMe,
  }) {
    return CommentsState(
      state: state ?? this.state,
      comments: comments ?? this.comments,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMe: isMe ?? this.isMe,
    );
  }

  @override
  List<Object?> get props => [
    state,
    comments,
    errorMessage,
    currentPage,
    hasMore,
    isLoadingMore,
    isMe,
  ];
}

// State للردود
class RepliesState extends Equatable {
  final CubitStates state;
  final List<ReplyModel> replies;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String commentId;

  const RepliesState({
    this.state = CubitStates.initial,
    this.replies = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    required this.commentId,
  });

  RepliesState copyWith({
    CubitStates? state,
    List<ReplyModel>? replies,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? commentId,
  }) {
    return RepliesState(
      state: state ?? this.state,
      replies: replies ?? this.replies,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      commentId: commentId ?? this.commentId,
    );
  }

  @override
  List<Object?> get props => [
    state,
    replies,
    errorMessage,
    currentPage,
    hasMore,
    isLoadingMore,
    commentId,
  ];
}
