import 'dart:async';
import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/custom_error_widget.dart';
import 'package:tayseer/features/shared/post_details/presentation/manager/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/widgets/comment_input_area.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/widgets/post_details_body.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/widgets/post_shimmer_loader.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
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
  late PostCallbacks _effectiveCallbacks;
  bool _isNotificationMode = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _currentPost = widget.post;

<<<<<<< HEAD
    _postSubscription = widget.callbacks.postUpdatesStream?.listen(
=======
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

    // ✅ إنشاء callbacks من HomeCubit إذا كان الدخول من الإشعارات
    _effectiveCallbacks = _buildEffectiveCallbacks();

    // ✅ إذا كنا في notification mode و البوست متاح، حقنه في HomeCubit
    if (_isNotificationMode && _currentPost != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) getIt<HomeCubit>().injectPost(_currentPost!);
      });
    }

    // ✅ الاشتراك في الـ Stream
    _postSubscription = _effectiveCallbacks.postUpdatesStream?.listen(
>>>>>>> a1f85496ce90ae6b2b578e296e6b9bcc12e1fca0
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

  /// ✅ إنشاء callbacks فعّالة - من الـ widget أو من HomeCubit
  PostCallbacks _buildEffectiveCallbacks() {
    // إذا كان هناك callbacks ممررة من الخارج (مش من الإشعارات)
    if (widget.callbacks.hasCallbacks ||
        widget.callbacks.postUpdatesStream != null) {
      return widget.callbacks;
    }

    // 🔔 دخول من الإشعارات -> إنشاء callbacks من HomeCubit
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
      onHashtagTap: (hashtag) {
        final cleanHashtag = hashtag.startsWith('#')
            ? hashtag.substring(1)
            : hashtag;
        navigatorKey.currentContext?.pushNamed(
          AppRouter.kAdvisorSearchView,
          arguments: {'query': cleanHashtag, 'tab': 'posts'},
        );
      },
      onEdit: (post) {
        navigatorKey.currentContext?.pushNamed(
          AppRouter.kAddPostView,
          arguments: {"post": post, "isEdit": true},
        );
      },
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
    );
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
=======
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
            // حقن البوست في HomeCubit حتى تعمل التفاعلات والمشاركة
            if (_isNotificationMode) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) getIt<HomeCubit>().injectPost(_currentPost!);
              });
            }
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
>>>>>>> a1f85496ce90ae6b2b578e296e6b9bcc12e1fca0
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
              body: CustomErrorView(
                message:
                    state.postLoadingError ??
                    context.tr(AppStrings.failedToLoadPost),
                onRetry: () => context.read<PostDetailsCubit>().loadPostFromAPI(
                  widget.postId_fromNotifc!,
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
              body: CustomErrorView(
                message:

                    context.tr(AppStrings.noPostData),
                onRetry: () => context.read<PostDetailsCubit>().loadPostFromAPI(
                  widget.postId_fromNotifc!,
                ),
              ),
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
                      callbacks: _effectiveCallbacks,
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

  void _notifyCommented(bool isAnonymous) {
    setState(() {
      _currentPost = _currentPost?.copyWith(
        isCommented: true,
        isAnonymous: isAnonymous,
        commentsCount: (_currentPost?.commentsCount ?? 0) + 1,
      );
    });

    // ✅ Lock anonymous state in cubit (for notification entry)
    _postDetailsCubit.lockAnonymousState(isAnonymous);

    _effectiveCallbacks.onCommented?.call(_currentPost!.postId, isAnonymous);
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
<<<<<<< HEAD

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

  // ✅ MODIFIED: سكرول متطور يراعي الكيبورد ويضيف مساحة لتظهر الأزرار
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

    // تريك إضافي: نعمل سكرول 60 بيكسل إضافية لضمان عدم قص الأزرار
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
=======
>>>>>>> a1f85496ce90ae6b2b578e296e6b9bcc12e1fca0
