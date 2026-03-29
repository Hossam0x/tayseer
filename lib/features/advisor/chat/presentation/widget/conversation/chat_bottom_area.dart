import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/message_actions_handler.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/scroll_behavior_handler.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_cubit_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/input/chat_input_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/state/chat_messages_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/block_action_area.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/conversation_input_area.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/selection_bottom_bar.dart';

class ChatBottomArea extends StatelessWidget {
  final String? chatRoomId;
  final String? receiverId;
  final bool isSystemChat;
  final MessageSelectionState selectionState;
  final MessageActionsHandler actionsHandler;
  final ScrollBehaviorHandler scrollHandler;
  final void Function(bool isBlocked)? onBlockStatusChanged;

  const ChatBottomArea({
    super.key,
    required this.chatRoomId,
    required this.receiverId,
    required this.isSystemChat,
    required this.selectionState,
    required this.actionsHandler,
    required this.scrollHandler,
    this.onBlockStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatMessagesCubit, ChatMessagesState>(
      builder: (context, messageState) {
        if (selectionState.isSelectionMode) {
          return SelectionBottomBar(
            onDeleteForMe: () => actionsHandler
                .showDeleteConfirmationForSelectedMessages(deleteType: 'me'),
            onDeleteForAll: () => actionsHandler
                .showDeleteConfirmationForSelectedMessages(
              deleteType: 'everyone',
            ),
            onCancel: () =>
                context.read<MessageSelectionCubit>().exitSelectionMode(),
          );
        } else if (messageState.isBlocked) {
          return BlockedActionArea(
            onUnblockTap: () async {
              if (receiverId != null) {
                await context.read<ChatMessagesCubit>().unblockUser(
                      blockedId: receiverId!,
                    );
                onBlockStatusChanged?.call(false);
              }
            },
            onDeleteChatTap: () {
              // TODO: Implement delete chat
            },
          );
        } else if (isSystemChat) {
          return const SizedBox.shrink();
        } else {
          return ConversationInputArea(
            sendMessageIcon: AssetsData.sendMessageIcon,
            chatEmojiIcon: AssetsData.chatEmojiIcon,
            cameraIcon: AssetsData.cameraIcon,
            onSendMessage: (message, replyMessageId) {
              _handleSendMessage(context, message, replyMessageId);
            },
            onSendMedia: (files, messageType, replyMessageId) {
              _handleSendMedia(context, files, messageType, replyMessageId);
            },
            onTypingStart: () =>
                context.read<ChatMessagesCubit>().typingStart(chatRoomId!),
            onTypingStop: () =>
                context.read<ChatMessagesCubit>().typingStop(chatRoomId!),
          );
        }
      },
    );
  }

  void _handleSendMessage(
    BuildContext context,
    String message,
    String? replyMessageId,
  ) {
    final replyToMessage =
        context.read<ChatInputCubit>().state.replyingToMessage;
    context.read<ChatMessagesCubit>().sendMessage(
          receiverId!,
          message,
          chatRoomId!,
          replyMessageId: replyMessageId,
          replyToMessage: replyToMessage,
        );
    scrollHandler.scrollToBottomAfterSend();
  }

  void _handleSendMedia(
    BuildContext context,
    List<File> files,
    String messageType,
    String? replyMessageId,
  ) {
    final replyToMessage =
        context.read<ChatInputCubit>().state.replyingToMessage;
    context.read<ChatMessagesCubit>().sendMediaMessage(
          chatRoomId: chatRoomId!,
          messageType: messageType,
          images: messageType == 'image' ? files : null,
          videos: messageType == 'video' ? files : null,
          replyMessageId: replyMessageId,
          replyToMessage: replyToMessage,
        );
    scrollHandler.scrollToBottomAfterSend();
  }
}
