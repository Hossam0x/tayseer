import 'package:flutter/material.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_cubit.dart';

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
      final position = scrollController.position;
      final isAtBottom =
          position.maxScrollExtent == 0 || scrollController.offset <= 100;
      scrollCubit.setAtBottom(isAtBottom);
    }
  }

  void scrollToBottom({bool force = false}) {
    if (!scrollController.hasClients) return;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onScroll();
      });
    }
  }

  void dispose() {
    scrollController.removeListener(_onScroll);
  }
}
