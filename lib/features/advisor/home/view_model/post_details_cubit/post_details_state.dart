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
  final String? activeReplyId;      // ID الكومنت المفتوح للرد
  final String? editingCommentId;   // ID الكومنت المفتوح للتعديل
  final int focusInputTrigger;      

  // Action States
  final CubitStates addingCommentState; // للكومنت الرئيسي
  final CubitStates addingReplyState;   // <--- جديد: للردود
    final CubitStates editingState; // <--- جديد: حالة التعديل

  

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
    this.addingReplyState = CubitStates.initial, // <--- القيمة الافتراضية
    this.editingState = CubitStates.initial, // <--- القيمة الافتراضية
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
    CubitStates? addingReplyState, // <---
    CubitStates? editingState, // <---
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
      addingReplyState: addingReplyState ?? this.addingReplyState, // <---
      editingState: editingState ?? this.editingState, // <---
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
        addingReplyState, // <---
        editingState, // <---
      ];
}