import 'package:flutter/services.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/advisor/home/model/comment_model.dart';
import 'package:tayseer/features/advisor/profille/data/models/reply_comment_model.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/comments_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/comments_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/comments_state.dart';
import 'package:tayseer/my_import.dart';

class CommentsTab extends StatelessWidget {
  const CommentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommentsCubit>(
      create: (_) => getIt<CommentsCubit>(),
      child: const _CommentsTabContent(),
    );
  }
}

class _CommentsTabContent extends StatelessWidget {
  const _CommentsTabContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentsCubit, CommentsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.kRedColor,
            ),
          );
          context.read<CommentsCubit>().clearError();
        }
      },
      builder: (context, state) {
        switch (state.state) {
          case CubitStates.loading:
            return _buildSkeletonComments();
          case CubitStates.failure:
            return _buildErrorComments(context, state.errorMessage);
          case CubitStates.success:
            if (state.comments.isEmpty) {
              return const SharedEmptyState(title: "لا توجد تعليقات");
            }
            return _buildCommentsContent(context, state);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildSkeletonComments() {
    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          children: List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      Gap(4.w),
                      Container(
                        width: 50.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ],
                  ),
                  Gap(12.h),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 45.w,
                              height: 45.h,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Gap(12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 80.w,
                                      height: 16.h,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                    ),
                                    Gap(4.w),
                                    Container(
                                      width: 16.w,
                                      height: 16.h,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                                Gap(4.h),
                                Container(
                                  width: 120.w,
                                  height: 12.h,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  Gap(12.h),
                  // Comment text
                  Container(
                    width: double.infinity,
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  Gap(12.h),
                  // Actions
                  Container(
                    width: 100.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorComments(BuildContext context, String? errorMessage) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
          Gap(16.h),
          Text(
            errorMessage ?? 'حدث خطأ في تحميل التعليقات',
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
            onPressed: () => context.read<CommentsCubit>().refresh(),
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

  Widget _buildCommentsContent(BuildContext context, CommentsState state) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          if (state.hasMore && !state.isLoadingMore) {
            context.read<CommentsCubit>().fetchComments(loadMore: true);
          }
        }
        return false;
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            // قائمة التعليقات
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              itemCount: state.comments.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (context, index) => Gap(16.h),
              itemBuilder: (context, index) {
                if (index == state.comments.length) {
                  return _buildLoadMoreIndicator(state);
                }

                final comment = state.comments[index];
                return _buildCommentItem(context, comment, state.isMe);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(
    BuildContext context,
    CommentModel comment,
    bool isMe,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Text(
                'أرسل إليك',
                style: Styles.textStyle12.copyWith(color: AppColors.hintText),
              ),
              Gap(4.h),
              Text(
                comment.commenter.userName,
                style: Styles.textStyle12.copyWith(
                  color: AppColors.mentionComment,
                ),
              ),
            ],
          ),
          // Header مع الصورة والمعلومات
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // معلومات المستخدم
              Expanded(
                child: Row(
                  children: [
                    // الصورة الشخصية
                    SizedBox(
                      width: 45.w,
                      height: 45.h,
                      child: CircleAvatar(
                        radius: 18.r,
                        backgroundColor: const Color(0xFFE5E7EB),
                        backgroundImage: comment.commenter.avatar != null
                            ? NetworkImage(comment.commenter.avatar!)
                            : AssetImage(AssetsData.avatarImage)
                                  as ImageProvider,
                        child: comment.commenter.avatar == null
                            ? Icon(
                                Icons.person,
                                color: Colors.black38,
                                size: 20.sp,
                              )
                            : null,
                      ),
                    ),
                    Gap(12.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم المستخدم والعلامة الزرقاء
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              comment.commenter.name,
                              style: Styles.textStyle14Bold.copyWith(
                                color: const Color(0xFF111827),
                              ),
                            ),
                            Gap(4.h),
                            if (comment.commenter.isVerified)
                              Padding(
                                padding: EdgeInsets.only(left: 4.w),
                                child: Icon(
                                  Icons.verified,
                                  color: const Color(0xFF3B82F6),
                                  size: 16.sp,
                                ),
                              ),
                          ],
                        ),
                        // Username واليوزرنيم والوقت
                        Gap(4.h),
                        Row(
                          children: [
                            Text(
                              comment.commenter.userName,
                              style: Styles.textStyle14.copyWith(
                                color: AppColors.secondary300,
                              ),
                            ),
                            Gap(8.w),
                            Icon(
                              Icons.public,
                              size: 14.w,
                              color: AppColors.hintText,
                            ),
                            Gap(4.w),
                            Text(
                              comment.timeAgo,
                              style: Styles.textStyle10.copyWith(
                                color: AppColors.hintText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // زر النقاط الثلاث
              GestureDetector(
                onTap: () {
                  _showCommentOptions(context, comment, isMe);
                },
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Icon(
                    Icons.more_vert,
                    color: AppColors.hintText,
                    size: 22.sp,
                  ),
                ),
              ),
            ],
          ),
          Gap(4.h),

          // نص التعليق
          Text(
            comment.comment,
            style: Styles.textStyle14.copyWith(color: AppColors.blackColor),
          ),

          Gap(12.h),

          // الأكشن (إعجابك والرد)
          Row(
            children: [
              // أيقونة القلب وعدد الإعجابات
              InkWell(
                onTap: () {
                  context.read<CommentsCubit>().toggleLikeComment(comment.id);
                },
                child: Row(
                  children: [
                    Icon(
                      comment.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: comment.isLiked ? Colors.red : AppColors.hintText,
                      size: 22.sp,
                    ),
                    Gap(4.w),
                    Text(
                      '${comment.likes}',
                      style: Styles.textStyle14.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap(4.w),
                    Text(
                      'إعجابك',
                      style: Styles.textStyle14.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              Gap(12.w),
              // فاصلة
              Text(
                '•',
                style: Styles.textStyle14.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
              Gap(12.w),

              // عرض الردود
              if (comment.repliesNumber > 0)
                InkWell(
                  onTap: () {
                    _showRepliesDialog(context, comment);
                  },
                  child: Text(
                    '${comment.repliesNumber} رد',
                    style: Styles.textStyle14.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
            ],
          ),
          Gap(16.h),
          Divider(color: AppColors.whiteCardBack, height: 4.h),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator(CommentsState state) {
    if (!state.hasMore) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: state.isLoadingMore
            ? CircularProgressIndicator(color: AppColors.kprimaryColor)
            : Container(),
      ),
    );
  }

  void _showCommentOptions(
    BuildContext context,
    CommentModel comment,
    bool isMe,
  ) {
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
              Gap(16.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Gap(24.h),

              // زر نسخ التعليق
              _buildOptionItem(
                context: context,
                icon: Icons.copy_outlined,
                text: "نسخ التعليق",
                onTap: () {
                  Navigator.pop(context);
                  _copyComment(context, comment);
                },
              ),

              // زر مشاركة التعليق
              _buildOptionItem(
                context: context,
                icon: Icons.share_outlined,
                text: "مشاركة التعليق",
                onTap: () {
                  Navigator.pop(context);
                  _shareComment(context, comment);
                },
              ),

              // زر الرد على التعليق
              _buildOptionItem(
                context: context,
                icon: Icons.reply_outlined,
                text: "الرد على التعليق",
                onTap: () {
                  Navigator.pop(context);
                  _replyToComment(context, comment);
                },
              ),

              // زر حذف التعليق (فقط إذا كان التعليق للمستخدم)
              if (isMe || comment.isOwner)
                _buildOptionItem(
                  context: context,
                  icon: Icons.delete_outlined,
                  text: "حذف التعليق",
                  textColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _deleteComment(context, comment);
                  },
                ),

              Gap(32.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black, size: 22.sp),
      title: Text(
        text,
        style: Styles.textStyle14.copyWith(
          color: textColor ?? Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
    );
  }

  void _showRepliesDialog(BuildContext context, CommentModel comment) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: BlocProvider<RepliesCubit>(
            create: (_) =>
                RepliesCubit(getIt<CommentsRepository>(), comment.id),
            child: _RepliesDialogContent(comment: comment),
          ),
        );
      },
    );
  }

  // دالة نسخ التعليق
  void _copyComment(BuildContext context, CommentModel comment) {
    Clipboard.setData(ClipboardData(text: comment.comment));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "تم نسخ التعليق",
          style: Styles.textStyle14.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // دالة مشاركة التعليق
  void _shareComment(BuildContext context, CommentModel comment) {
    // TODO: تنفيذ المشاركة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "جاري مشاركة التعليق...",
          style: Styles.textStyle14.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.kprimaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // دالة الرد على التعليق
  void _replyToComment(BuildContext context, CommentModel comment) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            "الرد على التعليق",
            style: Styles.textStyle16Bold.copyWith(color: AppColors.blackColor),
            textAlign: TextAlign.center,
          ),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "اكتب ردك هنا...",
              hintStyle: Styles.textStyle14.copyWith(
                color: Colors.grey.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "إلغاء",
                      style: Styles.textStyle14.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kprimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return BlocProvider.value(
                            value: context.read<RepliesCubit>(),
                            child: BlocBuilder<RepliesCubit, RepliesState>(
                              builder: (context, state) {
                                return AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(
                                        color: AppColors.kprimaryColor,
                                      ),
                                      Gap(16.h),
                                      Text(
                                        'جاري إرسال الرد...',
                                        style: Styles.textStyle14,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );

                      await context.read<RepliesCubit>().createReply(
                        controller.text,
                      );

                      Navigator.pop(context);
                    },
                    child: Text(
                      "إرسال",
                      style: Styles.textStyle14Bold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // دالة حذف التعليق
  void _deleteComment(BuildContext context, CommentModel comment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            "حذف التعليق",
            style: Styles.textStyle16Bold.copyWith(color: AppColors.blackColor),
            textAlign: TextAlign.center,
          ),
          content: Text(
            "هل أنت متأكد من حذف هذا التعليق؟ لا يمكن التراجع عن هذه الخطوة.",
            style: Styles.textStyle14.copyWith(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "إلغاء",
                      style: Styles.textStyle14.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<CommentsCubit>().deleteComment(comment.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "تم حذف التعليق بنجاح",
                            style: Styles.textStyle14.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Text(
                      "حذف",
                      style: Styles.textStyle14Bold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _RepliesDialogContent extends StatelessWidget {
  final CommentModel comment;

  const _RepliesDialogContent({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الردود', style: Styles.textStyle18Bold),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 24.sp),
                ),
              ],
            ),
          ),
          Divider(height: 1),

          // Replies list
          Expanded(
            child: BlocBuilder<RepliesCubit, RepliesState>(
              builder: (context, state) {
                if (state.state == CubitStates.loading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state.state == CubitStates.failure) {
                  return Center(child: Text(state.errorMessage ?? 'حدث خطأ'));
                }

                if (state.replies.isEmpty) {
                  return Center(child: Text('لا توجد ردود بعد'));
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: state.replies.length,
                  itemBuilder: (context, index) {
                    final reply = state.replies[index];
                    return _buildReplyItem(context, reply);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyItem(BuildContext context, ReplyModel reply) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundImage: reply.commenter.avatar != null
                ? NetworkImage(reply.commenter.avatar!)
                : null,
            child: reply.commenter.avatar == null
                ? Icon(Icons.person, size: 18.sp)
                : null,
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(reply.commenter.name, style: Styles.textStyle14Bold),
                    Text(
                      reply.timeAgo,
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.hintText,
                      ),
                    ),
                  ],
                ),
                Gap(4.h),
                Text(reply.comment, style: Styles.textStyle14),
                Gap(8.h),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        context.read<RepliesCubit>().toggleLikeReply(reply.id);
                      },
                      child: Row(
                        children: [
                          Icon(
                            reply.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: reply.isLiked
                                ? Colors.red
                                : AppColors.hintText,
                            size: 18.sp,
                          ),
                          Gap(4.w),
                          Text('${reply.likes}'),
                        ],
                      ),
                    ),
                    if (reply.isOwner)
                      Row(
                        children: [
                          Gap(16.w),
                          InkWell(
                            onTap: () {
                              _deleteReply(context, reply);
                            },
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 18.sp,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _deleteReply(BuildContext context, ReplyModel reply) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('حذف الرد'),
          content: Text('هل تريد حذف هذا الرد؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<RepliesCubit>().deleteReply(reply.id);
              },
              child: Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
