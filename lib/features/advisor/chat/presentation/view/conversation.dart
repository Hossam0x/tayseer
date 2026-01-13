import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/state/chat_messages_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/input/chat_input_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/typing/typing_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/typing/typing_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/view/message_details.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/block_action_area.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/conversation_app_bar.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/conversation_context_menu.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/message_shimmer.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/typing_indicator.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/scroll_to_bottom_button.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/selectable_message_list_view.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/selection_bottom_bar.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/conversation_input_area.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/bubble/message_bubble.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';

class ChatScreenWithOverlay extends StatefulWidget {
  final String? chatRoomId;
  final String? receiverId;
  final String? username;
  final String? userimage;
  final bool isBlocked;
  final void Function(bool isBlocked)? onBlockStatusChanged;

  const ChatScreenWithOverlay({
    super.key,
    this.chatRoomId,
    this.receiverId,
    this.username,
    this.userimage,
    this.isBlocked = false,
    this.onBlockStatusChanged,
  });

  @override
  State<ChatScreenWithOverlay> createState() => _ChatScreenWithOverlayState();
}

class _ChatScreenWithOverlayState extends State<ChatScreenWithOverlay> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _messageKeys = {};

  int _previousMessageCount = 0;
  bool _isFirstLoad = true;

  bool _isOverlayVisible = false;
  ChatMessage? _selectedMessage;
  Offset _messagePosition = Offset.zero;
  Size _messageSize = Size.zero;

  ChatScrollCubit? _scrollCubit;

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener(ChatScrollCubit scrollCubit) {
    if (_scrollCubit == null) {
      _scrollCubit = scrollCubit;
      _scrollController.addListener(_onScroll);
    }
  }

  void _onScroll() {
    final isAtBottom = _scrollController.offset <= 100;
    _scrollCubit?.setAtBottom(isAtBottom);
  }

  void _scrollToBottom({bool animate = true, bool force = false}) {
    if (!_scrollController.hasClients) return;

    final scrollState = _scrollCubit?.state;
    if (scrollState != null && !scrollState.isAtBottom && !force) {
      log('📍 User is not at bottom, skipping auto-scroll');
      return;
    }

    log('⬇️ Scrolling to bottom (animate: $animate, force: $force)');

    if (animate) {
      _scrollController.animateTo(
        0.0,
        duration: ChatAnimations.scrollDuration,
        curve: ChatAnimations.defaultCurve,
      );
    } else {
      _scrollController.jumpTo(0.0);
    }
  }

  void _scrollToBottomAfterSend() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _scrollToBottom(animate: true, force: true);
      }
    });
  }

  void _scrollToBottomOnFirstLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
        _scrollCubit?.setAtBottom(true);
      }
    });
  }

  void _showOverlay(ChatMessage message, GlobalKey key) {
    setState(() {
      _selectedMessage = message;
      _isOverlayVisible = true;

      final RenderBox? renderBox =
          key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        _messagePosition = renderBox.localToGlobal(Offset.zero);
        _messageSize = renderBox.size;
      }
    });
  }

  void _hideOverlay() {
    setState(() {
      _isOverlayVisible = false;
      _selectedMessage = null;
    });
  }

  void _openMessageDetails() {
    final selectedMessage = _selectedMessage;
    _hideOverlay();
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
  }

  void _scrollToMessage(String? messageId, List<ChatMessage> allMessages) {
    if (messageId == null) return;

    final messageIndex = allMessages.indexWhere((msg) => msg.id == messageId);
    if (messageIndex == -1) return;

    final reversedIndex = allMessages.length - 1 - messageIndex;
    _getOrCreateKey(messageId);

    final targetKey = _messageKeys[messageId];
    final targetContext = targetKey?.currentContext;

    if (targetContext != null) {
      _scrollAndHighlight(targetContext, messageId);
    } else {
      final estimatedOffset = reversedIndex * 80.0;
      _scrollController
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

  void _tryScrollToMessageAfterBuild(String messageId) {
    final targetKey = _messageKeys[messageId];
    final targetContext = targetKey?.currentContext;

    if (targetContext != null) {
      _scrollAndHighlight(targetContext, messageId);
    }
  }

  void _scrollAndHighlight(BuildContext targetContext, String messageId) {
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.3,
    ).then((_) {
      _scrollCubit?.setHighlightedMessageId(messageId);

      Future.delayed(ChatAnimations.highlightDuration, () {
        if (mounted) {
          _scrollCubit?.clearHighlight();
        }
      });
    });
  }

  GlobalKey _getOrCreateKey(String messageId) {
    if (!_messageKeys.containsKey(messageId)) {
      _messageKeys[messageId] = GlobalKey();
    }
    return _messageKeys[messageId]!;
  }

  void _showDeleteConfirmationForSingleMessage(
    BuildContext blocContext,
    String deleteType,
    ChatMessage message,
  ) {
    final isDeleteForAll = deleteType == 'everyone';
    final title = isDeleteForAll ? 'حذف لدى الجميع' : 'حذف لديّ';
    final content = isDeleteForAll
        ? 'هل أنت متأكد من حذف هذه الرسالة لدى الجميع؟'
        : 'هل أنت متأكد من حذف هذه الرسالة لديك فقط؟';

    // حفظ reference للـ cubit قبل فتح الـ dialog
    final cubit = blocContext.read<ChatMessagesCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(content, style: const TextStyle(fontFamily: 'Cairo')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);

                  final success = await cubit.deleteMessages(
                    messageIds: [message.id],
                    deleteType: deleteType,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success ? 'تم حذف الرسالة' : 'فشل حذف الرسالة',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                child: const Text(
                  'حذف',
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Handle delete for selected messages (multi-select mode)
  void _handleDeleteSelected(BuildContext blocContext, String deleteType) {
    final selectionCubit = blocContext.read<MessageSelectionCubit>();
    final selectedIds = selectionCubit.getSelectedMessageIds();

    if (selectedIds.isEmpty) return;

    final isDeleteForAll = deleteType == 'everyone';
    final count = selectedIds.length;
    final title = isDeleteForAll ? 'حذف لدى الجميع' : 'حذف لديّ';
    final content = isDeleteForAll
        ? 'هل أنت متأكد من حذف $count رسالة لدى الجميع؟'
        : 'هل أنت متأكد من حذف $count رسالة لديك فقط؟';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(content, style: const TextStyle(fontFamily: 'Cairo')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);

                  final success = await blocContext
                      .read<ChatMessagesCubit>()
                      .deleteMessages(
                        messageIds: selectedIds,
                        deleteType: deleteType,
                      );

                  // Exit selection mode after delete
                  selectionCubit.exitSelectionMode();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success ? 'تم حذف الرسائل' : 'فشل حذف الرسائل',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                child: const Text(
                  'حذف',
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            log(
              '🚀 Creating ChatMessagesCubit (Refactored) for room: ${widget.chatRoomId}',
            );
            final cubit = getIt<ChatMessagesCubit>(param1: widget.chatRoomId);
            // تعيين حالة الحظر الأولية
            cubit.setInitialBlocked(widget.isBlocked);
            // Load from local DB first, then sync with server
            cubit.loadInitialMessages(
              widget.chatRoomId!,
              receiverId: widget.receiverId,
            );
            cubit.setupSocketListeners();
            return cubit;
          },
        ),
        BlocProvider(create: (_) => ChatScrollCubit()),
        BlocProvider(create: (_) => MessageSelectionCubit()),
        BlocProvider(
          create: (_) => TypingCubit()..listenToUserTyping(widget.chatRoomId!),
        ),
        BlocProvider(
          create: (context) => ChatInputCubit(
            onTypingStart: () => context.read<ChatMessagesCubit>().typingStart(
              widget.chatRoomId!,
            ),
            onTypingStop: () => context.read<ChatMessagesCubit>().typingStop(
              widget.chatRoomId!,
            ),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          _setupScrollListener(context.read<ChatScrollCubit>());
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
                              // App bar عادي دائماً (بدون تغيير في selection mode)
                              ConversationAppBar(
                                username: widget.username,
                                userimage: widget.userimage,
                                videoIcon: AssetsData.videoIcon,
                                phoneIcon: AssetsData.phoneIcon,
                                receiverId: widget.receiverId,
                                onBlockUser: (blockedId) async {
                                  // حظر فوري بدون انتظار
                                  await context
                                      .read<ChatMessagesCubit>()
                                      .blockUser(blockedId: blockedId);
                                  // Notify parent about block status change
                                  widget.onBlockStatusChanged?.call(true);
                                },
                              ),
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
                                      _buildMessagesArea(isMobile),
                                      _buildScrollToBottomButton(),
                                    ],
                                  ),
                                ),
                              ),
                              // Show input area or selection bottom bar
                              BlocBuilder<ChatMessagesCubit, ChatMessagesState>(
                                builder: (context, messageState) {
                                  if (selectionState.isSelectionMode) {
                                    return SelectionBottomBar(
                                      onDeleteForMe: () =>
                                          _handleDeleteSelected(context, 'me'),
                                      onDeleteForAll: () =>
                                          _handleDeleteSelected(
                                            context,
                                            'everyone',
                                          ),
                                      onCancel: () => context
                                          .read<MessageSelectionCubit>()
                                          .exitSelectionMode(),
                                    );
                                  } else if (messageState.isBlocked) {
                                    return BlockedActionArea(
                                      onUnblockTap: () async {
                                        if (widget.receiverId != null) {
                                          await context
                                              .read<ChatMessagesCubit>()
                                              .unblockUser(
                                                blockedId: widget.receiverId!,
                                              );
                                          // Notify parent about block status change
                                          widget.onBlockStatusChanged?.call(
                                            false,
                                          );
                                        }
                                      },
                                      onDeleteChatTap: () {
                                        // TODO: Implement delete chat
                                      },
                                    );
                                  } else {
                                    return _buildInputArea();
                                  }
                                },
                              ),
                            ],
                          ),
                          if (_isOverlayVisible && _selectedMessage != null)
                            _buildContextMenuOverlay(screenSize, isMobile),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Build the app bar shown during selection mode
  Widget _buildMessagesArea(bool isMobile) {
    return BlocConsumer<ChatMessagesCubit, ChatMessagesState>(
      listenWhen: (previous, current) =>
          previous.messages.length != current.messages.length ||
          previous.loadingState != current.loadingState,
      listener: (context, state) {
        final currentCount = state.messages.length;

        if (state.loadingState == CubitStates.success &&
            _isFirstLoad &&
            currentCount > 0) {
          _isFirstLoad = false;
          _previousMessageCount = currentCount;
          _scrollToBottomOnFirstLoad();
          return;
        }

        if (currentCount > _previousMessageCount && _previousMessageCount > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom(animate: true);
          });
        }

        _previousMessageCount = currentCount;
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
              // Offline indicator
              if (!state.isOnline)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.orange.shade100,
                  child: const Text(
                    'أنت غير متصل - سيتم إرسال الرسائل عند الاتصال',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                ),
              // Pending messages indicator - removed as per user request
              // if (state.pendingCount > 0)
              //   Container(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 8,
              //       vertical: 2,
              //     ),
              //     child: Text(
              //       '${state.pendingCount} رسالة قيد الإرسال...',
              //       style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              //     ),
              //   ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    // Load older messages when scrolling to top
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
                      HapticFeedback.vibrate();
                      _showOverlay(message, key);
                    },
                    onReplyTap: _scrollToMessage,
                  ),
                ),
              ),
              BlocBuilder<TypingCubit, TypingState>(
                builder: (context, typingState) {
                  if (typingState.isUserTyping &&
                      typingState.typingInfo != null) {
                    return TypingIndicator(
                      userName: typingState.typingInfo!.userName,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          );
        }

        if (state.loadingState == CubitStates.failure) {
          return _buildErrorState(context, state);
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildScrollToBottomButton() {
    return BlocBuilder<ChatScrollCubit, ChatScrollState>(
      buildWhen: (previous, current) =>
          previous.isAtBottom != current.isAtBottom,
      builder: (context, state) {
        return ScrollToBottomButton(
          isVisible: !state.isAtBottom,
          onPressed: () => _scrollToBottom(force: true),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Builder(
      builder: (context) {
        return ConversationInputArea(
          sendMessageIcon: AssetsData.sendMessageIcon,
          chatEmojiIcon: AssetsData.chatEmojiIcon,
          cameraIcon: AssetsData.cameraIcon,
          onSendMessage: (message, replyMessageId) {
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
            _scrollToBottomAfterSend();
          },
          onSendMedia: (files, messageType, replyMessageId) {
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
            _scrollToBottomAfterSend();
          },
          onTypingStart: () {
            context.read<ChatMessagesCubit>().typingStart(widget.chatRoomId!);
          },
          onTypingStop: () {
            context.read<ChatMessagesCubit>().typingStop(widget.chatRoomId!);
          },
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, ChatMessagesState state) {
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

  Widget _buildContextMenuOverlay(Size screenSize, bool isMobile) {
    // حساب ارتفاع الـ Context Menu التقريبي
    // كل عنصر ~44 بكسل + padding
    final isMyMessage = _selectedMessage?.isMe ?? false;
    final menuItemCount = isMyMessage
        ? 5
        : 3; // 5 عناصر لرسائلي، 3 للرسائل الأخرى
    const menuItemHeight = 44.0;
    const menuPadding = 16.0;
    final estimatedMenuHeight = (menuItemCount * menuItemHeight) + menuPadding;

    // المساحة المتاحة تحت الرسالة
    final bottomPosition = _messagePosition.dy + _messageSize.height + 8;
    final availableSpaceBelow = screenSize.height - bottomPosition;

    // لو المساحة تحت مش كافية، نعرض الـ Menu فوق الرسالة
    final shouldShowAbove = availableSpaceBelow < estimatedMenuHeight;

    // حساب موقع الرسالة - لو هنعرض الـ Menu فوق، محتاج نعدل موقع الرسالة كمان
    final double messageTopPosition;
    final double menuTopPosition;

    if (shouldShowAbove) {
      // الـ Menu فوق الرسالة
      final safeTopMargin =
          MediaQuery.of(context).padding.top + 80; // AppBar + safe area
      menuTopPosition = (_messagePosition.dy - estimatedMenuHeight - 8).clamp(
        safeTopMargin,
        screenSize.height,
      );
      messageTopPosition = menuTopPosition + estimatedMenuHeight + 8;
    } else {
      // الـ Menu تحت الرسالة (الوضع الافتراضي)
      messageTopPosition = _messagePosition.dy;
      menuTopPosition = bottomPosition;
    }

    return GestureDetector(
      onTap: _hideOverlay,
      child: Container(
        color: ChatColors.overlayBackground,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Stack(
            children: [
              Positioned(
                top: messageTopPosition,
                left: _messagePosition.dx,
                width: screenSize.width - (isMobile ? 24 : 32),
                child: Align(
                  alignment: isMyMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: MessageBubble(
                    chatMessage: _selectedMessage,
                    isOverlay: true,
                  ),
                ),
              ),
              Positioned(
                top: menuTopPosition,
                left: isMyMessage ? null : _messagePosition.dx,
                right: isMyMessage
                    ? screenSize.width -
                          (_messagePosition.dx + _messageSize.width)
                    : null,
                child: Builder(
                  builder: (builderContext) {
                    return ConversationContextMenu(
                      isMyMessage: isMyMessage,
                      onReply: () {
                        if (_selectedMessage != null) {
                          builderContext
                              .read<ChatInputCubit>()
                              .setReplyingToMessage(_selectedMessage);
                        }
                        _hideOverlay();
                      },
                      onDetails: _openMessageDetails,
                      onSelect: () {
                        if (_selectedMessage != null) {
                          builderContext
                              .read<MessageSelectionCubit>()
                              .enterSelectionMode(_selectedMessage!);
                        }
                        _hideOverlay();
                      },
                      onDeleteForMe: () {
                        if (_selectedMessage != null) {
                          final messageToDelete = _selectedMessage!;
                          _hideOverlay();
                          _showDeleteConfirmationForSingleMessage(
                            builderContext,
                            'me',
                            messageToDelete,
                          );
                        }
                      },
                      onDeleteForAll: () {
                        if (_selectedMessage != null) {
                          final messageToDelete = _selectedMessage!;
                          _hideOverlay();
                          _showDeleteConfirmationForSingleMessage(
                            builderContext,
                            'everyone',
                            messageToDelete,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
