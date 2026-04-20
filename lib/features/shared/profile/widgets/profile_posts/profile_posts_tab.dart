import 'package:tayseer/core/widgets/post_card/post_shimmer.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart'
    as home_feed;
import 'package:tayseer/features/shared/profile/widgets/profile_posts/profile_post_item.dart';
import 'package:tayseer/features/shared/profile/widgets/profile_posts/profile_posts_cubit_contract.dart';
import 'package:tayseer/my_import.dart';

class ProfilePostsTab<C extends ProfilePostsCubitContract>
    extends StatefulWidget {
  const ProfilePostsTab({super.key, required this.heroPrefix});

  final String heroPrefix;

  @override
  State<ProfilePostsTab<C>> createState() => _ProfilePostsTabState<C>();
}

class _ProfilePostsTabState<C extends ProfilePostsCubitContract>
    extends State<ProfilePostsTab<C>> {
  CubitStates _prevShareState = CubitStates.initial;
  CubitStates _prevSaveState = CubitStates.initial;
  CubitStates _prevDeleteState = CubitStates.initial;
  CubitStates _prevArchiveState = CubitStates.initial;
  CubitStates _prevBlockState = CubitStates.initial;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<C>();

    return MultiBlocListener(
      listeners: [
        BlocListener<C, dynamic>(
          listenWhen: (_, __) {
            final changed =
                cubit.shareActionState != _prevShareState &&
                cubit.shareActionState != CubitStates.initial;
            _prevShareState = cubit.shareActionState;
            return changed;
          },
          listener: (context, _) {
            switch (cubit.shareActionState) {
              case CubitStates.success:
                cubit.isShareAdded == true
                    ? AppToast.success(
                        context,
                        cubit.shareMessage ?? context.tr('shared_success'),
                      )
                    : AppToast.info(
                        context,
                        cubit.shareMessage ?? context.tr('unshared_success'),
                      );
                break;
              case CubitStates.failure:
                AppToast.error(
                  context,
                  cubit.shareMessage ?? context.tr('shared_error'),
                );
                break;
              default:
                break;
            }
          },
        ),
        BlocListener<C, dynamic>(
          listenWhen: (_, __) {
            final changed =
                cubit.saveActionState != _prevSaveState &&
                cubit.saveActionState != CubitStates.initial;
            _prevSaveState = cubit.saveActionState;
            return changed;
          },
          listener: (context, _) {
            if (cubit.saveActionState == CubitStates.success) {
              AppToast.success(
                context,
                cubit.saveMessage ?? context.tr('saved_success'),
              );
            } else if (cubit.saveActionState == CubitStates.failure) {
              AppToast.error(
                context,
                cubit.saveMessage ?? context.tr('save_error'),
              );
            }
          },
        ),
        BlocListener<C, dynamic>(
          listenWhen: (_, __) {
            final changed =
                cubit.deletePostActionState != _prevDeleteState &&
                cubit.deletePostActionState != CubitStates.initial;
            _prevDeleteState = cubit.deletePostActionState;
            return changed;
          },
          listener: (context, _) {
            if (cubit.deletePostActionState == CubitStates.success) {
              AppToast.success(
                context,
                cubit.deletePostMessage ?? context.tr('delete_success'),
              );
            } else if (cubit.deletePostActionState == CubitStates.failure) {
              AppToast.error(
                context,
                cubit.deletePostMessage ?? context.tr('delete_error'),
              );
            }
          },
        ),
        BlocListener<C, dynamic>(
          listenWhen: (_, __) {
            final changed =
                cubit.archivePostActionState != _prevArchiveState &&
                cubit.archivePostActionState != CubitStates.initial;
            _prevArchiveState = cubit.archivePostActionState;
            return changed;
          },
          listener: (context, _) {
            if (cubit.archivePostActionState == CubitStates.success) {
              AppToast.success(
                context,
                cubit.archivePostMessage ?? context.tr('archive_success'),
              );
            } else if (cubit.archivePostActionState == CubitStates.failure) {
              AppToast.error(
                context,
                cubit.archivePostMessage ?? context.tr('archive_error'),
              );
            }
          },
        ),
        BlocListener<C, dynamic>(
          listenWhen: (_, __) {
            final changed =
                cubit.blockUserActionState != _prevBlockState &&
                cubit.blockUserActionState != CubitStates.initial;
            _prevBlockState = cubit.blockUserActionState;
            return changed;
          },
          listener: (context, _) {
            switch (cubit.blockUserActionState) {
              case CubitStates.loading:
                CustomloadingApp.show(context);
                break;
              case CubitStates.success:
                CustomloadingApp.hide(context);
                AppToast.success(
                  context,
                  cubit.blockUserMessage ?? context.tr('blocked_successfully'),
                );
                break;
              case CubitStates.failure:
                CustomloadingApp.hide(context);
                AppToast.error(
                  context,
                  cubit.blockUserMessage ?? context.tr('failed_to_block'),
                );
                break;
              default:
                break;
            }
          },
        ),
      ],
      child: BlocBuilder<C, dynamic>(
        buildWhen: (_, __) => true,
        builder: (context, _) {
          if (cubit.postsState == CubitStates.loading && cubit.posts.isEmpty) {
            return _PostsShimmer();
          }
          if (cubit.postsState == CubitStates.failure && cubit.posts.isEmpty) {
            return CustomErrorView(
              message: cubit.postsErrorMessage,
              onRetry: () => cubit.fetchPosts(),
            );
          }
          if (cubit.posts.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: 100.h),
              child: SharedEmptyState(title: context.tr('no_posts_yet')),
            );
          }

          return RefreshIndicator(
            color: AppColors.kprimaryColor,
            onRefresh: () => cubit.fetchPosts(),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  itemCount: cubit.posts.length,
                  itemBuilder: (context, index) => ProfilePostItem<C>(
                    key: ValueKey(cubit.posts[index].postId),
                    postId: cubit.posts[index].postId,
                    cubit: cubit,
                    heroPrefix: widget.heroPrefix,
                    showGap: index < cubit.posts.length - 1,
                  ),
                ),
                if (cubit.hasMore)
                  _LoadMoreButton(
                    onLoadMore: () => cubit.fetchPosts(loadMore: true),
                    isLoadingMore: cubit.isLoadingMore,
                  )
                else if (cubit.posts.isNotEmpty)
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
// Shimmer
// ─────────────────────────────────────────────

class _PostsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: 3,
      itemBuilder: (_, i) =>
          Column(children: [const PostCardShimmer(), if (i < 2) Gap(1.h)]),
    );
  }
}

// ─────────────────────────────────────────────
// Load More Button
// ─────────────────────────────────────────────

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton({
    required this.onLoadMore,
    required this.isLoadingMore,
  });

  final VoidCallback onLoadMore;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (_, i) =>
            Column(children: [const PostCardShimmer(), if (i < 2) Gap(1.h)]),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onLoadMore,
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
