import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/my_import.dart';

/// Helper class للـ dialogs المشتركة في chat rooms
/// يستخدم CustomshowDialogWithImage
class ChatRoomDialogHelper {
  /// عرض dialog تأكيد الحذف
  static void showDeleteDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    String? title,
    String? subtitle,
  }) {
    CustomshowDialogWithImage(
      context,
      imageUrl: AssetsData.deleteIcon,
      title: title ?? context.tr('delete_chat'),
      supTitle: subtitle ?? context.tr('delete_chat_confirm'),
      bottonText: context.tr('yes'),
      showCancelButton: true,
      cancelText: context.tr('no'),
      onPressed: onConfirm,
      onCancel: () {},
    );
  }

  /// عرض dialog تأكيد الأرشفة
  static void showArchiveDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    String? title,
    String? subtitle,
  }) {
    CustomshowDialogWithImage(
      context,
      imageUrl: AssetsData.chatArchiveIcon,
      title: title ?? context.tr('archive_chat'),
      supTitle: subtitle ?? context.tr('archive_chat_confirm'),
      bottonText: context.tr('yes'),
      showCancelButton: true,
      cancelText: context.tr('no'),
      onPressed: onConfirm,
      onCancel: () {},
    );
  }

  /// عرض dialog تأكيد الإبلاغ
  static void showReportDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    String? title,
    String? subtitle,
  }) {
    CustomshowDialogWithImage(
      context,
      imageUrl: AssetsData.reportIcon,
      title: title ?? context.tr('report_menu'),
      supTitle: subtitle ?? context.tr('report_confirm_subtitle'),
      bottonText: context.tr('yes'),
      showCancelButton: true,
      cancelText: context.tr('no'),
      onPressed: onConfirm,
      onCancel: () {},
    );
  }

  /// عرض dialog تأكيد الحظر
  static void showBlockDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    String? title,
    String? subtitle,
  }) {
    CustomshowDialogWithImage(
      context,
      icon: Icons.block_outlined,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red.withOpacity(0.1),
      title: title ?? context.tr('block_label'),
      supTitle: subtitle ?? context.tr('block_confirm_subtitle'),
      bottonText: context.tr('yes'),
      showCancelButton: true,
      cancelText: context.tr('no'),
      onPressed: onConfirm,
      onCancel: () {},
    );
  }

  /// عرض dialog تأكيد إلغاء الحظر
  static void showUnblockDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    String? title,
    String? subtitle,
  }) {
    CustomshowDialogWithImage(
      context,
      icon: Icons.lock_open_outlined,
      iconColor: Colors.green,
      iconBackgroundColor: Colors.green.withOpacity(0.1),
      title: title ?? context.tr('unblock_label'),
      supTitle: subtitle ?? context.tr('unblock_confirm_subtitle'),
      bottonText: context.tr('yes'),
      showCancelButton: true,
      cancelText: context.tr('no'),
      onPressed: onConfirm,
      onCancel: () {},
    );
  }

  /// عرض dialog تأكيد إلغاء التوافق
  static void showCancelMatchDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    String? title,
    String? subtitle,
  }) {
    CustomshowDialogWithImage(
      context,
      imageUrl: AssetsData.kWoriningImage,
      title: title ?? context.tr('cancel_match_title'),
      supTitle: subtitle ?? context.tr('cancel_match_confirm'),
      bottonText: context.tr('yes'),
      showCancelButton: true,
      cancelText: context.tr('no'),
      onPressed: onConfirm,
      onCancel: () {},
    );
  }
}
