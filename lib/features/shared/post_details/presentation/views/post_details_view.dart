import 'dart:async';
import 'package:tayseer/core/models/comment_model.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/comment_card/comment_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/features/shared/post_details/presentation/manager/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/widgets/comment_input_area.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/widgets/post_details_body.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/widgets/post_shimmer_loader.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/my_import.dart';

class PostDetailsView extends StatefulWidget {
  final PostModel? post;
  final VideoPlayerController? cachedController;
  final PostCallbacks callbacks;
  final bool isFromProfile;
  final String? heroPrefix;
  final bool isArchived;
  final String? postId_fromNotifc;

  const PostDetailsView({
    super.key,
    this.post,
    this.cachedController,
    this.callbacks = const PostCallbacks(),
    required this.isFromProfile,
    this.heroPrefix,
    this.isArchived = false,
    this.postId_fromNotifc,
  });

  @override
  State<PostDetailsView> createState() => _PostDetailsViewState();
}

class _PostDetailsViewState extends State<PostDetailsView> {
  late final ScrollController _scrollController;
  late PostModel? _currentPost;
  StreamSubscription<PostModel?>? _postSubscription;
  late PostDetailsCubit _postDetailsCubit;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _currentPost = widget.post;

    // ✅ Initialize cubit early
    _postDetailsCubit = PostDetailsCubit(
      homeRepository: getIt<HomeRepository>(),
      postId: widget.post?.postId ?? widget.postId_fromNotifc ?? '',
      isCommented: widget.post?.isCommented ?? false,
      isAnonymous: widget.post?.isAnonymous,
    );

    // ✅ إذا كان post null أو مرر postId_fromNotifc -> جلب من API
    if (widget.post == null && widget.postId_fromNotifc != null) {
      _postDetailsCubit.loadPostFromAPI(widget.postId_fromNotifc!);
    }

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

    if (_currentPost != null && updatedPost.postId == _currentPost!.postId) {
      setState(() => _currentPost = updatedPost);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _postSubscription?.cancel();
    _postDetailsCubit.close();
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
        isCommented: widget.post.isCommented,
        isAnonymous: widget.post.isAnonymous,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: MultiBlocListener(
          listeners: [
            // ✅ Comment success
            BlocListener<PostDetailsCubit, PostDetailsState>(
              listenWhen: (prev, curr) =>
                  prev.addingCommentState != curr.addingCommentState,
              listener: (_, state) {
                if (state.addingCommentState == CubitStates.success) {
                  _scrollToTop();
                  _notifyCommented(state.selectedAnonymous);
                }
              },
            ),
            // ✅ Reply success
            BlocListener<PostDetailsCubit, PostDetailsState>(
              listenWhen: (prev, curr) =>
                  prev.addingReplyState != curr.addingReplyState,
              listener: (_, state) {
                if (state.addingReplyState == CubitStates.success) {
                  _notifyCommented(state.selectedAnonymous);
                }
              },
            ),
          ],
          child: Column(
            children: [
              Expanded(
                child: _PostDetailsBody(
                  isFromProfile: widget.isFromProfile,
                  currentPost: _currentPost,
                  cachedController: widget.cachedController,
                  scrollController: _scrollController,
                  callbacks: widget.callbacks,
                  heroPrefix: widget.heroPrefix,
                  isArchived: widget.isArchived,
                ),
              ),
              const CommentInputArea(),
            ],
          ),
        ),
    return BlocProvider.value(
      value: _postDetailsCubit,
      child: BlocBuilder<PostDetailsCubit, PostDetailsState>(
        buildWhen: (prev, curr) =>
            prev.postLoadingState != curr.postLoadingState ||
            prev.postLoadingError != curr.postLoadingError ||
            prev.loadedPost != curr.loadedPost,
        builder: (context, state) {
          // ✅ تحديث _currentPost عندما يتم جلب البوست من API
          if (state.loadedPost != null && _currentPost == null) {
            _currentPost = state.loadedPost;
          }

          // ✅ إذا كان التحميل جاري
          if (state.postLoadingState == CubitStates.loading) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: const PostShimmerLoader(),
            );
          }

          // ✅ إذا كان هناك خطأ
          if (state.postLoadingState == CubitStates.failure) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.postLoadingError ?? 'فشل تحميل المنشور'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<PostDetailsCubit>()
                          .loadPostFromAPI(widget.postId_fromNotifc!),
                      child: const Text('إعادة محاولة'),
                    ),
                  ],
                ),
              ),
            );
          }

          // ✅ إذا لم يتم تحميل أي بوست ولا يوجد خطأ
          if (_currentPost == null) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: const Center(child: Text('لا توجد بيانات المنشور')),
            );
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar(context),
            body: MultiBlocListener(
              listeners: [
                // ✅ Comment success
                BlocListener<PostDetailsCubit, PostDetailsState>(
                  listenWhen: (prev, curr) =>
                      prev.addingCommentState != curr.addingCommentState,
                  listener: (_, state) {
                    if (state.addingCommentState == CubitStates.success) {
                      _scrollToTop();
                      _notifyCommented(state.selectedAnonymous);
                    }
                  },
                ),
                // ✅ Reply success
                BlocListener<PostDetailsCubit, PostDetailsState>(
                  listenWhen: (prev, curr) =>
                      prev.addingReplyState != curr.addingReplyState,
                  listener: (_, state) {
                    if (state.addingReplyState == CubitStates.success) {
                      _notifyCommented(state.selectedAnonymous);
                    }
                  },
                ),
              ],
              child: Column(
                children: [
                  Expanded(
                    child: PostDetailsBody(
                      isFromProfile: widget.isFromProfile,
                      currentPost: _currentPost!,
                      cachedController: widget.cachedController,
                      scrollController: _scrollController,
                      callbacks: widget.callbacks,
                      heroPrefix: widget.heroPrefix,
                    ),
                  ),
                  const CommentInputArea(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Notify HomeCubit about the comment/reply + update local post
  void _notifyCommented(bool isAnonymous) {
    setState(() {
      _currentPost = _currentPost?.copyWith(
        isCommented: true,
        isAnonymous: isAnonymous,
        commentsCount: (_currentPost?.commentsCount ?? 0) + 1,
      );
    });
    widget.callbacks.onCommented?.call(_currentPost!.postId, isAnonymous);
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
        _currentPost?.name ?? '',
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
  final String? heroPrefix;
  final bool isArchived;

  const _PostDetailsBody({
    required this.currentPost,
    this.cachedController,
    required this.scrollController,
    required this.callbacks,
    required this.isFromProfile,
    this.heroPrefix,
    this.isArchived = false,
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
                  onSendReply: (parentId, text) =>
                      cubit.addReply(parentId, text),
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
                  heroPrefix: widget.heroPrefix,
                  isArchived: widget.isArchived,
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
