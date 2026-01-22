import 'package:tayseer/core/widgets/comment_card/comment_callbacks.dart';
import 'package:tayseer/core/widgets/comment_card/comment_content.dart';
import 'package:tayseer/core/widgets/comment_card/comment_input_editor.dart';
import 'package:tayseer/core/models/comment_model.dart';
import 'package:tayseer/my_import.dart';

class CommentCard extends StatelessWidget {
  final CommentModel comment;
  final CommentCallbacks callbacks;
  final bool isReply,
      isEditing,
      isReplying,
      isEditLoading,
      isReplyLoading,
      isLoadingReplies;

  const CommentCard({
    super.key,
    required this.comment,
    required this.callbacks,
    this.isReply = false,
    this.isEditing = false,
    this.isReplying = false,
    this.isEditLoading = false,
    this.isReplyLoading = false,
    this.isLoadingReplies = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentBody(context),
        if (isReplying && !isEditing) _buildReplyInput(context),
        _buildRepliesList(context),
      ],
    );
  }

  Widget _buildCommentBody(BuildContext context) {
    if (isEditing) {
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
      callbacks: callbacks, // ✅ تمرير للأسفل
    );
  }

  Widget _buildReplyInput(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 40.w, top: 10.h),
      child: CommentInputEditor(
        initialText: '',
        buttonText: context.tr(AppStrings.sendReply),
        isLoading: isReplyLoading,
        onCancel: () => callbacks.onCancelReply?.call(),
        onSubmit: (text) => callbacks.onSendReply?.call(comment.id, text),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Replies List
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildRepliesList(BuildContext context) {
    // Case 1: Replies loaded
    if (comment.replies.isNotEmpty) {
      return Padding(
        padding: EdgeInsetsDirectional.only(start: 40.w, top: 15.h),
        child: Column(
          children: [
            // Replies List
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: comment.replies.length,
              separatorBuilder: (_, __) => Gap(15.h),
              itemBuilder: (_, index) => _ReplyItem(
                reply: comment.replies[index],
                callbacks: callbacks,
              ),
            ),

            // Load More Button
            if (comment.hasMoreReplies)
              _LoadMoreButton(
                isLoading: isLoadingReplies,
                onTap: () => callbacks.onLoadReplies?.call(comment.id),
              ),
          ],
        ),
      );
    }

    // Case 2: Has replies but not loaded yet
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
// Reply Item (Simplified for replies - no nested replies)
// ══════════════════════════════════════════════════════════════════════════════

class _ReplyItem extends StatelessWidget {
  final CommentModel reply;
  final CommentCallbacks callbacks;

  const _ReplyItem({
    required this.reply,
    this.callbacks = CommentCallbacks.empty,
  });

  @override
  Widget build(BuildContext context) {
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
          'عرض $repliesCount ردود',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
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
                'عرض المزيد من الردود',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ),
    );
  }
}
