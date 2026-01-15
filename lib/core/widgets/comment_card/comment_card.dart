import 'dart:developer';

import 'package:tayseer/core/widgets/comment_card/comment_content.dart';
import 'package:tayseer/core/widgets/comment_card/comment_input_editor.dart';
import 'package:tayseer/features/advisor/home/model/comment_model.dart';
import 'package:tayseer/my_import.dart';

/// CommentCard - Reusable component for displaying comments
///
/// Completely decoupled from any specific Cubit.
/// All interactions are handled via callback functions.
///
/// Performance Features:
/// - Separated static and dynamic parts
/// - Uses callbacks instead of direct Cubit access
class CommentCard extends StatelessWidget {
  final CommentModel comment;
  final bool isReply;

  // State flags (passed from parent)
  final bool isEditing;
  final bool isReplying;
  final bool isEditLoading;
  final bool isReplyLoading;
  final bool isLoadingReplies;

  // Callbacks
  final VoidCallback? onLikeTap;
  final VoidCallback? onReplyTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onCancelEdit;
  final VoidCallback? onCancelReply;
  final void Function(String newContent)? onSaveEdit;
  final void Function(String replyText)? onSendReply;
  final VoidCallback? onLoadReplies;
  final void Function(CommentModel reply)? onLikeReply;

  const CommentCard({
    super.key,
    required this.comment,
    this.isReply = false,
    this.isEditing = false,
    this.isReplying = false,
    this.isEditLoading = false,
    this.isReplyLoading = false,
    this.isLoadingReplies = false,
    this.onLikeTap,
    this.onReplyTap,
    this.onEditTap,
    this.onCancelEdit,
    this.onCancelReply,
    this.onSaveEdit,
    this.onSendReply,
    this.onLoadReplies,
    this.onLikeReply,
  });

  @override
  Widget build(BuildContext context) {
    log(">>>>>>>>>>>>>>${comment.comment}");
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comment Body or Edit Mode
        _buildCommentBody(context),

        // Reply Input (if replying to this comment)
        if (isReplying && !isEditing) _buildReplyInput(context),

        // Replies List
        _buildRepliesList(context),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Comment Body (View or Edit Mode)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildCommentBody(BuildContext context) {
    if (isEditing) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: CommentInputEditor(
          key: const ValueKey('edit_mode'),
          initialText: comment.comment,
          buttonText: context.tr(AppStrings.saveEdit),
          isLoading: isEditLoading,
          onCancel: onCancelEdit ?? () {},
          onSubmit: (text) => onSaveEdit?.call(text),
        ),
      );
    }

    return CommentContent(
      comment: comment,
      isReply: isReply,
      isReplying: isReplying,
      onLikeTap: onLikeTap,
      onReplyTap: onReplyTap,
      onEditTap: onEditTap,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Reply Input
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildReplyInput(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 40.w, top: 10.h),
      child: CommentInputEditor(
        key: const ValueKey('reply_mode'),
        initialText: '',
        buttonText: context.tr(AppStrings.sendReply),
        isLoading: isReplyLoading,
        onCancel: onCancelReply ?? () {},
        onSubmit: (text) => onSendReply?.call(text),
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
                onLikeTap: () => onLikeReply?.call(comment.replies[index]),
              ),
            ),

            // Load More Button
            if (comment.hasMoreReplies)
              _LoadMoreButton(
                isLoading: isLoadingReplies,
                onTap: onLoadReplies,
              ),
          ],
        ),
      );
    }

    // Case 2: Has replies but not loaded yet
    if (comment.repliesNumber > 0 && comment.replies.isEmpty) {
      return Padding(
        padding: EdgeInsetsDirectional.only(start: 40.w, top: 10.h),
        child: _ShowRepliesButton(
          repliesCount: comment.repliesNumber,
          isLoading: isLoadingReplies,
          onTap: onLoadReplies,
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
  final VoidCallback? onLikeTap;

  const _ReplyItem({required this.reply, this.onLikeTap});

  @override
  Widget build(BuildContext context) {
    return CommentContent(
      comment: reply,
      isReply: true,
      isReplying: false,
      onLikeTap: onLikeTap,
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
