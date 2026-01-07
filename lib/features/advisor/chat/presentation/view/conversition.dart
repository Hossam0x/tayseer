import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/input/chat_input_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/typing/typing_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/typing/typing_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/view/message_details.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversition/conversation_app_bar.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversition/conversation_context_menu.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversition/message_shimmer.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversition/typing_indicator.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversition/scroll_to_bottom_button.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversition/message_list_view.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversition/conversation_input_area.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/bubble/message_bubble.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';

class ChatScreenWithOverlay extends StatefulWidget {
  final String? chatRoomId;
  final String? receiverId;
  final String? username;
  final String? userimage;

  const ChatScreenWithOverlay({
    super.key,
    this.chatRoomId,
    this.receiverId,
    this.username,
    this.userimage,
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

  void _showDeleteConfirmation(BuildContext blocContext) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'حذف الرسالة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'هل أنت متأكد من حذف هذه الرسالة؟',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف الرسالة'),
                      backgroundColor: Colors.red,
                    ),
                  );
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
            log('🚀 Creating ChatMessagesCubit for room: ${widget.chatRoomId}');
            final cubit = ChatMessagesCubit(getIt<ChatRepo>());
            cubit.getChatMessages(widget.chatRoomId!);
            cubit.listenToNewMessages();
            cubit.listenToUserTyping(widget.chatRoomId!);
            cubit.listenToMessagesRead();
            return cubit;
          },
        ),
        BlocProvider(create: (_) => ChatScrollCubit()),
        BlocProvider(
          create: (_) => TypingCubit()..listenToUserTyping(widget.chatRoomId!),
        ),
        BlocProvider(
          create: (context) => ChatInputCubit(
            onTypingStart: () => context.read<ChatMessagesCubit>().typingstart(
              widget.chatRoomId!,
            ),
            onTypingStop: () => context.read<ChatMessagesCubit>().typingstop(
              widget.chatRoomId!,
            ),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          _setupScrollListener(context.read<ChatScrollCubit>());
          return SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: ChatColors.chatBackground,
              body: Directionality(
                textDirection: TextDirection.rtl,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        ConversationAppBar(
                          username: widget.username,
                          userimage: widget.userimage,
                          videoIcon: AssetsData.videoIcon,
                          phoneIcon: AssetsData.phoneIcon,
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
                        _buildInputArea(),
                      ],
                    ),
                    if (_isOverlayVisible && _selectedMessage != null)
                      _buildContextMenuOverlay(screenSize, isMobile),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessagesArea(bool isMobile) {
    return BlocConsumer<ChatMessagesCubit, ChatMessagesState>(
      listenWhen: (previous, current) =>
          previous.messages?.length != current.messages?.length ||
          previous.getChatMessages != current.getChatMessages,
      listener: (context, state) {
        final currentCount = state.messages?.length ?? 0;

        if (state.getChatMessages == CubitStates.success &&
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
          previous.getChatMessages != current.getChatMessages ||
          previous.messages != current.messages,
      builder: (context, state) {
        if (state.getChatMessages == CubitStates.loading) {
          return const MessageShimmer();
        }

        if (state.getChatMessages == CubitStates.success) {
          return Column(
            children: [
              Expanded(
                child: MessageListView(
                  messages: state.messages ?? [],
                  scrollController: _scrollController,
                  onMessageLongPress: (message, key) =>
                      _showOverlay(message, key),
                  onReplyTap: _scrollToMessage,
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

        if (state.getChatMessages == CubitStates.failure) {
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
            context.read<ChatMessagesCubit>().sendMessage(
              widget.receiverId!,
              message,
              widget.chatRoomId!,
              replyMessageId: replyMessageId,
            );
            _scrollToBottomAfterSend();
          },
          onSendMedia: (files, messageType, replyMessageId) {
            context.read<ChatMessagesCubit>().sendMediaMessage(
              chatRoomId: widget.chatRoomId!,
              messageType: messageType,
              images: messageType == 'image' ? files : null,
              videos: messageType == 'video' ? files : null,
              replyMessageId: replyMessageId,
            );
            _scrollToBottomAfterSend();
          },
          onTypingStart: () {
            context.read<ChatMessagesCubit>().typingstart(widget.chatRoomId!);
          },
          onTypingStop: () {
            context.read<ChatMessagesCubit>().typingstop(widget.chatRoomId!);
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
              context.read<ChatMessagesCubit>().getChatMessages(
                widget.chatRoomId!,
              );
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildContextMenuOverlay(Size screenSize, bool isMobile) {
    return GestureDetector(
      onTap: _hideOverlay,
      child: Container(
        color: ChatColors.overlayBackground,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Stack(
            children: [
              Positioned(
                top: _messagePosition.dy,
                left: _messagePosition.dx,
                width: screenSize.width - (isMobile ? 24 : 32),
                child: Align(
                  alignment: (_selectedMessage?.isMe ?? false)
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: MessageBubble(
                    chatMessage: _selectedMessage,
                    isOverlay: true,
                  ),
                ),
              ),
              Positioned(
                top: _messagePosition.dy + _messageSize.height + 8,
                left: (_selectedMessage?.isMe ?? false)
                    ? null
                    : _messagePosition.dx,
                right: (_selectedMessage?.isMe ?? false)
                    ? screenSize.width -
                          (_messagePosition.dx + _messageSize.width)
                    : null,
                child: Builder(
                  builder: (builderContext) {
                    return ConversationContextMenu(
                      isMyMessage: _selectedMessage?.isMe ?? false,
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
                        _hideOverlay();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم التحديد'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      onDeleteForMe: () {
                        _hideOverlay();
                        _showDeleteConfirmation(builderContext);
                      },
                      onDeleteForAll: () {
                        _hideOverlay();
                        _showDeleteConfirmation(builderContext);
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
