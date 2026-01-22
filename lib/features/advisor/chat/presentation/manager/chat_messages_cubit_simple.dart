import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/enum/message_status_enum.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/send_media_message_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/typing_model.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/state/chat_messages_state.dart';
import 'package:uuid/uuid.dart';

/// Simplified Chat Messages Cubit - No Cache, No Complexity
///
/// All data comes from server, no local storage
class ChatMessagesCubit extends Cubit<ChatMessagesState> {
  final ChatRepoSimple _repo;
  final tayseerSocketHelper _socketHelper = getIt.get<tayseerSocketHelper>();

  String? _currentChatRoomId;
  String? _currentReceiverId;
  bool _isBlocked = false;
  bool _isUserTyping = false;
  TypingModel? _typingInfo;

  // Upload progress tracking
  final Map<String, double> _uploadProgress = {};

  ChatMessagesCubit({required ChatRepoSimple repo})
    : _repo = repo,
      super(const ChatMessagesState.initial());

  // ══════════════════════════════════════════════════════════════════════════
  // LOAD MESSAGES
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> loadInitialMessages(
    String chatRoomId, {
    String? receiverId,
  }) async {
    _currentChatRoomId = chatRoomId;
    _currentReceiverId = receiverId;

    emit(const ChatMessagesState.loading());

    try {
      final messages = await _repo.loadMessages(chatRoomId);

      // Check block status from messages
      _isBlocked = _checkBlockStatusFromMessages(messages);

      emit(
        ChatMessagesState.loaded(
          messages: messages,
          hasMoreMessages: false, // No pagination for now
          isBlocked: _isBlocked,
        ),
      );

      setupSocketListeners();
    } catch (e) {
      log('❌ Error loading messages: $e');
      emit(ChatMessagesState.failure(message: e.toString()));
    }
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
  // SEND MESSAGE
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

    // Create optimistic message
    final optimisticMessage = ChatMessage(
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
      status: MessageStatusEnum.pending,
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

    // Add to UI immediately
    final currentMessages = state.messagesOrEmpty;
    emit(
      ChatMessagesState.loaded(
        messages: [...currentMessages, optimisticMessage],
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );

    // Send via socket
    final socketData = <String, dynamic>{
      'receiverId': receiverId,
      'content': message,
      'tempId': tempId,
    };

    if (replyMessageId != null && !replyMessageId.startsWith('temp_')) {
      socketData['replyMessageId'] = replyMessageId;
    }

    _socketHelper.send('send_message', socketData, (ack) {
      log('✅ Send message ACK: $ack');
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
    String? replyMessageId,
    ChatMessage? replyToMessage,
  }) async {
    const uuid = Uuid();
    final tempId = uuid.v4();
    final localId = 'temp_$tempId';
    final now = DateTime.now().toIso8601String();

    // Create optimistic message with local file paths
    final localPaths = <String>[];
    if (images != null) {
      localPaths.addAll(images.map((f) => f.path));
    }
    if (videos != null) {
      localPaths.addAll(videos.map((f) => f.path));
    }

    final optimisticMessage = ChatMessage(
      id: localId,
      chatRoomId: chatRoomId,
      senderId: _currentReceiverId ?? '',
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

    // Add to UI immediately
    final currentMessages = state.messagesOrEmpty;
    emit(
      ChatMessagesState.loaded(
        messages: [...currentMessages, optimisticMessage],
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );

    // Initialize progress
    _uploadProgress[localId] = 0.0;

    // Upload to server
    final result = await _repo.sendMediaMessage(
      chatRoomId: chatRoomId,
      messageType: messageType,
      images: images,
      videos: videos,
      replyMessageId: replyMessageId,
      tempId: tempId,
      onProgress: (sent, total) {
        final progress = sent / total;
        _uploadProgress[localId] = progress;
        // Emit progress update
        _emitProgressUpdate(localId, progress);
      },
    );

    result.fold(
      (error) {
        log('❌ Media upload failed: $error');
        // Update message status to failed
        _updateMessageStatus(localId, MessageStatusEnum.failed);
        _uploadProgress.remove(localId);
      },
      (response) {
        log('✅ Media uploaded: ${response.data.id}');
        // Replace optimistic message with server message
        _replaceOptimisticMessage(localId, response.data);
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

  double? getUploadProgress(String messageId) {
    return _uploadProgress[messageId];
  }

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

  void _replaceOptimisticMessage(String localId, SentMessage serverMessage) {
    final currentMessages = state.messagesOrEmpty;
    final index = currentMessages.indexWhere((m) => m.id == localId);
    if (index == -1) return;

    final updatedMessage = ChatMessage(
      id: serverMessage.id,
      chatRoomId: serverMessage.chatRoomId,
      senderId: serverMessage.senderId,
      senderName: serverMessage.senderName,
      senderImage: serverMessage.senderImage ?? '',
      senderType: serverMessage.senderType,
      isMe: serverMessage.isMe,
      contentList: serverMessage.contentList,
      messageType: serverMessage.messageType,
      createdAt: serverMessage.createdAt,
      updatedAt: serverMessage.updatedAt,
      isRead: serverMessage.isRead,
      status: MessageStatusEnum.sent,
      reply: serverMessage.reply,
    );

    final updatedMessages = List<ChatMessage>.from(currentMessages);
    updatedMessages[index] = updatedMessage;

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
    _socketHelper.listen('new_message', (data) {
      final message = ChatMessage.fromJson(data as Map<String, dynamic>);
      _handleNewMessage(message);
    });

    _socketHelper.listen('message_deleted', (data) {
      final messageId = data['messageId'] as String;
      _handleMessageDeleted(messageId);
    });

    _socketHelper.listen('user_typing', (data) {
      final userId = data['userId'] as String;
      final userName = data['userName'] as String;
      _handleUserTyping(userId, userName);
    });

    _socketHelper.listen('messages_read', (data) {
      _handleMessagesRead();
    });
  }

  void _handleNewMessage(ChatMessage message) {
    if (message.chatRoomId != _currentChatRoomId) return;

    final currentMessages = state.messagesOrEmpty;

    // Check if this is a confirmation of our optimistic message
    if (message.isMe) {
      // Find and replace temp message
      final tempIndex = currentMessages.indexWhere(
        (m) => m.id.startsWith('temp_') && m.content == message.content,
      );
      if (tempIndex != -1) {
        final updatedMessages = List<ChatMessage>.from(currentMessages);
        updatedMessages[tempIndex] = message.copyWith(
          status: MessageStatusEnum.sent,
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
        return;
      }
    }

    // Handle system messages (block/unblock)
    if (message.messageType == 'system') {
      if (message.action.isBlock) {
        _isBlocked = true;
      } else if (message.action.isUnblock) {
        _isBlocked = false;
      }
    }

    // Add new message
    emit(
      ChatMessagesState.loaded(
        messages: [...currentMessages, message],
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: _isUserTyping,
        typingInfo: _typingInfo,
      ),
    );
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
  }

  void _handleUserTyping(String userId, String userName) {
    _isUserTyping = true;
    _typingInfo = TypingModel(
      userId: userId,
      userName: userName,
      chatRoomId: _currentChatRoomId ?? '',
    );

    emit(
      ChatMessagesState.loaded(
        messages: state.messagesOrEmpty,
        hasMoreMessages: false,
        isBlocked: _isBlocked,
        isUserTyping: true,
        typingInfo: _typingInfo,
      ),
    );

    // Clear typing after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
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
    });
  }

  void _handleMessagesRead() {
    final currentMessages = state.messagesOrEmpty;
    final updatedMessages = currentMessages.map((m) {
      if (m.isMe && !m.isRead) {
        return m.copyWith(isRead: true, status: MessageStatusEnum.read);
      }
      return m;
    }).toList();

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
  // TYPING
  // ══════════════════════════════════════════════════════════════════════════

  void typingStart(String chatRoomId) {
    _socketHelper.send('typing_start', {'chatRoomId': chatRoomId}, null);
  }

  void typingStop(String chatRoomId) {
    _socketHelper.send('typing_stop', {'chatRoomId': chatRoomId}, null);
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

    final result = await _repo.deleteMessage(
      messageId: messageId,
      chatRoomId: _currentChatRoomId!,
      deleteType: deleteType,
    );

    return result.fold(
      (error) {
        log('❌ Delete failed: $error');
        return false;
      },
      (_) {
        _handleMessageDeleted(messageId);
        return true;
      },
    );
  }

  Future<bool> deleteMessages({
    required List<String> messageIds,
    required String deleteType,
  }) async {
    if (_currentChatRoomId == null) return false;

    final result = await _repo.deleteMessages(
      messageIds: messageIds,
      chatRoomId: _currentChatRoomId!,
      deleteType: deleteType,
    );

    return result.fold(
      (error) {
        log('❌ Delete failed: $error');
        return false;
      },
      (_) {
        for (final id in messageIds) {
          _handleMessageDeleted(id);
        }
        return true;
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BLOCK/UNBLOCK
  // ══════════════════════════════════════════════════════════════════════════

  Future<Either<String, String>> blockUser({required String blockedId}) async {
    final result = await _repo.blockUser(blockedId: blockedId);
    result.fold((error) => null, (_) {
      _isBlocked = true;
      emit(
        ChatMessagesState.loaded(
          messages: state.messagesOrEmpty,
          hasMoreMessages: false,
          isBlocked: true,
          isUserTyping: _isUserTyping,
          typingInfo: _typingInfo,
        ),
      );
    });
    return result;
  }

  Future<Either<String, String>> unblockUser({
    required String blockedId,
  }) async {
    final result = await _repo.unblockUser(blockedId: blockedId);
    result.fold((error) => null, (_) {
      _isBlocked = false;
      emit(
        ChatMessagesState.loaded(
          messages: state.messagesOrEmpty,
          hasMoreMessages: false,
          isBlocked: false,
          isUserTyping: _isUserTyping,
          typingInfo: _typingInfo,
        ),
      );
    });
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
    _socketHelper.off('new_message');
    _socketHelper.off('message_deleted');
    _socketHelper.off('user_typing');
    _socketHelper.off('messages_read');
    return super.close();
  }

  Future<void> loadOlderMessages() async {
    // Not implemented for now - no pagination
  }
}
