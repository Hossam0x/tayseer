import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';

/// Handler for scroll-related behavior
/// Follows Single Responsibility Principle
class ScrollBehaviorHandler {
  final ScrollController scrollController;
  final ChatScrollCubit scrollCubit;

  int _previousMessageCount = 0;
  bool _isFirstLoad = true;

  ScrollBehaviorHandler({
    required this.scrollController,
    required this.scrollCubit,
  }) {
    _setupScrollListener();
  }

  /// Setup scroll listener
  void _setupScrollListener() {
    scrollController.addListener(_onScroll);
  }

  /// Dispose resources
  void dispose() {
    scrollController.removeListener(_onScroll);
  }

  /// Handle scroll events
  void _onScroll() {
    final isAtBottom = scrollController.offset <= 100;
    scrollCubit.setAtBottom(isAtBottom);
  }

  /// Scroll to bottom of the list
  void scrollToBottom({bool animate = true, bool force = false}) {
    if (!scrollController.hasClients) return;

    final scrollState = scrollCubit.state;
    if (!scrollState.isAtBottom && !force) {
      log('📍 User is not at bottom, skipping auto-scroll');
      return;
    }

    log('⬇️ Scrolling to bottom (animate: $animate, force: $force)');

    if (animate) {
      scrollController.animateTo(
        0.0,
        duration: ChatAnimations.scrollDuration,
        curve: ChatAnimations.defaultCurve,
      );
    } else {
      scrollController.jumpTo(0.0);
    }
  }

  /// Scroll to bottom after sending a message
  void scrollToBottomAfterSend() {
    Future.delayed(const Duration(milliseconds: 100), () {
      scrollToBottom(animate: true, force: true);
    });
  }

  /// Scroll to bottom on first load
  void scrollToBottomOnFirstLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(0.0);
        scrollCubit.setAtBottom(true);
      }
    });
  }

  /// Handle message count changes
  void handleMessageCountChange({
    required int currentCount,
    required bool isSuccess,
  }) {
    if (isSuccess && _isFirstLoad && currentCount > 0) {
      _isFirstLoad = false;
      _previousMessageCount = currentCount;
      scrollToBottomOnFirstLoad();
      return;
    }

    if (currentCount > _previousMessageCount && _previousMessageCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom(animate: true);
      });
    }

    _previousMessageCount = currentCount;
  }

  /// Reset first load flag
  void resetFirstLoad() {
    _isFirstLoad = true;
    _previousMessageCount = 0;
  }

  /// Get current message count
  int get previousMessageCount => _previousMessageCount;

  /// Check if it's first load
  bool get isFirstLoad => _isFirstLoad;
}
