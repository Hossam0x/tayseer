import 'package:tayseer/features/advisor/home/model/comment_model.dart';
import 'package:tayseer/features/advisor/home/view_model/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/my_import.dart';

class CommentContentWidget extends StatelessWidget {
  final CommentModel comment;
  final String contentDisplay;
  final bool isReply;
  final bool isReplyingState;
  final VoidCallback onReplyTap;
  final VoidCallback onEditTap;

  const CommentContentWidget({
    super.key,
    required this.comment,
    required this.contentDisplay,
    required this.isReply,
    required this.isReplyingState,
    required this.onReplyTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          SizedBox(
            height: isReply ? 32.r : 40.r,
            width: isReply ? 32.r : 40.r,
            child: ClipOval(
              child: AppImage(comment.commenter.avatar, fit: BoxFit.cover),
            ),
          ),
          Gap(10.w),

          // Data
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildUserInfo(),
                Gap(6.h),
                Text(
                  contentDisplay,
                  style: Styles.textStyle14.copyWith(
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
                Gap(8.h),
                _buildActions(context),
                Gap(5.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          comment.commenter.name,
          style: Styles.textStyle16SemiBold.copyWith(
            color: const Color(0xFF19295C),
          ),
        ),
        Gap(4.w),
        if (comment.commenter.isVerified)
          Icon(Icons.verified, color: Colors.blue, size: 14.sp),
        const Spacer(),
        Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20.sp),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        Text(
          comment.commenter.userName,
          style: Styles.textStyle12.copyWith(color: AppColors.kGreyB3),
          textDirection: TextDirection.ltr,
        ),
        Gap(4.w),
        Icon(Icons.public, size: 12.sp, color: AppColors.kGreyB3),
        Gap(4.w),
        Text(
          comment.timeAgo,
          style: Styles.textStyle12.copyWith(color: AppColors.kGreyB3),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        // Like Button
        InkWell(
          onTap: () {
            context.read<PostDetailsCubit>().toggleLike(isReply, comment.id);
          },
          child: Row(
            children: [
              AppImage(
                AssetsData.loveDefault,
                height: 18.w,
                width: 18.w,
                color: comment.isLiked ? Colors.red : const Color(0xFFB3B3B3),
              ),
            ],
          ),
        ),
        Gap(4.w),
        Text(
          "${comment.likes}",
          style: Styles.textStyle12.copyWith(color: Colors.grey.shade600),
        ),

        // Reply Button (Only if not already a reply)
        if (!isReply) ...[
          Gap(10.w),
          const Text("•", style: TextStyle(color: Colors.black)),
          Gap(10.w),
          InkWell(
            onTap: onReplyTap,
            child: Text(
              context.tr(AppStrings.reply),
              style: Styles.textStyle14.copyWith(
                color: isReplyingState
                    ? const Color(0xFFD65A73)
                    : const Color(0xFF4267B2),
                fontWeight: isReplyingState
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],

        // Edit Button (Only if owner)
        if (comment.isOwner) ...[
          Gap(10.w),
          const Text("•", style: TextStyle(color: Colors.black)),
          Gap(10.w),
          InkWell(
            onTap: onEditTap,
            child: Text(
              context.tr(AppStrings.edit),
              style: Styles.textStyle14.copyWith(color: HexColor("#06A62D")),
            ),
          ),
        ],
      ],
    );
  }
}
