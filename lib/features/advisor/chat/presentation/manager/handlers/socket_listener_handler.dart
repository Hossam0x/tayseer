import 'dart:developer';

import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';

/// Handler for Socket.IO events in the Chat Room
class SocketListenerHandler {
  final tayseerSocketHelper _socketHelper;
  final String _listenerId;
  final String _chatRoomId;

  // Callbacks
  final void Function(ChatMessage message) onNewMessage;
  final void Function() onMessagesRead;
  final void Function(String messageId) onMessageDeleted;
  final void Function(String userId, String userName) onUserTyping;

  SocketListenerHandler({
    required tayseerSocketHelper socketHelper,
    required String listenerId,
    required String chatRoomId,
    required this.onNewMessage,
    required this.onMessagesRead,
    required this.onMessageDeleted,
    required this.onUserTyping,
  }) : _socketHelper = socketHelper,
       _listenerId = listenerId,
       _chatRoomId = chatRoomId;

  void setupListeners() {
    _listenToNewMessages();
    _listenToMessagesRead();
    _listenToMessageDeleted();
    _listenToUserTyping();
  }

  void _listenToNewMessages() {
    log('🎧 [$_listenerId] Setting up new_message listener');
    _socketHelper.listenWithId('new_message', _listenerId, (data) {
      _handleNewMessage(data);
    });
  }

  void _handleNewMessage(dynamic data) {
    try {
      final messageData = data is Map && data.containsKey('message')
          ? data['message']
          : data;
      final newMessage = ChatMessage.fromJson(messageData);

      if (newMessage.chatRoomId != _chatRoomId) {
        log('📭 [$_listenerId] Message for different room, ignoring');
        return;
      }

      onNewMessage(newMessage);
    } catch (e, stackTrace) {
      log('❌ [$_listenerId] Error processing message: $e');
      log('StackTrace: $stackTrace');
    }
  }

  void _listenToMessagesRead() {
    _socketHelper.listenWithId('messages_read', _listenerId, (data) {
      if (data != null && data['chatRoomId']?.toString() == _chatRoomId) {
        log('🎧 [$_listenerId] Messages read event received');
        onMessagesRead();
      }
    });
  }

  void _listenToMessageDeleted() {
    _socketHelper.listenWithId('message_deleted', _listenerId, (data) {
      if (data != null &&
          data['messageId'] != null &&
          data['chatRoomId']?.toString() == _chatRoomId) {
        final messageId = data['messageId'].toString();
        log('🗑️ [$_listenerId] Message deleted event: $messageId');
        onMessageDeleted(messageId);
      }
    });
  }

  void _listenToUserTyping() {
    _socketHelper.listenWithId('user_typing', _listenerId, (data) {
      if (data != null) {
        final roomId = data['chatRoomId']?.toString();
        if (roomId == _chatRoomId) {
          final userId = data['userId']?.toString();
          final userName = data['userName']?.toString();
          if (userId != null) {
            onUserTyping(userId, userName ?? '');
          }
        }
      }
    });
  }

  void dispose() {
    _socketHelper.offAllForListener(_listenerId);
  }
}
