import 'package:equatable/equatable.dart';
import 'package:tayseer/core/video/feed_video_preloader.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/end_of_cached_posts.dart';
import 'package:tayseer/core/widgets/offline_empty_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/story_post_editor_view.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/core/widgets/post_card/post_shimmer.dart';
import 'package:tayseer/features/shared/home/model/best_advisor_model.dart';
import 'package:tayseer/features/shared/home/model/similar_user_model.dart';
import 'package:tayseer/features/shared/home/views/widgets/sections/best_advisor_section.dart';
import 'package:tayseer/features/shared/home/views/widgets/sections/similar_users_section.dart';
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
      child: MultiBlocListener(
        listeners: [
          BlocListener<HomeCubit, HomeState>(
            listenWhen: _shouldListenToShare,
            listener: _handleShareFeedback,
          ),
          BlocListener<HomeCubit, HomeState>(
            listenWhen: _shouldListenToSave,
            listener: _handleSaveFeedback,
          ),
          BlocListener<HomeCubit, HomeState>(
            listenWhen: _shouldListenToDelete,
            listener: _handleDeleteFeedback,
          ),
          BlocListener<HomeCubit, HomeState>(
            listenWhen: (prev, curr) =>
                prev.hidePostActionState != curr.hidePostActionState,
            listener: _handleHideFeedback,
          ),
          BlocListener<HomeCubit, HomeState>(
            listenWhen: (prev, curr) =>
                prev.blockUserActionState != curr.blockUserActionState,
            listener: _handleBlockFeedback,
          ),
          BlocListener<HomeCubit, HomeState>(
            listenWhen: _shouldListenToArchive,
            listener: _handleArchiveFeedback,
          ),
          BlocListener<HomeCubit, HomeState>(
            listenWhen: _shouldListenToPollVote,
            listener: _handlePollVoteFeedback,
          ),
          BlocListener<HomeCubit, HomeState>(
            listenWhen: (prev, curr) =>
                prev.shareToStoryState != curr.shareToStoryState &&
                curr.shareToStoryState != CubitStates.initial,
            listener: _handleShareToStoryFeedback,
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
            ? AppToast.success(
                context,
                message ?? context.tr(AppStrings.shareSuccess),
              )
            : AppToast.info(
                context,
                message ?? context.tr(AppStrings.shareCancelled),
              );
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? context.tr(AppStrings.shareError));
        break;
      default:
        break;
    }
  }

  void _handleDeleteFeedback(BuildContext context, HomeState state) {
    final message = state.deletePostMessage;
    switch (state.deletePostActionState) {
      case CubitStates.success:
        AppToast.success(
          context,
          message ?? context.tr(AppStrings.operationSuccess),
        );
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? context.tr(AppStrings.deleteError));
        break;
      default:
        break;
    }
  }

  void _handleSaveFeedback(BuildContext context, HomeState state) {
    final message = state.saveMessage;
    switch (state.saveActionState) {
      case CubitStates.success:
        AppToast.success(
          context,
          message ?? context.tr(AppStrings.operationSuccess),
        );
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? context.tr(AppStrings.saveError));
        break;
      default:
        break;
    }
  }

  _FeedState _selectFeedState(HomeState state) {
    final feedState = _FeedState(
      postIds: state.postIds,
      status: state.postsState,
      isLoadingMore: state.isLoadingMore,
      hasMore: state.hasMore,
      error: state.postsErrorMessage,
      isAllCategory: state.selectedCategoryId == null,
      isOffline: state.isOffline,
      isShowingCachedData: state.isShowingCachedData,
      loadMoreServerFailed: state.loadMoreServerFailed,
      bestAdvisors: state.bestAdvisors,
      similarUsers: state.similarUsers,
    );

    // ✅ أبلّغ الـ FeedVideoPreloader بالـ posts الجديدة عشان يبدأ preloading
    final videoPosts = state.posts
        .where(
          (p) =>
              (p.videoData?.video.isNotEmpty == true ||
                  p.videoUrl?.isNotEmpty == true) &&
              !p.isHidden &&
              !p.isBlocked,
        )
        .toList();
    if (videoPosts.isNotEmpty) {
      FeedVideoPreloader.instance.updateFeedPosts(videoPosts);
    }

    return feedState;
  }

  void _handleHideFeedback(BuildContext context, HomeState state) {
    switch (state.hidePostActionState) {
      case CubitStates.loading:
        CustomloadingApp.show(context);
        break;
      case CubitStates.success:
        CustomloadingApp.hide(context);
        AppToast.success(
          context,
          state.hidePostMessage ?? 'تم إخفاء المنشور بنجاح',
        );
        break;
      case CubitStates.failure:
        CustomloadingApp.hide(context);
        AppToast.error(
          context,
          state.hidePostMessage ?? 'حدث خطأ أثناء الإخفاء',
        );
        break;
      default:
        break;
    }
  }

  void _handleBlockFeedback(BuildContext context, HomeState state) {
    switch (state.blockUserActionState) {
      case CubitStates.loading:
        CustomloadingApp.show(context);
        break;
      case CubitStates.success:
        CustomloadingApp.hide(context);
        AppToast.success(
          context,
          state.blockUserMessage ?? context.tr(AppStrings.blockSuccess),
        );
        break;
      case CubitStates.failure:
        CustomloadingApp.hide(context);
        AppToast.error(
          context,
          state.blockUserMessage ?? context.tr(AppStrings.blockError),
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
        AppToast.success(
          context,
          message ?? context.tr(AppStrings.operationSuccess),
        );
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? context.tr(AppStrings.archiveError));
        break;
      default:
        break;
    }
  }

  void _handlePollVoteFeedback(BuildContext context, HomeState state) {
    AppToast.error(
      context,
      state.pollVoteMessage ?? context.tr(AppStrings.pollVoteError),
    );
  }

  void _handleShareToStoryFeedback(BuildContext context, HomeState state) {
    switch (state.shareToStoryState) {
      case CubitStates.success:
        AppToast.success(
          context,
          state.shareToStoryMessage ?? context.tr('share_to_story_success'),
        );
        // ✅ refresh myStories locally so the new post story appears immediately
        getIt<StoriesCubit>().fetchMyStories(isSilent: true);
        break;
      case CubitStates.failure:
        AppToast.error(
          context,
          state.shareToStoryMessage ?? context.tr('share_to_story_error'),
        );
        break;
      default:
        break;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏗️ Build Content
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildContent(BuildContext context, _FeedState state) {
    // ✅ لا نظهر shimmer عند الـ refresh - فقط عند التحميل الأول
    if (state.isLoading && state.isEmpty) return _buildShimmerList();
    if (state.isError && state.isEmpty && state.isOffline) {
      return const OfflineEmptyState();
    }
    if (state.isError && state.isEmpty) return _buildError(state.error);
    if (state.isEmpty && !state.isAllCategory) {
      return _EmptyCategoryIndicator(onViewAllTap: _goToAllCategory);
    }
    return _buildPostList(context, state);
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
      child: Builder(
        builder: (context) => Text(
          error ?? context.tr(AppStrings.genericError),
          style: Styles.textStyle16,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );

  // ✅ CHANGED: O(1) indexMap + no KeepAlive
  Widget _buildPostList(BuildContext context, _FeedState state) {
    // 1. Determine which sections to show
    final List<Widget> items = [];
    final Map<int, int> postIndexToItemIndex = {};

    // Get feature flags from LayoutState
    final layoutState = context.read<LayoutCubit>().state;
    final bool isMarriageVisible = layoutState.isMarriageVisible;

    // RULE:
    // لو الزواج مفعل  → اظهر BestAdvisorSection + SimilarUsersSection
    // لو الزواج مش مفعل → اظهر BestAdvisorSection فقط (بدل SimilarUsersSection)
    final bool showAdvisors = isUser && state.bestAdvisors.isNotEmpty;
    final bool showMarriageContent =
        isUser && isMarriageVisible && state.similarUsers.isNotEmpty;

    int currentPostIndex = 0;
    const int maxItems = 100; // Safety break
    int iterations = 0;

    while (iterations < maxItems) {
      iterations++;

      // Inject Best Advisors after 2 items (ideally 2 posts)
      if (showAdvisors && items.length == 2) {
        items.add(
          BestAdvisorSection(
            advisors: state.bestAdvisors,
            pagination: homeCubit.state.bestAdvisorsPagination,
            onLoadMore: () => homeCubit.loadMoreBestAdvisors(),
            onFollowTap: (advisorId) =>
                homeCubit.toggleFollowBestAdvisor(advisorId: advisorId),
            isLoadingMore: homeCubit.state.bestAdvisorsIsLoadingMore,
          ),
        );
        continue;
      }

      // Inject Similar Users after 8 items (= 5 posts after BestAdvisorSection)
      if (showMarriageContent && items.length == 8) {
        if (state.similarUsers.isNotEmpty) {
          items.add(
            SimilarUsersSection(
              users: state.similarUsers,
              pagination: homeCubit.state.similarUsersPagination,
              onLoadMore: () => homeCubit.loadMoreSimilarUsers(),
              onUserVisited: (userId) => homeCubit.removeSimilarUser(userId),
              isLoadingMore: homeCubit.state.similarUsersIsLoadingMore,
            ),
          );
        }
        if (state.similarUsers.isNotEmpty) {
          continue;
        }
      }

      if (currentPostIndex < state.postIds.length) {
        final postId = state.postIds[currentPostIndex];
        postIndexToItemIndex[currentPostIndex] = items.length;
        items.add(
          _PostItem(
            key: ValueKey(postId),
            postId: postId,
            homeCubit: homeCubit,
            index: currentPostIndex,
            showGap: currentPostIndex < state.postIds.length - 1,
          ),
        );
        currentPostIndex++;
      } else if ((showAdvisors && items.length < 2) ||
          (showMarriageContent && items.length < 8)) {
        // If we still need to reach injection points but posts are exhausted, add something or just break?
        // Usually we want to show sections even if feed is empty or short.
        // But the user said "after 2 posts". If 0 posts, "after 2 posts" is undefined.
        // We'll just break if no more posts and we are below injection points to avoid infinite loop.
        break;
      } else {
        break;
      }
    }

    // Add footer indicators
    if (state.isLoadingMore) {
      items.add(const _LoadingMoreIndicator());
    } else if (state.isShowingCachedData && !state.hasMore) {
      items.add(const EndOfCachedPosts());
    } else if (state.isOffline && state.hasMore) {
      items.add(const EndOfCachedPosts());
    } else if (state.loadMoreServerFailed) {
      items.add(_LoadMoreFailedRetry(onRetry: () => homeCubit.retryLoadMore()));
    } else if (state.isAllCategory) {
      items.add(const EndOfFeedIndicator());
    } else {
      items.add(_EndOfCategoryIndicator(onViewAllTap: _goToAllCategory));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => items[index],
        childCount: items.length,
        addAutomaticKeepAlives: false,
        findChildIndexCallback: (key) {
          if (key is ValueKey<String>) {
            // Find which post index this key belongs to
            final postIndex = state.postIds.indexOf(key.value);
            if (postIndex != -1) return postIndexToItemIndex[postIndex];
          }
          return null;
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Feed State Model
// ══════════════════════════════════════════════════════════════════════════════

class _FeedState extends Equatable {
  final List<String> postIds;
  final CubitStates status;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final bool isAllCategory;
  final bool isOffline;
  final bool isShowingCachedData;
  final bool loadMoreServerFailed;

  final List<BestAdvisorModel> bestAdvisors;
  final List<SimilarUserModel> similarUsers;

  const _FeedState({
    required this.postIds,
    required this.status,
    required this.isLoadingMore,
    required this.hasMore,
    required this.isAllCategory,
    this.error,
    this.isOffline = false,
    this.isShowingCachedData = false,
    this.loadMoreServerFailed = false,
    this.bestAdvisors = const [],
    this.similarUsers = const [],
  });

  bool get isEmpty => postIds.isEmpty;
  bool get isLoading => status == CubitStates.loading;
  bool get isError => status == CubitStates.failure;

  @override
  List<Object?> get props => [
    postIds,
    status,
    isLoadingMore,
    hasMore,
    error,
    isAllCategory,
    isOffline,
    isShowingCachedData,
    loadMoreServerFailed,
    bestAdvisors,
    similarUsers,
  ];
}

// ══════════════════════════════════════════════════════════════════════════════
// Post Item Widget ✅ CHANGED: StatefulWidget بدون AutomaticKeepAlive
// ══════════════════════════════════════════════════════════════════════════════

class _PostItem extends StatefulWidget {
  const _PostItem({
    super.key,
    required this.postId,
    required this.homeCubit,
    required this.index,
    this.showGap = false,
  });

  final String postId;
  final HomeCubit homeCubit;
  final int index;
  final bool showGap;

  @override
  State<_PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<_PostItem> {
  late final PostCallbacks _callbacks;
  bool _markedAsRead = false;

  @override
  void initState() {
    super.initState();
    _initializeCallbacks();
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_markedAsRead) return;
    if (info.visibleFraction >= 0.5) {
      _markedAsRead = true;
      widget.homeCubit.markPostAsRead(widget.postId);
    }

    // ✅ أبلّغ الـ FeedVideoPreloader لما البوست يظهر عشان يبدأ preload للقادمين
    if (info.visibleFraction >= 0.3) {
      FeedVideoPreloader.instance.onPostVisible(widget.postId);
    }
  }

  void _initializeCallbacks() {
    _callbacks = PostCallbacks(
      onReactionChanged: _onReaction,
      onShareTap: _onShare,
      onShareToStoryTap: _onShareToStory,
      onHashtagTap: _onHashtagTap,
      onSave: _onSave,
      onDelete: _onDelete,
      onHide: _hidePost,
      onBlock: _blockUser,
      onArchive: _archivePost,
      onEdit: _editPost,
      onPollVote: _onPollVote,
      onCommented: _onCommented,
      onCommentCountDelta: _onCommentCountDelta,
      onCommentCountSync: _onCommentCountSync,
      onFollowTap: _onFollowAdvisor,
    );
  }

  PostCallbacks _buildCallbacksWithStream() {
    final stream = widget.homeCubit.stream
        .map((state) => state.postsMap[widget.postId])
        .distinct();

    return PostCallbacks(
      postUpdatesStream: stream,
      onReactionChanged: _onReaction,
      onShareTap: _onShare,
      onShareToStoryTap: _onShareToStory,
      onHashtagTap: _onHashtagTap,
      onSave: _onSave,
      onDelete: _onDelete,
      onHide: _hidePost,
      onBlock: _blockUser,
      onArchive: _archivePost,
      onEdit: _editPost,
      onPollVote: _onPollVote,
      onCommented: _onCommented,
      onCommentCountDelta: _onCommentCountDelta,
      onCommentCountSync: _onCommentCountSync,
      onFollowTap: _onFollowAdvisor,
    );
  }

  void _onFollowAdvisor(String advisorId) {
    widget.homeCubit.toggleFollowAdvisor(advisorId: advisorId);
  }

  void _editPost(PostModel post) {
    widget.homeCubit.updateEditedPost(post);
  }

  void _archivePost(String postId) {
    widget.homeCubit.archivePost(postId: postId);
  }

  void _blockUser(String postId, String userId) {
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

  void _onCommentCountDelta({
    required String postId,
    required int countDelta,
    bool? isCommented,
    bool? isAnonymous,
  }) {
    widget.homeCubit.updateCommentCountByDelta(
      postId: postId,
      countDelta: countDelta,
      isCommented: isCommented,
      isAnonymous: isAnonymous,
    );
  }

  void _onCommentCountSync({required String postId, required int totalCount}) {
    widget.homeCubit.syncCommentCountFromBackend(
      postId: postId,
      totalCount: totalCount,
    );
  }

  void _onReaction(String id, ReactionType? type) {
    widget.homeCubit.reactToPost(postId: id, reactionType: type);
  }

  void _onShare(String id) {
    widget.homeCubit.toggleSharePost(postId: id);
  }

  void _onShareToStory(String postId) {
    // ابحث عن الـ post من الـ state
    final post = widget.homeCubit.state.postsMap[postId];
    if (post == null) return;

    // افتح شاشة الـ editor بدل ما تبعت مباشرة للـ API
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryPostEditorView(post: post),
        fullscreenDialog: true,
      ),
    );
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
    VideoPlayerController? controller, {
    int initialImageIndex = 0,
  }) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => PostDetailsView(
          isFromProfile: false,
          post: post,
          cachedController: controller,
          initialImageIndex: initialImageIndex,
          callbacks: _buildCallbacksWithStream(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocSelector<HomeCubit, HomeState, PostModel?>(
          selector: (state) => state.postsMap[widget.postId],
          builder: (context, post) {
            if (post == null) return const SizedBox.shrink();
            final savedIndex =
                widget.homeCubit.postImageIndexCache[widget.postId] ?? 0;
            return VisibilityDetector(
              key: Key('post_read_${widget.postId}'),
              onVisibilityChanged: _onVisibilityChanged,
              child: PostCard(
                isFromProfile: false,
                post: post,
                callbacks: _callbacks,
                onNavigateToDetails: _onNavigateToDetails,
                initialImageIndex: savedIndex,
                onImageIndexChanged: (index) {
                  widget.homeCubit.postImageIndexCache[widget.postId] = index;
                },
              ),
            );
          },
        ),
        if (widget.showGap) Gap(1.h),
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

class _LoadMoreFailedRetry extends StatelessWidget {
  const _LoadMoreFailedRetry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.tr(AppStrings.loadMoreFailed),
            style: Styles.textStyle14.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 36.h,
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh, size: 18.w),
              label: Text(context.tr(AppStrings.retry)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.kprimaryColor,
                side: BorderSide(color: AppColors.kprimaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
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
            context.tr(AppStrings.endOfFeed),
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
            context.tr(AppStrings.endOfCategoryFeed),
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
                color: AppColors.kprimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppColors.kprimaryColor.withValues(alpha: 0.3),
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
                    context.tr(AppStrings.viewAllPosts),
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
              context.tr(AppStrings.noCategoryPosts),
              style: Styles.textStyle16.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Gap(8.h),
            Text(
              context.tr(AppStrings.tryOtherCategories),
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
                      AppColors.kprimaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.kprimaryColor.withValues(alpha: 0.3),
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
                      context.tr(AppStrings.exploreAllPosts),
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
