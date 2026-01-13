import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import '../../manager/scroll/chat_scroll_cubit.dart';
import '../../manager/scroll/chat_scroll_state.dart';
import '../bubble/message_bubble.dart';
import '../bubble/system_message_bubble.dart';

class MessageListView extends StatefulWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final Function(ChatMessage message, GlobalKey key)? onMessageLongPress;
  final Function(String? replyMessageId, List<ChatMessage> messages)?
  onReplyTap;

  const MessageListView({
    super.key,
    required this.messages,
    required this.scrollController,
    this.onMessageLongPress,
    this.onReplyTap,
  });

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  final Map<String, GlobalKey> _messageKeys = {};

  GlobalKey _getOrCreateKey(String messageId) {
    if (!_messageKeys.containsKey(messageId)) {
      _messageKeys[messageId] = GlobalKey();
    }
    return _messageKeys[messageId]!;
  }

  @override
  void didUpdateWidget(covariant MessageListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clean up keys for messages that no longer exist
    // This prevents GlobalKey conflicts when temp messages are replaced
    final currentIds = widget.messages.map((m) => m.id).toSet();
    _messageKeys.removeWhere((key, _) => !currentIds.contains(key));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return BlocBuilder<ChatScrollCubit, ChatScrollState>(
      buildWhen: (previous, current) =>
          previous.highlightedMessageId != current.highlightedMessageId,
      builder: (context, scrollState) {
        return ListView.builder(
          reverse: true,
          controller: widget.scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 12,
            vertical: isMobile ? 6 : 8,
          ),
          itemCount: widget.messages.length,
          // Keep items alive to prevent reload
          addAutomaticKeepAlives: true,
          // Cache items for better scroll performance
          cacheExtent: 500,
          itemBuilder: (context, index) {
            // With reverse: true, index 0 is the last message (newest at bottom)
            // So we access messages directly - newest messages are at the end of the list
            final msg = widget.messages[widget.messages.length - 1 - index];
            final currentMsgId = msg.id;
            final messageKey = currentMsgId.isNotEmpty
                ? _getOrCreateKey(currentMsgId)
                : GlobalKey();
            final isHighlighted =
                scrollState.highlightedMessageId != null &&
                currentMsgId == scrollState.highlightedMessageId;

            return _MessageItemKeepAlive(
              key: ValueKey(currentMsgId),
              messageKey: messageKey,
              child: msg.messageType == 'system'
                  ? SystemMessageBubble(content: msg.content)
                  : GestureDetector(
                      onLongPress: () {
                        widget.onMessageLongPress?.call(msg, messageKey);
                      },
                      child: MessageBubble(
                        chatMessage: msg,
                        isHighlighted: isHighlighted,
                        onReplyTap: (replyMessageId) {
                          widget.onReplyTap?.call(
                            replyMessageId,
                            widget.messages,
                          );
                        },
                      ),
                    ),
            );
          },
        );
      },
    );
  }
}

/// Keep message items alive to prevent image/video reload during scroll
class _MessageItemKeepAlive extends StatefulWidget {
  final GlobalKey messageKey;
  final Widget child;

  const _MessageItemKeepAlive({
    super.key,
    required this.messageKey,
    required this.child,
  });

  @override
  State<_MessageItemKeepAlive> createState() => _MessageItemKeepAliveState();
}

class _MessageItemKeepAliveState extends State<_MessageItemKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    // Don't pass GlobalKey to Container - it's already on the parent widget
    // The messageKey is only for external access (long press, etc.)
    return KeyedSubtree(key: widget.messageKey, child: widget.child);
  }
}
