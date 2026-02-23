// lib/core/widgets/comment_card/comment_actions_menu.dart

import 'package:tayseer/core/widgets/comment_card/comment_callbacks.dart';
import 'package:tayseer/my_import.dart';

typedef CommentMenuCallback = void Function(CommentMenuAction action);

enum CommentMenuAction { edit, delete, reply, report, hide }

class CommentActionsMenu extends StatelessWidget {
  final bool isOwner;
  final bool isReply;
  final String commentId;
  final CommentCallbacks callbacks;

  const CommentActionsMenu({
    super.key,
    required this.isOwner,
    required this.isReply,
    required this.commentId,
    required this.callbacks,
  });

  void _handleAction(CommentMenuAction action) {
    // Use Future.delayed to allow the popup menu to finish closing
    // before triggering state changes that rebuild the layout
    Future.delayed(const Duration(milliseconds: 100), () {
      switch (action) {
        case CommentMenuAction.edit:
          callbacks.onEditToggle?.call(commentId);
          break;
        case CommentMenuAction.delete:
          if (isReply) {
            callbacks.onDeleteReply?.call(commentId);
          } else {
            callbacks.onDeleteComment?.call(commentId);
          }
          break;
        case CommentMenuAction.reply:
          callbacks.onReplyToggle?.call(commentId);
          break;
        case CommentMenuAction.report:
          callbacks.onReport?.call(commentId);
          break;
        case CommentMenuAction.hide:
          if (isReply) {
            callbacks.onHideReply?.call(commentId);
          } else {
            callbacks.onHideComment?.call(commentId);
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<CommentMenuAction>(
      elevation: 0,
      padding: EdgeInsets.zero,
      color: AppColors.secondary50,
      // icon: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20.sp),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26.r)),
      onSelected: _handleAction,
      child: Container(
        // ممكن تشيل الـ color: Colors.transparent لو مش محتاجه، بس مفيد للضغط
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 4.h,
        ), // 👈 صغر القيم دي براحتك
        child: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20.sp),
      ),
      itemBuilder: (_) =>
          isOwner ? _buildOwnerItems(context) : _buildGuestItems(context),
    );
  }

  List<PopupMenuEntry<CommentMenuAction>> _buildOwnerItems(
    BuildContext context,
  ) {
    return [
      _buildMenuItem(
        action: CommentMenuAction.edit,
        title: context.tr(AppStrings.edit),
        icon: Icons.edit_outlined,
      ),
      _buildMenuItem(
        action: CommentMenuAction.delete,
        title: context.tr(AppStrings.delete),
        icon: Icons.delete_outline,
        isDestructive: true,
        isLast: true,
      ),
    ];
  }

  List<PopupMenuEntry<CommentMenuAction>> _buildGuestItems(
    BuildContext context,
  ) {
    return [
      _buildMenuItem(
        action: CommentMenuAction.reply,
        title: context.tr(AppStrings.reply),
        icon: Icons.reply,
      ),
      _buildMenuItem(
        action: CommentMenuAction.report,
        title: context.tr(AppStrings.report),
        icon: Icons.info_outline,
      ),
      _buildMenuItem(
        action: CommentMenuAction.hide,
        title: context.tr(AppStrings.hide),
        icon: Icons.disabled_by_default_outlined,
        isLast: true,
      ),
    ];
  }

  PopupMenuItem<CommentMenuAction> _buildMenuItem({
    required CommentMenuAction action,
    required String title,
    required IconData icon,
    bool isDestructive = false,
    bool isLast = false,
  }) {
    final color = isDestructive ? AppColors.kRedColor : AppColors.secondary800;

    return PopupMenuItem<CommentMenuAction>(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      value: action,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : BorderSide(color: AppColors.secondary100, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.sp),
            Gap(12.w),
            Text(
              title,
              style: Styles.textStyle16SemiBold.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
