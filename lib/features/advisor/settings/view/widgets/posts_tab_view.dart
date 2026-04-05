import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_states.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart'
    as home_feed;
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/core/widgets/post_card/post_shimmer.dart';

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
    // final cubit = context.read<ArchivedPostsCubit>();

    return MultiBlocListener(
      listeners: [
        BlocListener<ArchivedPostsCubit, ArchivedPostsState>(
          listener: (context, state) {
            final cubit = context.read<ArchivedPostsCubit>();

            // ⭐ Handle General Error
            if (state.errorMessage != null &&
                state.state == CubitStates.failure) {
              AppToast.error(context, state.errorMessage!);
              cubit.clearError();
            }

            // 📢 SHARE FEEDBACK
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

            // 💾 SAVE FEEDBACK
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

            // 🗑 DELETE FEEDBACK
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

            // 📦 ARCHIVE FEEDBACK (Unarchive)
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

            // 🚫 BLOCK FEEDBACK
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
              return _buildSkeletonPosts();
            case CubitStates.failure:
              return CustomErrorView(
                message: state.errorMessage,
                onRetry: () => context.read<ArchivedPostsCubit>().refresh(),
              );
            case CubitStates.success:
              if (state.posts.isEmpty) {
                return SharedEmptyState(title: context.tr("no_archived_posts"));
              }
              return _buildPostsContent(context, state);
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildSkeletonPosts() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: const PostCardShimmer(),
      ),
    );
  }

  Widget _buildPostsContent(BuildContext context, ArchivedPostsState state) {
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

            return _PostItem(
              key: ValueKey(state.posts[index].postId),
              postId: state.posts[index].postId,
            );
          },
        ),
      ),
    );
  }
}

class _PostItem extends StatefulWidget {
  final String postId;
  const _PostItem({super.key, required this.postId});

  @override
  State<_PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<_PostItem>
    with AutomaticKeepAliveClientMixin {
  late final ArchivedPostsCubit _cubit;
  late final Stream<PostModel?> _postStream;
  late final PostCallbacks _callbacks;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ArchivedPostsCubit>();
    _postStream = _cubit.stream
        .map(
          (state) =>
              state.posts.where((p) => p.postId == widget.postId).firstOrNull,
        )
        .distinct();

    _callbacks = PostCallbacks(
      postUpdatesStream: _postStream,
      onReactionChanged: (postId, reaction) =>
          _cubit.reactToPost(postId: postId, reactionType: reaction),
      onShareTap: (postId) => _cubit.toggleSharePost(postId: postId),
      onSave: (postId) => _cubit.toggleSavePost(postId: postId),
      onDelete: (postId) => _cubit.deletePost(postId: postId),
      onArchive: (postId) => _cubit.unarchivePost(postId),
      onHide: (postId) => _cubit.toggleHidePost(postId: postId),
      onBlock: (postId, advisorId) =>
          _cubit.blockUser(visiblePostId: postId, advisorId: advisorId),
      onEdit: (updatedPost) => _cubit.updatePostLocally(updatedPost),
      onCommented: (postId, isAnonymous) =>
          _cubit.markPostAsCommented(postId: postId, isAnonymous: isAnonymous),
      onCommentCountDelta:
          ({required postId, required countDelta, isCommented, isAnonymous}) =>
              _cubit.updateCommentCountByDelta(
                postId: postId,
                countDelta: countDelta,
                isCommented: isCommented,
                isAnonymous: isAnonymous,
              ),
      onCommentCountSync: ({required postId, required totalCount}) => _cubit
          .syncCommentCountFromBackend(postId: postId, totalCount: totalCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocSelector<ArchivedPostsCubit, ArchivedPostsState, PostModel?>(
      selector: (state) =>
          state.posts.where((p) => p.postId == widget.postId).firstOrNull,
      builder: (context, post) {
        if (post == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: PostCard(
            isFromProfile: true,
            heroPrefix: 'archived_posts',
            isArchived: true,
            post: post,
            callbacks: _callbacks,
            onNavigateToDetails: (context, post, controller) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailsView(
                    post: post,
                    isFromProfile: true,
                    isArchived: true,
                    heroPrefix: 'archived_posts',
                    cachedController: controller,
                    callbacks: _callbacks,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
