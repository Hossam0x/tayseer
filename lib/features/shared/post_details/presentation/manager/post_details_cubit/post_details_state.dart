part of 'post_details_cubit.dart';

class PostDetailsState extends Equatable {
  // Post Loading State (from Notification)
  final CubitStates postLoadingState;
  final String? postLoadingError;
  final PostModel? loadedPost;

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

  // Optimistic Update
  final String? pendingCommentTempId;

  // Auto-Scroll
  final String? scrollToCommentId;
  final int scrollTrigger;

  // DELETE COMMENT
  final String deleteCommentMessage;
  final CubitStates deleteCommentActionState;

  // DELETE REPLY
  final String deleteReplyMessage;
  final CubitStates deleteReplyActionState;

  // Anonymous state
  final bool isAnonymousLocked;
  final bool selectedAnonymous;

  // ✅ NEW: Comment Count Delta Sync
  final int pendingCommentCountDelta;
  final int commentCountDeltaTrigger;

  // ✅ NEW: Sync Comment Count from Backend
  final int syncCommentCountFromBackend;
  final int syncCommentCountTrigger;

  // ✅ NEW: Total Comments and Replies Count from Backend
  final int totalCommentsAndRepliesCount;

  const PostDetailsState({
    this.postLoadingState = CubitStates.initial,
    this.postLoadingError,
    this.loadedPost,
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
    this.deleteCommentMessage = '',
    this.deleteCommentActionState = CubitStates.initial,
    this.deleteReplyMessage = '',
    this.deleteReplyActionState = CubitStates.initial,
    this.isAnonymousLocked = false,
    this.selectedAnonymous = false,
    // ✅ NEW
    this.pendingCommentCountDelta = 0,
    this.commentCountDeltaTrigger = 0,
    // ✅ NEW: Sync from Backend
    this.syncCommentCountFromBackend = 0,
    this.syncCommentCountTrigger = 0,
    this.totalCommentsAndRepliesCount = 0,
  });

  bool get hasMoreComments => currentPage < totalPages;

  PostDetailsState copyWith({
    CubitStates? postLoadingState,
    String? postLoadingError,
    bool? clearPostLoadingError,
    PostModel? loadedPost,
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
    // Delete Comment
    String? deleteCommentMessage,
    CubitStates? deleteCommentActionState,
    // Delete Reply
    String? deleteReplyMessage,
    CubitStates? deleteReplyActionState,
    // Anonymous state
    bool? isAnonymousLocked,
    bool? selectedAnonymous,
    // ✅ NEW: Delta
    int? pendingCommentCountDelta,
    int? commentCountDeltaTrigger,
    // ✅ NEW: Sync from Backend
    int? syncCommentCountFromBackend,
    int? syncCommentCountTrigger,
    int? totalCommentsAndRepliesCount,
  }) {
    return PostDetailsState(
      postLoadingState: postLoadingState ?? this.postLoadingState,
      postLoadingError: (clearPostLoadingError == true)
          ? null
          : (postLoadingError ?? this.postLoadingError),
      loadedPost: loadedPost ?? this.loadedPost,
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
      pendingCommentTempId: (clearPendingCommentTempId == true)
          ? null
          : (pendingCommentTempId ?? this.pendingCommentTempId),
      scrollToCommentId: (clearScrollToCommentId == true)
          ? null
          : (scrollToCommentId ?? this.scrollToCommentId),
      scrollTrigger: scrollTrigger ?? this.scrollTrigger,
      deleteCommentMessage: deleteCommentMessage ?? this.deleteCommentMessage,
      deleteCommentActionState:
          deleteCommentActionState ?? this.deleteCommentActionState,
      deleteReplyMessage: deleteReplyMessage ?? this.deleteReplyMessage,
      deleteReplyActionState:
          deleteReplyActionState ?? this.deleteReplyActionState,
      isAnonymousLocked: isAnonymousLocked ?? this.isAnonymousLocked,
      selectedAnonymous: selectedAnonymous ?? this.selectedAnonymous,
      // ✅ NEW
      pendingCommentCountDelta:
          pendingCommentCountDelta ?? this.pendingCommentCountDelta,
      commentCountDeltaTrigger:
          commentCountDeltaTrigger ?? this.commentCountDeltaTrigger,
      // ✅ NEW: Sync from Backend
      syncCommentCountFromBackend:
          syncCommentCountFromBackend ?? this.syncCommentCountFromBackend,
      syncCommentCountTrigger:
          syncCommentCountTrigger ?? this.syncCommentCountTrigger,
      totalCommentsAndRepliesCount:
          totalCommentsAndRepliesCount ?? this.totalCommentsAndRepliesCount,
    );
  }

  @override
  List<Object?> get props => [
    postLoadingState,
    postLoadingError,
    loadedPost,
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
    deleteCommentMessage,
    deleteCommentActionState,
    deleteReplyMessage,
    deleteReplyActionState,
    isAnonymousLocked,
    selectedAnonymous,
    // ✅ NEW
    pendingCommentCountDelta,
    commentCountDeltaTrigger,
    // ✅ NEW: Sync from Backend
    syncCommentCountFromBackend,
    syncCommentCountTrigger,
    totalCommentsAndRepliesCount,
  ];
}
