import 'package:tayseer/core/models/comment_model.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/comment_card/comment_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_details_card/post_details_card.dart';
import 'package:tayseer/features/shared/post_details/presentation/manager/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/widgets/comments_ui_state.dart';
import 'package:tayseer/my_import.dart';

class PostDetailsBody extends StatefulWidget {
  final PostModel currentPost;
  final VideoPlayerController? cachedController;
  final ScrollController scrollController;
  final PostCallbacks callbacks;
  final bool isFromProfile;
  final String? heroPrefix;

  const PostDetailsBody({
    required this.currentPost,
    this.cachedController,
    required this.scrollController,
    required this.callbacks,
    required this.isFromProfile,
    this.heroPrefix,
  });

  @override
  State<PostDetailsBody> createState() => _PostDetailsBodyState();
}

class _PostDetailsBodyState extends State<PostDetailsBody> {
  final Map<String, GlobalKey> _commentKeys = {};

  void _scrollToComment(String commentId, {bool isForReply = false}) {
    final key = _commentKeys[commentId];
    if (key?.currentContext == null) return;
    Scrollable.ensureVisible(
      key!.currentContext!,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      alignment: isForReply ? 0.2 : 0.3,
    );
  }

  GlobalKey _getKeyForComment(String commentId) =>
      _commentKeys.putIfAbsent(commentId, () => GlobalKey());

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.kprimaryColor,
      onRefresh: () async =>
          context.read<PostDetailsCubit>().loadComments(isRefresh: true),
      child: BlocListener<PostDetailsCubit, PostDetailsState>(
        listenWhen: (prev, curr) =>
            prev.scrollTrigger != curr.scrollTrigger &&
            curr.scrollToCommentId != null,
        listener: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToComment(
              state.scrollToCommentId!,
              isForReply: state.activeReplyId == state.scrollToCommentId,
            );
            context.read<PostDetailsCubit>().clearScrollTarget();
          });
        },
        child:
            BlocSelector<PostDetailsCubit, PostDetailsState, CommentsUIState>(
              selector: _selectCommentsState,
              builder: (context, uiState) {
                final cubit = context.read<PostDetailsCubit>();

                // ✅ تجميع كل الـ Callbacks في الـ Bundle
                final commentCallbacks = CommentCallbacks(
                  onLike: (comment, isReply) =>
                      cubit.toggleLike(isReply, comment.id),
                  onReplyToggle: cubit.toggleReply,
                  onEditToggle: cubit.toggleEdit,
                  onCancelEdit: cubit.cancelEdit,
                  onCancelReply: cubit.cancelReply,
                  onSaveEdit: (id, content, isReply) => cubit.saveEditedComment(
                    commentId: id,
                    newContent: content,
                    isReply: isReply,
                  ),
                  onHideComment: (commentId) =>
                      cubit.toggleHideComment(commentId: commentId),
                  onHideReply: (replyId) =>
                      cubit.toggleHideReply(replyId: replyId),
                  onSendReply: (parentId, text) =>
                      cubit.addReply(parentId, text),
                  onLoadReplies: cubit.loadReplies,
                  onDeleteReply: (id) => cubit.deleteReply(replyId: id),
                  onDeleteComment: (id) => cubit.deleteComment(commentId: id),
                );

                return PostDetailsCard(
                  isFromProfile: widget.isFromProfile,
                  post: widget.currentPost,
                  cachedController: widget.cachedController,
                  scrollController: widget.scrollController,
                  callbacks: widget.callbacks,
                  heroPrefix: widget.heroPrefix,
                  commentCallbacks: commentCallbacks,
                  onCommentTap: () => cubit.requestInputFocus(),
                  comments: uiState.comments,
                  isLoadingComments: uiState.isLoading,
                  hasMoreComments: uiState.hasMore,
                  isLoadingMore: uiState.isLoadingMore,
                  commentsError: uiState.error,
                  editingCommentId: uiState.editingCommentId,
                  activeReplyId: uiState.activeReplyId,
                  isEditLoading: uiState.isEditLoading,
                  isReplyLoading: uiState.isReplyLoading,
                  getCommentKey: _getKeyForComment,
                  onLoadMore: cubit.loadMoreComments,
                  onRetry: cubit.loadComments,
                );
              },
            ),
      ),
    );
  }

  CommentsUIState _selectCommentsState(PostDetailsState state) =>
      CommentsUIState(
        comments: state.comments,
        isLoading: state.commentsState == CubitStates.loading,
        hasMore: state.hasMoreComments,
        isLoadingMore: state.isLoadingMore,
        error: state.commentsState == CubitStates.failure
            ? state.errorMessage
            : null,
        editingCommentId: state.editingCommentId,
        activeReplyId: state.activeReplyId,
        isEditLoading: state.editingState == CubitStates.loading,
        isReplyLoading: state.addingReplyState == CubitStates.loading,
      );
}
