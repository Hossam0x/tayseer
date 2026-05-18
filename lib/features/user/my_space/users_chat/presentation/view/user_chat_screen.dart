import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/core/services/chat_socket_service.dart';
import 'package:tayseer/core/services/secure_window_service.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/widgets/chat_room_list_item/helpers/chat_room_dialog_helper.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
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
import 'package:tayseer/features/user/interactions/data/Model/interaction_usermodel%20.dart';
import 'package:tayseer/my_import.dart';

class UserChatScreen extends StatelessWidget {
  final String? chatRoomId;
  final String? receiverId;
  final String? username;
  final String? userimage;
  final bool isImageBlurred;
  final bool myImageBlur;
  final bool blurMyImageFromOtherUser;
  final bool isBlocked;

  const UserChatScreen({
    super.key,
    this.chatRoomId,
    this.receiverId,
    this.username,
    this.userimage,
    this.isImageBlurred = false,
    this.myImageBlur = false,
    this.blurMyImageFromOtherUser = true,
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
        isImageBlurred: isImageBlurred,
        myImageBlur: myImageBlur,
        blurMyImageFromOtherUser: blurMyImageFromOtherUser,
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
  final bool isImageBlurred;
  final bool myImageBlur;
  final bool blurMyImageFromOtherUser;
  final bool isBlocked;

  const _UserChatContent({
    this.chatRoomId,
    this.receiverId,
    this.username,
    this.userimage,
    this.isImageBlurred = false,
    this.myImageBlur = false,
    this.blurMyImageFromOtherUser = true,
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
  StreamSubscription<Map<String, dynamic>>? _blurExceptionSubscription;
  bool _handlersInitialized = false;
  bool _isPopping = false;
  bool _wasSecureEnabled = false;
  // ✅ هل المستخدم ده مسموحله يشوف صورتي (blur exception مفعّل)
  late bool _isBlurExceptionEnabled;

  @override
  void initState() {
    super.initState();
    // ✅ الـ initial value من blurMyImageFromOtherUser فقط
    // blurMyImageFromOtherUser: false = سمحنا له يشوف صورتنا (exception مفعّل) → true
    // blurMyImageFromOtherUser: true  = صورتنا مبلورة عنده (exception مش مفعّل) → false
    _isBlurExceptionEnabled = !widget.blurMyImageFromOtherUser;
    _scrollController = ScrollController();
    final chatSocketService = getIt<ChatSocketService>();
    chatSocketService.clearChatNotificationCount();
    _failEventSubscription = chatSocketService.onFailEvent.listen((message) {
      // suppress join-related fail — server returns this when chatRoomId is sent
      // without targetId; the chat still works correctly after chatRoomJoined
      if (message.contains('طلب غير صالح')) return;
      if (mounted) AppToast.error(context, message);
    });
    // ✅ شيل FLAG_SECURE مؤقتاً عشان ExoPlayer يقدر يعرض الفيديو
    SecureWindowService.temporarilyDisableForChat().then((wasEnabled) {
      _wasSecureEnabled = wasEnabled;
    });
    // ✅ أبلّغ السيرفر إن المستخدم قرأ رسائل الـ room ده عشان يصفّر الـ notification count
    if (widget.chatRoomId != null) {
      getIt<ChatSocketService>().markMessagesRead(widget.chatRoomId!);
    }
    // ✅ استمع لـ imageBlurExceptionToggled عشان تحدّث الـ UI
    _blurExceptionSubscription = getIt<ChatSocketService>()
        .onImageBlurExceptionToggled
        .listen((data) {
      if (!mounted) return;
      // السيرفر بيبعت: {blur: false/true, userWithBlurredImage: ..., exceptedUserId: ...}
      // blur: false = سمحنا له يشوف صورتنا (exception مفعّل) → _isBlurExceptionEnabled = true
      // blur: true  = صورتنا مبلورة عنده (exception مش مفعّل) → _isBlurExceptionEnabled = false
      final blur = data['blur'] as bool? ?? true;
      setState(() => _isBlurExceptionEnabled = !blur);
      AppToast.success(
        context,
        blur
            ? (isArabic ? 'تم إلغاء السماح برؤية صورتك' : 'Image blur restored')
            : (isArabic ? 'تم السماح برؤية صورتك' : 'Image blur removed for this user'),
      );
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
    _blurExceptionSubscription?.cancel();
    _scrollHandler.dispose();
    _scrollController.dispose();
    // ✅ أعد تفعيل FLAG_SECURE بس لو كان مفعّل قبل فتح الشات
    SecureWindowService.restoreAfterChat(_wasSecureEnabled);
    // ✅ حدّث عداد الـ notifications بعد الخروج من الشات
    getIt<ChatSocketService>().requestChatNotificationNumbers();
    super.dispose();
  }

  /// ✅ يحوّل الـ messageType لـ content مناسب للعرض في الـ chat list
  /// بدل عرض الـ URL الفعلي للـ audio/image/video
  static String _contentForDisplay(ChatMessage msg) {
    switch (msg.messageType) {
      case 'audio':
      case 'record':
      case 'voice':
        return 'audio'; // ChatRoomListItem.formatLastMessage بيحوّله لـ 🎤
      case 'image':
      case 'photo':
      case 'media':
        return 'image'; // → 📷
      case 'video':
        return 'video'; // → 🎥
      case 'images/videos':
        // ✅ تحقق من الـ URL نفسه عشان نعرف image أو video
        final url = msg.contentList.isNotEmpty ? msg.contentList.first.toLowerCase() : '';
        if (url.contains('.mp4') || url.contains('.mov') ||
            url.contains('.avi') || url.contains('.webm')) {
          return 'video';
        }
        return 'image';
      case 'file':
      case 'document':
        return 'file'; // → 📄
      default:
        return msg.contentList.isNotEmpty ? msg.contentList.first : '';
    }
  }

  /// ✅ يخرج من الشات ويبعت آخر رسالة حقيقية كـ result
  /// عشان الـ chat list يعرض الرسالة الصح بعد الحذف
  void _popWithLastMessage(BuildContext context) {
    if (_isPopping) return; // ✅ منع double pop
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
          // ✅ نسمح بالـ swipe back على iOS لما مفيش selection mode
          canPop: !selectionState.isSelectionMode,
          onPopInvokedWithResult: (didPop, result) {
            if (selectionState.isSelectionMode) {
              context.read<MessageSelectionCubit>().exitSelectionMode();
              return;
            }
            // ✅ ابعت آخر رسالة حقيقية لما يخرج (بيحل مشكلة الصورة/الصوت المحذوف)
            // didPop = true لما الـ swipe back يحصل تلقائياً — مش محتاج نعمل pop تاني
            if (!didPop) {
              _popWithLastMessage(context);
            }
          },
          child: SafeArea(
            top: false,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: ChatColors.chatBackground,
              body: Stack(
                children: [
                  Column(
                    children: [
                      _buildAppBar(context),
                      _buildExpiryBanner(context),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(AssetsData.homeBackgroundImage),
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
      // ✅ نسمح بالـ rebuild دايماً عشان setState للـ _isBlurExceptionEnabled يشتغل
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
                    // ✅ افتح MarriageView بدل UserPublicProfileView
                    if (widget.receiverId != null) {
                      context.pushNamed(
                        AppRouter.kMarriageView,
                        arguments: {
                          'personId': widget.receiverId,
                          'fromInteractions': false,
                          'isFavorite': false,
                          'interactionUser': InteractionUserModel(
                            userId: widget.receiverId!,
                            name: widget.username ?? '',
                            age: 0, // غير متاح في الشات
                            country: '', // غير متاح في الشات
                            day: '',
                            job: '', // غير متاح في الشات
                            image: widget.userimage ?? '',
                            isverified: false, // غير متاح في الشات
                            isImageBlurred: false, // غير متاح في الشات

                          ),
                        },
                      );
                    }
                  },

                  child: Row(
                    children: [
                      ClipOval(
                        child: ImageFiltered(
                          imageFilter: widget.isImageBlurred
                              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                          child: CachedNetworkImage(
                            imageUrl: widget.userimage?.isNotEmpty == true
                                ? widget.userimage!
                                : AssetsData.defaultProfileImage,
                            width: 40.r,
                            height: 40.r,
                            fit: BoxFit.cover,
                            memCacheWidth: 80,
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            placeholder: (_, __) => CircleAvatar(
                              radius: 20.r,
                              backgroundColor: Colors.grey[200],
                            ),
                            errorWidget: (_, __, ___) => Image.asset(
                              AssetsData.defaultProfileImage,
                              width: 40.r,
                              height: 40.r,
                              fit: BoxFit.cover,
                            ),
                          ),
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
                    case 'toggle_blur':
                      if (widget.receiverId != null) {
                        // لو مفعّل → نرجعه (blur: true)، لو مش مفعّل → نشيله (blur: false)
                        final newBlur = _isBlurExceptionEnabled;
                        getIt<ChatSocketService>().toggleImageBlurException(
                          userId: widget.receiverId!,
                          blur: newBlur,
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
                  // ✅ شيل/أضف البلور لهذا المستخدم — بس لو صورته مبلورة أصلاً
                  if (widget.myImageBlur)
                    PopupMenuItem(
                      value: 'toggle_blur',
                      child: Row(
                        children: [
                          Icon(
                            _isBlurExceptionEnabled
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _isBlurExceptionEnabled
                                ? (isArabic ? 'إخفاء صورتي' : 'Hide my photo')
                                : (isArabic ? 'إظهار صورتي له' : 'Show my photo'),
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
