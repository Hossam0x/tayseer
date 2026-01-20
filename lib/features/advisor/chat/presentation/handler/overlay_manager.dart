import 'package:flutter/material.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';

/// Manager for overlay and message highlighting
/// Follows Single Responsibility Principle
class OverlayManager {
  final Map<String, GlobalKey> _messageKeys = {};
  final ScrollController scrollController;
  final ChatScrollCubit scrollCubit;

  bool _isOverlayVisible = false;
  ChatMessage? _selectedMessage;
  Offset _messagePosition = Offset.zero;
  Size _messageSize = Size.zero;

  OverlayManager({required this.scrollController, required this.scrollCubit});

  /// Check if overlay is visible
  bool get isOverlayVisible => _isOverlayVisible;

  /// Get selected message
  ChatMessage? get selectedMessage => _selectedMessage;

  /// Get message position
  Offset get messagePosition => _messagePosition;

  /// Get message size
  Size get messageSize => _messageSize;

  /// Show overlay for a message
  void showOverlay({
    required ChatMessage message,
    required GlobalKey key,
    required VoidCallback onStateChanged,
  }) {
    _selectedMessage = message;
    _isOverlayVisible = true;

    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      _messagePosition = renderBox.localToGlobal(Offset.zero);
      _messageSize = renderBox.size;
    }

    onStateChanged();
  }

  /// Hide overlay
  void hideOverlay({required VoidCallback onStateChanged}) {
    _isOverlayVisible = false;
    _selectedMessage = null;
    onStateChanged();
  }

  /// Get or create key for a message
  GlobalKey getOrCreateKey(String messageId) {
    if (!_messageKeys.containsKey(messageId)) {
      _messageKeys[messageId] = GlobalKey();
    }
    return _messageKeys[messageId]!;
  }

  /// Scroll to a specific message
  void scrollToMessage({
    required String? messageId,
    required List<ChatMessage> allMessages,
  }) {
    if (messageId == null) return;

    final messageIndex = allMessages.indexWhere((msg) => msg.id == messageId);
    if (messageIndex == -1) return;

    final reversedIndex = allMessages.length - 1 - messageIndex;
    getOrCreateKey(messageId);

    final targetKey = _messageKeys[messageId];
    final targetContext = targetKey?.currentContext;

    if (targetContext != null) {
      _scrollAndHighlight(targetContext, messageId);
    } else {
      final estimatedOffset = reversedIndex * 80.0;
      scrollController
          .animateTo(
            estimatedOffset,
            duration: ChatAnimations.scrollDuration,
            curve: ChatAnimations.defaultCurve,
          )
          .then((_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _tryScrollToMessageAfterBuild(messageId);
            });
          });
    }
  }

  /// Try to scroll to message after build
  void _tryScrollToMessageAfterBuild(String messageId) {
    final targetKey = _messageKeys[messageId];
    final targetContext = targetKey?.currentContext;

    if (targetContext != null) {
      _scrollAndHighlight(targetContext, messageId);
    }
  }

  /// Scroll and highlight a message
  void _scrollAndHighlight(BuildContext targetContext, String messageId) {
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.3,
    ).then((_) {
      scrollCubit.setHighlightedMessageId(messageId);

      Future.delayed(ChatAnimations.highlightDuration, () {
        scrollCubit.clearHighlight();
      });
    });
  }

  /// Clear all message keys
  void clearMessageKeys() {
    _messageKeys.clear();
  }
}
