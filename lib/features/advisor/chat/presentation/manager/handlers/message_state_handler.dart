import 'dart:developer';

import 'package:tayseer/core/enum/message_status_enum.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';

import 'package:tayseer/features/advisor/chat/domain/chat_domain.dart';

class MessageStateHandler {
  final IChatRepository _repo;
  final String _listenerId;
  final DeleteMessagesUseCase _deleteMessagesUseCase;

  // State Accessors
  final List<ChatMessage> Function() getCurrentMessages;
  final int Function() getCurrentPendingCount;

  // State Updaters
  final void Function(List<ChatMessage> messages) onMessagesUpdated;
  final void Function(int pendingCount) onPendingCountUpdated;

  final Set<String> _pendingSystemMessageContents = {};

  MessageStateHandler({
    required IChatRepository repo,
    required String listenerId,
    required DeleteMessagesUseCase deleteMessagesUseCase,
    required this.getCurrentMessages,
    required this.getCurrentPendingCount,
    required this.onMessagesUpdated,
    required this.onPendingCountUpdated,
  }) : _repo = repo,
       _listenerId = listenerId,
       _deleteMessagesUseCase = deleteMessagesUseCase;

  Future<void> handleIncomingMessage(ChatMessage message) async {
    await _repo.saveMessageLocally(message);
    _addMessageToState(message);
    log('📩 [$_listenerId] Incoming message added: ${message.id}');
  }

  Future<void> handleSentMessageConfirmation(ChatMessage serverMessage) async {
    final currentMessages = getCurrentMessages();

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

      await _repo.confirmMessageSent(localId, serverMessage.id);
      await _repo.removeFromPendingQueue(localId);

      final updatedMessages = List<ChatMessage>.from(currentMessages);
      updatedMessages[localIndex] = serverMessage;

      final currentPendingCount = getCurrentPendingCount();
      onMessagesUpdated(updatedMessages);
      onPendingCountUpdated(
        currentPendingCount > 0 ? currentPendingCount - 1 : 0,
      );

      log(
        '✅ [$_listenerId] Message confirmed: $localId -> ${serverMessage.id}',
      );
    } else {
      await _repo.saveMessageLocally(serverMessage);
      _addMessageToState(serverMessage);
    }
  }

  Future<void> handleSystemMessage(ChatMessage serverMessage) async {
    final serverContent = serverMessage.content.trim();
    log('📩 [$_listenerId] Received system message: $serverContent');

    final hasPendingMatch = _pendingSystemMessageContents.any(
      (pending) => pending.trim() == serverContent,
    );

    if (hasPendingMatch) {
      final currentMessages = getCurrentMessages();
      final localIndex = currentMessages.lastIndexWhere(
        (msg) =>
            msg.id.startsWith('temp_') &&
            msg.messageType == 'system' &&
            msg.content.trim() == serverContent,
      );

      if (localIndex != -1) {
        final localMessage = currentMessages[localIndex];
        final localId = localMessage.id;

        await _repo.confirmMessageSent(localId, serverMessage.id);

        final updatedMessages = List<ChatMessage>.from(currentMessages);
        updatedMessages[localIndex] = serverMessage;

        onMessagesUpdated(updatedMessages);

        log(
          '✅ [$_listenerId] System message confirmed: $localId -> ${serverMessage.id}',
        );

        _pendingSystemMessageContents.removeWhere(
          (pending) => pending.trim() == serverContent,
        );
        return;
      }
    }

    final currentMessages = getCurrentMessages();
    final tempIndex = currentMessages.lastIndexWhere(
      (msg) =>
          msg.id.startsWith('temp_') &&
          msg.messageType == 'system' &&
          msg.content.trim() == serverContent,
    );

    if (tempIndex != -1) {
      final localMessage = currentMessages[tempIndex];
      final localId = localMessage.id;

      await _repo.confirmMessageSent(localId, serverMessage.id);

      final updatedMessages = List<ChatMessage>.from(currentMessages);
      updatedMessages[tempIndex] = serverMessage;

      onMessagesUpdated(updatedMessages);

      log(
        '✅ [$_listenerId] System message confirmed (fallback): $localId -> ${serverMessage.id}',
      );
      return;
    }

    final exists = currentMessages.any((m) => m.id == serverMessage.id);
    if (exists) {
      log('📭 [$_listenerId] System message already exists, ignoring');
      return;
    }

    await _repo.saveMessageLocally(serverMessage);
    _addMessageToState(serverMessage);
    log('📩 [$_listenerId] New system message added: ${serverMessage.id}');
  }

  void handleMessagesRead() {
    log('👁️ [$_listenerId] Messages read handler');

    final currentMessages = getCurrentMessages();
    final updatedMessages = currentMessages.map((message) {
      if (message.isMe && message.status != MessageStatusEnum.read) {
        _repo.updateMessageStatus(message.id, 'read');
        return message.copyWith(isRead: true, status: MessageStatusEnum.read);
      }
      return message;
    }).toList();

    onMessagesUpdated(updatedMessages);
  }

  void handleMessageDeleted(String messageId) {
    log('🗑️ [$_listenerId] Message deleted handler: $messageId');

    _deleteMessagesUseCase.deleteLocally(messageId);

    final currentMessages = getCurrentMessages();
    final updatedMessages = currentMessages
        .where((message) => message.id != messageId)
        .toList();

    onMessagesUpdated(updatedMessages);
    log('🗑️ [$_listenerId] Message removed from state: $messageId');
  }

  void _addMessageToState(ChatMessage message) {
    final currentMessages = getCurrentMessages();
    final exists = currentMessages.any((m) => m.id == message.id);
    if (exists) return;

    final updatedMessages = [...currentMessages, message];
    onMessagesUpdated(updatedMessages);
  }

  void addPendingSystemMessageContent(String content) {
    _pendingSystemMessageContents.add(content);
  }

  void removePendingSystemMessageContent(String content) {
    _pendingSystemMessageContents.remove(content);
  }

  void clearPendingSystemMessages() {
    _pendingSystemMessageContents.clear();
  }
}
