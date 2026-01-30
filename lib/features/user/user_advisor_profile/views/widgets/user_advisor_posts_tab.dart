import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_cubit.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_state.dart';
import 'package:tayseer/my_import.dart';

class UserAdvisorPostsTab extends StatefulWidget {
  final String advisorId;

  const UserAdvisorPostsTab({super.key, required this.advisorId});

  @override
  State<UserAdvisorPostsTab> createState() => _UserAdvisorPostsTabState();
}

class _UserAdvisorPostsTabState extends State<UserAdvisorPostsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cubit = context.read<UserAdvisorProfileCubit>();

    return BlocListener<UserAdvisorProfileCubit, UserAdvisorProfileState>(
      listenWhen: _shouldListenToShare,
      listener: _handleShareState,
      child: BlocBuilder<UserAdvisorProfileCubit, UserAdvisorProfileState>(
        builder: (context, state) {
          if (state.postsState == CubitStates.loading && state.posts.isEmpty) {
            return _buildShimmerList();
          }

          if (state.postsState == CubitStates.failure && state.posts.isEmpty) {
            return _buildErrorState(cubit);
          }

          final userPosts = state.posts;

          if (userPosts.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            color: AppColors.kprimaryColor,
            onRefresh: () => cubit.fetchPosts(),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  itemCount: userPosts.length,
                  itemBuilder: (context, index) {
                    final post = userPosts[index];
                    return Column(
                      children: [
                        PostCard(
                          isFromProfile: true,
                          post: post,
                          onNavigateToDetails: (ctx, post, controller) {
                            Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                builder: (context) => PostDetailsView(
                                  isFromProfile: true,
                                  post: post,
                                  cachedController: controller,
                                  callbacks: PostCallbacks(
                                    postUpdatesStream: cubit.stream.map((
                                      state,
                                    ) {
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
                                      context.pushNamed(
                                        AppRouter.kAdvisorSearchView,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (index < userPosts.length - 1) Gap(16.h),
                      ],
                    );
                  },
                ),

                // زر تحميل المزيد
                if (state.hasMore) _buildLoadMoreButton(context, state, cubit),

                // مسافة إضافية في الأسفل
                Gap(20.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreButton(
    BuildContext context,
    UserAdvisorProfileState state,
    UserAdvisorProfileCubit cubit,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
      child: state.isLoadingMore
          ? Center(
              child: CircularProgressIndicator(color: AppColors.kprimaryColor),
            )
          : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => cubit.fetchPosts(loadMore: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kWhiteColor,
                  foregroundColor: AppColors.kprimaryColor,
                  side: BorderSide(color: AppColors.kprimaryColor, width: 1.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  elevation: 0,
                ),
                child: Text(
                  'تحميل المزيد من المنشورات',
                  style: Styles.textStyle14Meduim.copyWith(
                    color: AppColors.kprimaryColor,
                  ),
                ),
              ),
            ),
    );
  }

  bool _shouldListenToShare(
    UserAdvisorProfileState prev,
    UserAdvisorProfileState curr,
  ) =>
      prev.shareActionState != curr.shareActionState &&
      curr.shareActionState != CubitStates.initial;

  void _handleShareState(BuildContext context, UserAdvisorProfileState state) {
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

  Widget _buildErrorState(UserAdvisorProfileCubit cubit) {
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
}
