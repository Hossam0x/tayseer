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
  final String? heroPrefix;
  final bool isArchived;

  const PostDetailsView({
    super.key,
    required this.post,
    this.cachedController,
    this.callbacks = const PostCallbacks(),
    required this.isFromProfile,
    this.heroPrefix,
    this.isArchived = false,
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
      ),
    );
  }

  /// Notify HomeCubit about the comment/reply + update local post
  void _notifyCommented(bool isAnonymous) {
    setState(() {
      _currentPost = _currentPost.copyWith(
        isCommented: true,
        isAnonymous: isAnonymous,
        commentsCount: _currentPost.commentsCount + 1,
      );
    });
    widget.callbacks.onCommented?.call(_currentPost.postId, isAnonymous);
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

  void _scrollToComment(String commentId, {bool isForReply = false}) async {
    final key = _commentKeys[commentId];
    if (key?.currentContext == null) return;

    // 1. ننتظر 500 ملي ثانية لضمان انتهاء أنيميشن الكيبورد وبناء الـ UI
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted || key!.currentContext == null) return;

    // 2. عمل سكرول ليحاذي العنصر الكيبورد
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: 1.0,
    );

    // 3. (تِريك إضافي): نعمل سكرول زيادة 60 بيكسل للأسفل لضمان إعطاء مساحة تنفس للأزرار وعدم قصها
    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted && widget.scrollController.hasClients) {
      final currentOffset = widget.scrollController.offset;
      final maxScroll = widget.scrollController.position.maxScrollExtent;

      // نزود 60 بيكسل للسكرول بس بشرط منتخطاش الـ maxScroll
      final targetOffset = (currentOffset + 60).clamp(0.0, maxScroll);

      widget.scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
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
                  isArchived: widget.isArchived,
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
