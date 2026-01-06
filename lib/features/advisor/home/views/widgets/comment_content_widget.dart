import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/widgets/follow_button.dart';
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
          SizedBox(
            height: isReply ? 32.r : 40.r,
            width: isReply ? 32.r : 40.r,
            child: ClipOval(child: AppImage(comment.avatar, fit: BoxFit.cover)),
          ),
          Gap(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.name,
                      style: Styles.textStyle16SemiBold.copyWith(
                        color: const Color(0xFF19295C),
                      ),
                    ),
                    Gap(4.w),
                    if (comment.isVerified)
                      Icon(Icons.verified, color: Colors.blue, size: 14.sp),
                    Gap(4.w),
                    FollowButton(),
                    const Spacer(),
                    Icon(
                      Icons.more_vert,
                      color: Colors.grey.shade400,
                      size: 20.sp,
                    ),
                  ],
                ),
                Row(
                  spacing: 4.w,
                  children: [
                    Text(
                      comment.userName,
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.kGreyB3,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    Icon(Icons.public, size: 12.sp, color: AppColors.kGreyB3),
                    Text(
                      comment.timeAgo,
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.kGreyB3,
                      ),
                    ),
                  ],
                ),
                Gap(6.h),
                Text(
                  contentDisplay,
                  style: Styles.textStyle14.copyWith(
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
                Gap(8.h),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        context.read<PostDetailsCubit>().toggleLike(comment.id);
                      },
                      child: Row(
                        children: [
                          AppImage(
                            AssetsData.loveDefault,
                            height: 18.w,
                            width: 18.w,
                            color: comment.isLiked
                                ? Colors.red
                                : const Color(0xFFB3B3B3),
                          ),
                        ],
                      ),
                    ),
                    Gap(4.w),
                    Text(
                      "${comment.likesCount}",
                      style: Styles.textStyle12.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
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
                    Gap(10.w),
                    const Text("•", style: TextStyle(color: Colors.black)),
                    Gap(10.w),
                    if (comment.isOwner)
                      InkWell(
                        onTap: onEditTap,
                        child: Text(
                          context.tr(AppStrings.edit),
                          style: Styles.textStyle14.copyWith(
                            color: HexColor("#06A62D"),
                          ),
                        ),
                      ),
                  ],
                ),
                Gap(5.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
