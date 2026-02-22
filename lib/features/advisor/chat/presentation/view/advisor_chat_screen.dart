import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ للنسخ
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/utils/router/app_router.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_cubit_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/input/chat_input_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/typing/typing_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';
import 'package:tayseer/features/advisor/chat/presentation/view/base_chat_screen.dart';
import 'package:tayseer/features/advisor/chat/presentation/view/message_details.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/chat_context_menu_overlay.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/conversation_app_bar.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/conversation_input_area.dart';

/// Advisor Chat Page - Responsible for injecting dependencies
class AdvisorChatScreen extends StatelessWidget {
  final String? chatRoomId;
  final String? receiverId;
  final String? username;
  final String? userimage;
  final bool isBlocked;
  final bool isHaveSession;
  final void Function(bool isBlocked)? onBlockStatusChanged;

  const AdvisorChatScreen({
    super.key,
    this.chatRoomId,
    this.receiverId,
    this.username,
    this.userimage,
    this.isBlocked = false,
    this.isHaveSession = true,
    this.onBlockStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            log('🚀 Creating ChatMessagesCubit for room: $chatRoomId');
            final cubit = getIt<ChatMessagesCubit>(param1: chatRoomId);
            cubit.setInitialBlocked(isBlocked);
            cubit.loadInitialMessages(chatRoomId!, receiverId: receiverId);
            cubit.setupSocketListeners();
            return cubit;
          },
        ),
        BlocProvider(create: (_) => ChatScrollCubit()),
        BlocProvider(create: (_) => MessageSelectionCubit()),
        BlocProvider(
          create: (_) => TypingCubit()..listenToUserTyping(chatRoomId!),
        ),
        BlocProvider(
          create: (context) => ChatInputCubit(
            onTypingStart: () =>
                context.read<ChatMessagesCubit>().typingStart(chatRoomId!),
            onTypingStop: () =>
                context.read<ChatMessagesCubit>().typingStop(chatRoomId!),
          ),
        ),
      ],
      child: _AdvisorChatContent(
        chatRoomId: chatRoomId,
        receiverId: receiverId,
        username: username,
        userimage: userimage,
        isBlocked: isBlocked,
        isHaveSession: isHaveSession,
        onBlockStatusChanged: onBlockStatusChanged,
      ),
    );
  }
}

/// Internal Content Widget that extends BaseChatScreen
class _AdvisorChatContent extends BaseChatScreen {
  const _AdvisorChatContent({
    super.chatRoomId,
    super.receiverId,
    super.username,
    super.userimage,
    super.isBlocked,
    super.isHaveSession,
    super.onBlockStatusChanged,
  });

  @override
  State<_AdvisorChatContent> createState() => _AdvisorChatContentState();
}

class _AdvisorChatContentState
    extends BaseChatScreenState<_AdvisorChatContent> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeHandlers(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return BlocBuilder<MessageSelectionCubit, MessageSelectionState>(
      buildWhen: (previous, current) =>
          previous.isSelectionMode != current.isSelectionMode,
      builder: (context, selectionState) {
        return PopScope(
          canPop: !selectionState.isSelectionMode,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && selectionState.isSelectionMode) {
              context.read<MessageSelectionCubit>().exitSelectionMode();
            }
          },
          child: SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: ChatColors.chatBackground,
              body: Directionality(
                textDirection: TextDirection.rtl,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        buildAppBar(context),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  AssetsData.homeBackgroundImage,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: [
                                buildMessagesArea(isMobile),
                                buildScrollToBottomButton(),
                              ],
                            ),
                          ),
                        ),
                        buildBottomArea(context, selectionState),
                      ],
                    ),
                    buildContextMenuOverlay(
                      screenSize: screenSize,
                      isMobile: isMobile,
                      contextMenuBuilder: _buildContextMenuOverlay,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildAppBar(BuildContext context) {
    return ConversationAppBar(
      username: widget.username,
      userimage: widget.userimage,
      phoneIcon: AssetsData.phoneIcon,
      receiverId: widget.receiverId,
      onProfileTap: isUser
          ? () {
              Navigator.pushNamed(
                context,
                AppRouter.advisorchatprofile,
                arguments: {'advisorid': widget.receiverId},
              );
            }
          : null,
      onBlockUser: (blockedId) async {
        await context.read<ChatMessagesCubit>().blockUser(blockedId: blockedId);
        widget.onBlockStatusChanged?.call(true);
      },
    );
  }

  @override
  Widget buildInputArea(BuildContext context) {
    return ConversationInputArea(
      sendMessageIcon: AssetsData.sendMessageIcon,
      chatEmojiIcon: AssetsData.chatEmojiIcon,
      cameraIcon: AssetsData.cameraIcon,
      onSendMessage: (message, replyMessageId) {
        handleSendMessage(
          message: message,
          replyMessageId: replyMessageId,
          context: context,
        );
      },
      onSendMedia: (files, messageType, replyMessageId) {
        handleSendMedia(
          files: files,
          messageType: messageType,
          replyMessageId: replyMessageId,
          context: context,
        );
      },
      onTypingStart: () => handleTypingStart(context),
      onTypingStop: () => handleTypingStop(context),
    );
  }

  void _copyMessageText(ChatMessage message) {
    final textContent = message.contentList.join('\n');
    if (textContent.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: textContent));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'تم نسخ الرسالة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: ChatColors.bubbleSender,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          ),
        );
      }
    }
  }

  /// Build context menu overlay
  Widget _buildContextMenuOverlay(BuildContext context, bool isMyMessage) {
    final handler = overlayManager;
    if (handler == null) return const SizedBox.shrink();

    final selectedMessage = handler.selectedMessage;
    if (selectedMessage == null) return const SizedBox.shrink();

    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return ChatContextMenuOverlay(
      selectedMessage: selectedMessage,
      messagePosition: handler.messagePosition,
      messageSize: handler.messageSize,
      screenSize: screenSize,
      isMobile: isMobile,
      safeTopPadding: MediaQuery.of(context).padding.top,
      onDismiss: () {
        handler.hideOverlay(onStateChanged: () => setState(() {}));
      },
      onReply: () {
        context.read<ChatInputCubit>().setReplyingToMessage(selectedMessage);
        handler.hideOverlay(onStateChanged: () => setState(() {}));
      },
      onCopy: () {
        handler.hideOverlay(onStateChanged: () => setState(() {}));
        _copyMessageText(selectedMessage);
      },
      onDetails: () {
        handler.hideOverlay(onStateChanged: () => setState(() {}));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageDetailsScreen(
              chatMessage: selectedMessage,
              readMessageIcon: AssetsData.readMessageIcon,
              deliveredMessageIcon: AssetsData.readMessageIcon,
            ),
          ),
        );
      },
      onSelect: () {
        context.read<MessageSelectionCubit>().enterSelectionMode(
          selectedMessage,
        );
        handler.hideOverlay(onStateChanged: () => setState(() {}));
      },
      onDeleteForMe: () {
        handler.hideOverlay(onStateChanged: () => setState(() {}));
        actionsHandler?.showDeleteConfirmationForSingleMessage(
          message: selectedMessage,
          deleteType: 'me',
        );
      },
      onDeleteForAll: () {
        handler.hideOverlay(onStateChanged: () => setState(() {}));
        actionsHandler?.showDeleteConfirmationForSingleMessage(
          message: selectedMessage,
          deleteType: 'everyone',
        );
      },
    );
  }
}
