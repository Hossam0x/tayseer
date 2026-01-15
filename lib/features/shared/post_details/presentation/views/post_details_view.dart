import 'package:equatable/equatable.dart';
import 'package:tayseer/core/widgets/post_details_card/post_details_card.dart';
import 'package:tayseer/features/shared/home/model/comment_model.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/shared/post_details/presentation/manager/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/widgets/comment_input_area.dart';
import 'package:tayseer/my_import.dart';

/// PostDetailsView - Optimized view for displaying post details with comments
///
/// Performance Features:
/// - Uses BlocSelector for granular rebuilds
/// - Comments list rebuilds only on structural changes
/// - Individual comments rebuild independently
class PostDetailsView extends StatefulWidget {
  final PostModel post;
  final VideoPlayerController? cachedController;
  final Stream<PostModel>? postUpdatesStream;
  final void Function(String postId, ReactionType? reactionType)?
  onReactionChanged;
  final void Function(String postId)? onShareTap;
  final void Function(String hashtag)? onHashtagTap;
  final VoidCallback? onMoreTap;

  const PostDetailsView({
    super.key,
    required this.post,
    this.cachedController,
    this.postUpdatesStream,
    this.onReactionChanged,
    this.onShareTap,
    this.onHashtagTap,
    this.onMoreTap,
  });

  @override
  State<PostDetailsView> createState() => _PostDetailsViewState();
}

class _PostDetailsViewState extends State<PostDetailsView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
                  post: widget.post,
                  cachedController: widget.cachedController,
                  scrollController: _scrollController,
                  postUpdatesStream: widget.postUpdatesStream,
                  onReactionChanged: widget.onReactionChanged,
                  onShareTap: widget.onShareTap,
                  onHashtagTap: widget.onHashtagTap,
                  onMoreTap: widget.onMoreTap,
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
        widget.post.name,
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
// Body Widget (Handles stream updates)
// ══════════════════════════════════════════════════════════════════════════════

class _PostDetailsBody extends StatefulWidget {
  final PostModel post;
  final VideoPlayerController? cachedController;
  final ScrollController scrollController;
  final Stream<PostModel>? postUpdatesStream;
  final void Function(String postId, ReactionType? reactionType)?
  onReactionChanged;
  final void Function(String postId)? onShareTap;
  final void Function(String hashtag)? onHashtagTap;
  final VoidCallback? onMoreTap;

  const _PostDetailsBody({
    required this.post,
    this.cachedController,
    required this.scrollController,
    this.postUpdatesStream,
    this.onReactionChanged,
    this.onShareTap,
    this.onHashtagTap,
    this.onMoreTap,
  });

  @override
  State<_PostDetailsBody> createState() => _PostDetailsBodyState();
}

class _PostDetailsBodyState extends State<_PostDetailsBody> {
  late PostModel _currentPost;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;

    widget.postUpdatesStream?.listen((updatedPost) {
      if (mounted && updatedPost.postId == _currentPost.postId) {
        setState(() => _currentPost = updatedPost);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.kprimaryColor,
      onRefresh: () async {
        await context.read<PostDetailsCubit>().loadComments(isRefresh: true);
      },
      child: BlocSelector<PostDetailsCubit, PostDetailsState, _CommentsUIState>(
        selector: _selectCommentsState,
        builder: (context, uiState) {
          final cubit = context.read<PostDetailsCubit>();

          return PostDetailsCard(
            post: _currentPost,
            cachedController: widget.cachedController,
            scrollController: widget.scrollController,
            // Post Callbacks
            onReactionChanged: widget.onReactionChanged,
            onShareTap: widget.onShareTap,
            onHashtagTap: widget.onHashtagTap,
            onMoreTap: widget.onMoreTap,
            onCommentTap: () => cubit.requestInputFocus(),
            // Comments Data
            comments: uiState.comments,
            isLoadingComments: uiState.isLoading,
            hasMoreComments: uiState.hasMore,
            isLoadingMore: uiState.isLoadingMore,
            commentsError: uiState.error,
            // State
            editingCommentId: uiState.editingCommentId,
            activeReplyId: uiState.activeReplyId,
            isEditLoading: uiState.isEditLoading,
            isReplyLoading: uiState.isReplyLoading,
            // Comments Callbacks
            onLoadMore: () => cubit.loadMoreComments(),
            onRetry: () => cubit.loadComments(),
            onLikeComment: (comment, isReply) =>
                cubit.toggleLike(isReply, comment.id),
            onReplyTap: (id) => cubit.toggleReply(id),
            onEditTap: (id) => cubit.toggleEdit(id),
            onCancelEdit: () => cubit.cancelEdit(),
            onCancelReply: () => cubit.cancelReply(),
            onSaveEdit: (commentId, content, isReply) =>
                cubit.saveEditedComment(
                  commentId: commentId,
                  newContent: content,
                  isReply: isReply,
                ),
            onSendReply: (commentId, text) => cubit.addReply(commentId, text),
            onLoadReplies: (commentId) => cubit.loadReplies(commentId),
          );
        },
      ),
    );
  }

  _CommentsUIState _selectCommentsState(PostDetailsState state) {
    return _CommentsUIState(
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
}

// ══════════════════════════════════════════════════════════════════════════════
// State Model for BlocSelector
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
