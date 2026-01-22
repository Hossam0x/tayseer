import 'package:flutter/material.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_cubit.dart';

/// Manages the long-press overlay for chat messages
class OverlayManager {
  final ScrollController scrollController;
  final ChatScrollCubit scrollCubit;

  ChatMessage? _selectedMessage;
  bool _isOverlayVisible = false;

  // Position props
  Offset _messagePosition = Offset.zero;
  Size _messageSize = Size.zero;

  OverlayManager({required this.scrollController, required this.scrollCubit});

  bool get isOverlayVisible => _isOverlayVisible;
  ChatMessage? get selectedMessage => _selectedMessage;
  Offset get messagePosition => _messagePosition;
  Size get messageSize => _messageSize;

  void showOverlay({
    required ChatMessage message,
    required GlobalKey key,
    required VoidCallback onStateChanged,
  }) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _messagePosition = renderBox.localToGlobal(Offset.zero);
    _messageSize = renderBox.size;
    _selectedMessage = message;
    _isOverlayVisible = true;

    // The actual overlay UI is built by the screen using these properties
    onStateChanged();
  }

  void hideOverlay({required VoidCallback onStateChanged}) {
    _selectedMessage = null;
    _isOverlayVisible = false;
    onStateChanged();
  }

  void scrollToMessage({
    required String messageId,
    required List<ChatMessage> allMessages,
  }) {
    if (!scrollController.hasClients || messageId.isEmpty) return;

    // Find the index of the message
    final messageIndex = allMessages.indexWhere((msg) => msg.id == messageId);
    if (messageIndex == -1) return;

    // Calculate the reverse index (since list is reversed)
    final reverseIndex = allMessages.length - 1 - messageIndex;

    // Highlight the message
    scrollCubit.setHighlightedMessageId(messageId);

    // Scroll to the message
    // Approximate item height (adjust based on your message height)
    const approximateItemHeight = 100.0;
    final targetOffset = reverseIndex * approximateItemHeight;

    scrollController
        .animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        )
        .then((_) {
          // Clear highlight after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            scrollCubit.clearHighlight();
          });
        });
  }
}
