import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:tayseer/core/cache/chat_cache_service.dart';
import 'package:tayseer/core/enum/message_status_enum.dart';
import 'package:tayseer/core/services/appsflyer_events/appsflyer_events.dart';
import 'package:tayseer/core/services/socket_events/chat_socket_events.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/typing_model.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/state/chat_messages_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:uuid/uuid.dart';

class ChatMessagesCubit extends Cubit<ChatMessagesState> {
  final ChatRepoSimple _repo;
  final ChatCacheService _cacheService = getIt<ChatCacheService>();
  final tayseerSocketHelper _socketHelper = getIt.get<tayseerSocketHelper>();

  String? _currentChatRoomId;
  String? _currentReceiverId;
  bool _isBlocked = false;
  bool _amIBlocker = false;
  bool _isUserTyping = false;
  TypingModel? _typingInfo;
  int? _freeChatMinsLeft;
  bool _listenersSetup = false;
  bool _hasJoinedRoom = false;
  int _joinAttempts = 0;
  DateTime? _chatExpiresAt;
  bool _isSystemChat = false;
  // ✅ لو الـ socket أكّد الـ block status من chatRoomJoined، لا تـ override من الـ messages API
  bool _blockStatusConfirmedBySocket = false;

  // ✅ FIX 3: احفظ الـ receiverId الأصلي اللي جاء من الـ navigation
  // منفصل عن _currentReceiverId عشان لو _currentChatRoomId اتغيّر،
  // لسه عارفين مين المستخدم التاني
  String? _originalReceiverId;

  final Map<String, double> _uploadProgress = {};

  ChatMessagesCubit({required ChatRepoSimple repo})
    : _repo = repo,
      super(const ChatMessagesState.initial());

  // ══════════════════════════════════════════════════════════════════════════
  // JOIN / LEAVE ROOM
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> loadInitialMessages(
    String chatRoomId, {
    String? receiverId,
    bool isSystemChat = false,
    bool isBlocked = false,
    bool amIBlocker = false,
  }) async {
    // ✅ FIX 3: احفظ كل الـ IDs كأول خطوة قبل أي حاجة
    _currentChatRoomId = chatRoomId;
    _currentReceiverId = receiverId;
    _originalReceiverId = receiverId;
    _isSystemChat = isSystemChat;

    // ✅ اضبط الـ block state فوراً من الـ navigation args
    // عشان ما يكونش في تأخير قبل chatRoomJoined
    _isBlocked = isBlocked;
    _amIBlocker = amIBlocker;
    _blockStatusConfirmedBySocket = false; // reset عند كل room جديد

    _joinAttempts = 0;
    _hasJoinedRoom = false;

    log('🏠 loadInitialMessages: roomId=$chatRoomId, receiverId=$receiverId');

    // ✅ setup listeners أولاً عشان نستقبل chatRoomJoined بدون miss
    if (!_listenersSetup) {
      _listenersSetup = true;
      setupSocketListeners();
    }

    // ✅ ابعت joinChatRoom بعد الـ listeners بالتوازي مع جلب الـ messages
    // لو مش متصل، سجّل callback يتنادى لما يتصل
    if (_socketHelper.isConnected) {
      _sendJoinRequest(isSystemChat: isSystemChat, receiverId: receiverId);
    } else {
      _waitForSocketAndJoin(isSystemChat: isSystemChat, receiverId: receiverId);
    }

    // 1. عرض الكاش فوراً لو موجود
    final cachedMessages = _cacheService.getCachedMessages(
      chatRoomId: chatRoomId,
    );
    if (cachedMessages != null && cachedMessages.isNotEmpty) {
      final cacheBlock = _checkBlockStatusFromMessages(cachedMessages);
      if (cacheBlock) {
        _isBlocked = true;
      }
      emit(
        ChatMessagesState.loaded(
          messages: cachedMessages,
          hasMoreMessages: false,
          isBlocked: _isBlocked,
        ),
      );
    } else {
      emit(ChatMessagesState.loading(isBlocked: _isBlocked));
    }

    // 2. جلب من السيرفر وتحديث
    try {
      final messages = await _repo.loadMessages(chatRoomId);

      // ✅ لو الـ socket أكّد الـ block status بالفعل، لا نـ override
      // لو مفيش تأكيد من الـ socket بعد، نأخذ من الـ messages
      if (!_blockStatusConfirmedBySocket) {
        final blockFromMessages = _checkBlockStatusFromMessages(messages);
        if (blockFromMessages ||
            messages.any(
              (m) => m.messageType == 'system' && m.action.isUnblock,
            )) {
          _isBlocked = blockFromMessages;
        }
        // لو مفيش system messages → احتفظ بـ _isBlocked الأصلي من navigation
      }

      emit(
        ChatMessagesState.loaded(
          messages: messages,
          hasMoreMessages: false,
          isBlocked: _isBlocked,
        ),
      );

      // 3. حفظ في الكاش
      await _cacheService.saveMessages(
        chatRoomId: chatRoomId,
        messages: messages,
      );

      // ✅ سجّل الـ reconnect handler الدائم
      _setupReconnectHandler();
    } catch (e) {
      log('❌ Error loading messages: $e');
      if (cachedMessages == null || cachedMessages.isEmpty) {
        emit(ChatMessagesState.failure(message: e.toString()));
      }
    }
  }

  // ✅ سجّل callback في الـ socketHelper يتنادى لما الـ socket يرجع بعد انقطاع
  // كل cubit له ID فريد — مش بيكتب على cubits تانية
  void _setupReconnectHandler() {
    final reconnectId = 'ChatMessagesCubit_reconnect_$_currentChatRoomId';
    _socketHelper.addReconnectCallback(reconnectId, () {
      if (isClosed || _currentChatRoomId == null) return;

      log('🔄 Socket reconnected — rejoining room: $_currentChatRoomId');
      _hasJoinedRoom = false;
      _joinAttempts = 0;
      _sendJoinRequest(
        isSystemChat: _isSystemChat,
        receiverId: _currentReceiverId ?? _originalReceiverId,
      );

      // ✅ retry pending messages after rejoining (wait for chatRoomJoined)
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!isClosed) _retryPendingMessages();
      });
    });
  }

  Future<void> _waitForSocketAndJoin({
    required bool isSystemChat,
    String? receiverId,
  }) async {
    // ✅ لو بعتنا join بالفعل في البداية، مش محتاجين نبعت تاني
    if (_hasJoinedRoom || _joinAttempts > 0) return;

    // ✅ لو الـ socket متصل فعلاً، join فوراً بدون delay
    if (_socketHelper.isConnected) {
      log('✅ Socket connected, joining room (deferred): $_currentChatRoomId');
      _sendJoinRequest(isSystemChat: isSystemChat, receiverId: receiverId);
      return;
    }

    // ✅ لو مش متصل، سجّل callback بـ ID فريد يتنادى لما يتصل
    final waitId = 'ChatMessagesCubit_wait_$_currentChatRoomId';
    log(
      '⏳ Socket not ready — will join when connected (room: $_currentChatRoomId)',
    );
    _socketHelper.addReconnectCallback(waitId, () {
      if (isClosed || _hasJoinedRoom) return;
      log('🔄 Socket connected — joining room: $_currentChatRoomId');
      _socketHelper.removeReconnectCallback(waitId);
      _sendJoinRequest(isSystemChat: isSystemChat, receiverId: receiverId);
    });
  }

  void _sendJoinRequest({required bool isSystemChat, String? receiverId}) {
    if (isSystemChat) {
      final payload = <String, dynamic>{'system': true};
      // ✅ أضف chatRoomId لو موجود عشان السيرفر يعرف يـ join الـ room الصح
      if (_currentChatRoomId != null && _currentChatRoomId!.isNotEmpty) {
        payload['chatRoomId'] = _currentChatRoomId;
      }
      log('📤 joinChatRoom (system): $payload');
      _socketHelper.send('joinChatRoom', payload, null);
      return;
    }

    if (_currentChatRoomId == null) {
      log('❌ _sendJoinRequest: chatRoomId is null!');
      return;
    }

    _joinAttempts++;
    final payload = <String, dynamic>{'chatRoomId': _currentChatRoomId};

    // ✅ FIX 3: استخدم receiverId الممرر أو _currentReceiverId أو _originalReceiverId
    // بالأولوية دي عشان نضمن إن targetId موجود دايماً
    final targetId = receiverId ?? _currentReceiverId ?? _originalReceiverId;
    if (targetId != null && targetId.isNotEmpty) {
      payload['targetId'] = targetId;
    } else {
      log('⚠️ _sendJoinRequest: targetId is NULL for attempt $_joinAttempts');
    }

    log('📤 joinChatRoom attempt $_joinAttempts: $payload');
    _socketHelper.send('joinChatRoom', payload, null);
  }

  /// Leave الـ chat room الحالي وشيل كل الـ socket listeners
  void leaveCurrentChatRoom() {
    if (_currentChatRoomId == null) return;

    // ✅ FIX 2: لو لسه ما join حجرة ناجحة، متبعتش leaveChatRoom
    // ده بيمنع المشكلة اللي بتحصل لما الـ widget يتعمل dispose
    // قبل ما chatRoomJoined يرجع من السيرفر
    if (!_hasJoinedRoom) {
      log(
        '⚠️ leaveCurrentChatRoom: skipping leaveChatRoom — never joined successfully'
        ' (roomId: $_currentChatRoomId)',
      );
      // بس شيل الـ listeners عشان ما تتراكمش
      final listenerId = 'ChatMessagesCubit_$_currentChatRoomId';
      _socketHelper.offAllForListener(listenerId);
      _listenersSetup = false;
      _hasJoinedRoom = false;
      _joinAttempts = 0;
      return;
    }

    // ✅ هنا _hasJoinedRoom = true، يعني الـ _currentChatRoomId
    // هو الـ ID الصح اللي رجعه السيرفر في chatRoomJoined
    if (_socketHelper.isConnected) {
      _socketHelper.send('leaveChatRoom', {
        'chatRoomId': _currentChatRoomId,
      }, null);
      log('👋 Sent leaveChatRoom for $_currentChatRoomId');
    } else {
      log(
        '⚠️ Skipped leaveChatRoom — socket not connected (post-logout cleanup)',
      );
    }

    final listenerId = 'ChatMessagesCubit_$_currentChatRoomId';
    _socketHelper.offAllForListener(listenerId);

    _listenersSetup = false;
    _hasJoinedRoom = false;
    _joinAttempts = 0;
  }

  bool _checkBlockStatusFromMessages(List<ChatMessage> messages) {
    for (final msg in messages.reversed) {
      if (msg.messageType == 'system') {
        if (msg.action.isBlock) {
          // ✅ لو الـ system message block وكان `isMe: true` = أنت الحاظر
          _amIBlocker = msg.isMe;
          return true;
        }
        if (msg.action.isUnblock) {
          _amIBlocker = false;
          return false;
        }
      }
    }
    return false;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEND TEXT MESSAGE
  // ══════════════════════════════════════════════════════════════════════════

  /// Resend any messages currently stuck in [MessageStatusEnum.pending].
  /// Called automatically after [chatRoomJoined] succeeds or on socket reconnect.
  void _retryPendingMessages() {
    if (isClosed || _currentChatRoomId == null) return;

    final pending = state.messagesOrEmpty
        .where(
          (m) =>
              m.status == MessageStatusEnum.pending &&
              m.id.startsWith('temp_') &&
              m.messageType == 'text' &&
              m.tempId != null,
        )
        .toList();

    if (pending.isEmpty) return;

    log('🔄 Retrying ${pending.length} pending message(s)...');

    for (final msg in pending.reversed) {
      // بعت بنفس الـ tempId عشان السيرفر يتجنب الـ duplicates
      final payload = <String, dynamic>{
        'chatRoomId': _currentChatRoomId,
        'text': msg.contentList.isNotEmpty ? msg.contentList.first : '',
        'tempId': msg.tempId,
      };

      if (msg.reply?.replyMessageId != null &&
          !msg.reply!.replyMessageId!.startsWith('temp_')) {
        payload['replyToMessageId'] = msg.reply!.replyMessageId;
      }

      log('📤 Retrying pending message tempId=${msg.tempId}');
      _socketHelper.send('sendTextMessage', payload, (ack) {
        log('✅ Retry ACK for tempId=${msg.tempId}: $ack');
      });
    }
  }

  Future<void> sendMessage(
    String receiverId,
    String message,
    String chatRoomId, {
    String? replyMessageId,
    ChatMessage? replyToMessage,
  }) async {
    const uuid = Uuid();
    final tempId = uuid.v4();
    final localId = 'temp_$tempId';
    final now = DateTime.now().toIso8601String();

    final optimisticMessage = ChatMessage(
      id: localId,
      chatRoomId: chatRoomId,
      senderId: kCurrentUserData?.id ?? '',
      senderName: 'Me',
      senderImage: '',
      senderType: 'user',
      isMe: true,
      contentList: [message],
      messageType: 'text',
      createdAt: now,
      updatedAt: now,
      isRead: false,
      status: MessageStatusEnum.pending,
      tempId: tempId,
      reply: replyMessageId != null && replyToMessage != null
          ? ReplyInfo(
              replyMessageId: replyMessageId,
              replyMessage: replyToMessage.contentList.isNotEmpty
                  ? replyToMessage.contentList.first
                  : null,
              isReply: true,
            )
          : null,
    );

    final currentMessages = state.messagesOrEmpty;
    emit(
      ChatMessagesState.loaded(
        messages: [optimisticMessage, ...currentMessages],
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );

    final socketData = <String, dynamic>{
      'chatRoomId': _currentChatRoomId ?? chatRoomId,
      'text': message,
      'tempId': tempId,
    };

    if (replyMessageId != null && !replyMessageId.startsWith('temp_')) {
      socketData['replyToMessageId'] = replyMessageId;
    }

    _socketHelper.send('sendTextMessage', socketData, (ack) {
      log('✅ sendTextMessage ACK: $ack');
    });

    // 📊 AF: message sent
    unawaited(AppsFlyerEvents.messageSent(sessionType: 'chat'));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEND MEDIA
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> sendMediaMessage({
    required String chatRoomId,
    required String messageType,
    List<File>? images,
    List<File>? videos,
    File? audio,
    String? replyMessageId,
    ChatMessage? replyToMessage,
  }) async {
    const uuid = Uuid();
    final tempId = uuid.v4();
    final localId = 'temp_$tempId';
    final now = DateTime.now().toIso8601String();

    final localPaths = <String>[];
    if (images != null) localPaths.addAll(images.map((f) => f.path));
    if (videos != null) localPaths.addAll(videos.map((f) => f.path));
    if (audio != null) localPaths.add(audio.path);

    final optimisticMessage = ChatMessage(
      id: localId,
      chatRoomId: chatRoomId,
      senderId: kCurrentUserData?.id ?? '',
      senderName: 'Me',
      senderImage: '',
      senderType: 'user',
      isMe: true,
      contentList: [],
      messageType: messageType,
      createdAt: now,
      updatedAt: now,
      isRead: false,
      status: MessageStatusEnum.pending,
      localFilePaths: localPaths,
      tempId: tempId,
      reply: replyMessageId != null && replyToMessage != null
          ? ReplyInfo(
              replyMessageId: replyMessageId,
              replyMessage: replyToMessage.contentList.isNotEmpty
                  ? replyToMessage.contentList.first
                  : null,
              isReply: true,
            )
          : null,
    );

    final currentMessages = state.messagesOrEmpty;
    emit(
      ChatMessagesState.loaded(
        messages: [optimisticMessage, ...currentMessages],
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );

    _uploadProgress[localId] = 0.0;

    final result = await _repo.sendMediaMessage(
      chatRoomId: chatRoomId,
      contentType: messageType,
      images: images,
      videos: videos,
      audio: audio,
      replyToMessageId: replyMessageId,
      tempId: tempId,
      onProgress: (sent, total) {
        final progress = sent / total;
        _uploadProgress[localId] = progress;
        _emitProgressUpdate(localId, progress);
      },
    );

    result.fold(
      (error) {
        if (isClosed) return;
        log('❌ Media upload failed: $error');
        _updateMessageStatus(localId, MessageStatusEnum.failed);
        _uploadProgress.remove(localId);
      },
      (response) {
        if (isClosed) return;
        log('✅ Media uploaded: ${response.message.id}');
        // ✅ لو الـ server message مش عندها contentList (URLs)، احتفظ بالـ localFilePaths
        // عشان الـ VideoMessageWidget يشتغل من الـ local file لحد ما الـ URL يتحمّل
        final serverMsg = response.message;
        final msgToReplace =
            (serverMsg.contentList.isEmpty && localPaths.isNotEmpty)
            ? serverMsg.copyWith(localFilePaths: localPaths)
            : serverMsg;
        _replaceOptimisticMessage(localId, msgToReplace);
        _uploadProgress.remove(localId);
      },
    );
  }

  void _emitProgressUpdate(String messageId, double progress) {
    if (isClosed) return;
    final currentMessages = state.messagesOrEmpty;
    final index = currentMessages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final updatedMessages = List<ChatMessage>.from(currentMessages);
    updatedMessages[index] = currentMessages[index].copyWith(
      uploadProgress: progress,
    );

    emit(
      ChatMessagesState.loaded(
        messages: updatedMessages,
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );
  }

  double? getUploadProgress(String messageId) => _uploadProgress[messageId];

  void _updateMessageStatus(String messageId, MessageStatusEnum status) {
    final currentMessages = state.messagesOrEmpty;
    final index = currentMessages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final updatedMessages = List<ChatMessage>.from(currentMessages);
    updatedMessages[index] = currentMessages[index].copyWith(status: status);

    emit(
      ChatMessagesState.loaded(
        messages: updatedMessages,
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );
  }

  void _replaceOptimisticMessage(String localId, ChatMessage serverMessage) {
    if (isClosed) return;
    final currentMessages = state.messagesOrEmpty;
    final index = currentMessages.indexWhere((m) => m.id == localId);
    if (index == -1) return;

    final updatedMessages = List<ChatMessage>.from(currentMessages);
    updatedMessages[index] = serverMessage;
    log(
      '✅ Replaced optimistic message with server message - status: ${serverMessage.status}',
    );

    emit(
      ChatMessagesState.loaded(
        messages: updatedMessages,
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SOCKET LISTENERS
  // ══════════════════════════════════════════════════════════════════════════

  void setupSocketListeners() {
    final listenerId = 'ChatMessagesCubit_$_currentChatRoomId';

    _socketHelper.listenWithId('newMessage', listenerId, (data) {
      if (data is! Map) return;
      final messageData = data['message'];
      if (messageData is! Map) return;
      final message = ChatMessage.fromJson(messageData as Map<String, dynamic>);
      _handleNewMessage(message);
    });

    _socketHelper.listenWithId('messageDeleted', listenerId, (data) {
      if (data is! Map) return;
      final ids = data['chatMessageIds'];
      if (ids is List) {
        for (final id in ids) {
          _handleMessageDeleted(id.toString());
        }
      }
    });

    _socketHelper.listenWithId('typingStatus', listenerId, (data) {
      if (data is! Map) return;
      final isTyping = data['isTyping'] as bool? ?? false;
      _handleTypingStatus(isTyping);
    });

    _socketHelper.listenWithId('newMessageState', listenerId, (data) {
      if (data is! Map) return;
      final status = data['status']?.toString() ?? '';
      final messageIds = data['messageIds'];
      if (messageIds is List) {
        _handleMessageStateUpdate(
          status: status,
          messageIds: messageIds.map((e) => e.toString()).toList(),
        );
      }
    });

    _socketHelper.listenWithId('blockerStatus', listenerId, (data) {
      if (data is! Map) return;
      final newBlockStatus = data['newBlockStatus'] as bool? ?? false;
      _handleBlockerStatusChanged(newBlockStatus);
    });

    _socketHelper.listenWithId('blockedStatus', listenerId, (data) {
      if (data is! Map) return;
      final newBlockStatus = data['newBlockStatus'] as bool? ?? false;
      _handleBlockedStatusChanged(newBlockStatus);
    });

    _socketHelper.listenWithId('chatRoomJoined', listenerId, (data) {
      if (data is! Map) return;
      final receivedRoomId = data['chatRoomId']?.toString();
      final blockExists = data['blockExists'] as bool? ?? false;
      final isMe = data['isMe'] as bool?;
      _freeChatMinsLeft = data['freeChatMinsLeft'] as int?;
      _isBlocked = blockExists;

      // ✅ isMe: true = أنت الحاظر (أنت بلّكته)
      // isMe: false = أنت المحظور (هو بلّكك)
      if (blockExists && isMe != null) {
        _amIBlocker = isMe; // true = أنا الحاظر
      } else if (!blockExists) {
        _amIBlocker = false;
      }
      // ✅ الـ socket أكّد الـ block status — لا تـ override من messages API
      _blockStatusConfirmedBySocket = true;

      final expiresStr = data['chatExpiresAt']?.toString();
      if (expiresStr != null) {
        final utc = DateTime.tryParse(expiresStr);
        _chatExpiresAt = utc?.toLocal();
      }

      // ✅ FIX 2: السيرفر ممكن يرجع roomId مختلف (لو لقى room قديم بين نفس الـ users)
      // في الحالتين نقبل الـ roomId اللي السيرفر رجعه
      if (receivedRoomId != null && receivedRoomId != _currentChatRoomId) {
        log(
          '⚠️ chatRoomJoined: server returned different roomId!'
          ' expected: $_currentChatRoomId, got: $receivedRoomId'
          ' — accepting server room WITHOUT sending leaveChatRoom for old room',
        );

        // انقل الـ listeners للـ room ID الجديد
        final oldListenerId = 'ChatMessagesCubit_$_currentChatRoomId';
        final newListenerId = 'ChatMessagesCubit_$receivedRoomId';
        _socketHelper.renameListenerId(oldListenerId, newListenerId);

        // ✅ قبل الـ roomId من السيرفر — هو الـ room الصح للـ socket events
        _currentChatRoomId = receivedRoomId;
      }

      log(
        '✅ chatRoomJoined: blockExists=$blockExists, isMe=$isMe, '
        'freeChatMinsLeft=$_freeChatMinsLeft, roomId=$receivedRoomId',
      );

      _joinAttempts = 0;
      // ✅ FIX 2: بعد chatRoomJoined الناجح، عيّن _hasJoinedRoom = true
      // من الآن leaveCurrentChatRoom() مسموح تبعت leaveChatRoom للسيرفر
      _hasJoinedRoom = true;
      _emitCurrentState();

      // ✅ retry any messages that were stuck in pending state
      _retryPendingMessages();
    });

    _socketHelper.listenWithId('chatRoomLeft', listenerId, (data) {
      log('👋 chatRoomLeft: $data');
    });

    // ✅ FIX 3: في الـ retry، ابعت targetId من _originalReceiverId
    // مش بس الـ chatRoomId
    _socketHelper.listenWithId('fail', listenerId, (data) {
      if (_hasJoinedRoom || isClosed) return;
      if (_joinAttempts >= 2) return; // max 2 attempts

      log('⚠️ joinChatRoom failed (attempt $_joinAttempts), retrying...');

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!isClosed && !_hasJoinedRoom && _currentChatRoomId != null) {
          _joinAttempts++;

          final retryPayload = <String, dynamic>{
            'chatRoomId': _currentChatRoomId,
          };

          // ✅ FIX 3: ابعت targetId في الـ retry كمان من _originalReceiverId
          final targetId = _currentReceiverId ?? _originalReceiverId;
          if (targetId != null && targetId.isNotEmpty) {
            retryPayload['targetId'] = targetId;
          }

          log('🔄 Retry joinChatRoom attempt $_joinAttempts: $retryPayload');
          _socketHelper.send('joinChatRoom', retryPayload, null);
        }
      });
    });

    _socketHelper.listenWithId('messageReaction', listenerId, (data) {
      if (data is! Map) return;
      _handleMessageReaction(data);
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HANDLERS
  // ══════════════════════════════════════════════════════════════════════════

  void _handleNewMessage(ChatMessage message) {
    if (message.chatRoomId != _currentChatRoomId) return;

    final currentMessages = state.messagesOrEmpty;

    if (message.isMe) {
      final tempIndex = currentMessages.indexWhere(
        (m) =>
            m.id.startsWith('temp_') &&
            (m.tempId == message.tempId ||
                (message.tempId == null && m.content == message.content)),
      );
      if (tempIndex != -1) {
        final updatedMessages = List<ChatMessage>.from(currentMessages);
        updatedMessages[tempIndex] = message;
        log(
          '✅ Replaced temp message with server message - status: ${message.status}',
        );
        emit(
          ChatMessagesState.loaded(
            messages: updatedMessages,
            hasMoreMessages: false,
            isBlocked: _isBlocked,
            isUserTyping: _isUserTyping,
            typingInfo: _typingInfo,
          ),
        );
        _updateCache(updatedMessages);
        return;
      }

      // ✅ لو مفيش temp message، تحقق إن الرسالة مش موجودة بالفعل
      // ده بيحل مشكلة الـ duplicate لما sendMediaMessage يبعت عبر HTTP
      // والـ server يبعت newMessage socket event في نفس الوقت
      final alreadyExists = currentMessages.any((m) => m.id == message.id);
      if (alreadyExists) {
        log('⚠️ Duplicate message ignored: ${message.id}');
        return;
      }
    }

    if (message.messageType == 'system') {
      if (message.action.isBlock) {
        _isBlocked = true;
        _amIBlocker = message.isMe; // ✅ isMe: true = أنت الحاظر
      }
      if (message.action.isUnblock) {
        _isBlocked = false;
        _amIBlocker = false;
      }

      final localIndex = currentMessages.indexWhere(
        (m) =>
            m.id.startsWith('temp_') &&
            m.messageType == 'system' &&
            (m.action == message.action || m.content == message.content),
      );

      if (localIndex != -1) {
        final updatedMessages = List<ChatMessage>.from(currentMessages);
        updatedMessages[localIndex] = message;
        emit(
          ChatMessagesState.loaded(
            messages: updatedMessages,
            hasMoreMessages: false,
            isBlocked: _isBlocked,
            isUserTyping: _isUserTyping,
            typingInfo: _typingInfo,
          ),
        );
        _updateCache(updatedMessages);
        return;
      }
    }

    // ✅ تحقق عام من التكرار قبل الإضافة (لكل أنواع الرسائل)
    if (currentMessages.any((m) => m.id == message.id)) {
      log('⚠️ Duplicate message ignored (general check): ${message.id}');
      return;
    }

    final updatedMessages = [message, ...currentMessages];
    emit(
      ChatMessagesState.loaded(
        messages: updatedMessages,
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );
    _updateCache(updatedMessages);
  }

  void _handleMessageDeleted(String messageId) {
    final currentMessages = state.messagesOrEmpty;
    final updatedMessages = currentMessages
        .where((m) => m.id != messageId)
        .toList();

    emit(
      ChatMessagesState.loaded(
        messages: updatedMessages,
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );
    _updateCache(updatedMessages);
  }

  Future<void> _updateCache(List<ChatMessage> messages) async {
    if (_currentChatRoomId != null) {
      await _cacheService.saveMessages(
        chatRoomId: _currentChatRoomId!,
        messages: messages,
      );
    }
  }

  void _handleTypingStatus(bool isTyping) {
    _isUserTyping = isTyping;
    if (isTyping) {
      _typingInfo = TypingModel(
        userId: _currentReceiverId ?? '',
        userName: '',
        chatRoomId: _currentChatRoomId ?? '',
      );
    } else {
      _typingInfo = null;
    }

    emit(
      ChatMessagesState.loaded(
        messages: state.messagesOrEmpty,
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );

    if (isTyping) {
      Future.delayed(const Duration(seconds: 3), () {
        if (_isUserTyping) {
          _isUserTyping = false;
          _typingInfo = null;
          emit(
            ChatMessagesState.loaded(
              messages: state.messagesOrEmpty,
              hasMoreMessages: false,
              isBlocked: _isBlocked,
              isUserTyping: false,
            ),
          );
        }
      });
    }
  }

  void _handleMessageStateUpdate({
    required String status,
    required List<String> messageIds,
  }) {
    final parsedStatus = MessageStatusExtension.fromString(status);
    final currentMessages = state.messagesOrEmpty;
    final messageIdSet = messageIds.toSet();

    log(
      '📊 Updating message status: $status → $parsedStatus for ${messageIds.length} messages',
    );

    final updatedMessages = List<ChatMessage>.from(
      currentMessages.map((m) {
        if (messageIdSet.contains(m.id)) {
          log('✅ Updating message ${m.id} status: ${m.status} → $parsedStatus');
          return m.copyWith(
            status: parsedStatus,
            isRead: parsedStatus == MessageStatusEnum.read,
          );
        }
        return m;
      }),
    );

    emit(
      ChatMessagesState.loaded(
        messages: updatedMessages,
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );

    _updateCache(updatedMessages);
  }

  void _handleBlockerStatusChanged(bool isBlocked) {
    log('🔒 blockerStatus changed: isBlocked=$isBlocked (أنا الحاظر)');
    _isBlocked = isBlocked;
    _amIBlocker = isBlocked;
    emit(
      ChatMessagesState.loaded(
        messages: state.messagesOrEmpty,
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );
  }

  void _handleBlockedStatusChanged(bool isBlocked) {
    log('🚫 blockedStatus changed: isBlocked=$isBlocked (أنا محظور)');
    _isBlocked = isBlocked;
    _amIBlocker = false;
    emit(
      ChatMessagesState.loaded(
        messages: state.messagesOrEmpty,
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );
  }

  bool get amIBlocker => _amIBlocker;

  void _emitCurrentState() {
    emit(
      ChatMessagesState.loaded(
        messages: state.messagesOrEmpty,
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
        freeChatMinsLeft: _freeChatMinsLeft,
        chatExpiresAt: _chatExpiresAt,
      ),
    );
  }

  DateTime? get chatExpiresAt => _chatExpiresAt;

  // ══════════════════════════════════════════════════════════════════════════
  // TYPING (CLIENT → SERVER)
  // ══════════════════════════════════════════════════════════════════════════

  void typingStart(String chatRoomId) {
    if (!_hasJoinedRoom ||
        _currentReceiverId == null ||
        _currentChatRoomId == null)
      return;
    _socketHelper.send('typingStatus', {
      'chatRoomId': _currentChatRoomId,
      'receiverId': _currentReceiverId,
      'isTyping': true,
    }, null);
  }

  void typingStop(String chatRoomId) {
    if (!_hasJoinedRoom ||
        _currentReceiverId == null ||
        _currentChatRoomId == null)
      return;
    _socketHelper.send('typingStatus', {
      'chatRoomId': _currentChatRoomId,
      'receiverId': _currentReceiverId,
      'isTyping': false,
    }, null);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REPLY
  // ══════════════════════════════════════════════════════════════════════════

  void setReplyingToMessage(ChatMessage? message) {
    emit(
      ChatMessagesState.loaded(
        messages: state.messagesOrEmpty,
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
        replyingToMessage: message,
      ),
    );
  }

  void cancelReply() {
    emit(
      ChatMessagesState.loaded(
        messages: state.messagesOrEmpty,
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DELETE
  // ══════════════════════════════════════════════════════════════════════════

  Future<bool> deleteMessage({
    required String messageId,
    required String deleteType,
  }) async {
    if (_currentChatRoomId == null) return false;

    _handleMessageDeleted(messageId);

    final result = await _repo.deleteMessage(
      messageId: messageId,
      chatRoomId: _currentChatRoomId!,
      deleteType: deleteType,
    );

    return result.fold((error) {
      log('❌ Delete failed on server: $error');
      return false;
    }, (_) => true);
  }

  Future<bool> deleteMessages({
    required List<String> messageIds,
    required String deleteType,
  }) async {
    if (_currentChatRoomId == null) return false;

    for (final id in messageIds) {
      _handleMessageDeleted(id);
    }

    final result = await _repo.deleteMessages(
      messageIds: messageIds,
      chatRoomId: _currentChatRoomId!,
      deleteType: deleteType,
    );

    return result.fold((error) {
      log('❌ Delete failed on server: $error');
      return false;
    }, (_) => true);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BLOCK/UNBLOCK
  // ══════════════════════════════════════════════════════════════════════════

  Future<Either<String, String>> blockUser({required String blockedId}) async {
    const uuid = Uuid();
    final localId = 'temp_${uuid.v4()}';
    final now = DateTime.now().toIso8601String();

    _isBlocked = true;
    _amIBlocker = true;

    final optimisticMessage = ChatMessage(
      id: localId,
      chatRoomId: _currentChatRoomId ?? '',
      senderId: _currentReceiverId ?? '',
      senderName: 'System',
      senderImage: '',
      senderType: 'system',
      isMe: true,
      contentList: ['المستخدم محظور من إرسال الرسائل في هذه الدردشة'],
      messageType: 'system',
      action: SystemMessageAction.block,
      createdAt: now,
      updatedAt: now,
      isRead: true,
      status: MessageStatusEnum.sent,
    );

    final currentMessages = state.messagesOrEmpty;
    emit(
      ChatMessagesState.loaded(
        messages: [optimisticMessage, ...currentMessages],
        hasMoreMessages: false,
        isBlocked: true,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );

    final result = await _repo.blockUser(blockedId: blockedId);

    result.fold(
      (error) {
        _isBlocked = false;
        final revertedMessages = currentMessages
            .where((m) => m.id != localId)
            .toList();
        emit(
          ChatMessagesState.loaded(
            messages: revertedMessages,
            hasMoreMessages: false,
            isBlocked: false,
            isUserTyping: _isUserTyping,
            typingInfo: _typingInfo,
          ),
        );
      },
      (_) {
        // blockerStatus socket event will confirm the final state.
      },
    );
    return result;
  }

  Future<Either<String, String>> unblockUser({
    required String blockedId,
  }) async {
    const uuid = Uuid();
    final localId = 'temp_${uuid.v4()}';
    final now = DateTime.now().toIso8601String();

    _isBlocked = false;
    _amIBlocker = false;

    final optimisticMessage = ChatMessage(
      id: localId,
      chatRoomId: _currentChatRoomId ?? '',
      senderId: _currentReceiverId ?? '',
      senderName: 'System',
      senderImage: '',
      senderType: 'system',
      isMe: true,
      contentList: ['المستخدم غير محظور من إرسال الرسائل في هذه الدردشة'],
      messageType: 'system',
      action: SystemMessageAction.unblock,
      createdAt: now,
      updatedAt: now,
      isRead: true,
      status: MessageStatusEnum.sent,
    );

    final currentMessages = state.messagesOrEmpty;
    emit(
      ChatMessagesState.loaded(
        messages: [optimisticMessage, ...currentMessages],
        hasMoreMessages: false,
        isBlocked: false,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );

    final result = await _repo.unblockUser(blockedId: blockedId);

    result.fold(
      (error) {
        _isBlocked = true;
        final revertedMessages = currentMessages
            .where((m) => m.id != localId)
            .toList();
        emit(
          ChatMessagesState.loaded(
            messages: revertedMessages,
            hasMoreMessages: false,
            isBlocked: true,
            isUserTyping: _isUserTyping,
            typingInfo: _typingInfo,
          ),
        );
      },
      (_) {
        // blockerStatus socket event will confirm the final state.
      },
    );
    return result;
  }

  void setInitialBlocked(bool isBlocked, {bool amIBlocker = false}) {
    _isBlocked = isBlocked;
    _amIBlocker = amIBlocker;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> close() {
    // ✅ شيل الـ reconnect callbacks الخاصة بهذا الـ cubit
    _socketHelper.removeReconnectCallback(
      'ChatMessagesCubit_reconnect_$_currentChatRoomId',
    );
    _socketHelper.removeReconnectCallback(
      'ChatMessagesCubit_wait_$_currentChatRoomId',
    );
    leaveCurrentChatRoom();
    _listenersSetup = false;
    _originalReceiverId = null;
    return super.close();
  }

  Future<void> loadOlderMessages() async {
    // TODO: implement cursor-based pagination using repo.loadMessages(before:)
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REACTIONS
  // ══════════════════════════════════════════════════════════════════════════

  void reactToMessage({required String messageId, required String emoji}) {
    final currentMessages = state.messagesOrEmpty;
    final messageIndex = currentMessages.indexWhere((m) => m.id == messageId);

    if (messageIndex == -1) return;

    final message = currentMessages[messageIndex];
    final currentUserId = kCurrentUserData?.id ?? '';

    final existingReaction = message.reactions.firstWhere(
      (r) => r.userId == currentUserId && r.emoji == emoji,
      orElse: () => const MessageReaction(userId: '', emoji: ''),
    );

    if (existingReaction.userId.isNotEmpty) {
      _socketHelper.send('unreactToMessage', {'chatMessageId': messageId}, (
        ack,
      ) {
        log('✅ unreactToMessage ACK: $ack');
      });
    } else {
      _socketHelper.send(
        'reactToMessage',
        {'chatMessageId': messageId, 'emoji': emoji},
        (ack) {
          log('✅ reactToMessage ACK: $ack');
        },
      );
    }
  }

  void _handleMessageReaction(Map data) {
    final chatMessageId = data['chatMessageId']?.toString();
    final reactionsData = data['reactions'] as List?;

    if (chatMessageId == null || reactionsData == null) return;

    final reactions = reactionsData.map((r) {
      final reactionMap = Map<String, dynamic>.from(r as Map);
      return MessageReaction.fromJson(reactionMap);
    }).toList();

    final currentMessages = state.messagesOrEmpty;
    final messageIndex = currentMessages.indexWhere(
      (m) => m.id == chatMessageId,
    );

    if (messageIndex == -1) return;

    final updatedMessages = List<ChatMessage>.from(currentMessages);
    updatedMessages[messageIndex] = currentMessages[messageIndex].copyWith(
      reactions: reactions,
    );

    emit(
      ChatMessagesState.loaded(
        messages: updatedMessages,
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );

    log(
      '✅ Message reactions updated: $chatMessageId - ${reactions.length} reactions',
    );
  }
}
