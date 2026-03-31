import 'dart:async';

/// Event للإشعار بإلغاء أرشفة chat room
class ChatUnarchiveEvent {
  final String chatRoomId;

  ChatUnarchiveEvent(this.chatRoomId);
}

/// Event Bus للـ Chat events
class ChatEventBus {
  ChatEventBus._();
  static final ChatEventBus _instance = ChatEventBus._();
  static ChatEventBus get instance => _instance;

  final _unarchiveController = StreamController<ChatUnarchiveEvent>.broadcast();

  Stream<ChatUnarchiveEvent> get onChatUnarchived => _unarchiveController.stream;

  void notifyChatUnarchived(String chatRoomId) {
    _unarchiveController.add(ChatUnarchiveEvent(chatRoomId));
  }

  void dispose() {
    _unarchiveController.close();
  }
}
