import 'package:equatable/equatable.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/my_import.dart';

class HomePostFeed extends StatelessWidget {
  const HomePostFeed({
    super.key,
    required this.homeCubit,
    required this.scrollToTopCallback,
  });

  final HomeCubit homeCubit;
  final VoidCallback scrollToTopCallback;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: homeCubit,
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: _shouldListenToShare,
        listener: _handleShareState,
        child: BlocSelector<HomeCubit, HomeState, _FeedState>(
          selector: _selectFeedState,
          builder: (context, state) => _buildContent(context, state),
        ),
      ),
    );
  }

  bool _shouldListenToShare(HomeState prev, HomeState curr) =>
      prev.shareActionState != curr.shareActionState &&
      curr.shareActionState != CubitStates.initial;

  void _handleShareState(BuildContext context, HomeState state) {
    final message = state.shareMessage;
    switch (state.shareActionState) {
      case CubitStates.success:
        state.isShareAdded == true
            ? AppToast.success(context, message ?? 'تمت المشاركة بنجاح')
            : AppToast.info(context, message ?? 'تم إلغاء المشاركة');
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? 'حدث خطأ أثناء المشاركة');
        break;
      default:
        break;
    }
  }

  _FeedState _selectFeedState(HomeState state) => _FeedState(
    postIds: state.posts.map((p) => p.postId).toList(),
    status: state.postsState,
    isLoadingMore: state.isLoadingMore,
    error: state.postsErrorMessage,
    isAllCategory: state.selectedCategoryId == null,
  );

  Widget _buildContent(BuildContext context, _FeedState state) {
    // حالة التحميل
    if (state.isLoading && state.isEmpty) return _buildShimmerList();

    // حالة الخطأ
    if (state.isError && state.isEmpty) return _buildError(state.error);

    // حالة الـ empty في كاتيجوري معين (مش "الكل")
    if (state.isEmpty && !state.isAllCategory) {
      return _EmptyCategoryIndicator(onViewAllTap: _goToAllCategory);
    }

    return _buildPostList(state);
  }

  void _goToAllCategory() {
    scrollToTopCallback();
    homeCubit.selectCategory(null);
  }

  Widget _buildShimmerList() => SliverList(
    delegate: SliverChildBuilderDelegate(
      (_, __) => const PostCardShimmer(),
      childCount: 3,
    ),
  );

  Widget _buildError(String? error) => SliverFillRemaining(
    child: Center(
      child: Text(
        error ?? 'حدث خطأ ما',
        style: Styles.textStyle16,
        textAlign: TextAlign.center,
      ),
    ),
  );

  Widget _buildPostList(_FeedState state) => SliverList(
    delegate: SliverChildBuilderDelegate((context, index) {
      if (index < state.postIds.length) {
        return _PostItem(
          key: ValueKey(state.postIds[index]),
          postId: state.postIds[index],
          homeCubit: homeCubit,
          showGap: index < state.postIds.length - 1,
        );
      }

      // آخر عنصر - الـ indicator
      if (state.isLoadingMore) {
        return const _LoadingMoreIndicator();
      }

      // لو في "الكل" → الـ indicator العادي
      if (state.isAllCategory) {
        return const EndOfFeedIndicator();
      }

      // لو في كاتيجوري معين → indicator مختلف
      return _EndOfCategoryIndicator(onViewAllTap: _goToAllCategory);
    }, childCount: state.postIds.length + 1),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// Feed State Model
// ══════════════════════════════════════════════════════════════════════════════

class _FeedState extends Equatable {
  final List<String> postIds;
  final CubitStates status;
  final bool isLoadingMore;
  final String? error;
  final bool isAllCategory;

  const _FeedState({
    required this.postIds,
    required this.status,
    required this.isLoadingMore,
    required this.isAllCategory,
    this.error,
  });

  bool get isEmpty => postIds.isEmpty;
  bool get isLoading => status == CubitStates.loading;
  bool get isError => status == CubitStates.failure;

  @override
  List<Object?> get props => [
    postIds,
    status,
    isLoadingMore,
    error,
    isAllCategory,
  ];
}

// ══════════════════════════════════════════════════════════════════════════════
// Post Item Widget (Optimized - rebuilds only when its post changes)
// ══════════════════════════════════════════════════════════════════════════════

class _PostItem extends StatefulWidget {
  const _PostItem({
    super.key,
    required this.postId,
    required this.homeCubit,
    this.showGap = false,
  });

  final String postId;
  final HomeCubit homeCubit;
  final bool showGap;

  @override
  State<_PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<_PostItem> {
  // ✅ Cache stream & callbacks - created once in initState
  late final Stream<PostModel> _postStream;
  late final PostCallbacks _callbacks;

  @override
  void initState() {
    super.initState();
    _initializeStreamAndCallbacks();
  }

  void _initializeStreamAndCallbacks() {
    // ✅ Create stream once with distinct to prevent duplicate updates
    _postStream = widget.homeCubit.stream
        .map(
          (state) => state.posts.firstWhere(
            (p) => p.postId == widget.postId,
            orElse: () => _getFallbackPost(state),
          ),
        )
        .distinct();

    // ✅ Create callbacks once
    _callbacks = PostCallbacks(
      postUpdatesStream: _postStream,
      onReactionChanged: _onReaction,
      onShareTap: _onShare,
      onHashtagTap: _onHashtagTap,
    );
  }

  PostModel _getFallbackPost(HomeState state) {
    // Try to get existing post or return current one
    final existingPost = state.posts
        .where((p) => p.postId == widget.postId)
        .firstOrNull;
    return existingPost!;
  }

  void _onReaction(String id, ReactionType? type) {
    widget.homeCubit.reactToPost(postId: id, reactionType: type);
  }

  void _onShare(String id) {
    widget.homeCubit.toggleSharePost(postId: id);
  }

  void _onHashtagTap(String hashtag) {
    context.pushNamed(AppRouter.kAdvisorSearchView);
  }

  void _onNavigateToDetails(
    BuildContext ctx,
    PostModel post,
    VideoPlayerController? controller,
  ) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => PostDetailsView(
          post: post,
          cachedController: controller,
          callbacks: _callbacks,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocSelector<HomeCubit, HomeState, PostModel?>(
          selector: (state) =>
              state.posts.where((p) => p.postId == widget.postId).firstOrNull,
          builder: (context, post) {
            if (post == null) return const SizedBox.shrink();
            return PostCard(
              post: post,
              callbacks: _callbacks,
              onNavigateToDetails: _onNavigateToDetails,
            );
          },
        ),
        if (widget.showGap) Gap(12.h),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// UI Components
// ══════════════════════════════════════════════════════════════════════════════

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: const Center(child: PostCardShimmer()),
  );
}

class EndOfFeedIndicator extends StatelessWidget {
  const EndOfFeedIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(AssetsData.postsEndIcon, height: 110.h),
          Text(
            'تم الوصول لنهاية المنشورات',
            style: Styles.textStyle14.copyWith(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(4.h),
          _dot,
          Gap(32.h),
        ],
      ),
    );
  }

  Widget get _dot => Container(
    width: 4.w,
    height: 4.w,
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      shape: BoxShape.circle,
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// End of Category Indicator (لما يوصل لآخر البوستات في كاتيجوري معين)
// ══════════════════════════════════════════════════════════════════════════════

class _EndOfCategoryIndicator extends StatelessWidget {
  const _EndOfCategoryIndicator({required this.onViewAllTap});

  final VoidCallback onViewAllTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(AssetsData.postsEndIcon, height: 110.h),
          Gap(8.h),
          Text(
            'تم الوصول لنهاية المنشورات في هذه الفئة',
            style: Styles.textStyle14.copyWith(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Gap(12.h),
          GestureDetector(
            onTap: onViewAllTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.kprimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.kprimaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.grid_view_rounded,
                    size: 16.sp,
                    color: AppColors.kprimaryColor,
                  ),
                  Gap(6.w),
                  Text(
                    'عرض كل المنشورات',
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.kprimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gap(32.h),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Empty Category Indicator (لما الكاتيجوري فاضية)
// ══════════════════════════════════════════════════════════════════════════════

class _EmptyCategoryIndicator extends StatelessWidget {
  const _EmptyCategoryIndicator({required this.onViewAllTap});

  final VoidCallback onViewAllTap;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(AssetsData.noPosts, height: 217.h),
            Gap(16.h),
            Text(
              'لا توجد منشورات في هذه الفئة',
              style: Styles.textStyle16.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(8.h),
            Text(
              'جرب استكشاف فئات أخرى',
              style: Styles.textStyle14.copyWith(color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
            Gap(20.h),
            GestureDetector(
              onTap: onViewAllTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.kprimaryColor,
                      AppColors.kprimaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.kprimaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.explore_rounded,
                      size: 18.sp,
                      color: Colors.white,
                    ),
                    Gap(8.w),
                    Text(
                      'استكشف كل المنشورات',
                      style: Styles.textStyle14.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Gap(40.h),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shimmer Loading
// ══════════════════════════════════════════════════════════════════════════════

class PostCardShimmer extends StatelessWidget {
  const PostCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 28.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Gap(15.h),
              _buildTextLines(),
              Gap(12.h),
              _buildImagePlaceholder(),
              Gap(15.h),
              _buildStats(),
              Gap(12.h),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(
    children: [
      _circle(48.w),
      Gap(12.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rect(width: 120.w, height: 14.h),
            Gap(6.h),
            _rect(width: 180.w, height: 12.h),
          ],
        ),
      ),
    ],
  );

  Widget _buildTextLines() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _rect(width: double.infinity, height: 14.h),
      Gap(8.h),
      _rect(width: 250.w, height: 14.h),
    ],
  );

  Widget _buildImagePlaceholder() =>
      _rect(width: double.infinity, height: 206.h, radius: 12);

  Widget _buildStats() => _rect(width: 150.w, height: 12.h);

  Widget _buildActions() =>
      Row(spacing: 6.w, children: List.generate(3, (_) => _circle(38.w)));

  Widget _circle(double size) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
  );

  Widget _rect({
    required double width,
    required double height,
    double radius = 4,
  }) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius.r),
    ),
  );
}
