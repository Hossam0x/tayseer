import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/message_actions_handler.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/overlay_manager.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/scroll_behavior_handler.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/input/chat_input_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/state/chat_messages_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/typing/typing_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/typing/typing_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/block_action_area.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/message_shimmer.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/scroll_to_bottom_button.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/selectable_message_list_view.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/selection_bottom_bar.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/typing_indicator.dart';

/// Base chat screen with common functionality
/// This is an abstract class that can be extended by specific implementations
abstract class BaseChatScreen extends StatefulWidget {
  final String? chatRoomId;
  final String? receiverId;
  final String? username;
  final String? userimage;
  final bool isBlocked;
  final bool isHaveSession;
  final void Function(bool isBlocked)? onBlockStatusChanged;

  const BaseChatScreen({
    super.key,
    this.chatRoomId,
    this.receiverId,
    this.username,
    this.userimage,
    this.isBlocked = false,
    this.isHaveSession = true,
    this.onBlockStatusChanged,
  });
}

/// Base state for chat screen
/// Contains common logic for both User and Advisor chat screens
abstract class BaseChatScreenState<T extends BaseChatScreen> extends State<T> {
  late final ScrollController _scrollController;
  ScrollBehaviorHandler? _scrollHandler;
  OverlayManager? _overlayManager;
  MessageActionsHandler? _actionsHandler;
  bool _handlersInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollHandler?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Initialize handlers after context is available
  void initializeHandlers(BuildContext context) {
    if (_handlersInitialized) return;

    final scrollCubit = context.read<ChatScrollCubit>();
    _scrollHandler = ScrollBehaviorHandler(
      scrollController: _scrollController,
      scrollCubit: scrollCubit,
    );
    _overlayManager = OverlayManager(
      scrollController: _scrollController,
      scrollCubit: scrollCubit,
    );
    _actionsHandler = MessageActionsHandler(
      context: context,
      messagesCubit: context.read<ChatMessagesCubit>(),
      selectionCubit: context.read<MessageSelectionCubit>(),
    );
    _handlersInitialized = true;
  }

  /// Build app bar - to be implemented by subclasses
  Widget buildAppBar(BuildContext context);

  /// Build input area - to be implemented by subclasses
  Widget buildInputArea(BuildContext context);

  /// Handle send message
  void handleSendMessage({
    required String message,
    required String? replyMessageId,
    required BuildContext context,
  }) {
    final replyToMessage = context
        .read<ChatInputCubit>()
        .state
        .replyingToMessage;
    context.read<ChatMessagesCubit>().sendMessage(
      widget.receiverId!,
      message,
      widget.chatRoomId!,
      replyMessageId: replyMessageId,
      replyToMessage: replyToMessage,
    );
    _scrollHandler?.scrollToBottomAfterSend();
  }

  /// Handle send media
  void handleSendMedia({
    required List<File> files,
    required String messageType,
    required String? replyMessageId,
    required BuildContext context,
  }) {
    final replyToMessage = context
        .read<ChatInputCubit>()
        .state
        .replyingToMessage;
    context.read<ChatMessagesCubit>().sendMediaMessage(
      chatRoomId: widget.chatRoomId!,
      messageType: messageType,
      images: messageType == 'image' ? files : null,
      videos: messageType == 'video' ? files : null,
      replyMessageId: replyMessageId,
      replyToMessage: replyToMessage,
    );
    _scrollHandler?.scrollToBottomAfterSend();
  }

  /// Handle typing start
  void handleTypingStart(BuildContext context) {
    context.read<ChatMessagesCubit>().typingStart(widget.chatRoomId!);
  }

  /// Handle typing stop
  void handleTypingStop(BuildContext context) {
    context.read<ChatMessagesCubit>().typingStop(widget.chatRoomId!);
  }

  /// Build messages area
  Widget buildMessagesArea(bool isMobile) {
    return BlocConsumer<ChatMessagesCubit, ChatMessagesState>(
      listenWhen: (previous, current) =>
          previous.messages.length != current.messages.length ||
          previous.loadingState != current.loadingState,
      listener: (context, state) {
        _scrollHandler?.handleMessageCountChange(
          currentCount: state.messages.length,
          isSuccess: state.loadingState == CubitStates.success,
        );
      },
      buildWhen: (previous, current) =>
          previous.loadingState != current.loadingState ||
          previous.messages != current.messages,
      builder: (context, state) {
        if (state.loadingState == CubitStates.loading) {
          return const MessageShimmer();
        }

        if (state.loadingState == CubitStates.success ||
            state.messages.isNotEmpty) {
          return Column(
            children: [
              if (!state.isOnline) _buildOfflineIndicator(),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification) {
                      final metrics = notification.metrics;
                      if (metrics.pixels >= metrics.maxScrollExtent - 100) {
                        context.read<ChatMessagesCubit>().loadOlderMessages();
                      }
                    }
                    return false;
                  },
                  child: SelectableMessageListView(
                    messages: state.messages,
                    scrollController: _scrollController,
                    onMessageLongPress: (message, key) {
                      _overlayManager?.showOverlay(
                        message: message,
                        key: key,
                        onStateChanged: () => setState(() {}),
                      );
                    },
                    onReplyTap: (messageId, messages) {
                      _overlayManager?.scrollToMessage(
                        messageId: messageId,
                        allMessages: messages,
                      );
                    },
                  ),
                ),
              ),
              _buildTypingIndicator(),
            ],
          );
        }

        if (state.loadingState == CubitStates.failure) {
          return buildErrorState(context, state);
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  /// Build offline indicator
  Widget _buildOfflineIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.orange.shade100,
      child: const Text(
        'أنت غير متصل - سيتم إرسال الرسائل عند الاتصال',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.orange),
      ),
    );
  }

  /// Build typing indicator
  Widget _buildTypingIndicator() {
    return BlocBuilder<TypingCubit, TypingState>(
      builder: (context, typingState) {
        if (typingState.isUserTyping && typingState.typingInfo != null) {
          return TypingIndicator(userName: typingState.typingInfo!.userName);
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Build scroll to bottom button
  Widget buildScrollToBottomButton() {
    return BlocBuilder<ChatScrollCubit, ChatScrollState>(
      buildWhen: (previous, current) =>
          previous.isAtBottom != current.isAtBottom,
      builder: (context, state) {
        return ScrollToBottomButton(
          isVisible: !state.isAtBottom,
          onPressed: () => _scrollHandler?.scrollToBottom(force: true),
        );
      },
    );
  }

  /// Build error state
  Widget buildErrorState(BuildContext context, ChatMessagesState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            state.errorMessage ?? 'حدث خطأ ما',
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ChatMessagesCubit>().loadInitialMessages(
                widget.chatRoomId!,
                receiverId: widget.receiverId,
              );
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  /// Build bottom area (input or selection bar)
  Widget buildBottomArea(
    BuildContext context,
    MessageSelectionState selectionState,
  ) {
    return BlocBuilder<ChatMessagesCubit, ChatMessagesState>(
      builder: (context, messageState) {
        if (selectionState.isSelectionMode) {
          return SelectionBottomBar(
            onDeleteForMe: () => _actionsHandler
                ?.showDeleteConfirmationForSelectedMessages(deleteType: 'me'),
            onDeleteForAll: () =>
                _actionsHandler?.showDeleteConfirmationForSelectedMessages(
                  deleteType: 'everyone',
                ),
            onCancel: () =>
                context.read<MessageSelectionCubit>().exitSelectionMode(),
          );
        } else if (messageState.isBlocked) {
          return BlockedActionArea(
            onUnblockTap: () async {
              if (widget.receiverId != null) {
                await context.read<ChatMessagesCubit>().unblockUser(
                  blockedId: widget.receiverId!,
                );
                widget.onBlockStatusChanged?.call(false);
              }
            },
            onDeleteChatTap: () {
              // TODO: Implement delete chat
            },
          );
        } else {
          return buildInputArea(context);
        }
      },
    );
  }

  /// Build context menu overlay
  Widget buildContextMenuOverlay({
    required Size screenSize,
    required bool isMobile,
    required Widget Function(BuildContext, bool) contextMenuBuilder,
  }) {
    if (_overlayManager?.isOverlayVisible != true ||
        _overlayManager?.selectedMessage == null) {
      return const SizedBox.shrink();
    }

    final isMyMessage = _overlayManager?.selectedMessage?.isMe ?? false;
    return contextMenuBuilder(context, isMyMessage);
  }

  /// Get overlay manager
  OverlayManager? get overlayManager => _overlayManager;

  /// Get actions handler
  MessageActionsHandler? get actionsHandler => _actionsHandler;

  /// Get scroll handler
  ScrollBehaviorHandler? get scrollHandler => _scrollHandler;
}
