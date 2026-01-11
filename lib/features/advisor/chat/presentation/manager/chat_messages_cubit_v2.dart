import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:tayseer/core/database/entities/pending_message_entity.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/core/enum/message_status_enum.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/typinn_model.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_v2.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_messages_state_v2.dart';

/// Local-First Chat Messages Cubit
///
/// This cubit implements a local-first architecture where:
/// 1. Local SQLite DB is the single source of truth
/// 2. UI never waits for server response for initial load
/// 3. Messages are saved locally before sending to server
/// 4. Cursor-based pagination using createdAt
/// 5. Offline support with automatic retry
class ChatMessagesCubitV2 extends Cubit<ChatMessagesStateV2> {
  final ChatRepoV2 _repo;
  final tayseerSocketHelper _socketHelper = getIt.get<tayseerSocketHelper>();

  Timer? _typingTimer;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _connectivitySubscription;

  late final String _listenerId;
  String? _currentChatRoomId;
  String? _currentReceiverId;

  /// Connectivity checker
  final Connectivity _connectivity = Connectivity();

  ChatMessagesCubitV2(this._repo) : super(ChatMessagesStateV2()) {
    _listenerId =
        'ChatMessagesCubitV2_${DateTime.now().millisecondsSinceEpoch}_$hashCode';
    log('🆔 ChatMessagesCubitV2 created with ID: $_listenerId');

    _setupConnectivityListener();
  }

  /// Set initial blocked state
  void setInitialBlocked(bool isBlocked) {
    if (isBlocked) {
      emit(state.copyWith(isBlocked: true));
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CONNECTIVITY HANDLING
  // ══════════════════════════════════════════════════════════════════════════

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final isOnline =
          results.isNotEmpty && !results.contains(ConnectivityResult.none);

      if (isOnline && !state.isOnline) {
        log('📶 [$_listenerId] Back online - retrying pending messages');
        _retryPendingMessages();
      }

      _safeEmit(state.copyWith(isOnline: isOnline));
    });
  }

  Future<void> _retryPendingMessages() async {
    final pendingMessages = await _repo.getPendingMessages();

    for (final pending in pendingMessages) {
      log('🔄 [$_listenerId] Retrying message: ${pending.localId}');

      // Extract tempId from localId (format: "temp_<uuid>")
      final tempId = pending.localId.startsWith('temp_')
          ? pending.localId.substring(5)
          : pending.localId;

      final messageData = <String, dynamic>{
        'receiverId': pending.receiverId,
        'content': pending.content,
        'tempId': tempId, // ✅ Include tempId for reliable matching
      };

      // Only include replyMessageId if it's a real server ID (not temp_)
      if (pending.replyMessageId != null &&
          !pending.replyMessageId!.startsWith('temp_')) {
        messageData['replyMessageId'] = pending.replyMessageId;
      }

      _socketHelper.send('send_message', messageData, (ack) {
        log('✅ [$_listenerId] Retry ACK for ${pending.localId}: $ack');
      });
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SAFE EMIT
  // ══════════════════════════════════════════════════════════════════════════

  void _safeEmit(ChatMessagesStateV2 newState) {
    if (!isClosed) {
      emit(newState);
    } else {
      log('⚠️ [$_listenerId] Attempted to emit after close');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INITIAL LOAD (LOCAL-FIRST)
  // ══════════════════════════════════════════════════════════════════════════

  /// Load initial messages for a chat room
  /// Flow:
  /// 1. Load from local DB immediately (no waiting)
  /// 2. Display messages
  /// 3. Sync with server in background
  /// 4. Update UI with new messages (if any)
  Future<void> loadInitialMessages(
    String chatRoomId, {
    String? receiverId,
  }) async {
    _currentChatRoomId = chatRoomId;
    _currentReceiverId = receiverId;
    log('📥 [$_listenerId] Loading for receiverId: $_currentReceiverId');

    log('📥 [$_listenerId] Loading initial messages for: $chatRoomId');
    _safeEmit(state.copyWith(loadingState: CubitStates.loading));

    try {
      // Subscribe to message stream for reactive updates
      _subscribeToMessages(chatRoomId);

      // Load from local DB (this also triggers background sync)
      final messages = await _repo.loadInitialMessages(chatRoomId);

      if (isClosed) return;

      // التحقق من حالة الحظر من آخر رسالة system
      final isBlocked = _checkBlockStatusFromMessages(messages);

      _safeEmit(
        state.copyWith(
          loadingState: CubitStates.success,
          messages: messages,
          hasMoreMessages: messages.length >= 20,
          isBlocked: isBlocked,
        ),
      );

      // Mark chat as read since we're opening it
      await _repo.markChatAsRead(chatRoomId);

      log('✅ [$_listenerId] Loaded ${messages.length} messages from local DB');
      log('🔒 [$_listenerId] Block status from messages: $isBlocked');
    } catch (e) {
      log('❌ [$_listenerId] Error loading messages: $e');
      if (!isClosed) {
        _safeEmit(
          state.copyWith(
            loadingState: CubitStates.failure,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }

  /// Subscribe to message stream for reactive updates
  void _subscribeToMessages(String chatRoomId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _repo
        .watchMessages(chatRoomId)
        .listen(
          (messages) {
            if (!isClosed) {
              // Update hasMoreMessages based on message count
              final hasMore = messages.length >= 20;
              _safeEmit(
                state.copyWith(messages: messages, hasMoreMessages: hasMore),
              );
            }
          },
          onError: (e) {
            log('⚠️ [$_listenerId] Message stream error: $e');
          },
        );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PAGINATION (CURSOR-BASED)
  // ══════════════════════════════════════════════════════════════════════════

  /// Load older messages (cursor-based pagination)
  /// Cursor = sortTimestamp of the oldest displayed message
  Future<void> loadOlderMessages() async {
    if (_currentChatRoomId == null) return;
    if (state.paginationState == CubitStates.loading) return;
    if (!state.hasMoreMessages) return;

    final currentMessages = state.messages;
    if (currentMessages.isEmpty) return;

    // Get oldest message's sort_timestamp from DB (not from createdAt string)
    final oldestMessage = currentMessages.first;
    final cursorTimestamp = await _repo.getMessageSortTimestamp(
      oldestMessage.id,
    );

    if (cursorTimestamp == null) {
      log(
        '⚠️ [$_listenerId] Could not get sort_timestamp for message ${oldestMessage.id}',
      );
      _safeEmit(state.copyWith(hasMoreMessages: false));
      return;
    }

    log(
      '📜 [$_listenerId] Loading older messages before timestamp: $cursorTimestamp',
    );
    _safeEmit(state.copyWith(paginationState: CubitStates.loading));

    try {
      final olderMessages = await _repo.loadOlderMessages(
        _currentChatRoomId!,
        cursorTimestamp: cursorTimestamp,
      );

      if (isClosed) return;

      // Prepend older messages to current list
      final updatedMessages = [...olderMessages, ...currentMessages];

      _safeEmit(
        state.copyWith(
          paginationState: CubitStates.success,
          messages: updatedMessages,
          hasMoreMessages: olderMessages.length >= 20,
        ),
      );

      log('✅ [$_listenerId] Loaded ${olderMessages.length} older messages');
    } catch (e) {
      log('❌ [$_listenerId] Error loading older messages: $e');
      if (!isClosed) {
        _safeEmit(
          state.copyWith(
            paginationState: CubitStates.failure,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEND MESSAGE (OPTIMISTIC UI)
  // ══════════════════════════════════════════════════════════════════════════

  /// Send a text message
  /// Flow:
  /// 1. Create local message with status=sending
  /// 2. Save to local DB
  /// 3. Display immediately in UI
  /// 4. Send to server via socket
  /// 5. Update status when server confirms
  Future<void> sendMessage(
    String receiverId,
    String message,
    String chatRoomId, {
    String? replyMessageId,
  }) async {
    // Generate UUID for reliable server matching
    const uuid = Uuid();
    final tempId = uuid.v4();
    final localId = 'temp_$tempId';
    final now = DateTime.now().toIso8601String();

    // Create reply info if replying
    ReplyInfo? replyInfo;
    if (replyMessageId != null) {
      final originalMessage = state.messages.firstWhere(
        (msg) => msg.id == replyMessageId,
        orElse: () => ChatMessage(
          id: '',
          chatRoomId: '',
          senderId: '',
          senderName: '',
          senderImage: '',
          senderType: '',
          isMe: false,
          contentList: [],
          messageType: '',
          createdAt: '',
          updatedAt: '',
        ),
      );
      replyInfo = ReplyInfo(
        replyMessageId: replyMessageId,
        replyMessage: originalMessage.content,
        isReply: true,
      );
    }

    // Create optimistic message
    final localMessage = ChatMessage(
      id: localId,
      chatRoomId: chatRoomId,
      senderId: receiverId,
      senderName: 'Me',
      senderImage: '',
      senderType: 'user',
      isMe: true,
      contentList: [message],
      messageType: 'text',
      createdAt: now,
      updatedAt: now,
      isRead: false,
      status: MessageStatusEnum.pending, // Pending until server confirms
      reply: replyInfo,
    );

    // Step 1: Save to local DB and display immediately
    await _repo.saveMessageLocally(localMessage, localId: localId);

    // Add to pending queue for offline retry
    await _repo.addToPendingQueue(
      PendingMessageEntity(
        localId: localId,
        chatRoomId: chatRoomId,
        receiverId: receiverId,
        content: message,
        messageType: 'text',
        replyMessageId: replyMessageId,
        createdAt: now,
      ),
    );

    // Update UI immediately
    final updatedMessages = [...state.messages, localMessage];
    _safeEmit(
      state.copyWith(
        messages: updatedMessages,
        pendingCount: state.pendingCount + 1,
        clearReplyingToMessage: true, // Clear reply after sending
      ),
    );

    log('📤 [$_listenerId] Message saved locally: $localId');

    // Step 2: Send to server via socket
    final messageData = <String, dynamic>{
      'receiverId': receiverId,
      'content': message,
      'tempId': tempId, // ✅ Include tempId for reliable matching
    };

    // Only include replyMessageId if it's a real server ID (not temp_)
    // If it's a temp ID, the reply will be shown locally but server won't know about it
    if (replyMessageId != null && !replyMessageId.startsWith('temp_')) {
      messageData['replyMessageId'] = replyMessageId;
    }

    _socketHelper.send('send_message', messageData, (ack) {
      log('✅ [$_listenerId] Send message ACK: $ack');
    });
  }

  /// Send media message (image/video)
  Future<void> sendMediaMessage({
    required String chatRoomId,
    required String messageType,
    List<File>? images,
    List<File>? videos,
    String? replyMessageId,
  }) async {
    if (isClosed) return;

    _safeEmit(state.copyWith(sendMediaState: CubitStates.loading));

    final result = await _repo.sendMediaMessage(
      chatRoomId: chatRoomId,
      messageType: messageType,
      images: images,
      videos: videos,
      replyMessageId: replyMessageId,
    );

    if (isClosed) return;

    result.fold(
      (error) => _safeEmit(
        state.copyWith(
          sendMediaState: CubitStates.failure,
          errorMessage: error,
        ),
      ),
      (response) {
        // Create message from response and add to local
        final chatMessage = ChatMessage(
          id: response.data.id,
          chatRoomId: response.data.chatRoomId,
          senderId: response.data.senderId,
          senderName: response.data.senderName,
          senderImage: response.data.senderImage ?? '',
          senderType: response.data.senderType,
          isMe: response.data.isMe,
          contentList: response.data.contentList,
          messageType: response.data.messageType,
          createdAt: response.data.createdAt,
          updatedAt: response.data.updatedAt,
          isRead: response.data.isRead,
          reply: response.data.reply,
        );

        final updatedMessages = [...state.messages, chatMessage];

        _safeEmit(
          state.copyWith(
            sendMediaState: CubitStates.success,
            messages: updatedMessages,
            clearReplyingToMessage: true,
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SOCKET LISTENERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Setup all socket listeners for real-time updates
  void setupSocketListeners() {
    listenToNewMessages();
    listenToMessagesRead();
    listenToMessageDeleted();
    if (_currentChatRoomId != null) {
      listenToUserTyping(_currentChatRoomId!);
    }
  }

  /// Listen for new incoming messages
  void listenToNewMessages() {
    log('🎧 [$_listenerId] Setting up new_message listener');

    _socketHelper.listenWithId('new_message', _listenerId, (data) {
      _handleNewMessage(data);
    });
  }

  void _handleNewMessage(dynamic data) {
    if (isClosed) return;
    if (_currentChatRoomId == null) return;

    log('📨 [$_listenerId] Processing new message');

    try {
      // الـ socket بيبعت {message: {...}, chatRoomId: ...}
      final messageData = data is Map && data.containsKey('message')
          ? data['message']
          : data;
      final newMessage = ChatMessage.fromJson(messageData);

      // Only process messages for current chat room
      if (newMessage.chatRoomId != _currentChatRoomId) {
        log('📭 [$_listenerId] Message for different room, ignoring');
        return;
      }

      // معالجة رسائل النظام (Block/Unblock)
      if (newMessage.messageType == 'system') {
        _handleSystemMessage(newMessage);
        return;
      }

      if (newMessage.isMe) {
        // This is our sent message confirmed by server
        _handleSentMessageConfirmation(newMessage);
      } else {
        // This is a message from the other user
        _handleIncomingMessage(newMessage);
      }
    } catch (e, stackTrace) {
      log('❌ [$_listenerId] Error processing message: $e');
      log('StackTrace: $stackTrace');
    }
  }

  void _handleSentMessageConfirmation(ChatMessage serverMessage) async {
    // Find and replace local message with server message
    final currentMessages = state.messages;

    // ✅ Primary: Match by tempId (reliable)
    int localIndex = -1;
    final serverTempId = serverMessage.tempId;

    if (serverTempId != null && serverTempId.isNotEmpty) {
      localIndex = currentMessages.indexWhere(
        (msg) => msg.id == 'temp_$serverTempId',
      );
      log(
        '🔍 [$_listenerId] Matching by tempId: $serverTempId, found: ${localIndex != -1}',
      );
    }

    // ✅ Fallback: Match by content (for backwards compatibility)
    if (localIndex == -1) {
      localIndex = currentMessages.lastIndexWhere(
        (msg) =>
            msg.id.startsWith('temp_') &&
            msg.content.trim() == serverMessage.content.trim() &&
            msg.isMe,
      );
      log(
        '🔍 [$_listenerId] Fallback: content matching, found: ${localIndex != -1}',
      );
    }

    if (localIndex != -1) {
      final localMessage = currentMessages[localIndex];
      final localId = localMessage.id;

      // Update in local DB
      await _repo.confirmMessageSent(localId, serverMessage.id);
      await _repo.removeFromPendingQueue(localId);

      // Update UI
      final updatedMessages = List<ChatMessage>.from(currentMessages);
      updatedMessages[localIndex] = serverMessage;

      _safeEmit(
        state.copyWith(
          messages: updatedMessages,
          pendingCount: state.pendingCount > 0 ? state.pendingCount - 1 : 0,
        ),
      );

      log(
        '✅ [$_listenerId] Message confirmed: $localId -> ${serverMessage.id}',
      );
    } else {
      // No local message found, just add
      await _repo.saveMessageLocally(serverMessage);
      _addMessageToState(serverMessage);
    }
  }

  void _handleIncomingMessage(ChatMessage message) async {
    // Save to local DB
    await _repo.saveMessageLocally(message);

    // Add to UI
    _addMessageToState(message);

    log('📩 [$_listenerId] Incoming message added: ${message.id}');

    // Auto-mark as read since user is viewing this chat
    _autoMarkMessagesAsRead();
  }

  /// معالجة رسائل النظام من Socket (Block/Unblock)
  void _handleSystemMessage(ChatMessage serverMessage) async {
    final serverContent = serverMessage.content.trim();

    log('📩 [$_listenerId] Received system message: $serverContent');

    // التحقق من وجود رسالة محلية مطابقة (optimistic)
    // نستخدم any للبحث عن تطابق مع تجاهل المسافات
    final hasPendingMatch = _pendingSystemMessageContents.any(
      (pending) => pending.trim() == serverContent,
    );

    if (hasPendingMatch) {
      // البحث عن الرسالة المحلية بنفس المحتوى (مع تجاهل المسافات)
      final localIndex = state.messages.lastIndexWhere(
        (msg) =>
            msg.id.startsWith('temp_') &&
            msg.messageType == 'system' &&
            msg.content.trim() == serverContent,
      );

      if (localIndex != -1) {
        final localMessage = state.messages[localIndex];
        final localId = localMessage.id;

        // تحديث الـ ID في Local DB
        await _repo.confirmMessageSent(localId, serverMessage.id);

        // تحديث UI
        final updatedMessages = List<ChatMessage>.from(state.messages);
        updatedMessages[localIndex] = serverMessage;

        _safeEmit(state.copyWith(messages: updatedMessages));

        log(
          '✅ [$_listenerId] System message confirmed: $localId -> ${serverMessage.id}',
        );

        // إزالة من القائمة المعلقة (بالمقارنة المرنة)
        _pendingSystemMessageContents.removeWhere(
          (pending) => pending.trim() == serverContent,
        );
        return;
      }
    }

    // تحقق إضافي: هل توجد رسالة temp بنفس المحتوى؟
    // (في حالة عدم التطابق في القائمة المعلقة لأي سبب)
    final tempIndex = state.messages.lastIndexWhere(
      (msg) =>
          msg.id.startsWith('temp_') &&
          msg.messageType == 'system' &&
          msg.content.trim() == serverContent,
    );

    if (tempIndex != -1) {
      final localMessage = state.messages[tempIndex];
      final localId = localMessage.id;

      // تحديث الـ ID في Local DB
      await _repo.confirmMessageSent(localId, serverMessage.id);

      // تحديث UI
      final updatedMessages = List<ChatMessage>.from(state.messages);
      updatedMessages[tempIndex] = serverMessage;

      _safeEmit(state.copyWith(messages: updatedMessages));

      log(
        '✅ [$_listenerId] System message confirmed (fallback): $localId -> ${serverMessage.id}',
      );
      return;
    }

    // إذا لم يكن هناك رسالة محلية، تحقق من التكرار
    final exists = state.messages.any((m) => m.id == serverMessage.id);
    if (exists) {
      log('📭 [$_listenerId] System message already exists, ignoring');
      return;
    }

    // إضافة الرسالة الجديدة
    await _repo.saveMessageLocally(serverMessage);
    _addMessageToState(serverMessage);
    log('📩 [$_listenerId] New system message added: ${serverMessage.id}');
  }

  void _autoMarkMessagesAsRead() {
    if (_currentChatRoomId == null) return;

    // Mark in local DB
    _repo.markChatAsRead(_currentChatRoomId!);

    // Notify server/other user via socket
    _socketHelper.send(
      'mark_messages_read',
      {'chatRoomId': _currentChatRoomId},
      (ack) {
        log('✅ [$_listenerId] Auto mark_messages_read ACK: $ack');
      },
    );

    log(
      '✅ [$_listenerId] Auto-marked messages as read for $_currentChatRoomId',
    );
  }

  void _addMessageToState(ChatMessage message) {
    // Check if message already exists
    final exists = state.messages.any((m) => m.id == message.id);
    if (exists) return;

    final updatedMessages = [...state.messages, message];
    _safeEmit(state.copyWith(messages: updatedMessages));
  }

  /// Listen for message read status updates
  void listenToMessagesRead() {
    log('🎧 [$_listenerId] Setting up messages_read listener');

    _socketHelper.listenWithId('messages_read', _listenerId, (data) {
      _handleMessagesRead(data);
    });
  }

  void _handleMessagesRead(dynamic data) async {
    if (isClosed) return;

    final chatRoomId = data['chatRoomId']?.toString();
    if (chatRoomId != _currentChatRoomId) return;

    log('👁️ [$_listenerId] Messages read event received');

    // Update all my messages to read status
    final updatedMessages = state.messages.map((message) {
      if (message.isMe && message.status != MessageStatusEnum.read) {
        // Update in local DB
        _repo.updateMessageStatus(message.id, 'read');
        return message.copyWith(isRead: true, status: MessageStatusEnum.read);
      }
      return message;
    }).toList();

    _safeEmit(state.copyWith(messages: updatedMessages));
  }

  /// Listen for message deleted event
  void listenToMessageDeleted() {
    log('🎧 [$_listenerId] Setting up message_deleted listener');

    _socketHelper.listenWithId('message_deleted', _listenerId, (data) {
      _handleMessageDeleted(data);
    });
  }

  void _handleMessageDeleted(dynamic data) async {
    if (isClosed) return;

    final messageId = data['messageId']?.toString();
    final chatRoomId = data['chatRoomId']?.toString();

    if (messageId == null || chatRoomId != _currentChatRoomId) {
      return;
    }

    log('🗑️ [$_listenerId] Message deleted event received: $messageId');

    // Remove from local DB (silently, no need to wait)
    _repo.deleteMessageLocally(messageId);

    // Remove from state immediately
    final updatedMessages = state.messages
        .where((message) => message.id != messageId)
        .toList();

    _safeEmit(state.copyWith(messages: updatedMessages));
    log('🗑️ [$_listenerId] Message removed from state: $messageId');
  }

  /// Listen for typing indicator
  void listenToUserTyping(String chatRoomId) {
    log('🎧 [$_listenerId] Setting up user_typing listener');

    _socketHelper.listenWithId('user_typing', _listenerId, (data) {
      _handleUserTyping(data, chatRoomId);
    });
  }

  void _handleUserTyping(dynamic data, String expectedChatRoomId) {
    if (isClosed) return;

    final chatRoomId = data['chatRoomId']?.toString();
    if (chatRoomId != expectedChatRoomId) return;

    final userId = data['userId']?.toString();
    final userName = data['userName']?.toString();

    _typingTimer?.cancel();

    _safeEmit(
      state.copyWith(
        isUserTyping: true,
        typingInfo: TypinnModel(
          userId: userId ?? '',
          userName: userName ?? '',
          chatRoomId: chatRoomId ?? '',
        ),
      ),
    );

    // Reset typing after 3 seconds
    _typingTimer = Timer(const Duration(seconds: 3), () {
      resetTypingStatus();
    });
  }

  void resetTypingStatus() {
    if (isClosed) return;
    _safeEmit(state.copyWith(isUserTyping: false, clearTypingInfo: true));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TYPING INDICATORS
  // ══════════════════════════════════════════════════════════════════════════

  void typingStart(String chatRoomId) {
    _socketHelper.send('typing_start', {'chatRoomId': chatRoomId}, (ack) {});
  }

  void typingStop(String chatRoomId) {
    _socketHelper.send('typing_stop', {'chatRoomId': chatRoomId}, (ack) {});
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REPLY HANDLING
  // ══════════════════════════════════════════════════════════════════════════

  void setReplyingToMessage(ChatMessage? message) {
    if (isClosed) return;
    _safeEmit(
      state.copyWith(
        replyingToMessage: message,
        clearReplyingToMessage: message == null,
      ),
    );
  }

  void cancelReply() {
    if (isClosed) return;
    _safeEmit(state.copyWith(clearReplyingToMessage: true));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MESSAGE STATUS UPDATE (FOR BLOC SELECTOR)
  // ══════════════════════════════════════════════════════════════════════════

  /// Update a single message's status without rebuilding entire list
  /// Use with BlocSelector for efficient UI updates
  void updateSingleMessageStatus(String messageId, MessageStatusEnum status) {
    final index = state.messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final updatedMessage = state.messages[index].copyWith(status: status);
    final updatedMessages = List<ChatMessage>.from(state.messages);
    updatedMessages[index] = updatedMessage;

    // Update in local DB
    _repo.updateMessageStatus(messageId, status.toApiString());

    _safeEmit(state.copyWith(messages: updatedMessages));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DELETE MESSAGES
  // ══════════════════════════════════════════════════════════════════════════

  /// Delete a single message
  /// [deleteType] can be 'me' or 'everyone'
  Future<bool> deleteMessage({
    required String messageId,
    required String deleteType,
  }) async {
    if (_currentChatRoomId == null) return false;

    final result = await _repo.deleteMessage(
      messageId: messageId,
      chatRoomId: _currentChatRoomId!,
      deleteType: deleteType,
    );

    return result.fold(
      (error) {
        log('❌ [$_listenerId] Delete message error: $error');
        return false;
      },
      (_) {
        // Remove from local state
        final updatedMessages = state.messages
            .where((m) => m.id != messageId)
            .toList();
        _safeEmit(state.copyWith(messages: updatedMessages));
        return true;
      },
    );
  }

  /// Delete multiple messages
  /// [deleteType] can be 'me' or 'everyone'
  /// Automatically uses single or multiple delete based on count
  Future<bool> deleteMessages({
    required List<String> messageIds,
    required String deleteType,
  }) async {
    if (_currentChatRoomId == null) return false;
    if (messageIds.isEmpty) return false;

    // Use single delete for one message, multiple delete for more
    final Either<String, void> result;
    if (messageIds.length == 1) {
      result = await _repo.deleteMessage(
        messageId: messageIds.first,
        chatRoomId: _currentChatRoomId!,
        deleteType: deleteType,
      );
    } else {
      result = await _repo.deleteMessages(
        messageIds: messageIds,
        chatRoomId: _currentChatRoomId!,
        deleteType: deleteType,
      );
    }

    return result.fold(
      (error) {
        log('❌ [$_listenerId] Delete messages error: $error');
        return false;
      },
      (_) {
        // Remove from local state
        final idsSet = messageIds.toSet();
        final updatedMessages = state.messages
            .where((m) => !idsSet.contains(m.id))
            .toList();
        _safeEmit(state.copyWith(messages: updatedMessages));
        return true;
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> close() {
    log('🔴 [$_listenerId] Closing ChatMessagesCubitV2...');

    _typingTimer?.cancel();
    _messagesSubscription?.cancel();
    _connectivitySubscription?.cancel();

    _socketHelper.offAllForListener(_listenerId);

    _currentChatRoomId = null;
    _currentReceiverId = null;
    _pendingSystemMessageContents.clear();

    log('✅ [$_listenerId] ChatMessagesCubitV2 closed');

    return super.close();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BLOCK STATUS HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  /// التحقق من حالة الحظر من الرسائل
  /// يبحث عن آخر رسالة system ويحدد إذا كان المستخدم محظور أم لا
  bool _checkBlockStatusFromMessages(List<ChatMessage> messages) {
    // البحث عن آخر رسالة system من الأحدث للأقدم
    for (int i = messages.length - 1; i >= 0; i--) {
      final msg = messages[i];
      if (msg.messageType == 'system') {
        final content = msg.content.trim();
        // رسالة إلغاء حظر - يجب فحصها أولاً لأن "غير محظور" يحتوي على "محظور"
        if (content.contains('غير محظور من إرسال الرسائل')) {
          return false;
        }
        // رسالة حظر
        if (content.contains('محظور من إرسال الرسائل')) {
          return true;
        }
      }
    }
    // لو مفيش رسالة system، نرجع الـ state الحالي أو false
    return state.isBlocked;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BLOCK USER
  // ══════════════════════════════════════════════════════════════════════════

  /// Track pending system messages for block/unblock to prevent duplicates
  final Set<String> _pendingSystemMessageContents = {};

  /// Block a user with optimistic system message
  Future<Either<String, String>> blockUser({required String blockedId}) async {
    if (_currentChatRoomId == null) {
      return Left('لا يوجد محادثة مفتوحة');
    }

    try {
      log('🚫 [$_listenerId] Blocking user: $blockedId');

      // تحديث state فوراً لتعطيل منطقة الكتابة
      emit(state.copyWith(isBlocked: true));

      // إنشاء رسالة نظام محلية (Optimistic)
      // Note: Server sends with leading space, so we match it
      const systemContent = ' المستخدم محظور من إرسال الرسائل في هذه الدردشة';
      final localId = 'temp_block_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now().toIso8601String();

      final localSystemMessage = ChatMessage(
        id: localId,
        chatRoomId: _currentChatRoomId!,
        senderId: blockedId,
        senderName: '',
        senderImage: '',
        senderType: 'system',
        isMe: true,
        contentList: [systemContent],
        messageType: 'system',
        createdAt: 'الآن',
        updatedAt: now,
        isRead: false,
        status: MessageStatusEnum.sent,
      );

      // حفظ المحتوى لمنع التكرار
      _pendingSystemMessageContents.add(systemContent.trim());

      // حفظ في الـ local DB
      await _repo.saveMessageLocally(localSystemMessage, localId: localId);

      // تحديث UI فوراً
      final updatedMessages = [...state.messages, localSystemMessage];
      _safeEmit(state.copyWith(messages: updatedMessages));

      log('📤 [$_listenerId] Block system message saved locally: $localId');

      final result = await _repo.blockUser(blockedId: blockedId);
      return result.fold(
        (error) {
          log('❌ [$_listenerId] Block user failed: $error');
          // إرجاع state في حالة الفشل
          emit(state.copyWith(isBlocked: false));
          // إزالة الرسالة المحلية
          _removeLocalSystemMessage(localId);
          _pendingSystemMessageContents.remove(systemContent.trim());
          return Left(error);
        },
        (successMessage) {
          log('✅ [$_listenerId] Block user success: $successMessage');
          return Right(successMessage);
        },
      );
    } catch (e) {
      log('❌ [$_listenerId] Block user error: $e');
      emit(state.copyWith(isBlocked: false));
      return Left('حدث خطأ أثناء حظر المستخدم');
    }
  }

  /// Unblock a user with optimistic system message
  Future<Either<String, String>> unblockUser({
    required String blockedId,
  }) async {
    if (_currentChatRoomId == null) {
      return Left('لا يوجد محادثة مفتوحة');
    }

    try {
      log('✅ [$_listenerId] Unblocking user: $blockedId');

      // تحديث state فوراً لتفعيل منطقة الكتابة
      emit(state.copyWith(isBlocked: false));

      // إنشاء رسالة نظام محلية (Optimistic)
      // Note: Match server format
      const systemContent =
          'المستخدم غير محظور من إرسال الرسائل في هذه الدردشة';
      final localId = 'temp_unblock_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now().toIso8601String();

      final localSystemMessage = ChatMessage(
        id: localId,
        chatRoomId: _currentChatRoomId!,
        senderId: blockedId,
        senderName: '',
        senderImage: '',
        senderType: 'system',
        isMe: true,
        contentList: [systemContent],
        messageType: 'system',
        createdAt: 'الآن',
        updatedAt: now,
        isRead: false,
        status: MessageStatusEnum.sent,
      );

      // حفظ المحتوى لمنع التكرار
      _pendingSystemMessageContents.add(systemContent.trim());

      // حفظ في الـ local DB
      await _repo.saveMessageLocally(localSystemMessage, localId: localId);

      // تحديث UI فوراً
      final updatedMessages = [...state.messages, localSystemMessage];
      _safeEmit(state.copyWith(messages: updatedMessages));

      log('📤 [$_listenerId] Unblock system message saved locally: $localId');

      final result = await _repo.unblockUser(blockedId: blockedId);
      return result.fold(
        (error) {
          log('❌ [$_listenerId] Unblock user failed: $error');
          // إرجاع state في حالة الفشل
          emit(state.copyWith(isBlocked: true));
          // إزالة الرسالة المحلية
          _removeLocalSystemMessage(localId);
          _pendingSystemMessageContents.remove(systemContent.trim());
          return Left(error);
        },
        (successMessage) {
          log('✅ [$_listenerId] Unblock user success: $successMessage');
          return Right(successMessage);
        },
      );
    } catch (e) {
      log('❌ [$_listenerId] Unblock user error: $e');
      emit(state.copyWith(isBlocked: true));
      return Left('حدث خطأ أثناء إلغاء حظر المستخدم');
    }
  }

  /// إزالة رسالة نظام محلية في حالة الفشل
  void _removeLocalSystemMessage(String localId) {
    final updatedMessages = state.messages
        .where((m) => m.id != localId)
        .toList();
    _safeEmit(state.copyWith(messages: updatedMessages));
    // حذف من الـ local DB
    _repo.deleteMessageLocally(localId);
    log('🗑️ [$_listenerId] Removed local system message: $localId');
  }
}
