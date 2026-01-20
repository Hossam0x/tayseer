import 'dart:async';
import 'package:equatable/equatable.dart';
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

  const PostDetailsView({
    super.key,
    required this.post,
    this.cachedController,
    this.callbacks = const PostCallbacks(),
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
  final PostModel currentPost; // ✅ بيستقبل البوست المحدث
  final VideoPlayerController? cachedController;
  final ScrollController scrollController;
  final PostCallbacks callbacks;

  const _PostDetailsBody({
    required this.currentPost,
    this.cachedController,
    required this.scrollController,
    required this.callbacks,
  });

  @override
  State<_PostDetailsBody> createState() => _PostDetailsBodyState();
}

class _PostDetailsBodyState extends State<_PostDetailsBody> {
  // ✅ شيلنا إدارة الـ Post Subscription من هنا لأن الأب بيعملها

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

    if (isForReply) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (key.currentContext != null && mounted) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: 0.1,
          );
        }
      });
    }
  }

  GlobalKey _getKeyForComment(String commentId) {
    return _commentKeys.putIfAbsent(commentId, () => GlobalKey());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.kprimaryColor,
      onRefresh: () async {
        await context.read<PostDetailsCubit>().loadComments(isRefresh: true);
      },
      child: BlocListener<PostDetailsCubit, PostDetailsState>(
        listenWhen: (prev, curr) =>
            prev.scrollTrigger != curr.scrollTrigger &&
            curr.scrollToCommentId != null,
        listener: (context, state) {
          if (state.scrollToCommentId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final isForReply = state.activeReplyId == state.scrollToCommentId;
              _scrollToComment(
                state.scrollToCommentId!,
                isForReply: isForReply,
              );
              context.read<PostDetailsCubit>().clearScrollTarget();
            });
          }
        },
        child:
            BlocSelector<PostDetailsCubit, PostDetailsState, _CommentsUIState>(
              selector: _selectCommentsState,
              builder: (context, uiState) {
                final cubit = context.read<PostDetailsCubit>();

                return PostDetailsCard(
                  // ✅ بنستخدم البوست اللي جاي من الـ Widget مباشرة
                  post: widget.currentPost,
                  cachedController: widget.cachedController,
                  scrollController: widget.scrollController,
                  callbacks: widget.callbacks,
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
                  // Keys
                  getCommentKey: _getKeyForComment,
                  // Callbacks
                  onLoadMore: cubit.loadMoreComments,
                  onRetry: cubit.loadComments,
                  onLikeComment: (comment, isReply) =>
                      cubit.toggleLike(isReply, comment.id),
                  onReplyTap: cubit.toggleReply,
                  onEditTap: cubit.toggleEdit,
                  onCancelEdit: cubit.cancelEdit,
                  onCancelReply: cubit.cancelReply,
                  onSaveEdit: (commentId, content, isReply) =>
                      cubit.saveEditedComment(
                        commentId: commentId,
                        newContent: content,
                        isReply: isReply,
                      ),
                  onSendReply: cubit.addReply,
                  onLoadReplies: cubit.loadReplies,
                );
              },
            ),
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
