import 'package:equatable/equatable.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/core/widgets/post_card/post_shimmer.dart';
import 'package:tayseer/my_import.dart';

// ✅ حد أقصى للبوستات اللي هتفضل حية في الميموري
const int _kMaxKeepAliveCount = 50;

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
      child: MultiBlocListener(
        listeners: [
          // 📢 1. Share Listener
          BlocListener<HomeCubit, HomeState>(
            listenWhen: _shouldListenToShare,
            listener: _handleShareFeedback,
          ),

          // 💾 2. Save Listener
          BlocListener<HomeCubit, HomeState>(
            listenWhen: _shouldListenToSave,
            listener: _handleSaveFeedback,
          ),

          // 3. delete post Listener
          BlocListener<HomeCubit, HomeState>(
            listenWhen: _shouldListenToDelete,
            listener: _handleDeleteFeedback,
          ),

          // 4. block user Listener
          BlocListener<HomeCubit, HomeState>(
            listenWhen: (prev, curr) =>
                prev.blockUserActionState != curr.blockUserActionState,
            listener: _handleBlockFeedback,
          ),

          // 5. archive post Listener
          BlocListener<HomeCubit, HomeState>(
            listenWhen: _shouldListenToArchive,
            listener: _handleArchiveFeedback,
          ),

          // 6. poll vote Listener
          BlocListener<HomeCubit, HomeState>(
            listenWhen: _shouldListenToPollVote,
            listener: _handlePollVoteFeedback,
          ),
        ],
        child: BlocSelector<HomeCubit, HomeState, _FeedState>(
          selector: _selectFeedState,
          builder: (context, state) => _buildContent(context, state),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎧 Listen Conditions
  // ═══════════════════════════════════════════════════════════════════════════

  bool _shouldListenToShare(HomeState prev, HomeState curr) {
    return prev.shareActionState != curr.shareActionState &&
        curr.shareActionState != CubitStates.initial;
  }

  bool _shouldListenToSave(HomeState prev, HomeState curr) {
    return prev.saveActionState != curr.saveActionState &&
        curr.saveActionState != CubitStates.initial;
  }

  bool _shouldListenToDelete(HomeState prev, HomeState curr) {
    return prev.deletePostActionState != curr.deletePostActionState &&
        curr.deletePostActionState != CubitStates.initial;
  }

  bool _shouldListenToArchive(HomeState prev, HomeState curr) {
    return prev.archivePostActionState != curr.archivePostActionState &&
        curr.archivePostActionState != CubitStates.initial;
  }

  bool _shouldListenToPollVote(HomeState prev, HomeState curr) {
    return prev.pollVoteActionState != curr.pollVoteActionState &&
        curr.pollVoteActionState == CubitStates.failure;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎮 Action Handlers
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleShareFeedback(BuildContext context, HomeState state) {
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

  void _handleDeleteFeedback(BuildContext context, HomeState state) {
    final message = state.deletePostMessage;
    switch (state.deletePostActionState) {
      case CubitStates.success:
        AppToast.success(context, message ?? 'تمت العملية بنجاح');
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? 'حدث خطأ أثناء الحذف');
        break;
      default:
        break;
    }
  }

  void _handleSaveFeedback(BuildContext context, HomeState state) {
    final message = state.saveMessage;
    switch (state.saveActionState) {
      case CubitStates.success:
        AppToast.success(context, message ?? 'تمت العملية بنجاح');
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? 'حدث خطأ أثناء الحفظ');
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

  void _handleBlockFeedback(BuildContext context, HomeState state) {
    switch (state.blockUserActionState) {
      case CubitStates.loading:
        CustomloadingApp.show(context);
        break;
      case CubitStates.success:
        CustomloadingApp.hide(context);
        AppToast.success(
          context,
          state.blockUserMessage ?? 'تم حظر المستخدم بنجاح',
        );
        break;
      case CubitStates.failure:
        CustomloadingApp.hide(context);
        AppToast.error(
          context,
          state.blockUserMessage ?? 'حدث خطأ أثناء الحظر',
        );
        break;
      default:
        break;
    }
  }

  void _handleArchiveFeedback(BuildContext context, HomeState state) {
    final message = state.archivePostMessage;
    switch (state.archivePostActionState) {
      case CubitStates.success:
        AppToast.success(context, message ?? 'تمت العملية بنجاح');
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? 'حدث خطأ أثناء الأرشفة');
        break;
      default:
        break;
    }
  }

  void _handlePollVoteFeedback(BuildContext context, HomeState state) {
    AppToast.error(context, state.pollVoteMessage ?? 'حدث خطأ أثناء التصويت');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏗️ Build Content
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildContent(BuildContext context, _FeedState state) {
    if (state.isLoading && state.isEmpty) return _buildShimmerList();
    if (state.isError && state.isEmpty) return _buildError(state.error);
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

  // ✅ التعديل الرئيسي هنا - إضافة index
  Widget _buildPostList(_FeedState state) => SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        if (index < state.postIds.length) {
          return _PostItem(
            key: ValueKey(state.postIds[index]),
            postId: state.postIds[index],
            homeCubit: homeCubit,
            index: index, // ✅ بنمرر الـ index
            showGap: index < state.postIds.length - 1,
          );
        }

        if (state.isLoadingMore) {
          return const _LoadingMoreIndicator();
        }

        if (state.isAllCategory) {
          return const EndOfFeedIndicator();
        }

        return _EndOfCategoryIndicator(onViewAllTap: _goToAllCategory);
      },
      childCount: state.postIds.length + 1,
      addAutomaticKeepAlives: true, // ✅ تأكيد إنها true
    ),
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
// Post Item Widget ✅ معدّل بالكامل
// ══════════════════════════════════════════════════════════════════════════════

class _PostItem extends StatefulWidget {
  const _PostItem({
    super.key,
    required this.postId,
    required this.homeCubit,
    required this.index, // ✅ جديد
    this.showGap = false,
  });

  final String postId;
  final HomeCubit homeCubit;
  final int index; // ✅ جديد
  final bool showGap;

  @override
  State<_PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<_PostItem>
    with AutomaticKeepAliveClientMixin {
  // ✅ 1️⃣ الـ Mixin

  late final Stream<PostModel?> _postStream;
  late final PostCallbacks _callbacks;

  // ✅ 2️⃣ أول 50 بوست بس يتحفظوا في الميموري
  @override
  bool get wantKeepAlive => widget.index < _kMaxKeepAliveCount;

  @override
  void initState() {
    super.initState();
    _initializeStreamAndCallbacks();
  }

  void _initializeStreamAndCallbacks() {
    _postStream = widget.homeCubit.stream
        .map(
          (state) =>
              state.posts.where((p) => p.postId == widget.postId).firstOrNull,
        )
        .distinct();

    _callbacks = PostCallbacks(
      postUpdatesStream: _postStream,
      onReactionChanged: _onReaction,
      onShareTap: _onShare,
      onHashtagTap: _onHashtagTap,
      onSave: _onSave,
      onDelete: _onDelete,
      onHide: _hidePost,
      onBlock: _blockUser,
      onArchive: _archivePost,
      onEdit: _editPost,
      onPollVote: _onPollVote,
      onCommented: _onCommented,
    );
  }

  void _editPost(PostModel post) {
    context.pushNamed(
      AppRouter.kAddPostView,
      arguments: {"post": post, "isEdit": true},
    );
  }

  void _archivePost(String postId) {
    widget.homeCubit.archivePost(postId: postId);
  }

  void _blockUser(String userId, String postId) {
    widget.homeCubit.blockUser(visiblePostId: postId, advisorId: userId);
  }

  void _hidePost(String postId) {
    widget.homeCubit.toggleHidePost(postId: postId);
  }

  void _onDelete(String postId) {
    widget.homeCubit.deletePost(postId: postId);
  }

  void _onSave(String postId) {
    widget.homeCubit.toggleSavePost(postId: postId);
  }

  void _onPollVote(String postId, String choiceText) {
    widget.homeCubit.voteInPoll(postId: postId, choiceText: choiceText);
  }

  void _onCommented(String postId, bool isAnonymous) {
    widget.homeCubit.markPostAsCommented(
      postId: postId,
      isAnonymous: isAnonymous,
    );
  }

  void _onReaction(String id, ReactionType? type) {
    widget.homeCubit.reactToPost(postId: id, reactionType: type);
  }

  void _onShare(String id) {
    widget.homeCubit.toggleSharePost(postId: id);
  }

  void _onHashtagTap(String hashtag) {
    final cleanHashtag = hashtag.startsWith('#')
        ? hashtag.substring(1)
        : hashtag;

    context.pushNamed(
      AppRouter.kAdvisorSearchView,
      arguments: {'query': cleanHashtag, 'tab': 'posts'},
    );
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
          isFromProfile: false,
          post: post,
          cachedController: controller,
          callbacks: _callbacks,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // ✅ 3️⃣ لازم تنادي super.build

    return Column(
      children: [
        BlocSelector<HomeCubit, HomeState, PostModel?>(
          selector: (state) =>
              state.posts.where((p) => p.postId == widget.postId).firstOrNull,
          builder: (context, post) {
            if (post == null) return const SizedBox.shrink();
            return PostCard(
              isFromProfile: false,
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
