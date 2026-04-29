import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
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
        title: Text(context.tr('delete_message_title')),
        content: Text(
          deleteType == 'me'
              ? context.tr('delete_message_for_me_confirm')
              : context.tr('delete_message_for_all_confirm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              messagesCubit.deleteMessage(
                messageId: message.id,
                deleteType: deleteType,
              );
            },
            child: Text(
              context.tr('delete'),
              style: const TextStyle(color: Colors.red),
            ),
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
        title: Text(context.tr('delete_messages_title')),
        content: Text(
          deleteType == 'me'
              ? context.tr('delete_selected_for_me_confirm')
              : context.tr('delete_selected_for_all_confirm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel')),
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
            child: Text(
              context.tr('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
