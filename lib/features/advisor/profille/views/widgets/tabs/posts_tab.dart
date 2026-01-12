import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/advisor/profille/view_model/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/view_model/profile_state.dart';
import 'package:tayseer/features/advisor/home/views/post_details_view.dart';
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
          return Center(
            child: CircularProgressIndicator(color: AppColors.kprimaryColor),
          );
        }

        if (state.postsState == CubitStates.failure && state.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.errorMessage ?? 'حدث خطأ',
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

        // TODO: Filter posts by current user
        // final userPosts = state.posts.where((post) => post.advisorId == currentUserId).toList();
        final userPosts = state.posts; // مؤقتاً نعرض كل البوستات

        if (userPosts.isEmpty) {
          return const SharedEmptyState(title: "لا توجد منشورات");
        }

        return RefreshIndicator(
          color: AppColors.kprimaryColor,
          onRefresh: () => profileCubit.fetchPosts(),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 16.h),
            itemCount: userPosts.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < userPosts.length) {
                final post = userPosts[index];
                return Column(
                  children: [
                    PostCard(
                      post: post,
                      onReactionChanged: (postId, reactionType) {
                        // TODO: تنفيذ الـ reaction في ProfileCubit
                      },
                      onShareTap: (postId) {
                        // TODO: تنفيذ الـ share في ProfileCubit
                      },
                      onNavigateToDetails: (ctx, post, controller) {
                        Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (context) => PostDetailsView(
                              post: post,
                              cachedController: controller,
                              postUpdatesStream: profileCubit.stream.map((
                                state,
                              ) {
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
                    if (index < userPosts.length - 1) Gap(16.h),
                  ],
                );
              } else {
                // Loading more indicator
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.kprimaryColor,
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
