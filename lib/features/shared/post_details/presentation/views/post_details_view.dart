import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:tayseer/core/widgets/comment_card/comment_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_details_card/post_details_card.dart';
import 'package:tayseer/core/models/comment_model.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/shared/post_details/presentation/manager/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/widgets/comment_input_area.dart';
import 'package:tayseer/my_import.dart';

class PostDetailsView extends StatefulWidget {
  final PostModel post;
  final VideoPlayerController? cachedController;
  final PostCallbacks callbacks;
  final bool isFromProfile;

  const PostDetailsView({
    super.key,
    required this.post,
    this.cachedController,
    this.callbacks = const PostCallbacks(),
    required this.isFromProfile,
  });

  @override
  State<PostDetailsView> createState() => _PostDetailsViewState();
}

class _PostDetailsViewState extends State<PostDetailsView> {
  late final ScrollController _scrollController;
  late PostModel _currentPost;
  StreamSubscription<PostModel?>? _postSubscription;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _currentPost = widget.post;

    // ✅ الاشتراك في الـ Stream
    _postSubscription = widget.callbacks.postUpdatesStream?.listen(
      _onPostUpdated,
    );
  }

  void _onPostUpdated(PostModel? updatedPost) {
    if (!mounted) return;

    // ✅ لو البوست اتحذف -> اخرج
    if (updatedPost == null) {
      Navigator.of(context).pop();
      return;
    }

    if (updatedPost.postId == _currentPost.postId) {
      setState(() => _currentPost = updatedPost);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _postSubscription?.cancel();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostDetailsCubit(
        homeRepository: getIt<HomeRepository>(),
        postId: widget.post.postId,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: BlocListener<PostDetailsCubit, PostDetailsState>(
          listenWhen: (prev, curr) =>
              prev.addingCommentState != curr.addingCommentState,
          listener: (_, state) {
            if (state.addingCommentState == CubitStates.success) {
              _scrollToTop();
            }
          },
          child: Column(
            children: [
              Expanded(
                child: _PostDetailsBody(
                  isFromProfile: widget.isFromProfile,
                  currentPost: _currentPost,
                  cachedController: widget.cachedController,
                  scrollController: _scrollController,
                  callbacks: widget.callbacks,
                ),
              ),
              const CommentInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        _currentPost.name,
        style: Styles.textStyle16.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Body Widget
// ══════════════════════════════════════════════════════════════════════════════
class _PostDetailsBody extends StatefulWidget {
  final PostModel currentPost;
  final VideoPlayerController? cachedController;
  final ScrollController scrollController;
  final PostCallbacks callbacks;
  final bool isFromProfile;

  const _PostDetailsBody({
    required this.currentPost,
    this.cachedController,
    required this.scrollController,
    required this.callbacks,
    required this.isFromProfile,
  });

  @override
  State<_PostDetailsBody> createState() => _PostDetailsBodyState();
}

class _PostDetailsBodyState extends State<_PostDetailsBody> {
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
            BlocSelector<PostDetailsCubit, PostDetailsState, _CommentsUIState>(
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
                  onSendReply: cubit.addReply,
                  onLoadReplies: cubit.loadReplies,
                  onDeleteReply: (id) => cubit.deleteReply(
                    replyId: id,
                  ), // مثال لإضافة وظائف جديدة بسهولة
                  onDeleteComment: (id) => cubit.deleteComment(
                    commentId: id,
                  ), // مثال لإضافة وظائف جديدة بسهولة
                );

                return PostDetailsCard(
                  isFromProfile: widget.isFromProfile,
                  post: widget.currentPost,
                  cachedController: widget.cachedController,
                  scrollController: widget.scrollController,
                  callbacks: widget.callbacks,
                  commentCallbacks: commentCallbacks, // ✅ تمرير الـ Bundle
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

  _CommentsUIState _selectCommentsState(PostDetailsState state) =>
      _CommentsUIState(
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
// ══════════════════════════════════════════════════════════════════════════════
// State Model
// ══════════════════════════════════════════════════════════════════════════════

class _CommentsUIState extends Equatable {
  final List<CommentModel> comments;
  final bool isLoading;
  final bool hasMore;
  final bool isLoadingMore;
  final String? error;
  final String? editingCommentId;
  final String? activeReplyId;
  final bool isEditLoading;
  final bool isReplyLoading;

  const _CommentsUIState({
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
