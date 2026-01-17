// features/advisor/settings/view/widgets/archive_post_widget.dart
import 'package:tayseer/core/widgets/post_card/post_actions_row.dart';
import 'package:tayseer/core/widgets/post_card/post_contect_text.dart';
import 'package:tayseer/core/widgets/post_card/post_stats.dart';
import 'package:tayseer/core/widgets/post_card/user_info_header.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/my_import.dart';

class ArchivePostWidget extends StatelessWidget {
  final PostModel post; // ⭐️ غير من ArchivePostModel إلى PostModel
  final VoidCallback onUnarchive;
  final void Function(String postId, ReactionType? reactionType)?
  onReactionChanged;
  final void Function(String postId)? onShareTap;
  final void Function(String hashtag)? onHashtagTap;

  const ArchivePostWidget({
    super.key,
    required this.post,
    required this.onUnarchive,
    this.onReactionChanged,
    this.onShareTap,
    this.onHashtagTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Post Card
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info
                UserInfoHeader(
                  name: post.name,
                  avatar: post.avatar,
                  isVerified: post.isVerified,
                  onMoreTap: () => _showOptionsSheet(context),
                  subtitle: Row(
                    children: [
                      Flexible(
                        child: Text(
                          post.category,
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.kprimaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Gap(4.w),
                      Text(
                        " • ${post.timeAgo}",
                        style: Styles.textStyle10.copyWith(
                          color: HexColor("#99A1BE"),
                        ),
                      ),
                      Gap(4.w),
                      Icon(Icons.public, color: AppColors.kGreyB3, size: 12.sp),
                    ],
                  ),
                ),
                Gap(15.h),

                // Content Text
                PostContentText(
                  text: post.content,
                  style: Styles.textStyle14.copyWith(
                    color: HexColor("#333333"),
                    height: 1.5,
                  ),
                  hashtagStyle: Styles.textStyle14Bold.copyWith(
                    color: Colors.blue,
                  ),
                  onHashtagTap: onHashtagTap,
                ),
                Gap(12.h),

                // Images (إذا كانت موجودة)
                if (post.images.isNotEmpty)
                  _buildPostImages(context, post.images),

                // Video (إذا كان موجوداً)
                if (post.hasVideo) _buildPostVideo(context, post.videoUrl!),

                Gap(15.h),

                // Stats
                PostStats(
                  comments: post.commentsCount,
                  shares: post.sharesCount,
                  onTap: () {
                    // يمكنك إضافة navigation لتفاصيل المنشور
                  },
                ),
                Gap(8.h),

                // Actions
                PostActionsRow(
                  topReactions: post.topReactions,
                  likesCount: post.likesCount,
                  myReaction: post.myReaction,
                  isRepostedByMe: post.isRepostedByMe,
                  onCommentTap: () {
                    // يمكنك إضافة navigation للتعليقات
                  },
                  onReactionChanged: (reactionType) {
                    onReactionChanged?.call(post.postId, reactionType);
                  },
                  onShareTap: () {
                    onShareTap?.call(post.postId);
                  },
                ),
              ],
            ),
          ),

          // Unarchive Button
          Divider(height: 1, color: Colors.grey.shade200),
          _buildUnarchiveButton(context),
        ],
      ),
    );
  }

  Widget _buildPostImages(BuildContext context, List<String> images) {
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: AppImage(
          images[0],
          fit: BoxFit.cover,
          width: double.infinity,
          height: context.responsiveHeight(206),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
        childAspectRatio: 1,
      ),
      itemCount: images.length > 4 ? 4 : images.length,
      itemBuilder: (context, index) {
        if (index == 3 && images.length > 4) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: AppImage(
                  images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Text(
                    "+${images.length - 4}",
                    style: Styles.textStyle20Bold.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: AppImage(
            images[index],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      },
    );
  }

  Widget _buildPostVideo(BuildContext context, String videoUrl) {
    return Container(
      width: double.infinity,
      height: context.responsiveHeight(206),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.black,
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: 50.w,
            ),
          ),
          Positioned(
            bottom: 10.h,
            right: 10.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'فيديو',
                style: Styles.textStyle12.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnarchiveButton(BuildContext context) {
    return InkWell(
      onTap: () => _confirmUnarchive(context),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(12.r),
        bottomRight: Radius.circular(12.r),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.kprimaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12.r),
            bottomRight: Radius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.archive_outlined,
              color: AppColors.kprimaryColor,
              size: 18.w,
            ),
            Gap(8.w),
            Text(
              'إلغاء الأرشفة',
              style: Styles.textStyle14.copyWith(
                color: AppColors.kprimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsSheet(BuildContext context) {
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
              _buildOptionItem(
                context,
                icon: Icons.archive_outlined,
                title: 'إلغاء الأرشفة',
                color: AppColors.kprimaryColor,
                onTap: () {
                  Navigator.pop(context);
                  _confirmUnarchive(context);
                },
              ),
              _buildOptionItem(
                context,
                icon: Icons.share_rounded,
                title: 'مشاركة',
                color: AppColors.kprimaryColor,
                onTap: () {
                  Navigator.pop(context);
                  onShareTap?.call(post.postId);
                },
              ),
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

  void _confirmUnarchive(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'إلغاء الأرشفة',
            style: Styles.textStyle18Bold,
            textAlign: TextAlign.center,
          ),
          content: Text(
            'هل أنت متأكد من إلغاء أرشفة هذا المنشور؟',
            style: Styles.textStyle14,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: Styles.textStyle14.copyWith(
                  color: AppColors.secondary400,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onUnarchive();
              },
              child: Text(
                'إلغاء الأرشفة',
                style: Styles.textStyle14.copyWith(
                  color: AppColors.kprimaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
