import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart'
    as home_feed;
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/core/widgets/post_card/post_shimmer.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_state.dart';
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
      ],
      child: BlocBuilder<UserPublicProfileCubit, UserPublicProfileState>(
        builder: (context, state) {
          if (state.postsState == CubitStates.loading && state.posts.isEmpty) {
            return _buildShimmerList();
          }

          if (state.postsState == CubitStates.failure && state.posts.isEmpty) {
            return _buildErrorState(cubit);
          }

          final userPosts = state.posts;

          if (userPosts.isEmpty) {
            return _buildEmptyState();
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
      AppToast.success(
        context,
        state.saveMessage ?? context.tr('saved_success'),
      );
    } else if (state.saveActionState == CubitStates.failure) {
      AppToast.error(context, state.saveMessage ?? context.tr('save_error'));
    }
  }

  void _handleDeleteState(BuildContext context, UserPublicProfileState state) {
    if (state.deletePostActionState == CubitStates.success) {
      AppToast.success(
        context,
        state.deletePostMessage ?? context.tr('delete_success'),
      );
    } else if (state.deletePostActionState == CubitStates.failure) {
      AppToast.error(
        context,
        state.deletePostMessage ?? context.tr('delete_error'),
      );
    }
  }

  void _handleArchiveState(BuildContext context, UserPublicProfileState state) {
    if (state.archivePostActionState == CubitStates.success) {
      AppToast.success(
        context,
        state.archivePostMessage ?? context.tr('archive_success'),
      );
    } else if (state.archivePostActionState == CubitStates.failure) {
      AppToast.error(
        context,
        state.archivePostMessage ?? context.tr('archive_error'),
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

  Widget _buildErrorState(UserPublicProfileCubit cubit) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
          Gap(16.h),
          Text(
            'حدث خطأ في تحميل المنشورات',
            style: Styles.textStyle16.copyWith(color: AppColors.kRedColor),
            textAlign: TextAlign.center,
          ),
          Gap(24.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kprimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            onPressed: () => cubit.fetchPosts(),
            child: Text(
              'إعادة المحاولة',
              style: Styles.textStyle14Meduim.copyWith(
                color: AppColors.kWhiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.only(top: 100.h),
      child: const SharedEmptyState(title: "لا توجد منشورات حتى الآن"),
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
    );
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

  void _blockUser(String userId, String postId) {
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
