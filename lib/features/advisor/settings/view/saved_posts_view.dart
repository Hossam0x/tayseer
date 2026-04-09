import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/saved_posts_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/saved_posts/saved_posts_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/saved_posts/saved_posts_state.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart'
    as home_feed;
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/core/widgets/post_card/post_shimmer.dart';

class SavedPostsView extends StatelessWidget {
  const SavedPostsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SavedPostsCubit(
        getIt<SavedPostsRepository>(),
        getIt<HomeRepository>(),
      ),
      child: const _SavedPostsBody(),
    );
  }
}

class _SavedPostsBody extends StatelessWidget {
  const _SavedPostsBody();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SavedPostsCubit, SavedPostsState>(
          listenWhen: (p, c) =>
              p.status != c.status && c.status == CubitStates.failure,
          listener: (context, state) {
            if (state.errorMessage != null) {
              AppToast.error(context, state.errorMessage!);
            }
          },
        ),
        // 📢 SHARE FEEDBACK
        BlocListener<SavedPostsCubit, SavedPostsState>(
          listenWhen: (p, c) =>
              p.shareActionState != c.shareActionState &&
              c.shareActionState != CubitStates.initial,
          listener: (context, state) {
            if (state.shareActionState == CubitStates.success) {
              AppToast.success(
                context,
                state.isShareAdded == true
                    ? (state.shareMessage ?? context.tr('shared_success'))
                    : (state.shareMessage ?? context.tr('unshared_success')),
              );
            } else if (state.shareActionState == CubitStates.failure) {
              AppToast.error(
                context,
                state.shareMessage ?? context.tr('shared_error'),
              );
            }
          },
        ),
        // 💾 SAVE FEEDBACK
        BlocListener<SavedPostsCubit, SavedPostsState>(
          listenWhen: (p, c) =>
              p.saveActionState != c.saveActionState &&
              c.saveActionState != CubitStates.initial,
          listener: (context, state) {
            if (state.saveActionState == CubitStates.success) {
              AppToast.success(
                context,
                state.saveMessage ?? context.tr('saved_success'),
              );
            } else if (state.saveActionState == CubitStates.failure) {
              AppToast.error(
                context,
                state.saveMessage ?? context.tr('save_error'),
              );
            }
          },
        ),
        // 🗑 DELETE FEEDBACK
        BlocListener<SavedPostsCubit, SavedPostsState>(
          listenWhen: (p, c) =>
              p.deletePostActionState != c.deletePostActionState &&
              c.deletePostActionState != CubitStates.initial,
          listener: (context, state) {
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
          },
        ),
        // 📦 ARCHIVE FEEDBACK
        BlocListener<SavedPostsCubit, SavedPostsState>(
          listenWhen: (p, c) =>
              p.archivePostActionState != c.archivePostActionState &&
              c.archivePostActionState != CubitStates.initial,
          listener: (context, state) {
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
          },
        ),
        // 🚫 BLOCK FEEDBACK
        BlocListener<SavedPostsCubit, SavedPostsState>(
          listenWhen: (p, c) =>
              p.blockUserActionState != c.blockUserActionState &&
              c.blockUserActionState != CubitStates.initial,
          listener: (context, state) {
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
          },
        ),
      ],
      child: Scaffold(
        body: AdvisorBackground(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 105.h,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AssetsData.homeBarBackgroundImage),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Gap(30.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 15.h,
                    ),
                    child: SimpleAppBar(title: context.tr('saved_posts')),
                  ),
                  Expanded(child: _buildBody()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<SavedPostsCubit, SavedPostsState>(
      builder: (context, state) {
        final cubit = context.read<SavedPostsCubit>();

        if (state.status == CubitStates.loading && state.posts.isEmpty) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            itemCount: 3,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: const PostCardShimmer(),
            ),
          );
        }

        if (state.status == CubitStates.failure && state.posts.isEmpty) {
          return CustomErrorView(
            verticalPadding: 100,
            message: state.errorMessage,
            onRetry: () => cubit.refresh(),
          );
        }

        if (state.status == CubitStates.success && state.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppImage(AssetsData.postsEndIcon, height: 200.h, width: 200.w),
                Gap(16.h),
                Text(
                  context.tr('no_saved_posts'),
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.secondary400,
                  ),
                ),
                Gap(8.h),
                Text(
                  context.tr('saved_posts_empty_hint'),
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.secondary300,
                  ),
                ),
              ],
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            // Trigger load more when user is near the end
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

                return _PostItem(
                  postId: state.posts[index].postId,
                  cubit: cubit,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _PostItem extends StatefulWidget {
  final String postId;
  final SavedPostsCubit cubit;
  const _PostItem({required this.postId, required this.cubit});

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
      onReactionChanged: (postId, reaction) =>
          widget.cubit.reactToPost(postId: postId, reactionType: reaction),
      onShareTap: (postId) => widget.cubit.toggleSharePost(postId: postId),
      onSave: (postId) => widget.cubit.toggleSavePost(postId: postId),
      onDelete: (postId) => widget.cubit.deletePost(postId: postId),
      onArchive: (postId) => widget.cubit.archivePost(postId: postId),
      onHide: (postId) => widget.cubit.toggleHidePost(postId: postId),
      onBlock: (postId, userId) =>
          widget.cubit.blockUser(visiblePostId: postId, advisorId: userId),
      onEdit: (updatedPost) => widget.cubit.updatePostLocally(updatedPost),
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
      onPollVote: (postId, choiceText) =>
          widget.cubit.voteInPoll(postId: postId, choiceText: choiceText),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SavedPostsCubit, SavedPostsState, PostModel?>(
      selector: (state) =>
          state.posts.where((p) => p.postId == widget.postId).firstOrNull,
      builder: (context, post) {
        if (post == null) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: PostCard(
            isFromProfile: false,
            heroPrefix: 'saved_posts',
            post: post,
            callbacks: _callbacks,
            onNavigateToDetails: (context, post, controller) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailsView(
                    post: post,
                    isFromProfile: false,
                    heroPrefix: 'saved_posts',
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
