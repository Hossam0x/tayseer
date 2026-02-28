import 'package:tayseer/features/shared/followers/data/models/follower_model.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/user_advisor_profile_view.dart';
import 'package:tayseer/features/user/user_profile/views/user_public_profile_view.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';

class FollowerItem extends StatelessWidget {
  final FollowerModel follower;
  final bool isSkeleton;
  final VoidCallback onToggleFollow;

  const FollowerItem({
    super.key,
    required this.follower,
    this.isSkeleton = false,
    required this.onToggleFollow,
  });

  void _navigateToUserAdvisorProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserAdvisorProfileView(advisorId: follower.id),
      ),
    );
  }

  void _navigateToUserProfile(BuildContext context) {
    if (follower.id.isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserPublicProfileView(userId: follower.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => follower.isAdvisor
              ? _navigateToUserAdvisorProfile(context)
              : _navigateToUserProfile(context),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h),
            child: Row(
              children: [
                // Profile Image
                _buildProfileImage(),
                SizedBox(width: 12.w),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (follower.isAdvisor && !isSkeleton)
                            SizedBox(width: 4.w),
                          isSkeleton
                              ? Skeleton.shade(
                                  child: Container(
                                    width: 100.w,
                                    height: 16.h,
                                    color: Colors.grey.shade200,
                                  ),
                                )
                              // Make is verified icon
                              : Row(
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: 150.w,
                                      ),
                                      child: Text(
                                        follower.name,
                                        style: Styles.textStyle16.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    if (follower.isVerified)
                                      Icon(
                                        Icons.verified,
                                        size: 16.w,
                                        color: Colors.blue,
                                      ),
                                  ],
                                ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      isSkeleton
                          ? Skeleton.shade(
                              child: Container(
                                width: 80.w,
                                height: 14.h,
                                color: Colors.grey.shade200,
                              ),
                            )
                          : Text(
                              follower.username,
                              style: Styles.textStyle14.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                    ],
                  ),
                ),

                SizedBox(width: 12.w),

                // Follow Button
                if (!isSkeleton && follower.isAdvisor && !follower.isMe)
                  _buildFollowButton(context),
                // if (!isSkeleton && follower.isMe)
                //   Text(
                //     'Me',
                //     style: Styles.textStyle16.copyWith(
                //       fontWeight: FontWeight.bold,
                //       color: Colors.black87,
                //     ),
                //   ),
              ],
            ),
          ),
        ),
        Divider(color: Colors.grey.shade400, height: 0.5.h, thickness: 0.5.h),
      ],
    );
  }

  Widget _buildProfileImage() {
    return isSkeleton
        ? Skeleton.shade(
            child: Container(
              width: 55.r,
              height: 55.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
            ),
          )
        : Container(
            width: 55.r,
            height: 55.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: ClipOval(
              child: follower.imageUrl != null && follower.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: follower.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.person,
                          size: 24.w,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.person,
                          size: 24.w,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.person,
                        size: 24.w,
                        color: Colors.grey.shade400,
                      ),
                    ),
            ),
          );
  }

  Widget _buildFollowButton(BuildContext context) {
    if (follower.isFollowing) {
      return Container(
        width: 115.w,
        height: 45.h,
        decoration: BoxDecoration(
          color: AppColors.primary100,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.primary500),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6.r),
            onTap: () {
              if (isGuest) {
                _navigateToRegistration(context);
              } else {
                onToggleFollow();
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Center(
                child: Text(
                  context.tr('unfollow'),
                  style: Styles.textStyle16SemiBold.copyWith(
                    color: AppColors.primary400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return CustomBotton(
        title: context.tr('follow'),
        onPressed: () {
          if (isGuest) {
            _navigateToRegistration(context);
          } else {
            onToggleFollow();
          }
        },
        width: 110.w,
        height: 45.h,
        radius: 10.r,
        useGradient: true,
      );
    }
  }

  void _navigateToRegistration(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: context.tr('joinUs'),
      supTitle: context.tr("guest_login_first"),
      icon: Icons.lock_person_outlined,
      iconColor: AppColors.kprimaryColor,
      bottonText: context.tr("login"),
      showCancelButton: true,
      cancelText: context.tr('skip'),
      onPressed: () {
        CachNetwork.removeData(key: ktoken);
        context.pushNamedAndRemoveUntil(
          AppRouter.kRegisrationView,
          predicate: (_) => false,
        );
      },
      onCancel: () {},
    );
  }
}

// Skeleton item for loading state
class FollowerItemSkeleton extends StatelessWidget {
  const FollowerItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return FollowerItem(
      follower: FollowerModel(
        id: '',
        name: 'اسم المستخدم',
        username: '@username',
        isFollowing: false,
        userType: 'User',
        isMe: false,
      ),
      isSkeleton: true,
      onToggleFollow: () {},
    );
  }
}
