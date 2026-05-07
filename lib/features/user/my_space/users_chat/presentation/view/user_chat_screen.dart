import 'dart:async';
import 'dart:developer';
import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/core/services/chat_socket_service.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/helpers/chat_room_dialog_helper.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/message_actions_handler.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/overlay_manager.dart';
import 'package:tayseer/features/advisor/chat/presentation/handler/scroll_behavior_handler.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_cubit_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/input/chat_input_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/typing/typing_cubit.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/chat_bottom_area.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/chat_context_menu_wrapper.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/chat_messages_area.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/conversation/scroll_to_bottom_button.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/state/chat_messages_state.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/scroll/chat_scroll_state.dart';
import 'package:tayseer/my_import.dart';

class UserChatScreen extends StatelessWidget {
  final String? chatRoomId;
  final String? receiverId;
  final String? username;
  final String? userimage;
  final bool isBlocked;

  const UserChatScreen({
    super.key,
    this.chatRoomId,
    this.receiverId,
    this.username,
    this.userimage,
    this.isBlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            log('🚀 Creating ChatMessagesCubit for user room: $chatRoomId');
            final cubit = getIt<ChatMessagesCubit>(param1: chatRoomId);
            cubit.setInitialBlocked(isBlocked);
            cubit.loadInitialMessages(chatRoomId!, receiverId: receiverId);
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
                if (!messagesCubit.isClosed)
                  messagesCubit.typingStart(chatRoomId!);
              },
              onTypingStop: () {
                if (!messagesCubit.isClosed)
                  messagesCubit.typingStop(chatRoomId!);
              },
            );
          },
        ),
      ],
      child: _UserChatContent(
        chatRoomId: chatRoomId,
        receiverId: receiverId,
        username: username,
        userimage: userimage,
        isBlocked: isBlocked,
      ),
    );
  }
}

class _UserChatContent extends StatefulWidget {
  final String? chatRoomId;
  final String? receiverId;
  final String? username;
  final String? userimage;
  final bool isBlocked;

  const _UserChatContent({
    this.chatRoomId,
    this.receiverId,
    this.username,
    this.userimage,
    this.isBlocked = false,
  });

  @override
  State<_UserChatContent> createState() => _UserChatContentState();
}

class _UserChatContentState extends State<_UserChatContent> {
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
    final chatSocketService = getIt<ChatSocketService>();
    _failEventSubscription = chatSocketService.onFailEvent.listen((message) {
      // suppress join-related fail — server returns this when chatRoomId is sent
      // without targetId; the chat still works correctly after chatRoomJoined
      if (message.contains('طلب غير صالح')) return;
      if (mounted) AppToast.error(context, message);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_handlersInitialized) {
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
  }

  @override
  void dispose() {
    _failEventSubscription?.cancel();
    _scrollHandler.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// ✅ يخرج من الشات ويبعت آخر رسالة حقيقية كـ result
  /// عشان الـ chat list يعرض الرسالة الصح بعد الحذف
  void _popWithLastMessage(BuildContext context) {
    if (_isPopping) return; // ✅ منع double pop
    _isPopping = true;

    final messages = context.read<ChatMessagesCubit>().state.messagesOrEmpty;
    if (messages.isNotEmpty) {
      final lastMsg = messages.first; // مرتبة من الأحدث للأقدم
      final content = lastMsg.contentList.isNotEmpty
          ? lastMsg.contentList.first
          : '';
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

  Future<void> _cancelMatch() async {
    try {
      final api = getIt<ApiService>();
      await api.post(
        endPoint: ApiEndPoint.userChatCancelMatch,
        data: {'chatRoomId': widget.chatRoomId},
      );
      if (mounted) {
        AppToast.success(context, context.tr('match_cancelled_success'));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) AppToast.error(context, context.tr('match_cancel_failed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return BlocBuilder<MessageSelectionCubit, MessageSelectionState>(
      buildWhen: (p, c) => p.isSelectionMode != c.isSelectionMode,
      builder: (context, selectionState) {
        return PopScope(
          canPop: false, // ✅ نتحكم في الـ pop يدوياً عشان نبعت الـ last message
          onPopInvokedWithResult: (didPop, result) {
            if (selectionState.isSelectionMode) {
              context.read<MessageSelectionCubit>().exitSelectionMode();
              return;
            }
            // ✅ ابعت آخر رسالة حقيقية لما يخرج (بيحل مشكلة الصورة/الصوت المحذوف)
            _popWithLastMessage(context);
          },
          child: SafeArea(
            top: false,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: ChatColors.chatBackground,
              body: Directionality(
                textDirection: TextDirection.rtl,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _buildAppBar(context),
                        _buildExpiryBanner(context),
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
                                  showFreeChatBanner: false,
                                ),
                                _buildScrollToBottomButton(),
                              ],
                            ),
                          ),
                        ),
                        ChatBottomArea(
                          chatRoomId: widget.chatRoomId,
                          receiverId: widget.receiverId,
                          isSystemChat: false,
                          selectionState: selectionState,
                          actionsHandler: _actionsHandler,
                          scrollHandler: _scrollHandler,
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

  Widget _buildExpiryBanner(BuildContext context) {
    return BlocBuilder<ChatMessagesCubit, ChatMessagesState>(
      buildWhen: (p, c) => p.chatExpiresAt != c.chatExpiresAt,
      builder: (context, state) {
        final expiresAt = state.chatExpiresAt;
        if (expiresAt == null) return const SizedBox.shrink();

        final now = DateTime.now();
        final diff = expiresAt.difference(now);
        if (diff.isNegative) return const SizedBox.shrink();

        final days = diff.inDays;
        final hours = diff.inHours % 24;
        final minutes = diff.inMinutes % 60;

        final parts = <String>[];
        if (days > 0)
          parts.add(context.tr('expiry_days').replaceAll('{n}', '$days'));
        if (hours > 0)
          parts.add(context.tr('expiry_hours').replaceAll('{n}', '$hours'));
        if (minutes > 0)
          parts.add(context.tr('expiry_minutes').replaceAll('{n}', '$minutes'));
        final timeStr = parts.join(' ');

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.primary50,
          ),
          child: Text(
            context.tr('match_expiry_banner').replaceAll('{time}', timeStr),
            style: Styles.textStyle14.copyWith(
              color: AppColors.primary400,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildScrollToBottomButton() {
    return BlocBuilder<ChatScrollCubit, ChatScrollState>(
      buildWhen: (p, c) => p.isAtBottom != c.isAtBottom,
      builder: (context, state) {
        return ScrollToBottomButton(
          isVisible: !state.isAtBottom,
          onPressed: () => _scrollHandler.scrollToBottom(force: true),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return BlocBuilder<ChatMessagesCubit, ChatMessagesState>(
      buildWhen: (p, c) => p.isBlocked != c.isBlocked,
      builder: (context, chatState) {
        return Container(
          padding: EdgeInsets.only(
            top: 50.h,
            bottom: 10.h,
            left: 16.w,
            right: 8.w,
          ),
          color: const Color(0xFFF9EEFA),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _popWithLastMessage(context),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // ✅ افتح البروفايل لما يضغط على الاسم أو الصورة
                    if (widget.receiverId != null) {
                      context.pushNamed(
                        AppRouter.kUserPublicProfileView,
                        arguments: widget.receiverId,
                      );
                    }
                  },

                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundImage: NetworkImage(
                          widget.userimage ?? 'https://i.pravatar.cc/150',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          widget.username ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<String>(
                offset: const Offset(20, 50),
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.black87,
                  size: 24,
                ),
                color: const Color(0xFFF5F6F8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                onSelected: (value) async {
                  switch (value) {
                    case 'cancel_match':
                      ChatRoomDialogHelper.showCancelMatchDialog(
                        context: context,
                        title: context.tr('cancel_match_title'),
                        subtitle: context
                            .tr('cancel_match_confirm')
                            .replaceAll('{name}', widget.username ?? ''),
                        onConfirm: _cancelMatch,
                      );
                      break;
                    case 'report':
                      ChatRoomDialogHelper.showReportDialog(
                        context: context,
                        title: context.tr('report_menu'),
                        subtitle: context.tr('report_confirm_subtitle'),
                        onConfirm: () {
                          context.pushNamed(
                            AppRouter.kReportsView,
                            arguments: {
                              'type': ReportType.user,
                              'id': widget.receiverId ?? '',
                            },
                          );
                        },
                      );
                      break;
                    case 'block':
                      if (chatState.isBlocked) {
                        ChatRoomDialogHelper.showUnblockDialog(
                          context: context,
                          title: context.tr('unblock_label'),
                          subtitle: context.tr('unblock_confirm_subtitle'),
                          onConfirm: () async {
                            await context.read<ChatMessagesCubit>().unblockUser(
                              blockedId: widget.receiverId!,
                            );
                          },
                        );
                      } else {
                        ChatRoomDialogHelper.showBlockDialog(
                          context: context,
                          title: context.tr('block_label'),
                          subtitle: context.tr('block_confirm_subtitle'),
                          onConfirm: () async {
                            await context.read<ChatMessagesCubit>().blockUser(
                              blockedId: widget.receiverId!,
                            );
                          },
                        );
                      }
                      break;
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'cancel_match',
                    child: Row(
                      children: [
                        const Icon(Icons.cancel_outlined, size: 20),
                        SizedBox(width: 8.w),
                        Text(
                          context.tr('cancel_match_menu'),
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20),
                        SizedBox(width: 8.w),
                        Text(
                          context.tr('report_menu'),
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        const Icon(Icons.block_outlined, size: 20),
                        SizedBox(width: 8.w),
                        Text(
                          chatState.isBlocked
                              ? context.tr('unblock_label')
                              : context.tr('block_label'),
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
