import 'package:tayseer/core/widgets/post_card/post_shimmer.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_states.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/archived_posts/archived_post_item.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart'
    as home_feed;
import 'package:tayseer/my_import.dart';

class PostsTabView extends StatelessWidget {
  const PostsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<ArchivedPostsCubit>(),
      child: const _PostsTabBody(),
    );
  }
}

class _PostsTabBody extends StatelessWidget {
  const _PostsTabBody();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ArchivedPostsCubit, ArchivedPostsState>(
          listener: (context, state) {
            final cubit = context.read<ArchivedPostsCubit>();

            if (state.errorMessage != null &&
                state.state == CubitStates.failure) {
              AppToast.error(context, state.errorMessage!);
              cubit.clearError();
            }
            if (state.shareActionState == CubitStates.success) {
              if (state.shareMessage != null) {
                AppToast.success(context, context.tr(state.shareMessage!));
              }
              cubit.resetSharePostActionState();
            } else if (state.shareActionState == CubitStates.failure) {
              if (state.shareMessage != null) {
                AppToast.error(context, state.shareMessage!);
              }
              cubit.resetSharePostActionState();
            }
            if (state.saveActionState == CubitStates.success) {
              if (state.saveMessage != null) {
                AppToast.success(context, context.tr(state.saveMessage!));
              }
              cubit.resetSavePostActionState();
            } else if (state.saveActionState == CubitStates.failure) {
              if (state.saveMessage != null) {
                AppToast.error(context, state.saveMessage!);
              }
              cubit.resetSavePostActionState();
            }
            if (state.deletePostActionState == CubitStates.success) {
              if (state.deletePostMessage != null) {
                AppToast.success(context, context.tr(state.deletePostMessage!));
              }
              cubit.resetDeletePostActionState();
            } else if (state.deletePostActionState == CubitStates.failure) {
              if (state.deletePostMessage != null) {
                AppToast.error(context, state.deletePostMessage!);
              }
              cubit.resetDeletePostActionState();
            }
            if (state.archivePostActionState == CubitStates.success) {
              if (state.archivePostMessage != null) {
                AppToast.success(
                  context,
                  context.tr(state.archivePostMessage!),
                );
              }
              cubit.resetArchivePostState();
            } else if (state.archivePostActionState == CubitStates.failure) {
              if (state.archivePostMessage != null) {
                AppToast.error(context, state.archivePostMessage!);
              }
              cubit.resetArchivePostState();
            }
            if (state.blockUserActionState == CubitStates.success) {
              if (state.blockUserMessage != null) {
                AppToast.success(context, context.tr(state.blockUserMessage!));
              }
              cubit.resetBlockUserActionState();
            } else if (state.blockUserActionState == CubitStates.failure) {
              if (state.blockUserMessage != null) {
                AppToast.error(context, state.blockUserMessage!);
              }
              cubit.resetBlockUserActionState();
            }
          },
        ),
      ],
      child: BlocBuilder<ArchivedPostsCubit, ArchivedPostsState>(
        builder: (context, state) {
          switch (state.state) {
            case CubitStates.loading:
              return _ArchivedPostsShimmer();
            case CubitStates.failure:
              return CustomErrorView(
                message: state.errorMessage,
                onRetry: () => context.read<ArchivedPostsCubit>().refresh(),
              );
            case CubitStates.success:
              if (state.posts.isEmpty) {
                return SharedEmptyState(title: context.tr("no_archived_posts"));
              }
              return _ArchivedPostsList(state: state);
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Posts List
// ─────────────────────────────────────────────

class _ArchivedPostsList extends StatelessWidget {
  const _ArchivedPostsList({required this.state});

  final ArchivedPostsState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ArchivedPostsCubit>();

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          if (state.hasMore && !state.isLoadingMore) {
            cubit.fetchArchivedPosts(loadMore: true);
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => cubit.refresh(),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          itemCount: state.posts.length + 1,
          itemBuilder: (context, index) {
            if (index == state.posts.length) {
              if (state.isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!state.hasMore && state.posts.isNotEmpty) {
                return const home_feed.EndOfFeedIndicator();
              }
              return const SizedBox.shrink();
            }
            return ArchivedPostItem(
              key: ValueKey(state.posts[index].postId),
              postId: state.posts[index].postId,
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shimmer
// ─────────────────────────────────────────────

class _ArchivedPostsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      itemCount: 3,
      itemBuilder: (_, i) => Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: const PostCardShimmer(),
      ),
    );
  }
}
