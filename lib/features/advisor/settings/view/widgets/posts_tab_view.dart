import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/archive_post_widget.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_states.dart';

class PostsTabView extends StatelessWidget {
  const PostsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArchivedPostsCubit, ArchivedPostsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.kRedColor,
            ),
          );
          context.read<ArchivedPostsCubit>().clearError();
        }
      },
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
    );
  }

  Widget _buildSkeletonPosts() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonHeader(),
                  Gap(15.h),
                  _buildSkeletonTextLines(),
                  Gap(12.h),
                  _buildSkeletonImage(),
                  Gap(15.h),
                  _buildSkeletonStats(),
                  Gap(12.h),
                  _buildSkeletonActions(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonHeader() => Row(
    children: [
      Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
      Gap(12.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 120.w, height: 14.h, color: Colors.white),
            Gap(6.h),
            Container(width: 180.w, height: 12.h, color: Colors.white),
          ],
        ),
      ),
    ],
  );

  Widget _buildSkeletonTextLines() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(width: double.infinity, height: 14.h, color: Colors.white),
      Gap(8.h),
      Container(width: 250.w, height: 14.h, color: Colors.white),
    ],
  );

  Widget _buildSkeletonImage() => Container(
    width: double.infinity,
    height: 206.h,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
    ),
  );

  Widget _buildSkeletonStats() =>
      Container(width: 150.w, height: 12.h, color: Colors.white);

  Widget _buildSkeletonActions() => Row(
    spacing: 6.w,
    children: List.generate(
      3,
      (_) => Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      ),
    ),
  );

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
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => cubit.refresh(),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                itemCount: state.posts.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.posts.length) {
                    return _buildLoadMoreIndicator(state);
                  }

                  final post = state.posts[index];
                  return ArchivePostWidget(
                    post: post,
                    onUnarchive: () =>
                        _unarchivePost(context, post.postId, cubit),
                    onReactionChanged: (postId, reactionType) {
                      cubit.reactToPost(
                        postId: postId,
                        reactionType: reactionType,
                      );
                    },
                    onShareTap: (postId) {
                      cubit.toggleSharePost(postId: postId);
                    },
                    onHashtagTap: (hashtag) {
                      context.pushNamed(AppRouter.kAdvisorSearchView);
                    },
                  );
                },
              ),
            ),
          ),
          if (state.isLoadingMore) _buildLoadingMore(),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator(ArchivedPostsState state) {
    if (!state.hasMore) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: state.isLoadingMore
            ? CircularProgressIndicator(color: AppColors.kprimaryColor)
            : Container(),
      ),
    );
  }

  Widget _buildLoadingMore() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.kprimaryColor),
      ),
    );
  }

  Future<void> _unarchivePost(
    BuildContext context,
    String postId,
    ArchivedPostsCubit cubit,
  ) async {
    try {
      await cubit.unarchivePost(postId);
      if (context.mounted) {
        AppToast.success(context, 'تم إلغاء أرشفة المنشور');
      }
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, 'حدث خطأ أثناء إلغاء الأرشفة');
      }
    }
  }
}
