// features/advisor/user_profile/views/widgets/user_posts_tab.dart
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/profile_post_card.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/features/user/advisor_profile/views/cubit/user_profile_cubit.dart';
import 'package:tayseer/features/user/advisor_profile/views/cubit/user_profile_state.dart';
import 'package:tayseer/my_import.dart';

class UserPostsTab extends StatelessWidget {
  const UserPostsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfileCubit = context.read<UserProfileCubit>();

    return BlocListener<UserProfileCubit, UserProfileState>(
      listenWhen: _shouldListenToShare,
      listener: _handleShareState,
      child: BlocBuilder<UserProfileCubit, UserProfileState>(
        builder: (context, state) {
          if (state.postsState == CubitStates.loading && state.posts.isEmpty) {
            return _buildShimmerList();
          }

          if (state.postsState == CubitStates.failure && state.posts.isEmpty) {
            return _buildErrorState(userProfileCubit);
          }

          final userPosts = state.posts;

          if (userPosts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: AppColors.kprimaryColor,
            onRefresh: () => userProfileCubit.fetchPosts(),
            child: _buildPostList(userPosts, state, context, userProfileCubit),
          );
        },
      ),
    );
  }

  bool _shouldListenToShare(UserProfileState prev, UserProfileState curr) =>
      prev.shareActionState != curr.shareActionState &&
      curr.shareActionState != CubitStates.initial;

  void _handleShareState(BuildContext context, UserProfileState state) {
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
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Column(
          children: [const PostCardShimmer(), if (index < 2) Gap(16.h)],
        );
      },
    );
  }

  Widget _buildErrorState(UserProfileCubit cubit) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
          Gap(16.h),
          Text(
            'حدث خطأ',
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
            onPressed: () => cubit.fetchPosts(),
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

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.only(top: 100.h),
      child: const SharedEmptyState(title: "لا توجد منشورات حتى الآن"),
    );
  }

  Widget _buildPostList(
    List<PostModel> posts,
    UserProfileState state,
    BuildContext context,
    UserProfileCubit cubit,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: posts.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < posts.length) {
          final post = posts[index];
          return Column(
            children: [
              ProfilePostCard(
                post: post,
                onReactionChanged: (postId, reactionType) {
                  cubit.reactToPost(postId: postId, reactionType: reactionType);
                },
                onShareTap: (postId) {
                  cubit.toggleSharePost(postId: postId);
                },
                onNavigateToDetails: (ctx, post, controller) {
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (context) => PostDetailsView(
                        post: post,
                        cachedController: controller,
                        postUpdatesStream: cubit.stream.map((state) {
                          return state.posts.firstWhere(
                            (p) => p.postId == post.postId,
                            orElse: () => post,
                          );
                        }),
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
                      ),
                    ),
                  );
                },
                onHashtagTap: (hashtag) {
                  context.pushNamed(AppRouter.kAdvisorSearchView);
                },
              ),
              if (index < posts.length - 1) Gap(16.h),
            ],
          );
        } else {
          return const PostCardShimmer();
        }
      },
    );
  }
}
