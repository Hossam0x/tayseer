import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart'
    as home_feed;
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_state.dart';
import 'package:tayseer/core/widgets/post_card/post_shimmer.dart';
import 'posts_tab_listeners.dart';
import 'post_item_widget.dart';

class PostsTab extends StatelessWidget with PostsTabListeners {
  const PostsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();

    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: shouldListenToShare,
          listener: handleShareFeedback,
        ),
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: shouldListenToSave,
          listener: handleSaveFeedback,
        ),
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: shouldListenToDelete,
          listener: handleDeleteFeedback,
        ),
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: shouldListenToBlock,
          listener: handleBlockFeedback,
        ),
        BlocListener<ProfileCubit, ProfileState>(
          listenWhen: shouldListenToArchive,
          listener: handleArchiveFeedback,
        ),
      ],
      child: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (previous, current) =>
            previous.postsState != current.postsState ||
            previous.posts != current.posts ||
            previous.isLoadingMore != current.isLoadingMore ||
            previous.hasMore != current.hasMore,
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
      CustomErrorView(message: error, onRetry: () => cubit.fetchPosts());

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
          return PostItemWidget(
            key: ValueKey(state.posts[index].postId),
            postId: state.posts[index].postId,
            profileCubit: cubit,
            showGap: index < state.posts.length - 1,
          );
        },
      );
}
