import 'package:equatable/equatable.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/advisor/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/home/view_model/home_state.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/my_import.dart';

class HomePostFeed extends StatelessWidget {
  const HomePostFeed({super.key, required this.homeCubit});

  final HomeCubit homeCubit;

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
    error: state.errorMessage,
  );

  Widget _buildContent(BuildContext context, _FeedState state) {
    if (state.isLoading && state.isEmpty) return _buildShimmerList();
    if (state.isError && state.isEmpty) return _buildError(state.error);
    return _buildPostList(state);
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
          postId: state.postIds[index],
          homeCubit: homeCubit,
          showGap: index < state.postIds.length - 1,
        );
      }
      return state.isLoadingMore
          ? const _LoadingMoreIndicator()
          : const EndOfFeedIndicator();
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

  const _FeedState({
    required this.postIds,
    required this.status,
    required this.isLoadingMore,
    this.error,
  });

  bool get isEmpty => postIds.isEmpty;
  bool get isLoading => status == CubitStates.loading;
  bool get isError => status == CubitStates.failure;

  @override
  List<Object?> get props => [postIds, status, isLoadingMore, error];
}

// ══════════════════════════════════════════════════════════════════════════════
// Post Item Widget (Optimized - rebuilds only when its post changes)
// ══════════════════════════════════════════════════════════════════════════════

class _PostItem extends StatelessWidget {
  const _PostItem({
    required this.postId,
    required this.homeCubit,
    this.showGap = false,
  });

  final String postId;
  final HomeCubit homeCubit;
  final bool showGap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocSelector<HomeCubit, HomeState, PostModel?>(
          selector: (state) =>
              state.posts.where((p) => p.postId == postId).firstOrNull,
          builder: (context, post) {
            if (post == null) return const SizedBox.shrink();
            return PostCard(
              post: post,
              onReactionChanged: _onReaction,
              onShareTap: _onShare,
              onNavigateToDetails: _onNavigateToDetails,
              onHashtagTap: (_) =>
                  context.pushNamed(AppRouter.kAdvisorSearchView),
            );
          },
        ),
        if (showGap) Gap(12.h),
      ],
    );
  }

  void _onReaction(String id, ReactionType? type) =>
      homeCubit.reactToPost(postId: id, reactionType: type);

  void _onShare(String id) => homeCubit.toggleSharePost(postId: id);

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
          postUpdatesStream: homeCubit.stream.map(
            (s) => s.posts.firstWhere(
              (p) => p.postId == post.postId,
              orElse: () => post,
            ),
          ),
          onReactionChanged: _onReaction,
          onShareTap: _onShare,
          onHashtagTap: (_) => ctx.pushNamed(AppRouter.kAdvisorSearchView),
        ),
      ),
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
