import 'dart:async';
import 'dart:developer';

import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/services/socket_events/chat_socket_events.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';

/// Service موحد لإدارة كل الـ socket events الخاصة بالـ chat
/// يستخدم Streams بدل الـ listeners المباشرة
class ChatSocketService {
  final tayseerSocketHelper _socket = getIt.get<tayseerSocketHelper>();
  static const _id = 'ChatSocketService';

  // Streams للـ events
  final _newMessage = StreamController<NewMessageSocketEvent>.broadcast();
  final _messageDeleted = StreamController<MessageDeletedSocketEvent>.broadcast();
  final _typing = StreamController<TypingSocketEvent>.broadcast();
  final _messageState = StreamController<MessageStateSocketEvent>.broadcast();
  final _blockStatus = StreamController<BlockStatusSocketEvent>.broadcast();
  final _chatRoomJoined = StreamController<ChatRoomJoinedSocketEvent>.broadcast();
  final _messageReaction = StreamController<MessageReactionSocketEvent>.broadcast();
  final _failEvent = StreamController<String>.broadcast();

  // Public streams
  Stream<NewMessageSocketEvent> get onNewMessage => _newMessage.stream;
  Stream<MessageDeletedSocketEvent> get onMessageDeleted => _messageDeleted.stream;
  Stream<TypingSocketEvent> get onTyping => _typing.stream;
  Stream<MessageStateSocketEvent> get onMessageState => _messageState.stream;
  Stream<BlockStatusSocketEvent> get onBlockStatus => _blockStatus.stream;
  Stream<ChatRoomJoinedSocketEvent> get onChatRoomJoined => _chatRoomJoined.stream;
  Stream<MessageReactionSocketEvent> get onMessageReaction => _messageReaction.stream;
  Stream<String> get onFailEvent => _failEvent.stream;

  /// تهيئة الـ service وتسجيل الـ listeners
  void init() {
    // New message
    _socket.listenWithId('newMessage', _id, (data) {
      if (data is! Map) return;
      try {
        _newMessage.add(NewMessageSocketEvent.fromJson(data as Map<String, dynamic>));
      } catch (e) {
        log('❌ [ChatSocketService] newMessage parse error: $e');
      }
    });

    // Message deleted
    _socket.listenWithId('messageDeleted', _id, (data) {
      if (data is! Map) return;
      try {
        _messageDeleted.add(MessageDeletedSocketEvent.fromJson(data as Map<String, dynamic>));
      } catch (e) {
        log('❌ [ChatSocketService] messageDeleted parse error: $e');
      }
    });

    // Typing status
    _socket.listenWithId('typingStatus', _id, (data) {
      if (data is! Map) return;
      try {
        _typing.add(TypingSocketEvent.fromJson(data as Map<String, dynamic>));
      } catch (e) {
        log('❌ [ChatSocketService] typingStatus parse error: $e');
      }
    });

    // Message state
    _socket.listenWithId('newMessageState', _id, (data) {
      if (data is! Map) return;
      try {
        _messageState.add(MessageStateSocketEvent.fromJson(data as Map<String, dynamic>));
      } catch (e) {
        log('❌ [ChatSocketService] newMessageState parse error: $e');
      }
    });

    // Block status (blocker)
    _socket.listenWithId('blockerStatus', _id, (data) {
      if (data is! Map) return;
      try {
        _blockStatus.add(BlockStatusSocketEvent.fromJson(data as Map<String, dynamic>));
      } catch (e) {
        log('❌ [ChatSocketService] blockerStatus parse error: $e');
      }
    });

    // Block status (blocked)
    _socket.listenWithId('blockedStatus', _id, (data) {
      if (data is! Map) return;
      try {
        _blockStatus.add(BlockStatusSocketEvent.fromJson(data as Map<String, dynamic>));
      } catch (e) {
        log('❌ [ChatSocketService] blockedStatus parse error: $e');
      }
    });

    // Chat room joined
    _socket.listenWithId('chatRoomJoined', _id, (data) {
      if (data is! Map) return;
      try {
        _chatRoomJoined.add(ChatRoomJoinedSocketEvent.fromJson(data as Map<String, dynamic>));
      } catch (e) {
        log('❌ [ChatSocketService] chatRoomJoined parse error: $e');
      }
    });

    // Message reaction
    _socket.listenWithId('messageReaction', _id, (data) {
      if (data is! Map) return;
      try {
        _messageReaction.add(MessageReactionSocketEvent.fromJson(data as Map<String, dynamic>));
      } catch (e) {
        log('❌ [ChatSocketService] messageReaction parse error: $e');
      }
    });

    // Fail event
    _socket.listenWithId('fail', _id, (data) {
      if (data is! Map) return;
      try {
        final message = data['message'] as String? ?? 'حدث خطأ غير معروف';
        _failEvent.add(message);
        log('⚠️ [ChatSocketService] fail event: $message');
      } catch (e) {
        log('❌ [ChatSocketService] fail parse error: $e');
      }
    });

    log('✅ [ChatSocketService] initialized');
  }

  /// إرسال reaction على رسالة
  void reactToMessage({
    required String chatMessageId,
    required String emoji,
    Function(dynamic)? onAck,
  }) {
    _socket.send('reactToMessage', {
      'chatMessageId': chatMessageId,
      'emoji': emoji,
    }, onAck);
    log('📤 [ChatSocketService] reactToMessage: $emoji on $chatMessageId');
  }

  /// إزالة reaction من رسالة
  void unreactToMessage({
    required String chatMessageId,
    Function(dynamic)? onAck,
  }) {
    _socket.send('unreactToMessage', {
      'chatMessageId': chatMessageId,
    }, onAck);
    log('📤 [ChatSocketService] unreactToMessage: $chatMessageId');
  }

  /// تنظيف الـ service
  void dispose() {
    _socket.offAllForListener(_id);
    _newMessage.close();
    _messageDeleted.close();
    _typing.close();
    _messageState.close();
    _blockStatus.close();
    _chatRoomJoined.close();
    _messageReaction.close();
    _failEvent.close();
    log('🗑️ [ChatSocketService] disposed');
  }
}
