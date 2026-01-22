import 'package:flutter/material.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_cubit.dart';

/// Handles scroll behavior for the chat screen
class ScrollBehaviorHandler {
  final ScrollController scrollController;
  final ChatScrollCubit scrollCubit;

  ScrollBehaviorHandler({
    required this.scrollController,
    required this.scrollCubit,
  }) {
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.hasClients) {
      // For reverse list, position 0 is the bottom
      // User is at bottom when offset is close to 0
      final isAtBottom = scrollController.offset <= 100;
      scrollCubit.setAtBottom(isAtBottom);
    }
  }

  void scrollToBottom({bool force = false}) {
    if (!scrollController.hasClients) return;

    // Using a small delay to ensure the list has updated
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0, // 0 is bottom for reverse lists
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void scrollToBottomAfterSend() {
    scrollToBottom(force: true);
  }

  void handleMessageCountChange({
    required int currentCount,
    required bool isSuccess,
  }) {
    if (isSuccess) {
      // Logic to decide whether to auto-scroll usually goes here
      // For now, simple logic
    }
  }

  void dispose() {
    scrollController.removeListener(_onScroll);
  }
}
