import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/advisor/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/advisor/home/view_model/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/features/advisor/home/views/widgets/comment_input_area.dart';
import 'package:tayseer/features/advisor/home/views/widgets/comment_item_widget.dart';
import 'package:tayseer/features/advisor/home/views/widgets/comments_list_shimmer.dart';

import 'package:tayseer/my_import.dart';

/// PostDetailsView - Generic reusable component for displaying post details
///
/// This view is completely decoupled from any specific Cubit and can be used
/// anywhere in the app. Post interactions are handled via callback functions.
class PostDetailsView extends StatefulWidget {
  final PostModel post;
  final VideoPlayerController? cachedController;

  /// Optional: If you need to sync post updates from a parent cubit/state
  /// Use this stream to update the post data dynamically
  final Stream<PostModel>? postUpdatesStream;

  /// Callback when user reacts to the post
  final void Function(String postId, ReactionType? reactionType)?
  onReactionChanged;

  /// Callback when user shares/reposts the post
  final void Function(String postId)? onShareTap;

  /// Callback when user taps on hashtag
  final void Function(String hashtag)? onHashtagTap;

  /// Callback when user taps on "more" button
  final void Function()? onMoreTap;

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
  // 1. تعريف ScrollController
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

  // دالة مساعدة للصعود لأعلى الصفحة
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
      create: (context) => PostDetailsCubit(
        homeRepository: getIt<HomeRepository>(),
        postId: widget.post.postId,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),

        // 2. الاستماع لحالة إضافة الكومنت لعمل Scroll
        body: BlocListener<PostDetailsCubit, PostDetailsState>(
          listenWhen: (previous, current) =>
              previous.addingCommentState != current.addingCommentState,
          listener: (context, state) {
            // عند نجاح إضافة تعليق جديد، اصعد لأعلى الصفحة لرؤيته
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

// ═══════════════════════════════════════════════════════════
// 📌 BODY WIDGET
// ═══════════════════════════════════════════════════════════
class _PostDetailsBody extends StatefulWidget {
  final PostModel post;
  final VideoPlayerController? cachedController;
  final ScrollController scrollController;
  final Stream<PostModel>? postUpdatesStream;
  final void Function(String postId, ReactionType? reactionType)?
  onReactionChanged;
  final void Function(String postId)? onShareTap;
  final void Function(String hashtag)? onHashtagTap;
  final void Function()? onMoreTap;

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

    // Listen to post updates if stream is provided
    widget.postUpdatesStream?.listen((updatedPost) {
      if (mounted && updatedPost.postId == _currentPost.postId) {
        setState(() {
          _currentPost = updatedPost;
        });
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
      child: CustomScrollView(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 1. Post Section
          _PostSection(
            post: _currentPost,
            cachedController: widget.cachedController,
            onReactionChanged: widget.onReactionChanged,
            onShareTap: widget.onShareTap,
            onHashtagTap: widget.onHashtagTap,
            onMoreTap: widget.onMoreTap,
          ),

          SliverToBoxAdapter(child: Gap(10.h)),

          // 2. Comments Section
          const _CommentsSection(),

          SliverToBoxAdapter(child: Gap(20.h)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 📌 SECTION 1: POST CARD
// ═══════════════════════════════════════════════════════════
class _PostSection extends StatelessWidget {
  final PostModel post;
  final VideoPlayerController? cachedController;
  final void Function(String postId, ReactionType? reactionType)?
  onReactionChanged;
  final void Function(String postId)? onShareTap;
  final void Function(String hashtag)? onHashtagTap;
  final void Function()? onMoreTap;

  const _PostSection({
    required this.post,
    this.cachedController,
    this.onReactionChanged,
    this.onShareTap,
    this.onHashtagTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: PostCard(
        post: post,
        isDetailsView: true,
        sharedController: cachedController,
        onReactionChanged: onReactionChanged,
        onShareTap: onShareTap,
        onNavigateToDetails: (ctx, post, controller) {
          // في Details view، نريد فقط التركيز على حقل الإدخال
          ctx.read<PostDetailsCubit>().requestInputFocus();
        },
        onHashtagTap: onHashtagTap,
        onMoreTap: onMoreTap,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 📌 SECTION 2: COMMENTS LIST (With Shimmer)
// ═══════════════════════════════════════════════════════════
class _CommentsSection extends StatelessWidget {
  const _CommentsSection();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      sliver: BlocBuilder<PostDetailsCubit, PostDetailsState>(
        buildWhen: (previous, current) =>
            previous.comments != current.comments ||
            previous.commentsState != current.commentsState ||
            previous.isLoadingMore != current.isLoadingMore,
        builder: (context, state) {
          switch (state.commentsState) {
            // 1. Loading State -> Show Shimmer
            case CubitStates.loading:
              return const CommentsShimmerList(); // ✅ استخدام الشيمر هنا

            // 2. Failure State
            case CubitStates.failure:
              return SliverToBoxAdapter(
                child: _FailureState(errorMessage: state.errorMessage),
              );

            // 3. Success State
            case CubitStates.success:
              if (state.comments.isEmpty) {
                return const SliverToBoxAdapter(child: _EmptyState());
              }
              return _CommentsList(
                comments: state.comments,
                hasMore: state.hasMoreComments,
                isLoadingMore: state.isLoadingMore,
              );

            default:
              return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 📌 HELPER WIDGETS
// ═══════════════════════════════════════════════════════════

class _CommentsList extends StatelessWidget {
  final List<dynamic> comments;
  final bool hasMore;
  final bool isLoadingMore;

  const _CommentsList({
    required this.comments,
    required this.hasMore,
    required this.isLoadingMore,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        // Pagination Logic
        if (index == comments.length) {
          if (isLoadingMore) {
            return Padding(
              padding: EdgeInsets.all(16.h),
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          if (hasMore) {
            return TextButton(
              onPressed: () {
                context.read<PostDetailsCubit>().loadMoreComments();
              },
              child: Text('تحميل المزيد', style: Styles.textStyle14SemiBold),
            );
          }
          return const SizedBox.shrink();
        }

        final comment = comments[index];
        return Column(
          children: [
            CommentItemWidget(comment: comment),
            if (index != comments.length - 1)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Divider(color: Colors.grey.shade200, height: 1.h),
              ),
          ],
        );
      }, childCount: comments.length + (hasMore || isLoadingMore ? 1 : 0)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Gap(16.h),
        AppImage(AssetsData.noCommentsIcon, height: 130.h),
        Gap(20.h),
        Text(
          context.tr(AppStrings.noComments),
          style: Styles.textStyle14.copyWith(color: AppColors.kGreyB3),
        ),
      ],
    );
  }
}

class _FailureState extends StatelessWidget {
  final String? errorMessage;
  const _FailureState({this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            errorMessage ?? 'حدث خطأ',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          Gap(10.h),
          TextButton(
            onPressed: () {
              context.read<PostDetailsCubit>().loadComments();
            },
            child: Text(
              context.tr(AppStrings.retry),
              style: Styles.textStyle14SemiBold,
            ),
          ),
        ],
      ),
    );
  }
}
