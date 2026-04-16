import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:tayseer/core/cache/chat_cache_service.dart';
import 'package:tayseer/core/enum/message_status_enum.dart';
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
  bool _amIBlocker = false; // true = أنا الحاظر, false = أنا محظور
  bool _isUserTyping = false;
  TypingModel? _typingInfo;
  int? _freeChatMinsLeft;

  final Map<String, double> _uploadProgress = {};

  ChatMessagesCubit({required ChatRepoSimple repo})
    : _repo = repo,
      super(const ChatMessagesState.initial());

  // ══════════════════════════════════════════════════════════════════════════
  // JOIN / LEAVE ROOM
  // ══════════════════════════════════════════════════════════════════════════

  /// Join a chat room with [targetId] and load messages.
  /// Emits `joinChatRoom` socket event, then waits for `chatRoomJoined`.
  Future<void> loadInitialMessages(
    String chatRoomId, {
    String? receiverId,
    bool isSystemChat = false,
  }) async {
    _currentChatRoomId = chatRoomId;
    _currentReceiverId = receiverId;

    // 1. عرض الكاش فوراً لو موجود
    final cachedMessages = _cacheService.getCachedMessages(chatRoomId: chatRoomId);
    if (cachedMessages != null && cachedMessages.isNotEmpty) {
      _isBlocked = _checkBlockStatusFromMessages(cachedMessages);
      emit(
        ChatMessagesState.loaded(
          messages: cachedMessages,
          hasMoreMessages: false,
          isBlocked: _isBlocked,
        ),
      );
    } else {
      emit(const ChatMessagesState.loading());
    }

    // 2. جلب من السيرفر وتحديث
    try {
      final messages = await _repo.loadMessages(chatRoomId);

      _isBlocked = _checkBlockStatusFromMessages(messages);

      emit(
        ChatMessagesState.loaded(
          messages: messages,
          hasMoreMessages: false,
          isBlocked: _isBlocked,
        ),
      );

      setupSocketListeners();

      // 3. حفظ في الكاش
      await _cacheService.saveMessages(
        chatRoomId: chatRoomId,
        messages: messages,
      );

      // Join the chat room via socket so the server starts delivering events.
      if (isSystemChat) {
        // في حالة System Chat نرسل system: true
        _socketHelper.send('joinChatRoom', {'system': true}, null);
      } else if (receiverId != null) {
        // في حالة المحادثات العادية نرسل targetId
        _socketHelper.send('joinChatRoom', {'targetId': receiverId}, null);
      }
    } catch (e) {
      log('❌ Error loading messages: $e');
      // لو فشل وما عندناش كاش، نعرض error
      if (cachedMessages == null || cachedMessages.isEmpty) {
        emit(ChatMessagesState.failure(message: e.toString()));
      }
    }
  }

  /// Leave the current chat room and remove all socket listeners.
  void leaveCurrentChatRoom() {
    if (_currentChatRoomId == null) return;

    _socketHelper.send('leaveChatRoom', {
      'chatRoomId': _currentChatRoomId,
    }, null);

    final listenerId = 'ChatMessagesCubit_$_currentChatRoomId';
    _socketHelper.offAllForListener(listenerId);
  }

  bool _checkBlockStatusFromMessages(List<ChatMessage> messages) {
    for (final msg in messages.reversed) {
      if (msg.messageType == 'system') {
        if (msg.action.isBlock) return true;
        if (msg.action.isUnblock) return false;
      }
    }
    return false;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEND TEXT MESSAGE
  // ══════════════════════════════════════════════════════════════════════════

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

    // New event name: sendTextMessage
    // New payload: chatRoomId + text (not content) + optional replyToMessageId + tempId
    final socketData = <String, dynamic>{
      'chatRoomId': chatRoomId,
      'text': message,
      'tempId': tempId,
    };

    if (replyMessageId != null && !replyMessageId.startsWith('temp_')) {
      socketData['replyToMessageId'] = replyMessageId;
    }

    _socketHelper.send('sendTextMessage', socketData, (ack) {
      log('✅ sendTextMessage ACK: $ack');
    });
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
        log('❌ Media upload failed: $error');
        _updateMessageStatus(localId, MessageStatusEnum.failed);
        _uploadProgress.remove(localId);
      },
      (response) {
        log('✅ Media uploaded: ${response.message.id}');
        _replaceOptimisticMessage(localId, response.message);
        _uploadProgress.remove(localId);
      },
    );
  }

  void _emitProgressUpdate(String messageId, double progress) {
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
    final currentMessages = state.messagesOrEmpty;
    final index = currentMessages.indexWhere((m) => m.id == localId);
    if (index == -1) return;

    final updatedMessages = List<ChatMessage>.from(currentMessages);
    // Use the status from the server message instead of hardcoding 'sent'
    updatedMessages[index] = serverMessage;
    log('✅ Replaced optimistic message with server message - status: ${serverMessage.status}');

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

    // SERVER → CLIENT: newMessage  { message: {...}, chatRoom: {...} }
    _socketHelper.listenWithId('newMessage', listenerId, (data) {
      if (data is! Map) return;
      final messageData = data['message'];
      if (messageData is! Map) return;
      final message = ChatMessage.fromJson(messageData as Map<String, dynamic>);
      _handleNewMessage(message);
    });

    // SERVER → CLIENT: messageDeleted  { chatMessageIds: string[] }
    _socketHelper.listenWithId('messageDeleted', listenerId, (data) {
      if (data is! Map) return;
      final ids = data['chatMessageIds'];
      if (ids is List) {
        for (final id in ids) {
          _handleMessageDeleted(id.toString());
        }
      }
    });

    // SERVER → CLIENT: typingStatus  { isTyping: boolean }
    _socketHelper.listenWithId('typingStatus', listenerId, (data) {
      if (data is! Map) return;
      final isTyping = data['isTyping'] as bool? ?? false;
      _handleTypingStatus(isTyping);
    });

    // SERVER → CLIENT: newMessageState  { status: "RECEIVED"|"READ", messageIds: string[] }
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

    // SERVER → CLIENT: blockerStatus  { userId, newBlockStatus }
    // أنا اللي حاظر - يظهر لي حذف المحادثة أو إلغاء الحظر
    _socketHelper.listenWithId('blockerStatus', listenerId, (data) {
      if (data is! Map) return;
      final newBlockStatus = data['newBlockStatus'] as bool? ?? false;
      _handleBlockerStatusChanged(newBlockStatus);
    });

    // SERVER → CLIENT: blockedStatus  { userId, newBlockStatus }
    // أنا محظور - مقدرش أبعت رسائل
    _socketHelper.listenWithId('blockedStatus', listenerId, (data) {
      if (data is! Map) return;
      final newBlockStatus = data['newBlockStatus'] as bool? ?? false;
      _handleBlockedStatusChanged(newBlockStatus);
    });

    // SERVER → CLIENT: chatRoomJoined  { chatRoomId, blockExists, isMe, ... }
    _socketHelper.listenWithId('chatRoomJoined', listenerId, (data) {
      if (data is! Map) return;
      final blockExists = data['blockExists'] as bool? ?? false;
      final isMe = data['isMe'] as bool?;
      _freeChatMinsLeft = data['freeChatMinsLeft'] as int?;
      _isBlocked = blockExists;
      log('✅ chatRoomJoined: blockExists=$blockExists, isMe=$isMe, freeChatMinsLeft=$_freeChatMinsLeft');
      _emitCurrentState();
    });

    // SERVER → CLIENT: chatRoomLeft  { chatRoomId }
    _socketHelper.listenWithId('chatRoomLeft', listenerId, (data) {
      log('👋 chatRoomLeft: $data');
    });

    // SERVER → CLIENT: messageReaction  { chatMessageId, reactions: [{userId, emoji}] }
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

    // Match by tempId first (most reliable), then fall back to content match
    if (message.isMe) {
      final tempIndex = currentMessages.indexWhere(
        (m) =>
            m.id.startsWith('temp_') &&
            (m.tempId == message.tempId ||
                (message.tempId == null && m.content == message.content)),
      );
      if (tempIndex != -1) {
        final updatedMessages = List<ChatMessage>.from(currentMessages);
        // Use the status from the server message instead of hardcoding 'sent'
        updatedMessages[tempIndex] = message;
        log('✅ Replaced temp message with server message - status: ${message.status}');
        emit(
          ChatMessagesState.loaded(
            messages: updatedMessages,
            hasMoreMessages: false,
            isBlocked: _isBlocked,
            isUserTyping: _isUserTyping,
            typingInfo: _typingInfo,
          ),
        );
        // تحديث الكاش
        _updateCache(updatedMessages);
        return;
      }
    }

    // Handle system messages (block/unblock)
    if (message.messageType == 'system') {
      if (message.action.isBlock) _isBlocked = true;
      if (message.action.isUnblock) _isBlocked = false;

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
        // تحديث الكاش
        _updateCache(updatedMessages);
        return;
      }
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
    // تحديث الكاش
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
    // تحديث الكاش
    _updateCache(updatedMessages);
  }

  /// تحديث الكاش بعد أي تغيير في الرسائل
  Future<void> _updateCache(List<ChatMessage> messages) async {
    if (_currentChatRoomId != null) {
      await _cacheService.saveMessages(
        chatRoomId: _currentChatRoomId!,
        messages: messages,
      );
    }
  }

  /// Handles `typingStatus` from the other participant.
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

    // Auto-clear after 3 s in case the stop event never arrives
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

  /// Handles `newMessageState` — updates delivery/read status for specific messages.
  void _handleMessageStateUpdate({
    required String status,
    required List<String> messageIds,
  }) {
    final parsedStatus = MessageStatusExtension.fromString(status);
    final currentMessages = state.messagesOrEmpty;
    final messageIdSet = messageIds.toSet();

    log('📊 Updating message status: $status → $parsedStatus for ${messageIds.length} messages');

    // Create a completely new list with updated messages
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

    // تحديث الكاش
    _updateCache(updatedMessages);
  }

  /// معالجة blockerStatus - أنا اللي حاظر
  /// يظهر لي حذف المحادثة أو إلغاء الحظر
  void _handleBlockerStatusChanged(bool isBlocked) {
    log('🔒 blockerStatus changed: isBlocked=$isBlocked (أنا الحاظر)');
    _isBlocked = isBlocked;
    _amIBlocker = isBlocked; // أنا الحاظر
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

  /// معالجة blockedStatus - أنا محظور
  /// مقدرش أبعت رسائل
  void _handleBlockedStatusChanged(bool isBlocked) {
    log('🚫 blockedStatus changed: isBlocked=$isBlocked (أنا محظور)');
    _isBlocked = isBlocked;
    _amIBlocker = false; // أنا محظور
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

  /// getter للتحقق من نوع الحظر
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
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TYPING  (CLIENT → SERVER)
  // ══════════════════════════════════════════════════════════════════════════

  void typingStart(String chatRoomId) {
    if (_currentReceiverId == null) return;
    _socketHelper.send('typingStatus', {
      'chatRoomId': chatRoomId,
      'receiverId': _currentReceiverId,
      'isTyping': true,
    }, null);
  }

  void typingStop(String chatRoomId) {
    if (_currentReceiverId == null) return;
    _socketHelper.send('typingStatus', {
      'chatRoomId': chatRoomId,
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

    // Optimistic delete: remove from UI immediately
    _handleMessageDeleted(messageId);

    final result = await _repo.deleteMessage(
      messageId: messageId,
      chatRoomId: _currentChatRoomId!,
      deleteType: deleteType,
    );

    return result.fold((error) {
      log('❌ Delete failed on server: $error');
      // We could potentially reload messages here to revert the optimistic delete,
      // but removing it is usually safer for UX.
      return false;
    }, (_) => true);
  }

  Future<bool> deleteMessages({
    required List<String> messageIds,
    required String deleteType,
  }) async {
    if (_currentChatRoomId == null) return false;

    // Optimistic delete
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
    _amIBlocker = true; // أنا الحاظر

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
    _amIBlocker = false; // مش حاظر دلوقتي

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

  void setInitialBlocked(bool isBlocked) {
    _isBlocked = isBlocked;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> close() {
    if (_currentChatRoomId != null) {
      final listenerId = 'ChatMessagesCubit_$_currentChatRoomId';
      _socketHelper.offAllForListener(listenerId);
    }
    leaveCurrentChatRoom();
    return super.close();
  }

  Future<void> loadOlderMessages() async {
    // TODO: implement cursor-based pagination using repo.loadMessages(before:)
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REACTIONS
  // ══════════════════════════════════════════════════════════════════════════

  /// إضافة أو إزالة reaction على رسالة
  void reactToMessage({
    required String messageId,
    required String emoji,
  }) {
    final currentMessages = state.messagesOrEmpty;
    final messageIndex = currentMessages.indexWhere((m) => m.id == messageId);
    
    if (messageIndex == -1) return;

    final message = currentMessages[messageIndex];
    final currentUserId = kCurrentUserData?.id ?? '';
    
    // Check if user already reacted with this emoji
    final existingReaction = message.reactions.firstWhere(
      (r) => r.userId == currentUserId && r.emoji == emoji,
      orElse: () => const MessageReaction(userId: '', emoji: ''),
    );

    if (existingReaction.userId.isNotEmpty) {
      // User already reacted with this emoji, so remove it
      _socketHelper.send('unreactToMessage', {
        'chatMessageId': messageId,
      }, (ack) {
        log('✅ unreactToMessage ACK: $ack');
      });
    } else {
      // Add new reaction
      _socketHelper.send('reactToMessage', {
        'chatMessageId': messageId,
        'emoji': emoji,
      }, (ack) {
        log('✅ reactToMessage ACK: $ack');
      });
    }
  }

  /// Handle reaction update from server
  void _handleMessageReaction(Map data) {
    final chatMessageId = data['chatMessageId']?.toString();
    final reactionsData = data['reactions'] as List?;

    if (chatMessageId == null || reactionsData == null) return;

    final reactions = reactionsData
        .map((r) {
          final reactionMap = Map<String, dynamic>.from(r as Map);
          return MessageReaction.fromJson(reactionMap);
        })
        .toList();

    final currentMessages = state.messagesOrEmpty;
    final messageIndex = currentMessages.indexWhere((m) => m.id == chatMessageId);

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

    log('✅ Message reactions updated: $chatMessageId - ${reactions.length} reactions');
  }
}
