import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/services/chat_socket_service.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/widgets/app_toast.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/message_actions_handler.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/overlay_manager.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/scroll_behavior_handler.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_cubit_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/input/chat_input_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/typing/typing_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/chat_app_bar_wrapper.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/chat_bottom_area.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/chat_context_menu_wrapper.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/chat_messages_area.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/scroll_to_bottom_button.dart';

class AdvisorChatScreen extends StatelessWidget {
  final String? chatRoomId;
  final String? receiverId;
  final String? username;
  final String? userimage;
  final bool isBlocked;
  final bool isHaveSession;
  final bool isSystemChat;
  final void Function(bool isBlocked)? onBlockStatusChanged;

  const AdvisorChatScreen({
    super.key,
    this.chatRoomId,
    this.receiverId,
    this.username,
    this.userimage,
    this.isBlocked = false,
    this.isHaveSession = true,
    this.isSystemChat = false,
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
            // ✅ FIX: Only call loadInitialMessages - it handles setupSocketListeners internally
            // Do NOT call cubit.setupSocketListeners() here separately
            cubit.loadInitialMessages(
              chatRoomId!,
              receiverId: receiverId,
              isSystemChat: isSystemChat,
            );
            return cubit;
          },
        ),
        BlocProvider(create: (_) => ChatScrollCubit()),
        BlocProvider(create: (_) => MessageSelectionCubit()),
        BlocProvider(
          create: (_) => TypingCubit()..listenToUserTyping(chatRoomId!),
        ),
        BlocProvider(
          create: (context) {
            final messagesCubit = context.read<ChatMessagesCubit>();
            return ChatInputCubit(
              onTypingStart: () {
                if (!messagesCubit.isClosed) {
                  messagesCubit.typingStart(chatRoomId!);
                }
              },
              onTypingStop: () {
                if (!messagesCubit.isClosed) {
                  messagesCubit.typingStop(chatRoomId!);
                }
              },
            );
          },
        ),
      ],
      child: _ChatContent(
        chatRoomId: chatRoomId,
        receiverId: receiverId,
        username: username,
        userimage: userimage,
        isBlocked: isBlocked,
        isHaveSession: isHaveSession,
        isSystemChat: isSystemChat,
        onBlockStatusChanged: onBlockStatusChanged,
      ),
    );
  }
}

class _ChatContent extends StatefulWidget {
  final String? chatRoomId;
  final String? receiverId;
  final String? username;
  final String? userimage;
  final bool isBlocked;
  final bool isHaveSession;
  final bool isSystemChat;
  final void Function(bool isBlocked)? onBlockStatusChanged;

  const _ChatContent({
    this.chatRoomId,
    this.receiverId,
    this.username,
    this.userimage,
    this.isBlocked = false,
    this.isHaveSession = true,
    this.isSystemChat = false,
    this.onBlockStatusChanged,
  });

  @override
  State<_ChatContent> createState() => _ChatContentState();
}

class _ChatContentState extends State<_ChatContent> {
  late final ScrollController _scrollController;
  late final ScrollBehaviorHandler _scrollHandler;
  late final OverlayManager _overlayManager;
  late final MessageActionsHandler _actionsHandler;
  StreamSubscription<String>? _failEventSubscription;
  bool _handlersInitialized = false;
  bool _isPopping = false; // ✅ guard ضد double pop

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _setupFailEventListener();
  }

  void _setupFailEventListener() {
    final chatSocketService = getIt<ChatSocketService>();
    _failEventSubscription = chatSocketService.onFailEvent.listen((message) {
      if (message.contains('طلب غير صالح')) return;
      if (mounted) {
        AppToast.error(context, message);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_handlersInitialized) {
      _initializeHandlers();
      _handlersInitialized = true;
    }
  }

  void _initializeHandlers() {
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
  }

  @override
  void dispose() {
    _failEventSubscription?.cancel();
    _scrollHandler.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// ✅ يخرج من الشات ويبعت آخر رسالة حقيقية كـ result
  void _popWithLastMessage(BuildContext context) {
    if (_isPopping) return;
    _isPopping = true;

    final messages = context.read<ChatMessagesCubit>().state.messagesOrEmpty;
    if (messages.isNotEmpty) {
      final lastMsg = messages.first; // مرتبة من الأحدث للأقدم
      final content = _contentForDisplay(lastMsg);
      final sentAt = DateTime.tryParse(lastMsg.createdAt) ?? DateTime.now();
      Navigator.pop(context, {
        'lastMessage': content,
        'sentAt': sentAt,
        'status': lastMsg.status.name,
      });
    } else {
      Navigator.pop(context);
    }
  }

  /// ✅ يحوّل الـ messageType لـ keyword موحد للعرض في الـ chat list
  static String _contentForDisplay(ChatMessage msg) {
    switch (msg.messageType) {
      case 'audio':
      case 'record':
      case 'voice':
        return 'audio';
      case 'image':
      case 'photo':
      case 'media':
      case 'images/videos':
        return 'image';
      case 'video':
        return 'video';
      case 'file':
      case 'document':
        return 'file';
      default:
        return msg.contentList.isNotEmpty ? msg.contentList.first : '';
    }
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
            if (selectionState.isSelectionMode) {
              if (!didPop) {
                context.read<MessageSelectionCubit>().exitSelectionMode();
              }
              return;
            }
            if (didPop) return;
            _popWithLastMessage(context);
          },
          child: SafeArea(
            top: false,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: ChatColors.chatBackground,
              body: Directionality(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        ChatAppBarWrapper(
                          username: widget.username,
                          userimage: widget.userimage,
                          receiverId: widget.receiverId,
                          isSystemChat: widget.isSystemChat,
                          onBlockStatusChanged: widget.onBlockStatusChanged,
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
                                ChatMessagesArea(
                                  isMobile: isMobile,
                                  scrollController: _scrollController,
                                  scrollHandler: _scrollHandler,
                                  overlayManager: _overlayManager,
                                  onStateChanged: () => setState(() {}),
                                ),
                                _buildScrollToBottomButton(),
                              ],
                            ),
                          ),
                        ),
                        ChatBottomArea(
                          chatRoomId: widget.chatRoomId,
                          receiverId: widget.receiverId,
                          isSystemChat: widget.isSystemChat,
                          selectionState: selectionState,
                          actionsHandler: _actionsHandler,
                          scrollHandler: _scrollHandler,
                          onBlockStatusChanged: widget.onBlockStatusChanged,
                        ),
                      ],
                    ),
                    ChatContextMenuWrapper(
                      screenSize: screenSize,
                      isMobile: isMobile,
                      overlayManager: _overlayManager,
                      actionsHandler: _actionsHandler,
                      onStateChanged: () => setState(() {}),
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

  Widget _buildScrollToBottomButton() {
    return BlocBuilder<ChatScrollCubit, ChatScrollState>(
      buildWhen: (previous, current) =>
          previous.isAtBottom != current.isAtBottom,
      builder: (context, state) {
        return ScrollToBottomButton(
          isVisible: !state.isAtBottom,
          onPressed: () => _scrollHandler.scrollToBottom(force: true),
        );
      },
    );
  }
}
