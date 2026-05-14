import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/services/socket_events/chat_socket_events.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';

/// Service موحد لإدارة كل الـ socket events الخاصة بالـ chat
/// يستخدم Streams بدل الـ listeners المباشرة
class ChatSocketService {
  final tayseerSocketHelper _socket = getIt.get<tayseerSocketHelper>();
  static const _id = 'ChatSocketService';
  static const _reconnectId = '${_id}_reconnect';
  bool _isInitialized = false;

  // Streams للـ events — broadcast عشان يشتغلوا مع أكتر من subscriber
  final _newMessage = StreamController<NewMessageSocketEvent>.broadcast();
  final _messageDeleted =
      StreamController<MessageDeletedSocketEvent>.broadcast();
  final _typing = StreamController<TypingSocketEvent>.broadcast();
  final _messageState = StreamController<MessageStateSocketEvent>.broadcast();
  final _blockStatus = StreamController<BlockStatusSocketEvent>.broadcast();
  final _chatRoomJoined =
      StreamController<ChatRoomJoinedSocketEvent>.broadcast();
  final _messageReaction =
      StreamController<MessageReactionSocketEvent>.broadcast();
  final _chatNotificationNumbers =
      StreamController<ChatNotificationNumbersSocketEvent>.broadcast();
  final _failEvent = StreamController<String>.broadcast();
  final ValueNotifier<int> chatNotificationTotal = ValueNotifier<int>(0);

  // Public streams
  Stream<NewMessageSocketEvent> get onNewMessage => _newMessage.stream;
  Stream<MessageDeletedSocketEvent> get onMessageDeleted =>
      _messageDeleted.stream;
  Stream<TypingSocketEvent> get onTyping => _typing.stream;
  Stream<MessageStateSocketEvent> get onMessageState => _messageState.stream;
  Stream<BlockStatusSocketEvent> get onBlockStatus => _blockStatus.stream;
  Stream<ChatRoomJoinedSocketEvent> get onChatRoomJoined =>
      _chatRoomJoined.stream;
  Stream<MessageReactionSocketEvent> get onMessageReaction =>
      _messageReaction.stream;
  Stream<ChatNotificationNumbersSocketEvent> get onChatNotificationNumbers =>
      _chatNotificationNumbers.stream;
  Stream<String> get onFailEvent => _failEvent.stream;

  // ══════════════════════════════════════════════════════════════════════════
  // INIT
  // ══════════════════════════════════════════════════════════════════════════

  /// تهيئة الـ service — يُستدعى مرة واحدة بعد الـ socket connect
  void init() {
    if (_isInitialized) {
      // إعادة تهيئة — شيل الـ listeners القديمة وسجّل من جديد
      _socket.offAllForListener(_id);
      log('🔄 [ChatSocketService] re-initializing');
    }
    _isInitialized = true;

    // ✅ سجّل reconnect callback مرة واحدة
    // بيعيد تسجيل الـ socket listeners بعد كل reconnect
    _socket.addReconnectCallback(_reconnectId, () {
      if (!_isInitialized) return;
      log('🔄 [ChatSocketService] reconnected — re-registering listeners');
      _socket.offAllForListener(_id);
      _registerSocketListeners();
    });

    _registerSocketListeners();
    log('✅ [ChatSocketService] initialized');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SOCKET LISTENERS
  // ══════════════════════════════════════════════════════════════════════════

  void _registerSocketListeners() {
    // New message
    _socket.listenWithId('newMessage', _id, (data) {
      if (data is! Map || _newMessage.isClosed) return;
      try {
        _newMessage.add(
          NewMessageSocketEvent.fromJson(data as Map<String, dynamic>),
        );
      } catch (e) {
        log('❌ [ChatSocketService] newMessage parse error: $e');
      }
    });

    // Message deleted
    _socket.listenWithId('messageDeleted', _id, (data) {
      if (data is! Map || _messageDeleted.isClosed) return;
      try {
        _messageDeleted.add(
          MessageDeletedSocketEvent.fromJson(data as Map<String, dynamic>),
        );
      } catch (e) {
        log('❌ [ChatSocketService] messageDeleted parse error: $e');
      }
    });

    // Typing status
    _socket.listenWithId('typingStatus', _id, (data) {
      if (data is! Map || _typing.isClosed) return;
      try {
        _typing.add(TypingSocketEvent.fromJson(data as Map<String, dynamic>));
      } catch (e) {
        log('❌ [ChatSocketService] typingStatus parse error: $e');
      }
    });

    // Message state
    _socket.listenWithId('newMessageState', _id, (data) {
      if (data is! Map || _messageState.isClosed) return;
      try {
        _messageState.add(
          MessageStateSocketEvent.fromJson(data as Map<String, dynamic>),
        );
      } catch (e) {
        log('❌ [ChatSocketService] newMessageState parse error: $e');
      }
    });

    // Block status (blocker)
    _socket.listenWithId('blockerStatus', _id, (data) {
      if (data is! Map || _blockStatus.isClosed) return;
      try {
        _blockStatus.add(
          BlockStatusSocketEvent.fromJson(
            data as Map<String, dynamic>,
            BlockType.blocker,
          ),
        );
      } catch (e) {
        log('❌ [ChatSocketService] blockerStatus parse error: $e');
      }
    });

    // Block status (blocked)
    _socket.listenWithId('blockedStatus', _id, (data) {
      if (data is! Map || _blockStatus.isClosed) return;
      try {
        _blockStatus.add(
          BlockStatusSocketEvent.fromJson(
            data as Map<String, dynamic>,
            BlockType.blocked,
          ),
        );
      } catch (e) {
        log('❌ [ChatSocketService] blockedStatus parse error: $e');
      }
    });

    // Chat room joined
    _socket.listenWithId('chatRoomJoined', _id, (data) {
      if (data is! Map || _chatRoomJoined.isClosed) return;
      try {
        _chatRoomJoined.add(
          ChatRoomJoinedSocketEvent.fromJson(data as Map<String, dynamic>),
        );
      } catch (e) {
        log('❌ [ChatSocketService] chatRoomJoined parse error: $e');
      }
    });

    // Message reaction
    _socket.listenWithId('messageReaction', _id, (data) {
      if (data is! Map || _messageReaction.isClosed) return;
      try {
        _messageReaction.add(
          MessageReactionSocketEvent.fromJson(data as Map<String, dynamic>),
        );
      } catch (e) {
        log('❌ [ChatSocketService] messageReaction parse error: $e');
      }
    });

    // Chat notification numbers
    _socket.listenWithId('chatNotificationNumbers', _id, (data) {
      if (data is! Map || _chatNotificationNumbers.isClosed) return;
      try {
        final event = ChatNotificationNumbersSocketEvent.fromJson(
          data as Map<String, dynamic>,
        );
        _chatNotificationNumbers.add(event);
        chatNotificationTotal.value = event.total;
      } catch (e) {
        log('❌ [ChatSocketService] chatNotificationNumbers parse error: $e');
      }
    });

    // Fail event
    _socket.listenWithId('fail', _id, (data) {
      if (data is! Map || _failEvent.isClosed) return;
      try {
        final message = data['message'] as String? ?? 'حدث خطأ غير معروف';
        _failEvent.add(message);
        log('⚠️ [ChatSocketService] fail event: $message');
      } catch (e) {
        log('❌ [ChatSocketService] fail parse error: $e');
      }
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEND
  // ══════════════════════════════════════════════════════════════════════════

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

  void unreactToMessage({
    required String chatMessageId,
    Function(dynamic)? onAck,
  }) {
    _socket.send('unreactToMessage', {'chatMessageId': chatMessageId}, onAck);
    log('📤 [ChatSocketService] unreactToMessage: $chatMessageId');
  }

  void requestChatNotificationNumbers({Function(dynamic)? onAck}) {
    _socket.send('getChatNotificationNumbers', {}, onAck);
    log('📤 [ChatSocketService] getChatNotificationNumbers requested');
  }

  /// ✅ أبلّغ السيرفر إن المستخدم قرأ كل رسائل الـ chat room
  /// بيصفّر الـ notification count للـ room ده
  void markMessagesRead(String chatRoomId) {
    _socket.send('mark_messages_read', {'chatRoomId': chatRoomId}, (ack) {
      log('✅ [ChatSocketService] mark_messages_read ACK for $chatRoomId: $ack');
    });
    log('📤 [ChatSocketService] mark_messages_read: $chatRoomId');
  }

  void clearChatNotificationCount() {
    if (chatNotificationTotal.value != 0) {
      chatNotificationTotal.value = 0;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ══════════════════════════════════════════════════════════════════════════

  /// إزالة الـ socket listeners فقط (بدون إغلاق الـ streams)
  void removeListeners() {
    _socket.offAllForListener(_id);
    _socket.removeReconnectCallback(_reconnectId);
    _isInitialized = false;
    log('🔕 [ChatSocketService] listeners removed');
  }

  /// تنظيف الـ service الكامل
  void dispose() {
    _socket.offAllForListener(_id);
    _socket.removeReconnectCallback(_reconnectId);
    _isInitialized = false;
    _newMessage.close();
    _messageDeleted.close();
    _typing.close();
    _messageState.close();
    _blockStatus.close();
    _chatRoomJoined.close();
    _messageReaction.close();
    _chatNotificationNumbers.close();
    _failEvent.close();
    log('🗑️ [ChatSocketService] disposed');
  }
}

class ChatNotificationNumbersSocketEvent {
  final int total;
  final int system;
  final int userAdvisor;
  final int userUser;

  ChatNotificationNumbersSocketEvent({
    required this.total,
    required this.system,
    required this.userAdvisor,
    required this.userUser,
  });

  factory ChatNotificationNumbersSocketEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    final breakdown = json['breakdown'] as Map<String, dynamic>? ?? {};
    return ChatNotificationNumbersSocketEvent(
      total: json['total'] is int
          ? json['total'] as int
          : int.tryParse('${json['total']}') ?? 0,
      system: breakdown['system'] is int
          ? breakdown['system'] as int
          : int.tryParse('${breakdown['system']}') ?? 0,
      userAdvisor: breakdown['user-advisor'] is int
          ? breakdown['user-advisor'] as int
          : int.tryParse('${breakdown['user-advisor']}') ?? 0,
      userUser: breakdown['user-user'] is int
          ? breakdown['user-user'] as int
          : int.tryParse('${breakdown['user-user']}') ?? 0,
    );
  }
}
