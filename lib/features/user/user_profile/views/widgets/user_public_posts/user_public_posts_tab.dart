import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart'
    as home_feed;
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_shimmer.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_posts/user_public_post_item.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_posts/user_public_posts_listeners.dart';
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
          listener: handleShareState,
        ),
        BlocListener<UserPublicProfileCubit, UserPublicProfileState>(
          listenWhen: (prev, curr) =>
              prev.saveActionState != curr.saveActionState &&
              curr.saveActionState != CubitStates.initial,
          listener: handleSaveState,
        ),
        BlocListener<UserPublicProfileCubit, UserPublicProfileState>(
          listenWhen: (prev, curr) =>
              prev.deletePostActionState != curr.deletePostActionState &&
              curr.deletePostActionState != CubitStates.initial,
          listener: handleDeleteState,
        ),
        BlocListener<UserPublicProfileCubit, UserPublicProfileState>(
          listenWhen: (prev, curr) =>
              prev.archivePostActionState != curr.archivePostActionState &&
              curr.archivePostActionState != CubitStates.initial,
          listener: handleArchiveState,
        ),
        BlocListener<UserPublicProfileCubit, UserPublicProfileState>(
          listenWhen: (prev, curr) =>
              prev.blockUserActionState != curr.blockUserActionState &&
              curr.blockUserActionState != CubitStates.initial,
          listener: handleBlockUserState,
        ),
        BlocListener<UserPublicProfileCubit, UserPublicProfileState>(
          listenWhen: (prev, curr) =>
              prev.pollVoteActionState != curr.pollVoteActionState &&
              curr.pollVoteActionState == CubitStates.failure,
          listener: handlePollVoteState,
        ),
      ],
      child: BlocBuilder<UserPublicProfileCubit, UserPublicProfileState>(
        builder: (context, state) {
          if (state.postsState == CubitStates.loading && state.posts.isEmpty) {
            return const _PostsShimmer();
          }

          if (state.postsState == CubitStates.failure && state.posts.isEmpty) {
            return CustomErrorView(
              message: state.postsErrorMessage,
              onRetry: () => cubit.fetchPosts(),
            );
          }

          if (state.posts.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: 100.h),
              child: SharedEmptyState(title: context.tr("no_posts_yet")),
            );
          }

          return RefreshIndicator(
            color: AppColors.kprimaryColor,
            onRefresh: () => cubit.fetchPosts(),
            child: Column(
              children: [
                _PostList(posts: state.posts, cubit: cubit),
                if (state.hasMore)
                  _LoadMoreButton(
                    cubit: cubit,
                    isLoadingMore: state.isLoadingMore,
                  )
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
}

// ─────────────────────────────────────────────
// Post List
// ─────────────────────────────────────────────

class _PostList extends StatelessWidget {
  const _PostList({required this.posts, required this.cubit});

  final List<PostModel> posts;
  final UserPublicProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: posts.length,
      itemBuilder: (context, index) => UserPublicPostItem(
        postId: posts[index].postId,
        cubit: cubit,
        showGap: index < posts.length - 1,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Load More Button
// ─────────────────────────────────────────────

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({required this.cubit, required this.isLoadingMore});

  final UserPublicProfileCubit cubit;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const _PostsShimmer(itemCount: 2);
    }
    return Padding(
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
}

// ─────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────

class _PostsShimmer extends StatelessWidget {
  const _PostsShimmer({this.itemCount = 3});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: itemCount,
      itemBuilder: (_, index) => Column(
        children: [
          const PostCardShimmer(),
          if (index < itemCount - 1) Gap(16.h),
        ],
      ),
    );
  }
}
