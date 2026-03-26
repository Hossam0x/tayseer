import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/message_actions_handler.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/overlay_manager.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/input/chat_input_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';
import 'package:tayseer/features/advisor/chat/presentation/view/message_details.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/chat_context_menu_overlay.dart';

class ChatContextMenuWrapper extends StatelessWidget {
  final Size screenSize;
  final bool isMobile;
  final OverlayManager overlayManager;
  final MessageActionsHandler actionsHandler;
  final VoidCallback onStateChanged;

  const ChatContextMenuWrapper({
    super.key,
    required this.screenSize,
    required this.isMobile,
    required this.overlayManager,
    required this.actionsHandler,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!overlayManager.isOverlayVisible ||
        overlayManager.selectedMessage == null) {
      return const SizedBox.shrink();
    }

    final selectedMessage = overlayManager.selectedMessage!;

    return ChatContextMenuOverlay(
      selectedMessage: selectedMessage,
      messagePosition: overlayManager.messagePosition,
      messageSize: overlayManager.messageSize,
      screenSize: screenSize,
      isMobile: isMobile,
      safeTopPadding: MediaQuery.of(context).padding.top,
      onDismiss: () {
        overlayManager.hideOverlay(onStateChanged: onStateChanged);
      },
      onReply: () {
        context.read<ChatInputCubit>().setReplyingToMessage(selectedMessage);
        overlayManager.hideOverlay(onStateChanged: onStateChanged);
      },
      onCopy: () {
        overlayManager.hideOverlay(onStateChanged: onStateChanged);
        _copyMessageText(context, selectedMessage);
      },
      onDetails: () {
        overlayManager.hideOverlay(onStateChanged: onStateChanged);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageDetailsScreen(
              chatMessage: selectedMessage,
              readMessageIcon: AssetsData.readMessageIcon,
              deliveredMessageIcon: AssetsData.readMessageIcon,
            ),
          ),
        );
      },
      onSelect: () {
        context.read<MessageSelectionCubit>().enterSelectionMode(
              selectedMessage,
            );
        overlayManager.hideOverlay(onStateChanged: onStateChanged);
      },
      onDeleteForMe: () {
        overlayManager.hideOverlay(onStateChanged: onStateChanged);
        actionsHandler.showDeleteConfirmationForSingleMessage(
          message: selectedMessage,
          deleteType: 'me',
        );
      },
      onDeleteForAll: () {
        overlayManager.hideOverlay(onStateChanged: onStateChanged);
        actionsHandler.showDeleteConfirmationForSingleMessage(
          message: selectedMessage,
          deleteType: 'everyone',
        );
      },
    );
  }

  void _copyMessageText(BuildContext context, ChatMessage message) {
    final textContent = message.contentList.join('\n');
    if (textContent.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: textContent));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تم نسخ الرسالة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: ChatColors.bubbleSender,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        ),
      );
    }
  }
}
