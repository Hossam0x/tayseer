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
  final String? postId_fromNotifc;

  const PostDetailsView({
    super.key,
    this.post,
    this.cachedController,
    this.callbacks = const PostCallbacks(),
    required this.isFromProfile,
    this.heroPrefix,
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
