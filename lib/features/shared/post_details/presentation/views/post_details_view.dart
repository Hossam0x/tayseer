import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/core/models/comment_model.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/comment_card/comment_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_details_card/post_details_card.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/post_details/presentation/manager/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/widgets/comment_input_area.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/widgets/post_shimmer_loader.dart';
import 'package:tayseer/main.dart';
import 'package:tayseer/my_import.dart';

class PostDetailsView extends StatefulWidget {
  final PostModel? post;
  final VideoPlayerController? cachedController;
  final PostCallbacks callbacks;
  final bool isFromProfile;
  final String? heroPrefix;
  final bool isArchived;
  final String? postId_fromNotifc;
  final int initialImageIndex;

  const PostDetailsView({
    super.key,
    this.post,
    this.cachedController,
    this.callbacks = const PostCallbacks(),
    required this.isFromProfile,
    this.heroPrefix,
    this.isArchived = false,
    this.postId_fromNotifc,
    this.initialImageIndex = 0,
  });

  @override
  State<PostDetailsView> createState() => _PostDetailsViewState();
}

class _PostDetailsViewState extends State<PostDetailsView> {
  late final ScrollController _scrollController;
  PostModel? _currentPost;
  StreamSubscription<PostModel?>? _postSubscription;
  late PostDetailsCubit _postDetailsCubit;
  late PostCallbacks _effectiveCallbacks;
  bool _isNotificationMode = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _currentPost = widget.post;

    _postDetailsCubit = PostDetailsCubit(
      homeRepository: getIt<HomeRepository>(),
      postId: widget.post?.postId ?? widget.postId_fromNotifc ?? '',
      isCommented: widget.post?.isCommented ?? false,
      isAnonymous: widget.post?.isAnonymous,
    );

    if (widget.post == null && widget.postId_fromNotifc != null) {
      _postDetailsCubit.loadPostFromAPI(widget.postId_fromNotifc!);
    }

    _effectiveCallbacks = _buildEffectiveCallbacks();

    if (_isNotificationMode && _currentPost != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) getIt<HomeCubit>().injectPost(_currentPost!);
      });
    }

    _postSubscription = _effectiveCallbacks.postUpdatesStream?.listen(
      _onPostUpdated,
    );
  }

  void _onPostUpdated(PostModel? updatedPost) {
    if (!mounted) return;

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
    if (_currentPost != null) {
      widget.callbacks.onEdit?.call(_currentPost!);
    }
    _postDetailsCubit.close();
    super.dispose();
  }

  PostCallbacks _buildEffectiveCallbacks() {
    if (widget.callbacks.hasCallbacks ||
        widget.callbacks.postUpdatesStream != null) {
      return widget.callbacks;
    }

    _isNotificationMode = true;
    final homeCubit = getIt<HomeCubit>();
    final String postId = widget.post?.postId ?? widget.postId_fromNotifc ?? '';

    final postStream = homeCubit.stream
        .map(
          (state) => state.posts.where((p) => p.postId == postId).firstOrNull,
        )
        .distinct();

    return PostCallbacks(
      postUpdatesStream: postStream,
      onReactionChanged: (pId, type) =>
          homeCubit.reactToPost(postId: pId, reactionType: type),
      onShareTap: (pId) => homeCubit.toggleSharePost(postId: pId),
      onShareToStoryTap: (pId) => homeCubit.sharePostToStory(postId: pId),
      onHashtagTap: (hashtag) {
        final clean = hashtag.startsWith('#') ? hashtag.substring(1) : hashtag;
        navigatorKey.currentContext?.pushNamed(
          AppRouter.kAdvisorSearchView,
          arguments: {'query': clean, 'tab': 'posts'},
        );
      },
      onEdit: (post) => homeCubit.updateEditedPost(post),
      onReport: (pId) {
        navigatorKey.currentContext?.pushNamed(
          AppRouter.kReportsView,
          arguments: {'type': ReportType.post, 'id': pId},
        );
      },
      onSave: (pId) => homeCubit.toggleSavePost(postId: pId),
      onDelete: (pId) => homeCubit.deletePost(postId: pId),
      onHide: (pId) => homeCubit.toggleHidePost(postId: pId),
      onBlock: (pId, userId) =>
          homeCubit.blockUser(visiblePostId: pId, advisorId: userId),
      onArchive: (pId) => homeCubit.archivePost(postId: pId),
      onPollVote: (pId, choice) =>
          homeCubit.voteInPoll(postId: pId, choiceText: choice),
      onCommented: (pId, isAnon) =>
          homeCubit.markPostAsCommented(postId: pId, isAnonymous: isAnon),
      onCommentCountDelta:
          ({required postId, required countDelta, isCommented, isAnonymous}) =>
              homeCubit.updateCommentCountByDelta(
                postId: postId,
                countDelta: countDelta,
                isCommented: isCommented,
                isAnonymous: isAnonymous,
              ),
      onCommentCountSync: ({required postId, required totalCount}) => homeCubit
          .syncCommentCountFromBackend(postId: postId, totalCount: totalCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _postDetailsCubit,
      child: BlocBuilder<PostDetailsCubit, PostDetailsState>(
        builder: (context, state) {
          if (state.loadedPost != null && _currentPost == null) {
            _currentPost = state.loadedPost;
          }

          if (state.postLoadingState == CubitStates.loading) {
            return const Scaffold(body: PostShimmerLoader());
          }

          if (state.postLoadingState == CubitStates.failure) {
            return Scaffold(
              body: CustomErrorView(
                message: state.postLoadingError ?? 'Error',
                onRetry: () => _postDetailsCubit.loadPostFromAPI(
                  widget.postId_fromNotifc!,
                ),
              ),
            );
          }

          if (_currentPost == null) {
            return Scaffold(
              body: CustomErrorView(
                message: 'No post data',
                onRetry: () => _postDetailsCubit.loadPostFromAPI(
                  widget.postId_fromNotifc!,
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _buildAppBar(),
            body: Column(
              children: [
                Expanded(
                  child: _PostDetailsBody(
                    currentPost: _currentPost!,
                    cachedController: widget.cachedController,
                    scrollController: _scrollController,
                    callbacks: _effectiveCallbacks,
                    isFromProfile: widget.isFromProfile,
                    heroPrefix: widget.heroPrefix,
                    isArchived: widget.isArchived,
                    initialImageIndex: widget.initialImageIndex,
                  ),
                ),
                const CommentInputArea(),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: const BackButton(color: Colors.black),
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
// Body Widget ✅ MODIFIED
// ══════════════════════════════════════════════════════════════════════════════
class _PostDetailsBody extends StatefulWidget {
  final PostModel currentPost;
  final VideoPlayerController? cachedController;
  final ScrollController scrollController;
  final PostCallbacks callbacks;
  final bool isFromProfile;
  final String? heroPrefix;
  final bool isArchived;
  final int initialImageIndex;

  const _PostDetailsBody({
    required this.currentPost,
    this.cachedController,
    required this.scrollController,
    required this.callbacks,
    required this.isFromProfile,
    this.heroPrefix,
    this.isArchived = false,
    this.initialImageIndex = 0,
  });

  @override
  State<_PostDetailsBody> createState() => _PostDetailsBodyState();
}

class _PostDetailsBodyState extends State<_PostDetailsBody> {
  final Map<String, GlobalKey> _commentKeys = {};

  void _scrollToComment(String commentId, {bool isForReply = false}) async {
    final key = _commentKeys[commentId];
    if (key?.currentContext == null) return;

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted || key!.currentContext == null) return;

    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: 1.0,
    );

    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted && widget.scrollController.hasClients) {
      final currentOffset = widget.scrollController.offset;
      final maxScroll = widget.scrollController.position.maxScrollExtent;

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
      child: MultiBlocListener(
        listeners: [
          // 1️⃣ ليسنر السكرول
          BlocListener<PostDetailsCubit, PostDetailsState>(
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
          ),

          // 2️⃣ ليسنر حذف الكومنت ✅ NEW
          BlocListener<PostDetailsCubit, PostDetailsState>(
            listenWhen: (prev, curr) =>
                prev.deleteCommentActionState != curr.deleteCommentActionState,
            listener: (context, state) {
              switch (state.deleteCommentActionState) {
                case CubitStates.loading:
                  CustomloadingApp.show(context);
                  break;
                case CubitStates.success:
                  CustomloadingApp.hide(context);
                  AppToast.success(context, state.deleteCommentMessage);
                  break;
                case CubitStates.failure:
                  CustomloadingApp.hide(context);
                  AppToast.error(context, state.deleteCommentMessage);
                  break;
                default:
                  break;
              }
            },
          ),

          // 3️⃣ ليسنر حذف الرد ✅ NEW
          BlocListener<PostDetailsCubit, PostDetailsState>(
            listenWhen: (prev, curr) =>
                prev.deleteReplyActionState != curr.deleteReplyActionState,
            listener: (context, state) {
              switch (state.deleteReplyActionState) {
                case CubitStates.loading:
                  CustomloadingApp.show(context);
                  break;
                case CubitStates.success:
                  CustomloadingApp.hide(context);
                  AppToast.success(context, state.deleteReplyMessage);
                  break;
                case CubitStates.failure:
                  CustomloadingApp.hide(context);
                  AppToast.error(context, state.deleteReplyMessage);
                  break;
                default:
                  break;
              }
            },
          ),

          // 4️⃣ ✅ NEW: ليسنر مزامنة عدد الكومنتات مع الـ HomeCubit
          BlocListener<PostDetailsCubit, PostDetailsState>(
            listenWhen: (prev, curr) =>
                prev.commentCountDeltaTrigger != curr.commentCountDeltaTrigger,
            listener: (context, state) {
              final postId = widget.currentPost.postId;
              final delta = state.pendingCommentCountDelta;

              widget.callbacks.onCommentCountDelta?.call(
                postId: postId,
                countDelta: delta,
                // ✅ لو إضافة (delta > 0) → نحدث isCommented و isAnonymous
                isCommented: delta > 0 ? true : null,
                isAnonymous: delta > 0 ? state.selectedAnonymous : null,
              );
            },
          ),

          // 5️⃣ ✅ NEW: ليسنر تحديث عدد التعليقات من الباك اند
          BlocListener<PostDetailsCubit, PostDetailsState>(
            listenWhen: (prev, curr) =>
                prev.syncCommentCountTrigger != curr.syncCommentCountTrigger,
            listener: (context, state) {
              final postId = widget.currentPost.postId;
              final backendCount = state.syncCommentCountFromBackend;

              widget.callbacks.onCommentCountSync?.call(
                postId: postId,
                totalCount: backendCount,
              );
            },
          ),
        ],
        child:
            BlocSelector<PostDetailsCubit, PostDetailsState, _CommentsUIState>(
              selector: _selectCommentsState,
              builder: (context, uiState) {
                final cubit = context.read<PostDetailsCubit>();

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
                  initialImageIndex: widget.initialImageIndex,
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
