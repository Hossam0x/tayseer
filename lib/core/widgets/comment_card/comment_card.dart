import 'package:tayseer/core/widgets/comment_card/comment_avatar.dart';
import 'package:tayseer/core/widgets/comment_card/comment_callbacks.dart';
import 'package:tayseer/core/widgets/comment_card/comment_content.dart';
import 'package:tayseer/core/widgets/comment_card/comment_input_editor.dart';
import 'package:tayseer/core/models/comment_model.dart';
import 'package:tayseer/my_import.dart';

class CommentCard extends StatelessWidget {
  final CommentModel comment;
  final CommentCallbacks callbacks;
  final String? editingCommentId;
  final bool isReply,
      isReplying,
      isEditLoading,
      isReplyLoading,
      isLoadingReplies;

  const CommentCard({
    super.key,
    required this.comment,
    required this.callbacks,
    this.isReply = false,
    this.editingCommentId,
    this.isReplying = false,
    this.isEditLoading = false,
    this.isReplyLoading = false,
    this.isLoadingReplies = false,
  });

  @override
  Widget build(BuildContext context) {
    if (comment.isHidden) {
      return _HiddenCommentWidget(
        isReply: isReply,
        comment: comment,
        onUnhide: () => isReply
            ? callbacks.onHideReply?.call(comment.id)
            : callbacks.onHideComment?.call(comment.id),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentBody(context),
        if (isReplying && editingCommentId != comment.id)
          _buildReplyInput(context),
        _buildRepliesList(context),
      ],
    );
  }

  Widget _buildCommentBody(BuildContext context) {
    if (editingCommentId == comment.id) {
      return CommentInputEditor(
        initialText: comment.comment,
        buttonText: context.tr(AppStrings.saveEdit),
        isLoading: isEditLoading,
        onCancel: () => callbacks.onCancelEdit?.call(),
        onSubmit: (text) =>
            callbacks.onSaveEdit?.call(comment.id, text, isReply),
      );
    }
    return CommentContent(
      comment: comment,
      isReply: isReply,
      isReplying: isReplying,
      callbacks: callbacks,
    );
  }

  Widget _buildReplyInput(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 40.w, top: 10.h),
      child: CommentInputEditor(
        initialText: '',
        buttonText: context.tr(AppStrings.sendReply),
        isLoading: isReplyLoading,
        showAnonymousToggle: isUser,
        onCancel: () => callbacks.onCancelReply?.call(),
        onSubmit: (text) => callbacks.onSendReply?.call(comment.id, text),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Replies List
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildRepliesList(BuildContext context) {
    if (comment.replies.isNotEmpty) {
      return Padding(
        padding: EdgeInsetsDirectional.only(start: 40.w, top: 15.h),
        child: Column(
          children: [
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: comment.replies.length,
              separatorBuilder: (_, __) => Gap(15.h),
              itemBuilder: (_, index) => _ReplyItem(
                reply: comment.replies[index],
                callbacks: callbacks,
                editingCommentId: editingCommentId,
                isEditLoading: isEditLoading,
              ),
            ),
            if (comment.hasMoreReplies)
              _LoadMoreButton(
                isLoading: isLoadingReplies,
                onTap: () => callbacks.onLoadReplies?.call(comment.id),
              ),
          ],
        ),
      );
    }

    if (comment.repliesNumber > 0 && comment.replies.isEmpty) {
      return Padding(
        padding: EdgeInsetsDirectional.only(start: 40.w),
        child: _ShowRepliesButton(
          repliesCount: comment.repliesNumber,
          isLoading: isLoadingReplies,
          onTap: () => callbacks.onLoadReplies?.call(comment.id),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 🎨 Hidden Comment Widget (UI مطابق للصورة)
// ══════════════════════════════════════════════════════════════════════════════

class _HiddenCommentWidget extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback? onUnhide;
  final bool isReply;

  const _HiddenCommentWidget({
    required this.comment,
    this.onUnhide,
    required this.isReply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CommentAvatar(
                isAnnonymous: comment.commenter.isAnnonymous,
                avatarUrl: comment.commenter.avatar,
                isReply: isReply,
              ),
              Gap(10.w),

              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.commenter.isAnnonymous
                            ? context.tr(AppStrings.anonymous)
                            : comment.commenter.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Styles.textStyle16SemiBold.copyWith(
                          color: const Color(0xFF19295C),
                        ),
                      ),
                    ),
                    Gap(4.w),
                    if (comment.commenter.isVerified &&
                        !comment.commenter.isAnnonymous)
                      Icon(Icons.verified, color: Colors.blue, size: 14.sp),

                    Gap(4.w),
                    Text(
                      comment.timeAgo,
                      style: Styles.textStyle12.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Gap(4.w),
                  ],
                ),
              ),

              InkWell(
                onTap: onUnhide,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ).r,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    context.tr(AppStrings.unhide),
                    style: Styles.textStyle12.copyWith(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),

          // Row 2: Red Icon & Message
          Row(
            children: [
              Gap(40.w),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red, // لون أحمر غامق (Crimson)
                ),
                padding: EdgeInsets.all(4.r),
                child: Icon(Icons.close, color: Colors.white, size: 14.sp),
              ),
              Gap(8.w),
              Text(
                context.tr(AppStrings.commentHiddenMessage),
                style: Styles.textStyle14.copyWith(color: Colors.grey.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Reply Item
// ══════════════════════════════════════════════════════════════════════════════

class _ReplyItem extends StatelessWidget {
  final CommentModel reply;
  final CommentCallbacks callbacks;
  final String? editingCommentId;
  final bool isEditLoading;

  const _ReplyItem({
    required this.reply,
    this.callbacks = CommentCallbacks.empty,
    this.editingCommentId,
    this.isEditLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ 2. التحقق من حالة الإخفاء للرد (Reply)
    if (reply.isHidden) {
      return _HiddenCommentWidget(
        isReply: true,
        comment: reply,
        onUnhide: () => callbacks.onHideReply?.call(reply.id),
      );
    }

    if (editingCommentId == reply.id) {
      return CommentInputEditor(
        initialText: reply.comment,
        buttonText: context.tr(AppStrings.saveEdit),
        isLoading: isEditLoading,
        onCancel: () => callbacks.onCancelEdit?.call(),
        onSubmit: (text) => callbacks.onSaveEdit?.call(reply.id, text, true),
      );
    }

    return CommentContent(
      comment: reply,
      isReply: true,
      isReplying: false,
      callbacks: callbacks,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Show Replies Button
// ══════════════════════════════════════════════════════════════════════════════

class _ShowRepliesButton extends StatelessWidget {
  final int repliesCount;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ShowRepliesButton({
    required this.repliesCount,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 20.w,
        height: 20.w,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(
          Icons.subdirectory_arrow_left,
          size: 16.sp,
          color: Colors.grey.shade600,
        ),
        label: Text(
          // ✅ التعديل هنا: نترجم النص أولاً ثم نستبدل العلامة {} بالرقم
          context
              .tr(AppStrings.showNReplies)
              .replaceFirst('{}', '$repliesCount'),

          style: Styles.textStyle12SemiBold.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Load More Button
// ══════════════════════════════════════════════════════════════════════════════

class _LoadMoreButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _LoadMoreButton({required this.isLoading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: isLoading
          ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                context.tr(AppStrings.showMoreReplies),
                style: Styles.textStyle12SemiBold.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
    );
  }
}
