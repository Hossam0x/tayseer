import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';
import '../../manager/scroll/chat_scroll_cubit.dart';
import '../../manager/scroll/chat_scroll_state.dart';
import '../bubble/message_bubble.dart';

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
          itemBuilder: (context, index) {
            final msg = widget.messages[widget.messages.length - 1 - index];
            final currentMsgId = msg.id;
            final messageKey = currentMsgId.isNotEmpty
                ? _getOrCreateKey(currentMsgId)
                : GlobalKey();
            final isHighlighted =
                scrollState.highlightedMessageId != null &&
                currentMsgId == scrollState.highlightedMessageId;

            return _MessageItemAnimated(
              key: ValueKey(currentMsgId),
              messageKey: messageKey,
              index: index,
              child: GestureDetector(
                onLongPress: () =>
                    widget.onMessageLongPress?.call(msg, messageKey),
                child: MessageBubble(
                  chatMessage: msg,
                  isHighlighted: isHighlighted,
                  onReplyTap: (replyMessageId) {
                    widget.onReplyTap?.call(replyMessageId, widget.messages);
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

class _MessageItemAnimated extends StatelessWidget {
  final GlobalKey messageKey;
  final int index;
  final Widget child;

  const _MessageItemAnimated({
    super.key,
    required this.messageKey,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(
        milliseconds:
            ChatAnimations.messageEntryDuration.inMilliseconds + (index * 50),
      ),
      curve: ChatAnimations.defaultCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(key: messageKey, child: child),
    );
  }
}
