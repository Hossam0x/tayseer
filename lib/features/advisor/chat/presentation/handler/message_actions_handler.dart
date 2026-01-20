import 'package:flutter/material.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_cubit.dart';

/// Handler for message-related actions (delete, reply, etc.)
/// Follows Single Responsibility Principle
class MessageActionsHandler {
  final BuildContext context;
  final ChatMessagesCubit messagesCubit;
  final MessageSelectionCubit selectionCubit;

  MessageActionsHandler({
    required this.context,
    required this.messagesCubit,
    required this.selectionCubit,
  });

  /// Show delete confirmation dialog for a single message
  Future<void> showDeleteConfirmationForSingleMessage({
    required ChatMessage message,
    required String deleteType,
  }) async {
    final isDeleteForAll = deleteType == 'everyone';
    final title = isDeleteForAll ? 'حذف لدى الجميع' : 'حذف لديّ';
    final content = isDeleteForAll
        ? 'هل أنت متأكد من حذف هذه الرسالة لدى الجميع؟'
        : 'هل أنت متأكد من حذف هذه الرسالة لديك فقط؟';

    final confirmed = await _showConfirmationDialog(
      title: title,
      content: content,
    );

    if (confirmed == true) {
      await _executeDelete(messageIds: [message.id], deleteType: deleteType);
    }
  }

  /// Show delete confirmation dialog for selected messages
  Future<void> showDeleteConfirmationForSelectedMessages({
    required String deleteType,
  }) async {
    final selectedIds = selectionCubit.getSelectedMessageIds();
    if (selectedIds.isEmpty) return;

    final isDeleteForAll = deleteType == 'everyone';
    final count = selectedIds.length;
    final title = isDeleteForAll ? 'حذف لدى الجميع' : 'حذف لديّ';
    final content = isDeleteForAll
        ? 'هل أنت متأكد من حذف $count رسالة لدى الجميع؟'
        : 'هل أنت متأكد من حذف $count رسالة لديك فقط؟';

    final confirmed = await _showConfirmationDialog(
      title: title,
      content: content,
    );

    if (confirmed == true) {
      await _executeDelete(messageIds: selectedIds, deleteType: deleteType);
      selectionCubit.exitSelectionMode();
    }
  }

  /// Show confirmation dialog
  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(content, style: const TextStyle(fontFamily: 'Cairo')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text(
                  'حذف',
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Execute delete operation
  Future<void> _executeDelete({
    required List<String> messageIds,
    required String deleteType,
  }) async {
    final success = await messagesCubit.deleteMessages(
      messageIds: messageIds,
      deleteType: deleteType,
    );

    if (context.mounted) {
      _showResultSnackbar(success: success, messageCount: messageIds.length);
    }
  }

  /// Show result snackbar
  void _showResultSnackbar({required bool success, required int messageCount}) {
    final message = messageCount > 1
        ? (success ? 'تم حذف الرسائل' : 'فشل حذف الرسائل')
        : (success ? 'تم حذف الرسالة' : 'فشل حذف الرسالة');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}
