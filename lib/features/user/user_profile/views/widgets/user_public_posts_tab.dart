import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart'
    as home_feed;
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/core/widgets/post_card/post_shimmer.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_state.dart';
import 'package:tayseer/my_import.dart';

class UserPublicPostsTab extends StatelessWidget {
  const UserPublicPostsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UserPublicProfileCubit>();

    return MultiBlocListener(
      listeners: [
        BlocListener<UserPublicProfileCubit, UserPublicProfileState>(
          listenWhen: (prev, curr) =>
              prev.shareActionState != curr.shareActionState &&
              curr.shareActionState != CubitStates.initial,
          listener: _handleShareState,
        ),
        BlocListener<UserPublicProfileCubit, UserPublicProfileState>(
          listenWhen: (prev, curr) =>
              prev.saveActionState != curr.saveActionState &&
              curr.saveActionState != CubitStates.initial,
          listener: _handleSaveState,
        ),
        BlocListener<UserPublicProfileCubit, UserPublicProfileState>(
          listenWhen: (prev, curr) =>
              prev.deletePostActionState != curr.deletePostActionState &&
              curr.deletePostActionState != CubitStates.initial,
          listener: _handleDeleteState,
        ),
        BlocListener<UserPublicProfileCubit, UserPublicProfileState>(
          listenWhen: (prev, curr) =>
              prev.archivePostActionState != curr.archivePostActionState &&
              curr.archivePostActionState != CubitStates.initial,
          listener: _handleArchiveState,
        ),
        BlocListener<UserPublicProfileCubit, UserPublicProfileState>(
          listenWhen: (prev, curr) =>
              prev.blockUserActionState != curr.blockUserActionState &&
              curr.blockUserActionState != CubitStates.initial,
          listener: _handleBlockUserState,
        ),
        BlocListener<UserPublicProfileCubit, UserPublicProfileState>(
          listenWhen: (prev, curr) =>
              prev.pollVoteActionState != curr.pollVoteActionState &&
              curr.pollVoteActionState == CubitStates.failure,
          listener: _handlePollVoteState,
        ),
      ],
      child: BlocBuilder<UserPublicProfileCubit, UserPublicProfileState>(
        builder: (context, state) {
          if (state.postsState == CubitStates.loading && state.posts.isEmpty) {
            return _buildShimmerList();
          }

          if (state.postsState == CubitStates.failure && state.posts.isEmpty) {
            return _buildErrorState(context, cubit);
          }

          final userPosts = state.posts;

          if (userPosts.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            color: AppColors.kprimaryColor,
            onRefresh: () => cubit.fetchPosts(),
            child: Column(
              children: [
                _buildPostList(userPosts, state, context, cubit),

                // زر تحميل المزيد أو إند فيد
                if (state.hasMore)
                  _buildLoadMoreButton(context, state, cubit)
                else if (userPosts.isNotEmpty)
                  const home_feed.EndOfFeedIndicator(),

                Gap(40.h),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleSaveState(BuildContext context, UserPublicProfileState state) {
    if (state.saveActionState == CubitStates.success) {
      showSafeSnackBar(
        context: context,
        text: state.saveMessage ?? context.tr('saved_success'),
        isSuccess: true,
      );
    } else if (state.saveActionState == CubitStates.failure) {
      showSafeSnackBar(
        context: context,
        text: state.saveMessage ?? context.tr('save_error'),
        isError: true,
      );
    }
  }

  void _handleDeleteState(BuildContext context, UserPublicProfileState state) {
    if (state.deletePostActionState == CubitStates.success) {
      showSafeSnackBar(
        context: context,
        text: state.deletePostMessage ?? context.tr('delete_success'),
        isSuccess: true,
      );
    } else if (state.deletePostActionState == CubitStates.failure) {
      showSafeSnackBar(
        context: context,
        text: state.deletePostMessage ?? context.tr('delete_error'),
        isError: true,
      );
    }
  }

  void _handleArchiveState(BuildContext context, UserPublicProfileState state) {
    if (state.archivePostActionState == CubitStates.success) {
      showSafeSnackBar(
        context: context,
        text: state.archivePostMessage ?? context.tr('archive_success'),
        isSuccess: true,
      );
    } else if (state.archivePostActionState == CubitStates.failure) {
      showSafeSnackBar(
        context: context,
        text: state.archivePostMessage ?? context.tr('archive_error'),
        isError: true,
      );
    }
  }

  void _handleBlockUserState(
    BuildContext context,
    UserPublicProfileState state,
  ) {
    if (state.blockUserActionState == CubitStates.success) {
      AppToast.success(
        context,
        state.blockUserMessage ?? context.tr('blocked_successfully'),
      );
    } else if (state.blockUserActionState == CubitStates.failure) {
      AppToast.error(
        context,
        state.blockUserMessage ?? context.tr('failed_to_block'),
      );
    }
  }

  void _handleShareState(BuildContext context, UserPublicProfileState state) {
    final message = state.shareMessage;
    switch (state.shareActionState) {
      case CubitStates.success:
        showSafeSnackBar(
          context: context,
          text: state.isShareAdded == true
              ? (message ?? context.tr('shared_success'))
              : (message ?? context.tr('unshared_success')),
          isSuccess: true,
          duration: const Duration(milliseconds: 1500),
        );
        break;
      case CubitStates.failure:
        showSafeSnackBar(
          context: context,
          text: message ?? context.tr('shared_error'),
          isError: true,
        );
        break;
      default:
        break;
    }
  }

  void _handlePollVoteState(
    BuildContext context,
    UserPublicProfileState state,
  ) {
    showSafeSnackBar(
      context: context,
      text: state.pollVoteMessage ?? context.tr('poll_vote_error'),
      isError: true,
    );
  }

  Widget _buildLoadMoreButton(
    BuildContext context,
    UserPublicProfileState state,
    UserPublicProfileCubit cubit,
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

  Widget _buildShimmerList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Column(
          children: [const PostCardShimmer(), if (index < 2) Gap(16.h)],
        );
      },
    );
  }

  Widget _buildShimmerListMore() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Column(
          children: [const PostCardShimmer(), if (index < 2) Gap(16.h)],
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, UserPublicProfileCubit cubit) {
    final state = cubit.state;
    return CustomErrorView(
      message: state.postsErrorMessage,
      onRetry: () => cubit.fetchPosts(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 100.h),
      child: SharedEmptyState(title: context.tr("no_posts_yet")),
    );
  }

  Widget _buildPostList(
    List<PostModel> posts,
    UserPublicProfileState state,
    BuildContext context,
    UserPublicProfileCubit cubit,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _PostItem(
          postId: post.postId,
          cubit: cubit,
          showGap: index < posts.length - 1,
        );
      },
    );
  }
}

class _PostItem extends StatefulWidget {
  const _PostItem({
    required this.postId,
    required this.cubit,
    this.showGap = false,
  });

  final String postId;
  final UserPublicProfileCubit cubit;
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
    _postStream = widget.cubit.stream
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
      onCommented: (postId, isAnonymous) => widget.cubit.markPostAsCommented(
        postId: postId,
        isAnonymous: isAnonymous,
      ),
      onCommentCountDelta:
          ({required postId, required countDelta, isCommented, isAnonymous}) =>
              widget.cubit.updateCommentCountByDelta(
                postId: postId,
                countDelta: countDelta,
                isCommented: isCommented,
                isAnonymous: isAnonymous,
              ),
      onCommentCountSync: ({required postId, required totalCount}) => widget
          .cubit
          .syncCommentCountFromBackend(postId: postId, totalCount: totalCount),
    );
  }

  void _onPollVote(String postId, String choiceText) {
    widget.cubit.voteInPoll(postId: postId, choiceText: choiceText);
  }

  void _editPost(PostModel post) {
    context.pushNamed(
      AppRouter.kAddPostView,
      arguments: {"post": post, "isEdit": true},
    );
  }

  void _archivePost(String postId) {
    widget.cubit.archivePost(postId: postId);
  }

  void _blockUser(String postId, String userId) {
    widget.cubit.blockUser(visiblePostId: postId, userId: userId);
  }

  void _hidePost(String postId) {
    widget.cubit.toggleHidePost(postId: postId);
  }

  void _onDelete(String postId) {
    widget.cubit.deletePost(postId: postId);
  }

  void _onSave(String postId) {
    widget.cubit.toggleSavePost(postId: postId);
  }

  void _onReaction(String id, ReactionType? type) {
    widget.cubit.reactToPost(postId: id, reactionType: type);
  }

  void _onShare(String id) {
    widget.cubit.toggleSharePost(postId: id);
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
          isFromProfile: true,
          heroPrefix: 'user_profile',
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
        BlocSelector<
          UserPublicProfileCubit,
          UserPublicProfileState,
          PostModel?
        >(
          selector: (state) =>
              state.posts.where((p) => p.postId == widget.postId).firstOrNull,
          builder: (context, post) {
            if (post == null) return const SizedBox.shrink();
            return PostCard(
              isFromProfile: true,
              heroPrefix: 'user_profile',
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
