import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/message_model.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversition/conversation_app_bar.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversition/conversation_context_menu.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversition/conversation_input_area.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversition/message_bubble.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversition/message_shimmer.dart';

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
  late List<Message> messages;
  final ScrollController _scrollController = ScrollController();

  String? _highlightedMessageId;

  // ✅ جديد - Map لتخزين GlobalKey لكل رسالة بناءً على الـ ID
  final Map<String, GlobalKey> _messageKeys = {};

  @override
  void initState() {
    super.initState();
    messages = [];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isOverlayVisible = false;
  ChatMessage? _selectedMessage;
  Message? _selectedOldMessage;
  Offset _messagePosition = Offset.zero;
  Size _messageSize = Size.zero;

  void _showOverlay(dynamic message, GlobalKey<State<StatefulWidget>> key) {
    setState(() {
      if (message is ChatMessage) {
        _selectedMessage = message;
        _selectedOldMessage = null;
      } else if (message is Message) {
        _selectedOldMessage = message;
        _selectedMessage = null;
      }
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
      _selectedOldMessage = null;
    });
  }

  // ✅ دالة محسّنة للتمرير إلى رسالة معينة
  void _scrollToMessage(String? messageId, List<ChatMessage> allMessages) {
    if (messageId == null) {
      log('⚠️ messageId is null');
      return;
    }

    log('🔍 Searching for message with ID: $messageId');

    // ✅ أولاً: البحث عن index الرسالة في القائمة
    final messageIndex = allMessages.indexWhere((msg) => msg.id == messageId);

    if (messageIndex == -1) {
      log('❌ Message not found in list: $messageId');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرسالة غير موجودة'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    log('✅ Found message at index: $messageIndex');

    // ✅ حساب الـ index المعكوس (لأن ListView بيستخدم reverse: true)
    final reversedIndex = allMessages.length - 1 - messageIndex;

    // ✅ الحصول على الـ GlobalKey للرسالة (أو إنشاؤه)
    _getOrCreateKey(messageId);

    // ✅ التحقق إذا الرسالة موجودة في الشاشة حالياً
    final targetKey = _messageKeys[messageId];
    final targetContext = targetKey?.currentContext;

    if (targetContext != null) {
      // ✅ الرسالة موجودة في الشاشة - نستخدم ensureVisible مباشرة
      log('✅ Message already visible, using ensureVisible');
      _scrollAndHighlight(targetContext, messageId);
    } else {
      // ✅ الرسالة مش موجودة في الشاشة - نحتاج نتمرر للـ index الأول
      log('📍 Message not visible, scrolling to estimated position first');

      // ✅ تقدير الموقع (متوسط ارتفاع الرسالة حوالي 80 بيكسل)
      final estimatedOffset = reversedIndex * 80.0;

      _scrollController
          .animateTo(
            estimatedOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          )
          .then((_) {
            // ✅ بعد التمرير، ننتظر الـ build ثم نتحقق من الـ context
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _tryScrollToMessageAfterBuild(messageId, reversedIndex);
            });
          });
    }
  }

  // ✅ دالة للمحاولة مرة أخرى بعد الـ build
  void _tryScrollToMessageAfterBuild(String messageId, int reversedIndex) {
    final targetKey = _messageKeys[messageId];
    final targetContext = targetKey?.currentContext;

    if (targetContext != null) {
      log('✅ Message now visible after scroll');
      _scrollAndHighlight(targetContext, messageId);
    } else {
      // ✅ محاولة أخرى بتعديل الموقع
      log('⚠️ Message still not visible, trying again...');

      // نحاول التمرير أكثر
      final newOffset = _scrollController.offset + 200;
      _scrollController
          .animateTo(
            newOffset,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          )
          .then((_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final retryContext = _messageKeys[messageId]?.currentContext;
              if (retryContext != null) {
                _scrollAndHighlight(retryContext, messageId);
              } else {
                log('❌ Could not find message after retries: $messageId');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('لم نتمكن من العثور على الرسالة'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            });
          });
    }
  }

  // ✅ دالة للتمرير والـ highlight
  void _scrollAndHighlight(BuildContext targetContext, String messageId) {
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.3,
    ).then((_) {
      setState(() {
        _highlightedMessageId = messageId;
      });

      log('✨ Highlighted message: $_highlightedMessageId');

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _highlightedMessageId = null;
          });
        }
      });
    });
  }

  // ✅ دالة للحصول على أو إنشاء GlobalKey لرسالة
  GlobalKey _getOrCreateKey(String messageId) {
    if (!_messageKeys.containsKey(messageId)) {
      _messageKeys[messageId] = GlobalKey();
    }
    return _messageKeys[messageId]!;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return BlocProvider(
      create: (context) {
        log('🚀 Creating ChatMessagesCubit for room: ${widget.chatRoomId}');
        final cubit = ChatMessagesCubit(getIt<ChatRepo>());
        cubit.getChatMessages(widget.chatRoomId!);
        cubit.listenToNewMessages();
        cubit.listenToUserTyping(widget.chatRoomId!);
        cubit.listenToMessagesRead();

        return cubit;
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: const Color(0xFFFDF7F8),
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: Stack(
              children: [
                Column(
                  children: [
                    // App Bar
                    ConversationAppBar(
                      username: widget.username,
                      userimage: widget.userimage,
                      videoIcon: AssetsData.videoIcon,
                      phoneIcon: AssetsData.phoneIcon,
                    ),

                    // Messages Area
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(AssetsData.homeBackgroundImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: BlocConsumer<ChatMessagesCubit, ChatMessagesState>(
                          listener: (context, state) {
                            log('📱 State Changed:');
                            log('   - isUserTyping: ${state.isUserTyping}');
                            log(
                              '   - typingInfo: ${state.typingInfo?.userName}',
                            );
                            log(
                              '   - messagesCount: ${state.messages?.length}',
                            );
                          },
                          builder: (context, state) {
                            // Loading State
                            if (state.getChatMessages == CubitStates.loading) {
                              return const MessageShimmer();
                            }

                            // Success State
                            if (state.getChatMessages == CubitStates.success) {
                              return Column(
                                children: [
                                  // Messages List
                                  Expanded(
                                    child: ListView.builder(
                                      reverse: true,
                                      controller: _scrollController,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 10 : 12,
                                        vertical: isMobile ? 6 : 8,
                                      ),
                                      itemCount: state.messages?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        final msg =
                                            state.messages![state
                                                    .messages!
                                                    .length -
                                                1 -
                                                index];

                                        // ✅ تحديد الـ ID للرسالة الحالية
                                        final currentMsgId = msg.id ?? '';

                                        // ✅ الحصول على GlobalKey للرسالة
                                        final messageKey =
                                            currentMsgId.isNotEmpty
                                            ? _getOrCreateKey(currentMsgId)
                                            : GlobalKey();

                                        // ✅ هل الرسالة مُحددة (highlighted)؟
                                        final isHighlighted =
                                            _highlightedMessageId != null &&
                                            currentMsgId ==
                                                _highlightedMessageId;

                                        return TweenAnimationBuilder<double>(
                                          tween: Tween(begin: 0.0, end: 1.0),
                                          duration: Duration(
                                            milliseconds: 300 + (index * 50),
                                          ),
                                          curve: Curves.easeOut,
                                          builder: (context, value, child) {
                                            return Transform.translate(
                                              offset: Offset(
                                                0,
                                                20 * (1 - value),
                                              ),
                                              child: Opacity(
                                                opacity: value,
                                                child: child,
                                              ),
                                            );
                                          },
                                          // ✅ وضع الـ key على Container خارجي
                                          child: Container(
                                            key: messageKey, // ✅ الـ key هنا
                                            child: GestureDetector(
                                              onLongPress: () =>
                                                  _showOverlay(msg, messageKey),
                                              child: MessageBubble(
                                                chatMessage: msg,
                                                readMessageIcon:
                                                    AssetsData.readMessageIcon,
                                                isHighlighted: isHighlighted,
                                                onReplyTap: (replyMessageId) {
                                                  _scrollToMessage(
                                                    replyMessageId,
                                                    state.messages!,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // ✅ Typing Indicator
                                  if (state.isUserTyping &&
                                      state.typingInfo != null)
                                    TypingIndicatorWidget(
                                      userName: state.typingInfo!.userName,
                                    ),
                                ],
                              );
                            }

                            // Error State
                            if (state.getChatMessages == CubitStates.failure) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      state.errorMessage ?? 'حدث خطأ ما',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        context
                                            .read<ChatMessagesCubit>()
                                            .getChatMessages(
                                              widget.chatRoomId!,
                                            );
                                      },
                                      child: const Text('إعادة المحاولة'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Initial State
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                    ),

                    // ✅ Input Area مع Typing callbacks والـ Reply
                    BlocBuilder<ChatMessagesCubit, ChatMessagesState>(
                      buildWhen: (previous, current) =>
                          previous.replyingToMessage !=
                          current.replyingToMessage,
                      builder: (builderContext, state) {
                        return ConversationInputArea(
                          sendMessageIcon: AssetsData.sendMessageIcon,
                          chatEmojiIcon: AssetsData.chatEmojiIcon,
                          cameraIcon: AssetsData.cameraIcon,
                          replyingToMessage: state.replyingToMessage,
                          onCancelReply: () {
                            builderContext
                                .read<ChatMessagesCubit>()
                                .cancelReply();
                          },
                          onSendMessage: (message) {
                            builderContext
                                .read<ChatMessagesCubit>()
                                .sendMessage(
                                  widget.receiverId!,
                                  message,
                                  widget.chatRoomId!,
                                );
                          },
                          onSendMedia: (files, messageType) {
                            builderContext
                                .read<ChatMessagesCubit>()
                                .sendMediaMessage(
                                  chatRoomId: widget.chatRoomId!,
                                  messageType: messageType,
                                  images: messageType == 'image' ? files : null,
                                  videos: messageType == 'video' ? files : null,
                                );
                          },
                          onTypingStart: () {
                            builderContext
                                .read<ChatMessagesCubit>()
                                .typingstart(widget.chatRoomId!);
                          },
                          onTypingStop: () {
                            builderContext.read<ChatMessagesCubit>().typingstop(
                              widget.chatRoomId!,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),

                // Overlay for Context Menu
                if (_isOverlayVisible &&
                    (_selectedMessage != null || _selectedOldMessage != null))
                  GestureDetector(
                    onTap: _hideOverlay,
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Stack(
                          children: [
                            Positioned(
                              top: _messagePosition.dy,
                              left: _messagePosition.dx,
                              width: screenSize.width - (isMobile ? 24 : 32),
                              child: Align(
                                alignment:
                                    (_selectedMessage?.isMe ??
                                        _selectedOldMessage?.isMe ??
                                        false)
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: MessageBubble(
                                  chatMessage: _selectedMessage,
                                  oldMessage: _selectedOldMessage,
                                  readMessageIcon: AssetsData.readMessageIcon,
                                  isOverlay: true,
                                ),
                              ),
                            ),
                            Positioned(
                              top:
                                  _messagePosition.dy + _messageSize.height + 8,
                              left:
                                  (_selectedMessage?.isMe ??
                                      _selectedOldMessage?.isMe ??
                                      false)
                                  ? null
                                  : _messagePosition.dx,
                              right:
                                  (_selectedMessage?.isMe ??
                                      _selectedOldMessage?.isMe ??
                                      false)
                                  ? screenSize.width -
                                        (_messagePosition.dx +
                                            _messageSize.width)
                                  : null,
                              child: Builder(
                                builder: (builderContext) {
                                  return ConversationContextMenu(
                                    isMyMessage:
                                        _selectedMessage?.isMe ??
                                        _selectedOldMessage?.isMe ??
                                        false,
                                    onReply: () {
                                      if (_selectedMessage != null) {
                                        builderContext
                                            .read<ChatMessagesCubit>()
                                            .setReplyingToMessage(
                                              _selectedMessage,
                                            );
                                      }
                                      _hideOverlay();
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ Typing Indicator Widget
class TypingIndicatorWidget extends StatefulWidget {
  final String userName;

  const TypingIndicatorWidget({super.key, required this.userName});

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.userName} يكتب الآن',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        final delay = index * 0.2;
                        final animValue = (_controller.value + delay) % 1.0;
                        final bounce = _calculateBounce(animValue);

                        return Transform.translate(
                          offset: Offset(0, bounce),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade500,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateBounce(double value) {
    if (value < 0.5) {
      return -6 * (value * 2);
    } else {
      return -6 + (6 * ((value - 0.5) * 2));
    }
  }
}
