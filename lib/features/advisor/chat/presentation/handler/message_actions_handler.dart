import 'package:flutter/material.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_cubit_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_cubit.dart';

/// Handles actions like deleting messages
class MessageActionsHandler {
  final BuildContext context;
  final ChatMessagesCubit messagesCubit;
  final MessageSelectionCubit selectionCubit;

  MessageActionsHandler({
    required this.context,
    required this.messagesCubit,
    required this.selectionCubit,
  });

  void showDeleteConfirmationForSingleMessage({
    required ChatMessage message,
    required String deleteType, // 'me' or 'everyone'
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الرسالة'),
        content: Text(
          deleteType == 'me'
              ? 'هل أنت متأكد من حذف هذه الرسالة لديك؟'
              : 'هل أنت متأكد من حذف هذه الرسالة لدى الجميع؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              messagesCubit.deleteMessage(
                messageId: message.id,
                deleteType: deleteType,
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmationForSelectedMessages({
    required String deleteType, // 'me' or 'everyone'
  }) {
    final selectedIds = selectionCubit.state.selectedMessageIds;
    if (selectedIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الرسائل'),
        content: Text(
          deleteType == 'me'
              ? 'هل أنت متأكد من حذف الرسائل المحددة لديك؟'
              : 'هل أنت متأكد من حذف الرسائل المحددة لدى الجميع؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              messagesCubit.deleteMessages(
                messageIds: selectedIds.toList(),
                deleteType: deleteType,
              );
              selectionCubit.exitSelectionMode();
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
