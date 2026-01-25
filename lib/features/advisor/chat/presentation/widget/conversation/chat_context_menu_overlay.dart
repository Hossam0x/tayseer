import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/bubble/message_bubble.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/conversation_context_menu.dart';

/// Overlay widget for displaying context menu
/// Follows Single Responsibility Principle
class ChatContextMenuOverlay extends StatelessWidget {
  final ChatMessage selectedMessage;
  final Offset messagePosition;
  final Size messageSize;
  final Size screenSize;
  final bool isMobile;
  final double safeTopPadding;
  final VoidCallback onDismiss;
  final VoidCallback onReply;
  final VoidCallback onDetails;
  final VoidCallback onSelect;
  final VoidCallback onDeleteForMe;
  final VoidCallback onDeleteForAll;

  const ChatContextMenuOverlay({
    super.key,
    required this.selectedMessage,
    required this.messagePosition,
    required this.messageSize,
    required this.screenSize,
    required this.isMobile,
    required this.safeTopPadding,
    required this.onDismiss,
    required this.onReply,
    required this.onDetails,
    required this.onSelect,
    required this.onDeleteForMe,
    required this.onDeleteForAll,
  });

  @override
  Widget build(BuildContext context) {
    final isMyMessage = selectedMessage.isMe;
    final menuPositions = _calculateMenuPositions(isMyMessage);

    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: ChatColors.overlayBackground,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Stack(
            children: [
              _buildMessageBubble(isMyMessage, menuPositions.messageTop),
              _buildContextMenu(isMyMessage, menuPositions.menuTop),
            ],
          ),
        ),
      ),
    );
  }

  /// Build message bubble
  Widget _buildMessageBubble(bool isMyMessage, double top) {
    return Positioned(
      top: top,
      left: messagePosition.dx,
      width: screenSize.width - (isMobile ? 24 : 32),
      child: Align(
        alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: MessageBubble(chatMessage: selectedMessage, isOverlay: true),
      ),
    );
  }

  /// Build context menu
  Widget _buildContextMenu(bool isMyMessage, double top) {
    return Positioned(
      top: top,
      left: isMyMessage ? null : messagePosition.dx,
      right: isMyMessage
          ? screenSize.width - (messagePosition.dx + messageSize.width)
          : null,
      child: ConversationContextMenu(
        isMyMessage: isMyMessage,
        onReply: onReply,
        onDetails: onDetails,
        onSelect: onSelect,
        onDeleteForMe: onDeleteForMe,
        onDeleteForAll: onDeleteForAll,
      ),
    );
  }

  /// Calculate menu positions
  _MenuPositions _calculateMenuPositions(bool isMyMessage) {
    final menuItemCount = isMyMessage ? 5 : 3;
    const menuItemHeight = 44.0;
    const menuPadding = 16.0;
    final estimatedMenuHeight = (menuItemCount * menuItemHeight) + menuPadding;

    final bottomPosition = messagePosition.dy + messageSize.height + 8;
    final availableSpaceBelow = screenSize.height - bottomPosition;

    final shouldShowAbove = availableSpaceBelow < estimatedMenuHeight;

    final double messageTop;
    final double menuTop;

    if (shouldShowAbove) {
      final safeTopMargin = safeTopPadding + 80;
      menuTop = (messagePosition.dy - estimatedMenuHeight - 8).clamp(
        safeTopMargin,
        screenSize.height,
      );
      messageTop = menuTop + estimatedMenuHeight + 8;
    } else {
      messageTop = messagePosition.dy;
      menuTop = bottomPosition;
    }

    return _MenuPositions(messageTop: messageTop, menuTop: menuTop);
  }
}

/// Helper class for menu positions
class _MenuPositions {
  final double messageTop;
  final double menuTop;

  _MenuPositions({required this.messageTop, required this.menuTop});
}
