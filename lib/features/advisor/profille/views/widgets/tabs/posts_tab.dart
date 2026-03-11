import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart'
    as home_feed;
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_state.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_shimmer.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';

class PostsTab extends StatelessWidget {
  const PostsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();

    return MultiBlocListener(
      listeners: [
        // 📢 1. Share Listener
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: _shouldListenToShare,
          listener: _handleShareFeedback,
        ),

        // 💾 2. Save Listener
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: _shouldListenToSave,
          listener: _handleSaveFeedback,
        ),

        // 🗑️ 3. Delete Listener
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: _shouldListenToDelete,
          listener: _handleDeleteFeedback,
        ),

        // 🚫 4. Block Listener
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: _shouldListenToBlock,
          listener: _handleBlockFeedback,
        ),

        // 📦 5. Archive Listener
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: _shouldListenToArchive,
          listener: _handleArchiveFeedback,
        ),
      ],
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.postsState == CubitStates.loading && state.posts.isEmpty) {
            return _buildShimmerList();
          }

          if (state.postsState == CubitStates.failure && state.posts.isEmpty) {
            return _buildError(state.postsErrorMessage, profileCubit, context);
          }

          if (state.posts.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            color: AppColors.kprimaryColor,
            onRefresh: () => profileCubit.fetchPosts(),
            child: Column(
              children: [
                _buildPostList(state, profileCubit),

                // زر تحميل المزيد أو إند فيد
                if (state.hasMore)
                  _buildLoadMoreButton(context, state, profileCubit)
                else if (state.posts.isNotEmpty)
                  const home_feed.EndOfFeedIndicator(),

                Gap(40.h),
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎧 Listen Conditions
  // ═══════════════════════════════════════════════════════════════════════════

  bool _shouldListenToShare(ProfileState prev, ProfileState curr) =>
      prev.shareActionState != curr.shareActionState &&
      curr.shareActionState != CubitStates.initial;

  bool _shouldListenToSave(ProfileState prev, ProfileState curr) =>
      prev.saveActionState != curr.saveActionState &&
      curr.saveActionState != CubitStates.initial;

  bool _shouldListenToDelete(ProfileState prev, ProfileState curr) =>
      prev.deletePostActionState != curr.deletePostActionState &&
      curr.deletePostActionState != CubitStates.initial;

  bool _shouldListenToBlock(ProfileState prev, ProfileState curr) =>
      prev.blockUserActionState != curr.blockUserActionState &&
      curr.blockUserActionState != CubitStates.initial;

  bool _shouldListenToArchive(ProfileState prev, ProfileState curr) =>
      prev.archivePostActionState != curr.archivePostActionState &&
      curr.archivePostActionState != CubitStates.initial;

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎮 Action Handlers
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleShareFeedback(BuildContext context, ProfileState state) {
    final message = state.shareMessage;
    switch (state.shareActionState) {
      case CubitStates.success:
        state.isShareAdded == true
            ? AppToast.success(context, message ?? context.tr('shared_success'))
            : AppToast.info(context, message ?? context.tr('unshared_success'));
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? context.tr('shared_error'));
        break;
      default:
        break;
    }
  }

  void _handleSaveFeedback(BuildContext context, ProfileState state) {
    final message = state.saveMessage;
    switch (state.saveActionState) {
      case CubitStates.success:
        AppToast.success(context, message ?? context.tr('operation_success'));
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? context.tr('save_error'));
        break;
      default:
        break;
    }
  }

  void _handleDeleteFeedback(BuildContext context, ProfileState state) {
    final message = state.deletePostMessage;
    switch (state.deletePostActionState) {
      case CubitStates.success:
        AppToast.success(context, message ?? context.tr('delete_success'));
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? context.tr('delete_error'));
        break;
      default:
        break;
    }
  }

  void _handleArchiveFeedback(BuildContext context, ProfileState state) {
    final message = state.archivePostMessage;
    switch (state.archivePostActionState) {
      case CubitStates.success:
        AppToast.success(context, message ?? context.tr('archive_success'));
        break;
      case CubitStates.failure:
        AppToast.error(context, message ?? context.tr('archive_error'));
        break;
      default:
        break;
    }
  }

  void _handleBlockFeedback(BuildContext context, ProfileState state) {
    switch (state.blockUserActionState) {
      case CubitStates.loading:
        CustomloadingApp.show(context);
        break;
      case CubitStates.success:
        CustomloadingApp.hide(context);
        AppToast.success(
          context,
          state.blockUserMessage ?? context.tr('blocked_successfully'),
        );
        break;
      case CubitStates.failure:
        CustomloadingApp.hide(context);
        AppToast.error(
          context,
          state.blockUserMessage ?? context.tr('failed_to_block'),
        );
        break;
      default:
        break;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏗️ Build UI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildShimmerList() => ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: EdgeInsets.symmetric(vertical: 16.h),
    itemCount: 3,
    itemBuilder: (_, __) => const PostCardShimmer(),
  );

  Widget _buildShimmerListMore() => ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: 3,
    itemBuilder: (_, __) => const PostCardShimmer(),
  );

  Widget _buildError(String? error, ProfileCubit cubit, BuildContext context) =>
      CustomErrorView(
        message: error,
        onRetry: () => cubit.fetchPosts(),
      );

  Widget _buildEmptyState(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: 80.h),
    child: Center(
      child: Column(
        children: [
          AppImage(AssetsData.noPosts, height: 150.h),
          Gap(16.h),
          Text(
            context.tr('create_first_post'),
            style: Styles.textStyle16.copyWith(color: AppColors.kGreyB3),
          ),
        ],
      ),
    ),
  );

  Widget _buildLoadMoreButton(
    BuildContext context,
    ProfileState state,
    ProfileCubit cubit,
  ) {
    return state.isLoadingMore
        ? _buildShimmerListMore()
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => cubit.fetchPosts(loadMore: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kWhiteColor,
                  foregroundColor: AppColors.kprimaryColor,
                  side: BorderSide(color: AppColors.kprimaryColor, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  elevation: 0,
                ),
                child: Text(
                  context.tr('load_more_posts'),
                  style: Styles.textStyle14Meduim.copyWith(
                    color: AppColors.kprimaryColor,
                  ),
                ),
              ),
            ),
          );
  }

  Widget _buildPostList(ProfileState state, ProfileCubit cubit) =>
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        itemCount: state.posts.length,
        itemBuilder: (context, index) {
          return _PostItem(
            key: ValueKey(state.posts[index].postId),
            postId: state.posts[index].postId,
            profileCubit: cubit,
            showGap: index < state.posts.length - 1,
          );
        },
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// Post Item Widget (Optimized)
// ══════════════════════════════════════════════════════════════════════════════

class _PostItem extends StatefulWidget {
  const _PostItem({
    super.key,
    required this.postId,
    required this.profileCubit,
    this.showGap = false,
  });

  final String postId;
  final ProfileCubit profileCubit;
  final bool showGap;

  @override
  State<_PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<_PostItem> {
  late final Stream<PostModel?> _postStream;
  late final PostCallbacks _callbacks;

  @override
  void initState() {
    super.initState();
    _initializeStreamAndCallbacks();
  }

  void _initializeStreamAndCallbacks() {
    _postStream = widget.profileCubit.stream
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
    );
  }

  void _editPost(PostModel post) {
    context.pushNamed(
      AppRouter.kAddPostView,
      arguments: {"post": post, "isEdit": true},
    );
  }

  void _archivePost(String postId) =>
      widget.profileCubit.archivePost(postId: postId);

  void _blockUser(String postId, String userId) =>
      widget.profileCubit.blockUser(visiblePostId: postId, advisorId: userId);

  void _hidePost(String postId) =>
      widget.profileCubit.toggleHidePost(postId: postId);

  void _onDelete(String postId) =>
      widget.profileCubit.deletePost(postId: postId);

  void _onSave(String postId) =>
      widget.profileCubit.toggleSavePost(postId: postId);

  void _onReaction(String id, ReactionType? type) =>
      widget.profileCubit.reactToPost(postId: id, reactionType: type);

  void _onShare(String id) => widget.profileCubit.toggleSharePost(postId: id);

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
          isFromProfile: true,
          heroPrefix: 'profile',
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
        BlocSelector<ProfileCubit, ProfileState, PostModel?>(
          selector: (state) =>
              state.posts.where((p) => p.postId == widget.postId).firstOrNull,
          builder: (context, post) {
            if (post == null) return const SizedBox.shrink();
            return PostCard(
              isFromProfile: true,
              heroPrefix: 'profile',
              post: post,
              callbacks: _callbacks,
              onNavigateToDetails: _onNavigateToDetails,
            );
          },
        ),
        if (widget.showGap) Gap(16.h),
      ],
    );
  }
}
