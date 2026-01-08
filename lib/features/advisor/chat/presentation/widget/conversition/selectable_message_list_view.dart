import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/bubble/message_bubble.dart';

/// Message list view with selection support
class SelectableMessageListView extends StatefulWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final Function(ChatMessage message, GlobalKey key)? onMessageLongPress;
  final Function(String? replyMessageId, List<ChatMessage> messages)?
  onReplyTap;

  const SelectableMessageListView({
    super.key,
    required this.messages,
    required this.scrollController,
    this.onMessageLongPress,
    this.onReplyTap,
  });

  @override
  State<SelectableMessageListView> createState() =>
      _SelectableMessageListViewState();
}

class _SelectableMessageListViewState extends State<SelectableMessageListView> {
  final Map<String, GlobalKey> _messageKeys = {};

  GlobalKey _getOrCreateKey(String messageId) {
    if (!_messageKeys.containsKey(messageId)) {
      _messageKeys[messageId] = GlobalKey();
    }
    return _messageKeys[messageId]!;
  }

  @override
  void didUpdateWidget(covariant SelectableMessageListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clean up keys for messages that no longer exist
    final currentIds = widget.messages.map((m) => m.id).toSet();
    _messageKeys.removeWhere((key, _) => !currentIds.contains(key));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return BlocBuilder<MessageSelectionCubit, MessageSelectionState>(
      builder: (context, selectionState) {
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
              addAutomaticKeepAlives: true,
              cacheExtent: 500,
              itemBuilder: (context, index) {
                final msg = widget.messages[widget.messages.length - 1 - index];
                final currentMsgId = msg.id;
                final messageKey = currentMsgId.isNotEmpty
                    ? _getOrCreateKey(currentMsgId)
                    : GlobalKey();
                final isHighlighted =
                    scrollState.highlightedMessageId != null &&
                    currentMsgId == scrollState.highlightedMessageId;
                final isSelected = selectionState.isSelected(currentMsgId);

                return _SelectableMessageItem(
                  key: ValueKey(currentMsgId),
                  messageKey: messageKey,
                  message: msg,
                  isHighlighted: isHighlighted,
                  isSelected: isSelected,
                  isSelectionMode: selectionState.isSelectionMode,
                  onLongPress: () {
                    if (!selectionState.isSelectionMode) {
                      widget.onMessageLongPress?.call(msg, messageKey);
                    }
                  },
                  onTap: () {
                    if (selectionState.isSelectionMode) {
                      context
                          .read<MessageSelectionCubit>()
                          .toggleMessageSelection(msg);
                    }
                  },
                  onReplyTap: (replyMessageId) {
                    widget.onReplyTap?.call(replyMessageId, widget.messages);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Individual selectable message item
class _SelectableMessageItem extends StatefulWidget {
  final GlobalKey messageKey;
  final ChatMessage message;
  final bool isHighlighted;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final Function(String?) onReplyTap;

  const _SelectableMessageItem({
    super.key,
    required this.messageKey,
    required this.message,
    required this.isHighlighted,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onLongPress,
    required this.onTap,
    required this.onReplyTap,
  });

  @override
  State<_SelectableMessageItem> createState() => _SelectableMessageItemState();
}

class _SelectableMessageItemState extends State<_SelectableMessageItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return KeyedSubtree(
      key: widget.messageKey,
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(
            left: widget.isSelectionMode ? 0 : 0,
            right: 0,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.blue.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Selection checkbox on the left
              if (widget.isSelectionMode) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _SelectionCircle(isSelected: widget.isSelected),
                ),
              ],
              // Message bubble
              Expanded(
                child: MessageBubble(
                  chatMessage: widget.message,
                  isHighlighted: widget.isHighlighted,
                  onReplyTap: widget.onReplyTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selection circle indicator
class _SelectionCircle extends StatelessWidget {
  final bool isSelected;

  const _SelectionCircle({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.kprimaryColor : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.kprimaryColor : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}
