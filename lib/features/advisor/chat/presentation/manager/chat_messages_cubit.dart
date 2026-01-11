import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/core/enum/message_status_enum.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/typing_model.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/send_media_message_response.dart';
import 'handlers/socket_listener_handler.dart';
import 'handlers/message_state_handler.dart';
import 'handlers/typing_handler.dart';
import 'handlers/connectivity_handler.dart';
import 'handlers/block_handler.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_v2.dart';
import 'package:tayseer/features/advisor/chat/domain/chat_domain.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/state/chat_messages_state.dart';

/// Refactored Local-First Chat Messages Cubit
///
/// Uses:
/// - Freezed state for immutable, type-safe state management
/// - Use Cases for business logic separation
/// - Clean Architecture principles
class ChatMessagesCubit extends Cubit<ChatMessagesState> {
  // ══════════════════════════════════════════════════════════════════════════
  // DEPENDENCIES
  // ══════════════════════════════════════════════════════════════════════════

  final ChatRepoV2 _repo;
  final tayseerSocketHelper _socketHelper = getIt.get<tayseerSocketHelper>();

  // Use Cases
  final SendMessageUseCase _sendMessageUseCase;
  final SendMediaUseCase _sendMediaUseCase;
  final LoadMessagesUseCase _loadMessagesUseCase;
  final LoadOlderMessagesUseCase _loadOlderMessagesUseCase;
  final DeleteMessagesUseCase _deleteMessagesUseCase;
  final BlockUserUseCase _blockUserUseCase;
  final UnblockUserUseCase _unblockUserUseCase;

  // ══════════════════════════════════════════════════════════════════════════
  // INTERNAL STATE
  // ══════════════════════════════════════════════════════════════════════════

  StreamSubscription? _messagesSubscription;

  late final String _listenerId;
  String? _currentChatRoomId;
  String? _currentReceiverId;
  SocketListenerHandler? _socketHandler;
  late final MessageStateHandler _messageStateHandler;
  late final TypingHandler _typingHandler;
  late final ConnectivityHandler _connectivityHandler;
  late final BlockHandler _blockHandler;

  // ══════════════════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  // ══════════════════════════════════════════════════════════════════════════

  ChatMessagesCubit({
    required ChatRepoV2 repo,
    required SendMessageUseCase sendMessageUseCase,
    required SendMediaUseCase sendMediaUseCase,
    required LoadMessagesUseCase loadMessagesUseCase,
    required LoadOlderMessagesUseCase loadOlderMessagesUseCase,
    required DeleteMessagesUseCase deleteMessagesUseCase,
    required BlockUserUseCase blockUserUseCase,
    required UnblockUserUseCase unblockUserUseCase,
  }) : _repo = repo,
       _sendMessageUseCase = sendMessageUseCase,
       _sendMediaUseCase = sendMediaUseCase,
       _loadMessagesUseCase = loadMessagesUseCase,
       _loadOlderMessagesUseCase = loadOlderMessagesUseCase,
       _deleteMessagesUseCase = deleteMessagesUseCase,
       _blockUserUseCase = blockUserUseCase,
       _unblockUserUseCase = unblockUserUseCase,
       super(const ChatMessagesState.initial()) {
    _listenerId =
        'ChatMessagesCubit_${DateTime.now().millisecondsSinceEpoch}_$hashCode';
    log('🆔 ChatMessagesCubit created with ID: $_listenerId');

    _messageStateHandler = MessageStateHandler(
      repo: _repo,
      listenerId: _listenerId,
      deleteMessagesUseCase: _deleteMessagesUseCase,
      getCurrentMessages: () => state.messagesOrEmpty,
      getCurrentPendingCount: () =>
          state.maybeMap(loaded: (s) => s.pendingCount, orElse: () => 0),
      onMessagesUpdated: (messages) => _emitLoaded(messages: messages),
      onPendingCountUpdated: (count) => _emitLoaded(pendingCount: count),
    );

    _typingHandler = TypingHandler(
      socketHelper: _socketHelper,
      onTypingStatusChanged: (isTyping, typingInfo) => _emitLoaded(
        isUserTyping: isTyping,
        typingInfo: typingInfo,
        clearTypingInfo: !isTyping,
      ),
    );

    _connectivityHandler = ConnectivityHandler(
      connectivity: Connectivity(),
      repo: _repo,
      socketHelper: _socketHelper,
      listenerId: _listenerId,
      onConnectivityChanged: (isOnline) => _emitLoaded(isOnline: isOnline),
    );
    _connectivityHandler.setupConnectivityListener();

    _blockHandler = BlockHandler(
      blockUserUseCase: _blockUserUseCase,
      unblockUserUseCase: _unblockUserUseCase,
      messageStateHandler: _messageStateHandler,
      listenerId: _listenerId,
      onBlockStatusChanged: (isBlocked) => _emitLoaded(isBlocked: isBlocked),
      onMessagesUpdated: (messages) => _emitLoaded(messages: messages),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SAFE EMIT HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  void _safeEmit(ChatMessagesState newState) {
    if (!isClosed) {
      emit(newState);
    } else {
      log('⚠️ [$_listenerId] Attempted to emit after close');
    }
  }

  /// Helper to emit loaded state updates
  void _emitLoaded({
    List<ChatMessage>? messages,
    bool? hasMoreMessages,
    bool? isOnline,
    int? pendingCount,
    bool? isBlocked,
    bool? isUserTyping,
    TypingModel? typingInfo,
    ChatMessage? replyingToMessage,
    bool clearReplyingToMessage = false,
    bool clearTypingInfo = false,
    CubitStates? paginationState,
    CubitStates? sendMediaState,
  }) {
    state.maybeMap(
      loaded: (current) {
        _safeEmit(
          current.copyWith(
            messages: messages ?? current.messages,
            hasMoreMessages: hasMoreMessages ?? current.hasMoreMessages,
            isOnline: isOnline ?? current.isOnline,
            pendingCount: pendingCount ?? current.pendingCount,
            isBlocked: isBlocked ?? current.isBlocked,
            isUserTyping: isUserTyping ?? current.isUserTyping,
            typingInfo: clearTypingInfo
                ? null
                : (typingInfo ?? current.typingInfo),
            replyingToMessage: clearReplyingToMessage
                ? null
                : (replyingToMessage ?? current.replyingToMessage),
            paginationState: paginationState ?? current.paginationState,
            sendMediaState: sendMediaState ?? current.sendMediaState,
          ),
        );
      },
      loadingMore: (current) {
        _safeEmit(
          ChatMessagesState.loaded(
            messages: messages ?? current.messages,
            hasMoreMessages: hasMoreMessages ?? current.hasMoreMessages,
            isOnline: isOnline ?? current.isOnline,
            pendingCount: pendingCount ?? current.pendingCount,
            isBlocked: isBlocked ?? current.isBlocked,
            isUserTyping: isUserTyping ?? current.isUserTyping,
            typingInfo: clearTypingInfo ? null : typingInfo,
            replyingToMessage: clearReplyingToMessage
                ? null
                : replyingToMessage,
          ),
        );
      },
      orElse: () {
        // For other states, create a new loaded state
        _safeEmit(
          ChatMessagesState.loaded(
            messages: messages ?? [],
            hasMoreMessages: hasMoreMessages ?? true,
            isOnline: isOnline ?? true,
            pendingCount: pendingCount ?? 0,
            isBlocked: isBlocked ?? false,
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CONNECTIVITY HANDLING
  // ══════════════════════════════════════════════════════════════════════════

  // ══════════════════════════════════════════════════════════════════════════
  // INITIAL LOAD (LOCAL-FIRST)
  // ══════════════════════════════════════════════════════════════════════════

  void setInitialBlocked(bool isBlocked) {
    if (isBlocked) {
      _emitLoaded(isBlocked: true);
    }
  }

  Future<void> loadInitialMessages(
    String chatRoomId, {
    String? receiverId,
  }) async {
    _currentChatRoomId = chatRoomId;
    _currentReceiverId = receiverId;
    log('📥 [$_listenerId] Loading for receiverId: $_currentReceiverId');

    log('📥 [$_listenerId] Loading initial messages for: $chatRoomId');
    _safeEmit(const ChatMessagesState.loading());

    try {
      _subscribeToMessages(chatRoomId);

      final messages = await _loadMessagesUseCase.call(chatRoomId);

      if (isClosed) return;

      final isBlocked = _blockHandler.checkBlockStatusFromMessages(
        messages,
        state.isBlockedStatus,
      );

      _safeEmit(
        ChatMessagesState.loaded(
          messages: messages,
          hasMoreMessages: messages.length >= 20,
          isBlocked: isBlocked,
        ),
      );

      await _loadMessagesUseCase.markAsRead(chatRoomId);

      log('✅ [$_listenerId] Loaded ${messages.length} messages from local DB');
      log('🔒 [$_listenerId] Block status from messages: $isBlocked');
    } catch (e) {
      log('❌ [$_listenerId] Error loading messages: $e');
      if (!isClosed) {
        _safeEmit(ChatMessagesState.failure(message: e.toString()));
      }
    }
  }

  void _subscribeToMessages(String chatRoomId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _loadMessagesUseCase
        .watch(chatRoomId)
        .listen(
          (messages) {
            if (!isClosed) {
              final hasMore = messages.length >= 20;
              // Re-check block status from latest messages (after sync)
              final isBlocked = _blockHandler.checkBlockStatusFromMessages(
                messages,
                state.isBlockedStatus,
              );
              _emitLoaded(
                messages: messages,
                hasMoreMessages: hasMore,
                isBlocked: isBlocked,
              );
            }
          },
          onError: (e) {
            log('⚠️ [$_listenerId] Message stream error: $e');
          },
        );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PAGINATION
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> loadOlderMessages() async {
    if (_currentChatRoomId == null) return;

    final currentMessages = state.messagesOrEmpty;
    if (currentMessages.isEmpty) return;

    final canLoad = state.maybeMap(
      loaded: (s) =>
          s.hasMoreMessages && s.paginationState != CubitStates.loading,
      orElse: () => false,
    );
    if (!canLoad) return;

    final oldestMessage = currentMessages.first;
    final cursorTimestamp = await _loadOlderMessagesUseCase.getCursorTimestamp(
      oldestMessage.id,
    );

    if (cursorTimestamp == null) {
      log(
        '⚠️ [$_listenerId] Could not get sort_timestamp for message ${oldestMessage.id}',
      );
      _emitLoaded(hasMoreMessages: false);
      return;
    }

    log(
      '📜 [$_listenerId] Loading older messages before timestamp: $cursorTimestamp',
    );
    _emitLoaded(paginationState: CubitStates.loading);

    try {
      final olderMessages = await _loadOlderMessagesUseCase.call(
        LoadOlderMessagesParams(
          chatRoomId: _currentChatRoomId!,
          cursorTimestamp: cursorTimestamp,
        ),
      );

      if (isClosed) return;

      final updatedMessages = [...olderMessages, ...currentMessages];

      _emitLoaded(
        paginationState: CubitStates.success,
        messages: updatedMessages,
        hasMoreMessages: olderMessages.length >= 20,
      );

      log('✅ [$_listenerId] Loaded ${olderMessages.length} older messages');
    } catch (e) {
      log('❌ [$_listenerId] Error loading older messages: $e');
      if (!isClosed) {
        _emitLoaded(paginationState: CubitStates.failure);
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEND MESSAGE (USING USE CASE)
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> sendMessage(
    String receiverId,
    String message,
    String chatRoomId, {
    String? replyMessageId,
    ChatMessage? replyToMessage,
  }) async {
    // Use the SendMessageUseCase
    final result = await _sendMessageUseCase.call(
      SendMessageParams(
        receiverId: receiverId,
        message: message,
        chatRoomId: chatRoomId,
        replyMessageId: replyMessageId,
        replyToMessage: replyToMessage,
      ),
    );

    // Update UI immediately with local message
    final currentMessages = state.messagesOrEmpty;
    final updatedMessages = [...currentMessages, result.localMessage];
    final currentPendingCount = state.maybeMap(
      loaded: (s) => s.pendingCount,
      orElse: () => 0,
    );

    _emitLoaded(
      messages: updatedMessages,
      pendingCount: currentPendingCount + 1,
      clearReplyingToMessage: true,
    );

    log('📤 [$_listenerId] Message saved locally: ${result.localId}');

    // Send to server via socket
    _socketHelper.send('send_message', result.socketData, (ack) {
      log('✅ [$_listenerId] Send message ACK: $ack');
    });
  }

  Future<void> sendMediaMessage({
    required String chatRoomId,
    required String messageType,
    List<File>? images,
    List<File>? videos,
    String? replyMessageId,
    ChatMessage? replyToMessage,
  }) async {
    if (isClosed) return;

    final params = SendMediaParams(
      chatRoomId: chatRoomId,
      messageType: messageType,
      images: images,
      videos: videos,
      replyMessageId: replyMessageId,
      replyToMessage: replyToMessage,
    );

    // Step 1: Create optimistic local message with local file paths
    final optimisticResult = await _sendMediaUseCase.createOptimisticMessage(
      params,
    );

    if (isClosed) return;

    // Step 2: Add local message to UI immediately
    final currentMessages = state.messagesOrEmpty;
    final currentPendingCount = state.maybeMap(
      loaded: (s) => s.pendingCount,
      orElse: () => 0,
    );

    _emitLoaded(
      messages: [...currentMessages, optimisticResult.localMessage],
      pendingCount: currentPendingCount + 1,
      clearReplyingToMessage: true,
      sendMediaState: CubitStates.loading,
    );

    log(
      '📤 [$_listenerId] Media message saved locally: ${optimisticResult.localId}',
    );

    // Step 3: Upload media to server in background (with tempId)
    final uploadParams = SendMediaParams(
      chatRoomId: params.chatRoomId,
      messageType: params.messageType,
      images: params.images,
      videos: params.videos,
      replyMessageId: params.replyMessageId,
      replyToMessage: params.replyToMessage,
      tempId: optimisticResult.tempId,
    );
    final uploadResult = await _sendMediaUseCase.upload(uploadParams);

    if (isClosed) return;

    uploadResult.fold(
      (error) {
        log('❌ [$_listenerId] Media upload failed: $error');
        // Update status to failed but keep showing local file
        _updateMediaMessageStatus(
          optimisticResult.localId,
          MessageStatusEnum.failed,
        );
        _emitLoaded(sendMediaState: CubitStates.failure);
      },
      (response) {
        log('✅ [$_listenerId] Media uploaded: ${response.data.id}');
        // Replace local message with server message (with URLs instead of local paths)
        _confirmMediaMessageSent(optimisticResult.localId, response.data);
        _emitLoaded(sendMediaState: CubitStates.success);
      },
    );
  }

  /// Update media message status when upload fails
  void _updateMediaMessageStatus(String localId, MessageStatusEnum status) {
    final currentMessages = state.messagesOrEmpty;
    final index = currentMessages.indexWhere((m) => m.id == localId);
    if (index == -1) return;

    final updatedMessages = List<ChatMessage>.from(currentMessages);
    updatedMessages[index] = currentMessages[index].copyWith(status: status);

    _emitLoaded(messages: updatedMessages);
  }

  /// Replace local media message with server confirmed message
  void _confirmMediaMessageSent(String localId, SentMessage serverData) {
    final currentMessages = state.messagesOrEmpty;
    final index = currentMessages.indexWhere((m) => m.id == localId);
    if (index == -1) {
      log('⚠️ [$_listenerId] Local media message not found: $localId');
      return;
    }

    // Create server message with URLs (no local file paths)
    final serverMessage = ChatMessage(
      id: serverData.id,
      chatRoomId: serverData.chatRoomId,
      senderId: serverData.senderId,
      senderName: serverData.senderName,
      senderImage: serverData.senderImage ?? '',
      senderType: serverData.senderType,
      isMe: serverData.isMe,
      contentList: serverData.contentList, // Server URLs
      messageType: serverData.messageType,
      createdAt: serverData.createdAt,
      updatedAt: serverData.updatedAt,
      isRead: serverData.isRead,
      reply: serverData.reply,
      status: MessageStatusEnum.sent,
      // Clear local file paths since we now have server URLs
    );

    // Update local database
    _repo.confirmMessageSent(localId, serverData.id);

    // Update state
    final updatedMessages = List<ChatMessage>.from(currentMessages);
    updatedMessages[index] = serverMessage;

    final currentPendingCount = state.maybeMap(
      loaded: (s) => s.pendingCount,
      orElse: () => 0,
    );

    _emitLoaded(
      messages: updatedMessages,
      pendingCount: currentPendingCount > 0 ? currentPendingCount - 1 : 0,
    );

    log(
      '✅ [$_listenerId] Media message confirmed: $localId -> ${serverData.id}',
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SOCKET LISTENERS
  // ══════════════════════════════════════════════════════════════════════════

  void setupSocketListeners() {
    if (_currentChatRoomId == null) return;

    _socketHandler = SocketListenerHandler(
      socketHelper: _socketHelper,
      listenerId: _listenerId,
      chatRoomId: _currentChatRoomId!,
      onNewMessage: (message) {
        if (isClosed) return;
        if (message.messageType == 'system') {
          _messageStateHandler.handleSystemMessage(message);
          // Update block status if this is a block/unblock system message
          if (message.action.isBlock || message.action.isUnblock) {
            final newBlockStatus = message.action.isBlock;
            _emitLoaded(isBlocked: newBlockStatus);
            log(
              '🔒 [$_listenerId] Block status updated from system message: $newBlockStatus',
            );
          }
        } else if (message.isMe) {
          _messageStateHandler.handleSentMessageConfirmation(message);
        } else {
          _messageStateHandler.handleIncomingMessage(message);
        }
      },
      onMessagesRead: () {
        _messageStateHandler.handleMessagesRead();
      },
      onMessageDeleted: (messageId) {
        _messageStateHandler.handleMessageDeleted(messageId);
      },
      onUserTyping: (userId, userName) {
        if (_currentChatRoomId != null) {
          _typingHandler.handleUserTyping(
            userId,
            userName,
            _currentChatRoomId!,
          );
        }
      },
    );

    _socketHandler!.setupListeners();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TYPING INDICATORS
  // ══════════════════════════════════════════════════════════════════════════

  void typingStart(String chatRoomId) => _typingHandler.typingStart(chatRoomId);

  void typingStop(String chatRoomId) => _typingHandler.typingStop(chatRoomId);

  // ══════════════════════════════════════════════════════════════════════════
  // REPLY HANDLING
  // ══════════════════════════════════════════════════════════════════════════

  void setReplyingToMessage(ChatMessage? message) {
    if (isClosed) return;
    _emitLoaded(
      replyingToMessage: message,
      clearReplyingToMessage: message == null,
    );
  }

  void cancelReply() {
    if (isClosed) return;
    _emitLoaded(clearReplyingToMessage: true);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MESSAGE STATUS UPDATE
  // ══════════════════════════════════════════════════════════════════════════

  void updateSingleMessageStatus(String messageId, MessageStatusEnum status) {
    final currentMessages = state.messagesOrEmpty;
    final index = currentMessages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    final updatedMessage = currentMessages[index].copyWith(status: status);
    final updatedMessages = List<ChatMessage>.from(currentMessages);
    updatedMessages[index] = updatedMessage;

    _repo.updateMessageStatus(messageId, status.toApiString());

    _emitLoaded(messages: updatedMessages);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DELETE MESSAGES (USING USE CASE)
  // ══════════════════════════════════════════════════════════════════════════

  Future<bool> deleteMessage({
    required String messageId,
    required String deleteType,
  }) async {
    if (_currentChatRoomId == null) return false;

    final result = await _deleteMessagesUseCase.call(
      DeleteMessagesParams.single(
        messageId: messageId,
        chatRoomId: _currentChatRoomId!,
        deleteType: deleteType,
      ),
    );

    return result.fold(
      (error) {
        log('❌ [$_listenerId] Delete message error: $error');
        return false;
      },
      (_) {
        final updatedMessages = state.messagesOrEmpty
            .where((m) => m.id != messageId)
            .toList();
        _emitLoaded(messages: updatedMessages);
        return true;
      },
    );
  }

  Future<bool> deleteMessages({
    required List<String> messageIds,
    required String deleteType,
  }) async {
    if (_currentChatRoomId == null) return false;
    if (messageIds.isEmpty) return false;

    final result = await _deleteMessagesUseCase.call(
      DeleteMessagesParams(
        messageIds: messageIds,
        chatRoomId: _currentChatRoomId!,
        deleteType: deleteType,
      ),
    );

    return result.fold(
      (error) {
        log('❌ [$_listenerId] Delete messages error: $error');
        return false;
      },
      (_) {
        final idsSet = messageIds.toSet();
        final updatedMessages = state.messagesOrEmpty
            .where((m) => !idsSet.contains(m.id))
            .toList();
        _emitLoaded(messages: updatedMessages);
        return true;
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BLOCK STATUS HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  // ══════════════════════════════════════════════════════════════════════════
  // BLOCK USER (USING USE CASE)
  // ══════════════════════════════════════════════════════════════════════════

  Future<Either<String, String>> blockUser({required String blockedId}) async {
    if (_currentChatRoomId == null) {
      return const Left('لا يوجد محادثة مفتوحة');
    }

    return _blockHandler.blockUser(
      chatRoomId: _currentChatRoomId!,
      blockedId: blockedId,
    );
  }

  Future<Either<String, String>> unblockUser({
    required String blockedId,
  }) async {
    if (_currentChatRoomId == null) {
      return const Left('لا يوجد محادثة مفتوحة');
    }

    return _blockHandler.unblockUser(
      chatRoomId: _currentChatRoomId!,
      blockedId: blockedId,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Future<void> close() {
    log('🔴 [$_listenerId] Closing ChatMessagesCubit...');

    _typingHandler.dispose();
    _messagesSubscription?.cancel();
    _connectivityHandler.dispose();

    _socketHandler?.dispose();

    _currentChatRoomId = null;
    _currentReceiverId = null;
    _messageStateHandler.clearPendingSystemMessages();

    log('✅ [$_listenerId] ChatMessagesCubit closed');

    return super.close();
  }
}
