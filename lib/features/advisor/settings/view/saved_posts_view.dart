import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/profile_post_card.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/saved_posts_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/saved_posts_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/saved_posts_state.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/my_import.dart';

class SavedPostsView extends StatelessWidget {
  const SavedPostsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SavedPostsCubit(getIt<SavedPostsRepository>());
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cubit.fetchSavedPosts();
        });
        return cubit;
      },
      child: BlocListener<SavedPostsCubit, SavedPostsState>(
        // ⭐️ Listener للـ Share
        listenWhen: (prev, curr) =>
            prev.shareActionState != curr.shareActionState &&
            curr.shareActionState != CubitStates.initial,
        listener: (context, state) {
          final message = state.shareMessage;
          switch (state.shareActionState) {
            case CubitStates.success:
              state.isShareAdded == true
                  ? AppToast.success(context, message ?? 'تمت المشاركة بنجاح')
                  : AppToast.info(context, message ?? 'تم إلغاء المشاركة');
              break;
            case CubitStates.failure:
              AppToast.error(context, message ?? 'حدث خطأ أثناء المشاركة');
              break;
            default:
              break;
          }
        },
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
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<SavedPostsCubit, SavedPostsState>(
      builder: (context, state) {
        final cubit = context.read<SavedPostsCubit>();

        // ⭐️⭐️⭐️ الحل: التحقق من حالة التحميل أولاً
        if (state.status == CubitStates.loading && state.posts.isEmpty) {
          return _buildShimmerList();
        }

        if (state.status == CubitStates.failure && state.posts.isEmpty) {
          return _buildErrorState(cubit);
        }

        // ⭐️⭐️⭐️ هذا هو الجزء المهم:
        // تأكد أن التحميل انتهى وفقط عندها تحقق من وجود الـ posts
        if (state.status == CubitStates.success && state.posts.isEmpty) {
          return _buildEmptyState();
        }

        // ⭐️⭐️⭐️ إذا كانت الـ posts ليست فارغة أو مازال التحميل جارياً
        return RefreshIndicator(
          color: AppColors.kprimaryColor,
          onRefresh: () => cubit.refresh(),
          child: _buildPostsList(state, cubit),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: const PostCardShimmer(),
        );
      },
    );
  }

  Widget _buildErrorState(SavedPostsCubit cubit) {
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
            onPressed: () => cubit.fetchSavedPosts(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kprimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(AssetsData.postsEndIcon, height: 200.h, width: 200.w),
          Gap(16.h),
          Text(
            'لا توجد منشورات محفوظة',
            style: Styles.textStyle16.copyWith(color: AppColors.secondary400),
          ),
          Gap(8.h),
          Text(
            'عند حفظ منشور سيظهر هنا',
            style: Styles.textStyle14.copyWith(color: AppColors.secondary300),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(SavedPostsState state, SavedPostsCubit cubit) {
    return ListView.builder(
      itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0),

      itemBuilder: (context, index) {
        if (index < state.posts.length) {
          final post = state.posts[index];
          return _buildPostItem(context, post, cubit);
        } else {
          return _buildLoadingMoreIndicator();
        }
      },
    );
  }

  Widget _buildPostItem(
    BuildContext context,
    PostModel post,
    SavedPostsCubit cubit,
  ) {
    return Container(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        children: [
          // Post Card
          ProfilePostCard(
            post: post,
            onReactionChanged: (postId, reactionType) {
              // ⭐️ استدعاء Like
              cubit.reactToPost(postId: postId, reactionType: reactionType);
            },
            onShareTap: (postId) {
              // ⭐️ استدعاء Share
              cubit.toggleSharePost(postId: postId);
            },
            onNavigateToDetails: (ctx, post, controller) {
              _navigateToDetails(ctx, post, controller, cubit);
            },
            onHashtagTap: (hashtag) {
              context.pushNamed(AppRouter.kAdvisorSearchView);
            },
            onMoreTap: () => _showOptionsBottomSheet(context, post, cubit),
          ),

          // Remove button
          Divider(height: 1, color: Colors.grey.shade200),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: _buildRemoveButton(context, post, cubit),
          // ),
        ],
      ),
    );
  }

  // Widget _buildRemoveButton(
  //   BuildContext context,
  //   PostModel post,
  //   SavedPostsCubit cubit,
  // ) {
  //   return InkWell(
  //     onTap: () => _confirmRemove(context, post, cubit),
  //     borderRadius: BorderRadius.only(
  //       bottomLeft: Radius.circular(12.r),
  //       bottomRight: Radius.circular(12.r),
  //     ),
  //     child: Container(
  //       padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
  //       decoration: BoxDecoration(
  //         color: AppColors.kRedColor.withOpacity(0.05),
  //         borderRadius: BorderRadius.only(
  //           bottomLeft: Radius.circular(12.r),
  //           bottomRight: Radius.circular(12.r),
  //         ),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             Icons.bookmark_remove_rounded,
  //             color: AppColors.kRedColor,
  //             size: 18.w,
  //           ),
  //           Gap(8.w),
  //           Text(
  //             'إزالة من المحفوظات',
  //             style: Styles.textStyle14.copyWith(
  //               color: AppColors.kRedColor,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildLoadingMoreIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.kprimaryColor),
      ),
    );
  }

  void _navigateToDetails(
    BuildContext context,
    PostModel post,
    VideoPlayerController? controller,
    SavedPostsCubit cubit,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailsView(
          post: post,
          cachedController: controller,
          postUpdatesStream: cubit.stream.map((state) {
            return state.posts.firstWhere(
              (p) => p.postId == post.postId,
              orElse: () => post,
            );
          }),
          onReactionChanged: (postId, reactionType) {
            // TODO: يمكنك إضافة reaction logic لاحقاً
          },
          onShareTap: (postId) {
            // TODO: يمكنك إضافة share logic لاحقاً
          },
          onHashtagTap: (hashtag) {
            context.pushNamed(AppRouter.kAdvisorSearchView);
          },
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(
    BuildContext context,
    PostModel post,
    SavedPostsCubit cubit,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Gap(12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Gap(16.h),
              // ⭐️ أضف خيار الإزالة من المحفوظات
              _buildOptionItem(
                context,
                icon: Icons.bookmark_remove_rounded,
                title: 'إزالة من المحفوظات',
                color: AppColors.kRedColor,
                onTap: () {
                  Navigator.pop(context);
                  _confirmRemove(context, post, cubit);
                },
              ),
              // ⭐️ أضف خيار المشاركة
              _buildOptionItem(
                context,
                icon: Icons.share_rounded,
                title: 'مشاركة',
                color: AppColors.kprimaryColor,
                onTap: () {
                  Navigator.pop(context);
                  cubit.toggleSharePost(postId: post.postId);
                },
              ),
              // ⭐️ أضف خيار حفظ/إلغاء حفظ
              // _buildOptionItem(
              //   context,
              //   icon: post.isSaved
              //       ? Icons.bookmark_remove_rounded
              //       : Icons.bookmark_add_rounded,
              //   title: post.isSaved ? 'إلغاء الحفظ' : 'حفظ',
              //   color: AppColors.kprimaryColor,
              //   onTap: () {
              //     Navigator.pop(context);
              //     cubit.toggleSavePost(postId: post.postId);
              //     AppToast.success(
              //       context,
              //       post.isSaved ? 'تم إلغاء الحفظ' : 'تم الحفظ بنجاح',
              //     );
              //   },
              // ),
              Gap(16.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: Styles.textStyle16.copyWith(color: color)),
      onTap: onTap,
    );
  }

  // في _confirmRemove:
  void _confirmRemove(
    BuildContext context,
    PostModel post,
    SavedPostsCubit cubit,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'إزالة من المحفوظات',
            style: Styles.textStyle18Bold,
            textAlign: TextAlign.center,
          ),
          content: Text(
            'هل أنت متأكد من إزالة هذا المنشور من المحفوظات؟',
            style: Styles.textStyle14,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: Styles.textStyle14.copyWith(
                  color: AppColors.secondary400,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                // ⭐️ استخدام try-catch مع mounted check
                try {
                  await cubit.removeFromSaved(post.postId);

                  // ⭐️ التحقق من mounted قبل show toast
                  if (context.mounted) {
                    AppToast.success(context, 'تمت الإزالة من المحفوظات');
                  }
                } catch (e) {
                  if (context.mounted) {
                    AppToast.error(context, 'حدث خطأ أثناء الإزالة');
                  }
                }
              },
              child: Text(
                'إزالة',
                style: Styles.textStyle14.copyWith(color: AppColors.kRedColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
