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
              body: CustomErrorWidget(
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
              body: Center(child: Text(context.tr(AppStrings.noPostData))),
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

  /// Notify HomeCubit about the comment/reply + update local post
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
