import 'package:flutter_bloc/flutter_bloc.dart';
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
      children: [
        BlocSelector<PostDetailsCubit, PostDetailsState, bool>(
          selector: (state) {
            return state is PostDetailsLoaded &&
                state.editingCommentId == comment.id;
          },
          builder: (context, isEditing) {
            if (isEditing) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: CommentInputEditorWidget(
                  key: const ValueKey('edit_mode'),
                  initialText: comment.content,
                  btnText: context.tr(AppStrings.saveEdit),
                  onCancel: () {
                    context.read<PostDetailsCubit>().cancelEdit();
                  },
                  onSave: (newText) {
                    context.read<PostDetailsCubit>().saveEditedComment(
                      comment.id,
                      newText,
                    );
                  },
                ),
              );
            }
            return BlocSelector<PostDetailsCubit, PostDetailsState, bool>(
              selector: (state) {
                return state is PostDetailsLoaded &&
                    state.activeReplyId == comment.id;
              },
              builder: (context, isReplyingToThis) {
                return CommentContentWidget(
                  comment: comment,
                  contentDisplay: comment.content,
                  isReply: isReply,
                  isReplyingState: isReplyingToThis,
                  onReplyTap: () {
                    context.read<PostDetailsCubit>().toggleReply(comment.id);
                  },
                  onEditTap: () {
                    context.read<PostDetailsCubit>().toggleEdit(comment.id);
                  },
                );
              },
            );
          },
        ),
        BlocSelector<PostDetailsCubit, PostDetailsState, bool>(
          selector: (state) {
            return state is PostDetailsLoaded &&
                state.activeReplyId == comment.id &&
                state.editingCommentId != comment.id;
          },
          builder: (context, showReplyInput) {
            if (showReplyInput) {
              return Padding(
                padding: EdgeInsetsDirectional.only(
                  start: isReply ? 40.w : 0,
                  top: 10.h,
                ),
                child: CommentInputEditorWidget(
                  key: const ValueKey('reply_mode'),
                  initialText: "",
                  btnText: context.tr(AppStrings.sendReply),
                  onCancel: () {
                    context.read<PostDetailsCubit>().cancelReply();
                  },
                  onSave: (text) {
                    print("New Reply: $text");
                    context.read<PostDetailsCubit>().cancelReply();
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        if (comment.replies.isNotEmpty)
          Padding(
            padding: EdgeInsetsDirectional.only(start: 40.w, top: 15.h),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: comment.replies.length,
              separatorBuilder: (c, i) => Gap(15.h),
              itemBuilder: (context, index) {
                return CommentItemWidget(
                  comment: comment.replies[index],
                  isReply: true,
                );
              },
            ),
          ),
      ],
    );
  }
}
