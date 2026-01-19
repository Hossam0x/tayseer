import 'dart:ui';

import 'package:tayseer/core/functions/count_formate.dart';
import 'package:tayseer/core/widgets/follow_button.dart';
import 'package:tayseer/core/widgets/post_card/circular_icon_button.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/reaction_like_button.dart';
import 'package:tayseer/core/widgets/post_card/share_button.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/my_import.dart';
// تأكد من استيراد AppImage

class ReelsOverlay extends StatelessWidget {
  final PostModel post;
  final dynamic Function(ReactionType?) onReactionChanged;
  final VoidCallback onShareTapped;
  final VideoPlayerController? cachedController;
  final GlobalKey? likeButtonKey;

  const ReelsOverlay({
    super.key,
    required this.post,
    required this.onReactionChanged,
    required this.onShareTapped,
    this.cachedController,
    this.likeButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          // 1. Header
          _buildHeader(context),

          const Spacer(),

          // 2. Bottom Content (UserInfo + Actions)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // أ. الأزرار الجانبية (نضعها أولاً لتظهر على اليمين في العربي)
                _buildSideActions(context),

                Gap(10.w), // مسافة بين الأزرار والنص
                // ب. معلومات المستخدم (تأخذ باقي المساحة وتظهر على اليسار)
                Expanded(child: _buildUserInfo(context)),
              ],
            ),
          ),
          Gap(24.h),
        ],
      ),
    );
  }

  // --- Header Section ---
  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      // 1. البوردر ريدياس من تحت بس (للقص)
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),

            // 2. البوردر ريدياس من تحت بس (للشكل)
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),

            // 3. البوردر (الخط) من تحت بس
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(Icons.close, color: Colors.white, size: 28.sp),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                    Gap(20.w),
                    Icon(Icons.info_outline, color: Colors.white, size: 26.sp),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FollowButton(
                    isFollowing: post.isFollowing,
                    onTap: () {
                      // Call follow/unfollow API
                    },
                  ),
                  Gap(8.w),
                  if (post.isVerified)
                    Icon(Icons.verified, color: Colors.blue, size: 16.sp),
                  Gap(4.w),
                  Flexible(
                    child: Text(
                      post.name,
                      style: Styles.textStyle16.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),

              Gap(4.h),

              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    post.timeAgo,
                    style: Styles.textStyle12.copyWith(color: Colors.white70),
                  ),
                  Gap(context.responsiveWidth(5)),
                  Icon(Icons.public, color: Colors.white70, size: 12.sp),
                  Gap(context.responsiveWidth(5)),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Flexible(
                      child: Text(
                        post.userName,
                        style: Styles.textStyle12.copyWith(
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Gap(10.w),

        Container(
          width: 45.w,
          height: 45.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: ClipOval(
            child: AppImage(
              post.avatar,
              width: 45.w,
              height: 45.w,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: context.responsiveHeight(22),
      children: [
        _buildCircleActionBtn(
          child: SizedBox(
            key: likeButtonKey,
            child: ReactionLikeButton(
              height: 50,
              width: 50,
              onReactionChanged: onReactionChanged,
              initialReaction: post.myReaction,
            ),
          ),
          count: post.likesCount,
        ),
        _buildCircleActionBtn(
          child: CircularIconButton(
            height: 50,
            width: 50,
            icon: AssetsData.commentIcon,
            backgroundColor: const Color(0xFFFCE9ED),

            onTap: () {
              final homeCubit = getIt<HomeCubit>();
              homeCubit.setInitialPost(post);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailsView(
                    post: post,
                    cachedController: cachedController,
                    callbacks: PostCallbacks(
                       postUpdatesStream: homeCubit.stream.map((state) {
                      return state.posts.firstWhere(
                        (p) => p.postId == post.postId,
                        orElse: () => post,
                      );
                    }),
                    onReactionChanged: (postId, reactionType) {
                      homeCubit.reactToPost(
                        postId: postId,
                        reactionType: reactionType,
                      );
                    },
                    onShareTap: (postId) {
                      homeCubit.toggleSharePost(postId: postId);
                    },
                    onHashtagTap: (hashtag) {
                      context.pushNamed(AppRouter.kAdvisorSearchView);
                    },
                    ),
                  ),
                ),
              );
            },
          ),
          count: post.commentsCount,
        ),

        _buildCircleActionBtn(
          child: ShareButton(
            height: 50,
            width: 50,
            onShareTapped: onShareTapped,
            isShared: post.isRepostedByMe,
          ),
          count: post.sharesCount,
        ),
        // 4. More
        CircularIconButton(
          height: 50,
          width: 50,
          icon: AssetsData.moreIcon,
          iconColor: HexColor("#F2A6B5"),
          backgroundColor: const Color(0xFFFCE9ED),
          onTap: () {
            // Show more options
          },
        ),
      ],
    );
  }

  Widget _buildCircleActionBtn({required int count, required Widget child}) {
    return Column(
      children: [
        child,
        Gap(4.h),
        Text(
          formatCount(count),
          style: Styles.textStyle12.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              const Shadow(
                offset: Offset(0, 1),
                blurRadius: 2,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
