import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/saved_posts_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/saved_posts_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/saved_posts_state.dart';
import 'package:tayseer/core/models/post_model.dart';
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
      create: (context) => SavedPostsCubit(getIt<SavedPostsRepository>()),
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
        BlocListener<SavedPostsCubit, SavedPostsState>(
          listenWhen: (p, c) => p.saveActionState != c.saveActionState,
          listener: (context, state) {
            if (state.saveActionState == CubitStates.success) {
              AppToast.success(context, state.saveMessage ?? 'تم تحديث الحفظ');
            } else if (state.saveActionState == CubitStates.failure) {
              AppToast.error(context, state.saveMessage ?? 'فشل تحديث الحفظ');
            }
          },
        ),
        // 🗑 DELETE FEEDBACK
        BlocListener<SavedPostsCubit, SavedPostsState>(
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
        // 📦 ARCHIVE FEEDBACK
        BlocListener<SavedPostsCubit, SavedPostsState>(
          listenWhen: (p, c) =>
              p.archivePostActionState != c.archivePostActionState,
          listener: (context, state) {
            if (state.archivePostActionState == CubitStates.success) {
              AppToast.success(
                context,
                state.archivePostMessage ?? 'تم الأرشفة',
              );
            } else if (state.archivePostActionState == CubitStates.failure) {
              AppToast.error(
                context,
                state.archivePostMessage ?? 'فشل الأرشفة',
              );
            }
          },
        ),
        // 🚫 BLOCK FEEDBACK
        BlocListener<SavedPostsCubit, SavedPostsState>(
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
                    child: SimpleAppBar(title: 'المنشورات المحفوظة'),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'حدث خطأ في تحميل المنشورات',
                  style: Styles.textStyle16.copyWith(color: AppColors.kGreyB3),
                ),
                Gap(12.h),
                ElevatedButton(
                  onPressed: () => cubit.refresh(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kprimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: Text(
                    'إعادة المحاولة',
                    style: Styles.textStyle14.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
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
                  'لا توجد منشورات محفوظة',
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.secondary400,
                  ),
                ),
                Gap(8.h),
                Text(
                  'عند حفظ منشور سيظهر هنا',
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
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
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
      },
    );
  }
}

class _PostItem extends StatelessWidget {
  final PostModel post;
  const _PostItem({required this.post});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SavedPostsCubit>();

    return BlocSelector<SavedPostsCubit, SavedPostsState, PostModel>(
      selector: (state) => state.posts.firstWhere(
        (p) => p.postId == post.postId,
        orElse: () => post,
      ),
      builder: (context, currentPost) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: PostCard(
            isFromProfile: false,
            post: currentPost,
            callbacks: PostCallbacks(
              onReactionChanged: (postId, reaction) =>
                  cubit.reactToPost(postId: postId, reactionType: reaction),
              onShareTap: (postId) => cubit.toggleSharePost(postId: postId),
              onSave: (postId) => cubit.toggleSavePost(postId: postId),
              onDelete: (postId) => cubit.deletePost(postId: postId),
              onArchive: (postId) => cubit.archivePost(postId: postId),
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
                    isFromProfile: false,
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
