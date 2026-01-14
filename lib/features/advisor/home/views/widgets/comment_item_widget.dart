import 'package:tayseer/features/advisor/home/model/comment_model.dart';
import 'package:tayseer/features/advisor/home/view_model/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/features/advisor/home/views/widgets/comment_content_widget.dart';
import 'package:tayseer/features/advisor/home/views/widgets/comment_input_editor_widget.dart';
import 'package:tayseer/my_import.dart';

class CommentItemWidget extends StatelessWidget {
  final CommentModel comment;
  final bool isReply;

  const CommentItemWidget({
    super.key,
    required this.comment,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. عرض المحتوى أو وضع التعديل
        _CommentBodySection(comment: comment, isReply: isReply),

        // 2. خانة إضافة رد (تظهر وتختفي)
        _ReplyInputSection(comment: comment),

        // 3. قائمة الردود والباجينشن
        _RepliesListSection(comment: comment),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 📌 SECTION 1: COMMENT BODY / EDIT EDITOR
// ═══════════════════════════════════════════════════════════
class _CommentBodySection extends StatelessWidget {
  final CommentModel comment;
  final bool isReply;

  const _CommentBodySection({required this.comment, required this.isReply});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostDetailsCubit, PostDetailsState>(
      // Performance Optimization: Rebuild only if editing/replying to THIS comment changes
      buildWhen: (previous, current) {
        final isEditingThis =
            current.editingCommentId == comment.id ||
            previous.editingCommentId == comment.id;
        final isReplyingToThis =
            current.activeReplyId == comment.id ||
            previous.activeReplyId == comment.id;
        final loadingChanged = previous.editingState != current.editingState;

        // Rebuild if interaction status changed OR if loading state changed while editing this specific comment
        return isEditingThis ||
            isReplyingToThis ||
            (isEditingThis && loadingChanged);
      },
      builder: (context, state) {
        final isEditing = state.editingCommentId == comment.id;

        // A. Edit Mode
        if (isEditing) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: CommentInputEditorWidget(
              key: const ValueKey('edit_mode'),
              initialText: comment.comment,
              btnText: context.tr(AppStrings.saveEdit),
              isLoading: state.editingState == CubitStates.loading,
              onCancel: () {
                context.read<PostDetailsCubit>().cancelEdit();
              },
              onSave: (newText) {
                context.read<PostDetailsCubit>().saveEditedComment(
                  commentId: comment.id,
                  newContent: newText,
                  isReply: isReply,
                );
              },
            ),
          );
        }

        // B. View Mode
        return CommentContentWidget(
          comment: comment,
          contentDisplay: comment.comment,
          isReply: isReply,
          isReplyingState: state.activeReplyId == comment.id,
          onReplyTap: () {
            context.read<PostDetailsCubit>().toggleReply(comment.id);
          },
          onEditTap: () {
            context.read<PostDetailsCubit>().toggleEdit(comment.id);
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 📌 SECTION 2: REPLY INPUT
// ═══════════════════════════════════════════════════════════
class _ReplyInputSection extends StatelessWidget {
  final CommentModel comment;

  const _ReplyInputSection({required this.comment});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostDetailsCubit, PostDetailsState>(
      buildWhen: (previous, current) {
        final isReplyingToThis =
            current.activeReplyId == comment.id ||
            previous.activeReplyId == comment.id;
        final loadingChanged =
            previous.addingReplyState != current.addingReplyState;

        return isReplyingToThis ||
            (current.activeReplyId == comment.id && loadingChanged);
      },
      builder: (context, state) {
        // Show input ONLY if activeReplyId matches AND we are not in edit mode for the same comment
        final showReplyInput =
            state.activeReplyId == comment.id &&
            state.editingCommentId != comment.id;

        if (!showReplyInput) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsetsDirectional.only(start: 40.w, top: 10.h),
          child: CommentInputEditorWidget(
            key: const ValueKey('reply_mode'),
            initialText: "",
            btnText: context.tr(AppStrings.sendReply),
            isLoading: state.addingReplyState == CubitStates.loading,
            onCancel: () {
              context.read<PostDetailsCubit>().cancelReply();
            },
            onSave: (text) {
              context.read<PostDetailsCubit>().addReply(comment.id, text);
            },
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// 📌 SECTION 3: REPLIES LIST
// ═══════════════════════════════════════════════════════════
class _RepliesListSection extends StatelessWidget {
  final CommentModel comment;

  const _RepliesListSection({required this.comment});

  @override
  Widget build(BuildContext context) {
    // 1. Replies Available
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
              separatorBuilder: (c, i) => Gap(15.h),
              itemBuilder: (context, index) {
                return CommentItemWidget(
                  comment: comment.replies[index],
                  isReply: true,
                );
              },
            ),
            // Load More / Pagination
            if (comment.hasMoreReplies)
              _LoadMoreRepliesButton(comment: comment),
          ],
        ),
      );
    }

    // 2. Replies Count > 0 but not loaded
    if (comment.repliesNumber > 0 && comment.replies.isEmpty) {
      return Padding(
        padding: EdgeInsetsDirectional.only(start: 40.w, top: 10.h),
        child: comment.isLoadingReplies
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
            : Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () {
                    context.read<PostDetailsCubit>().loadReplies(comment.id);
                  },
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
                    'عرض ${comment.repliesNumber} ردود',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _LoadMoreRepliesButton extends StatelessWidget {
  final CommentModel comment;

  const _LoadMoreRepliesButton({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: comment.isLoadingReplies
          ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : TextButton(
              onPressed: () {
                context.read<PostDetailsCubit>().loadReplies(comment.id);
              },
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
