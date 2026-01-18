part of 'post_details_cubit.dart';

class PostDetailsState extends Equatable {
  // Comments List State
  final CubitStates commentsState;
  final List<CommentModel> comments;
  final String? errorMessage;

  // Pagination
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;

  // Interaction Logic
  final String? activeReplyId;
  final String? editingCommentId;
  final int focusInputTrigger;

  // Action States
  final CubitStates addingCommentState;
  final CubitStates addingReplyState;
  final CubitStates editingState;

  // ✅ Optimistic Update
  final String? pendingCommentTempId;

  // ✅ Auto-Scroll
  final String? scrollToCommentId;
  final int scrollTrigger;

  const PostDetailsState({
    this.commentsState = CubitStates.initial,
    this.comments = const [],
    this.errorMessage,
    this.currentPage = 0,
    this.totalPages = 1,
    this.isLoadingMore = false,
    this.activeReplyId,
    this.editingCommentId,
    this.focusInputTrigger = 0,
    this.addingCommentState = CubitStates.initial,
    this.addingReplyState = CubitStates.initial,
    this.editingState = CubitStates.initial,
    this.pendingCommentTempId,
    this.scrollToCommentId,
    this.scrollTrigger = 0,
  });

  bool get hasMoreComments => currentPage < totalPages;

  PostDetailsState copyWith({
    CubitStates? commentsState,
    List<CommentModel>? comments,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    String? activeReplyId,
    bool? clearActiveReplyId,
    String? editingCommentId,
    bool? clearEditingCommentId,
    int? focusInputTrigger,
    CubitStates? addingCommentState,
    CubitStates? addingReplyState,
    CubitStates? editingState,
    // Optimistic Update
    String? pendingCommentTempId,
    bool? clearPendingCommentTempId,
    // Auto-Scroll
    String? scrollToCommentId,
    bool? clearScrollToCommentId,
    int? scrollTrigger,
  }) {
    return PostDetailsState(
      commentsState: commentsState ?? this.commentsState,
      comments: comments ?? this.comments,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      activeReplyId: (clearActiveReplyId == true)
          ? null
          : (activeReplyId ?? this.activeReplyId),
      editingCommentId: (clearEditingCommentId == true)
          ? null
          : (editingCommentId ?? this.editingCommentId),
      focusInputTrigger: focusInputTrigger ?? this.focusInputTrigger,
      addingCommentState: addingCommentState ?? this.addingCommentState,
      addingReplyState: addingReplyState ?? this.addingReplyState,
      editingState: editingState ?? this.editingState,
      // Optimistic Update
      pendingCommentTempId: (clearPendingCommentTempId == true)
          ? null
          : (pendingCommentTempId ?? this.pendingCommentTempId),
      // Auto-Scroll
      scrollToCommentId: (clearScrollToCommentId == true)
          ? null
          : (scrollToCommentId ?? this.scrollToCommentId),
      scrollTrigger: scrollTrigger ?? this.scrollTrigger,
    );
  }

  @override
  List<Object?> get props => [
        commentsState,
        comments,
        errorMessage,
        currentPage,
        totalPages,
        isLoadingMore,
        activeReplyId,
        editingCommentId,
        focusInputTrigger,
        addingCommentState,
        addingReplyState,
        editingState,
        pendingCommentTempId,
        scrollToCommentId,
        scrollTrigger,
      ];
}