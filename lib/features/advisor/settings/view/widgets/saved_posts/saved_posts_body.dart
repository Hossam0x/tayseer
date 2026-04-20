import 'package:tayseer/core/widgets/post_card/post_shimmer.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/saved_posts/saved_posts_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/saved_posts/saved_posts_state.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/saved_posts/saved_post_item.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/saved_posts/saved_posts_listeners.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart'
    as home_feed;
import 'package:tayseer/my_import.dart';

class SavedPostsBody extends StatelessWidget {
  const SavedPostsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: buildSavedPostsListeners(context),
      child: BlocBuilder<SavedPostsCubit, SavedPostsState>(
        builder: (context, state) {
          final cubit = context.read<SavedPostsCubit>();

          if (state.status == CubitStates.loading && state.posts.isEmpty) {
            return const _SavedPostsShimmer();
          }

          if (state.status == CubitStates.failure && state.posts.isEmpty) {
            return CustomErrorView(
              verticalPadding: 100,
              message: state.errorMessage,
              onRetry: () => cubit.refresh(),
            );
          }

          if (state.status == CubitStates.success && state.posts.isEmpty) {
            return const _SavedPostsEmpty();
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 400) {
                if (state.hasMore && !state.isLoadingMore) {
                  cubit.fetchSavedPosts(loadMore: true);
                }
              }
              return false;
            },
            child: RefreshIndicator(
              color: AppColors.kprimaryColor,
              onRefresh: () => cubit.refresh(),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                itemCount: state.posts.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.posts.length) {
                    if (state.isLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: PostCardShimmer(),
                      );
                    }
                    if (!state.hasMore && state.posts.isNotEmpty) {
                      return const home_feed.EndOfFeedIndicator();
                    }
                    return const SizedBox.shrink();
                  }
                  return SavedPostItem(
                    postId: state.posts[index].postId,
                    cubit: cubit,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────

class _SavedPostsShimmer extends StatelessWidget {
  const _SavedPostsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: 3,
      itemBuilder: (_, i) => Padding(
        padding: EdgeInsets.only(bottom: 1.h),
        child: const PostCardShimmer(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────

class _SavedPostsEmpty extends StatelessWidget {
  const _SavedPostsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(AssetsData.postsEndIcon, height: 200.h, width: 200.w),
          Gap(16.h),
          Text(
            context.tr('no_saved_posts'),
            style: Styles.textStyle16.copyWith(color: AppColors.secondary400),
          ),
          Gap(8.h),
          Text(
            context.tr('saved_posts_empty_hint'),
            style: Styles.textStyle14.copyWith(color: AppColors.secondary300),
          ),
        ],
      ),
    );
  }
}
