import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_state.dart';
import 'package:tayseer/my_import.dart';

/// PostsTab - Displays user's posts in profile
/// Uses ProfileCubit to fetch and display posts
class PostsTab extends StatelessWidget {
  const PostsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.postsState == CubitStates.loading && state.posts.isEmpty) {
          return _buildShimmerList();
        }

        if (state.postsState == CubitStates.failure && state.posts.isEmpty) {
          return _buildErrorState(profileCubit);
        }

        // TODO: Filter posts by current user
        // final userPosts = state.posts.where((post) => post.advisorId == currentUserId).toList();
        final userPosts = state.posts; // مؤقتاً نعرض كل البوستات

        if (userPosts.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: AppColors.kprimaryColor,
          onRefresh: () => profileCubit.fetchPosts(),
          child: _buildPostList(userPosts, state, context, profileCubit),
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      itemCount: 3, // عدد عناصر Shimmer للتجربة
      itemBuilder: (context, index) {
        return Column(
          children: [
            const PostCardShimmer(),
            if (index < 2) Gap(16.h), // فجوة بين عناصر Shimmer
          ],
        );
      },
    );
  }

  Widget _buildErrorState(ProfileCubit profileCubit) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'حدث خطأ',
            style: Styles.textStyle14.copyWith(color: AppColors.kGreyB3),
          ),
          Gap(10.h),
          TextButton(
            onPressed: () => profileCubit.fetchPosts(),
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.only(top: 100.h),
      child: const SharedEmptyState(title: "لا توجد منشورات"),
    );
  }

  Widget _buildPostList(
    List<PostModel> posts,
    ProfileState state,
    BuildContext context,
    ProfileCubit profileCubit,
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
              PostCard(
                post: post,
                onReactionChanged: (postId, reactionType) {
                  // TODO: تنفيذ الـ reaction في ProfileCubit
                  // يمكنك استخدام: profileCubit.reactToPost(postId: postId, reactionType: reactionType)
                },
                onShareTap: (postId) {
                  // TODO: تنفيذ الـ share في ProfileCubit
                  // يمكنك استخدام: profileCubit.toggleSharePost(postId: postId)
                },
                onNavigateToDetails: (ctx, post, controller) {
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (context) => PostDetailsView(
                        post: post,
                        cachedController: controller,
                        postUpdatesStream: profileCubit.stream.map((state) {
                          return state.posts.firstWhere(
                            (p) => p.postId == post.postId,
                            orElse: () => post,
                          );
                        }),
                        onReactionChanged: (postId, reactionType) {
                          // TODO: تنفيذ الـ reaction في ProfileCubit
                        },
                        onShareTap: (postId) {
                          // TODO: تنفيذ الـ share في ProfileCubit
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
          // Loading more indicator - استخدام نفس الـ Shimmer عند التحميل الإضافي
          return const _LoadingMoreIndicator();
        }
      },
    );
  }
}

/// مؤشر التحميل الإضافي باستخدام Shimmer
class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: const PostCardShimmer(),
    );
  }
}
