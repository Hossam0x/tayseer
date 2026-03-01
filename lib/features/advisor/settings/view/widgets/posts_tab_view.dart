import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_states.dart';
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
          listenWhen: (p, c) =>
              p.state != c.state && c.state == CubitStates.failure,
          listener: (context, state) {
            if (state.errorMessage != null) {
              AppToast.error(context, state.errorMessage!);
            }
          },
        ),
        // 📢 SHARE FEEDBACK
        BlocListener<ArchivedPostsCubit, ArchivedPostsState>(
          listenWhen: (p, c) => p.shareActionState != c.shareActionState,
          listener: (context, state) {
            if (state.shareActionState == CubitStates.success) {
              AppToast.success(context, state.shareMessage ?? 'تمت المشاركة');
            } else if (state.shareActionState == CubitStates.failure) {
              AppToast.error(context, state.shareMessage ?? 'فشل المشاركة');
            }
          },
        ),
        // 💾 SAVE FEEDBACK
        BlocListener<ArchivedPostsCubit, ArchivedPostsState>(
          listenWhen: (p, c) => p.saveActionState != c.saveActionState,
          listener: (context, state) {
            if (state.saveActionState == CubitStates.success) {
              AppToast.success(context, state.saveMessage ?? 'تم الحفظ');
            } else if (state.saveActionState == CubitStates.failure) {
              AppToast.error(context, state.saveMessage ?? 'فشل الحفظ');
            }
          },
        ),
        // 🗑 DELETE FEEDBACK
        BlocListener<ArchivedPostsCubit, ArchivedPostsState>(
          listenWhen: (p, c) =>
              p.deletePostActionState != c.deletePostActionState,
          listener: (context, state) {
            if (state.deletePostActionState == CubitStates.success) {
              AppToast.success(context, state.deletePostMessage ?? 'تم الحذف');
            } else if (state.deletePostActionState == CubitStates.failure) {
              AppToast.error(context, state.deletePostMessage ?? 'فشل الحذف');
            }
          },
        ),
        // 📦 ARCHIVE FEEDBACK (Unarchive in this case)
        BlocListener<ArchivedPostsCubit, ArchivedPostsState>(
          listenWhen: (p, c) =>
              p.archivePostActionState != c.archivePostActionState,
          listener: (context, state) {
            if (state.archivePostActionState == CubitStates.success) {
              AppToast.success(
                context,
                state.archivePostMessage ?? 'تم إلغاء الأرشفة',
              );
            } else if (state.archivePostActionState == CubitStates.failure) {
              AppToast.error(
                context,
                state.archivePostMessage ?? 'فشل إلغاء الأرشفة',
              );
            }
          },
        ),
        // 🚫 BLOCK FEEDBACK
        BlocListener<ArchivedPostsCubit, ArchivedPostsState>(
          listenWhen: (p, c) =>
              p.blockUserActionState != c.blockUserActionState,
          listener: (context, state) {
            if (state.blockUserActionState == CubitStates.success) {
              AppToast.success(context, state.blockUserMessage ?? 'تم الحظر');
            } else if (state.blockUserActionState == CubitStates.failure) {
              AppToast.error(context, state.blockUserMessage ?? 'فشل الحظر');
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
              return _buildErrorPosts(context, state.errorMessage);
            case CubitStates.success:
              if (state.posts.isEmpty) {
                return const SharedEmptyState(title: "لا توجد منشورات مؤرشفة");
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

  Widget _buildErrorPosts(BuildContext context, String? errorMessage) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
          Gap(16.h),
          Text(
            errorMessage ?? 'حدث خطأ في تحميل المنشورات المؤرشفة',
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
            onPressed: () => context.read<ArchivedPostsCubit>().refresh(),
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

            return _PostItem(post: state.posts[index]);
          },
        ),
      ),
    );
  }
}

class _PostItem extends StatelessWidget {
  final PostModel post;
  const _PostItem({required this.post});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ArchivedPostsCubit>();

    return BlocSelector<ArchivedPostsCubit, ArchivedPostsState, PostModel>(
      selector: (state) => state.posts.firstWhere(
        (p) => p.postId == post.postId,
        orElse: () => post,
      ),
      builder: (context, currentPost) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: PostCard(
            isFromProfile: true,
            heroPrefix: 'archived_posts',
            post: currentPost,
            callbacks: PostCallbacks(
              onReactionChanged: (postId, reaction) =>
                  cubit.reactToPost(postId: postId, reactionType: reaction),
              onShareTap: (postId) => cubit.toggleSharePost(postId: postId),
              onSave: (postId) => cubit.toggleSavePost(postId: postId),
              onDelete: (postId) => cubit.deletePost(postId: postId),
              onArchive: (postId) => cubit.unarchivePost(postId),
              onHide: (postId) => cubit.toggleHidePost(postId: postId),
              onBlock: (postId, advisorId) =>
                  cubit.blockUser(visiblePostId: postId, advisorId: advisorId),
            ),
            onNavigateToDetails: (context, post, controller) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailsView(
                    post: post,
                    isFromProfile: true,
                    heroPrefix: 'archived_posts',
                    cachedController: controller,
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
