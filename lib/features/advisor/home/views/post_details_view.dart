import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/advisor/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/advisor/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/home/view_model/home_state.dart';
import 'package:tayseer/features/advisor/home/view_model/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/features/advisor/home/views/widgets/comment_input_area.dart';
import 'package:tayseer/features/advisor/home/views/widgets/comment_item_widget.dart';
import 'package:tayseer/features/advisor/home/views/widgets/comments_list_shimmer.dart';

import 'package:tayseer/my_import.dart';

class PostDetailsView extends StatefulWidget {
  final PostModel post;
  final VideoPlayerController? cachedController;
  final HomeCubit homeCubit;

  const PostDetailsView({
    super.key,
    required this.post,
    this.cachedController,
    required this.homeCubit,
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PostDetailsCubit(
            homeRepository: getIt<HomeRepository>(),
            postId: widget.post.postId,
          ),
        ),
        BlocProvider.value(value: widget.homeCubit),
      ],
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
class _PostDetailsBody extends StatelessWidget {
  final PostModel post;
  final VideoPlayerController? cachedController;
  final ScrollController scrollController;

  const _PostDetailsBody({
    required this.post,
    this.cachedController,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.kprimaryColor,
      onRefresh: () async {
        await context.read<PostDetailsCubit>().loadComments(isRefresh: true);
      },
      child: CustomScrollView(
        controller: scrollController, // ربط الكونترولر
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 1. Post Section
          _PostSection(post: post, cachedController: cachedController),

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

  const _PostSection({required this.post, this.cachedController});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final updatedPost = state.posts.firstWhere(
            (p) => p.postId == post.postId,
            orElse: () => post,
          );
          return PostCard(
            post: updatedPost,
            isDetailsView: true,
            sharedController: cachedController,
          );
        },
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
