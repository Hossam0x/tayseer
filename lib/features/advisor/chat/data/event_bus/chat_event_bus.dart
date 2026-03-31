import 'dart:async';

/// Event للإشعار بإلغاء أرشفة chat room
class ChatUnarchiveEvent {
  final String chatRoomId;

  ChatUnarchiveEvent(this.chatRoomId);
}

/// Event للإشعار بأرشفة chat room
class ChatArchiveEvent {
  final String chatRoomId;

  ChatArchiveEvent(this.chatRoomId);
}

/// Event للإشعار بحذف chat room
class ChatDeleteEvent {
  final String chatRoomId;

  ChatDeleteEvent(this.chatRoomId);
}

/// Event Bus للـ Chat events
class ChatEventBus {
  ChatEventBus._();
  static final ChatEventBus _instance = ChatEventBus._();
  static ChatEventBus get instance => _instance;

  final _unarchiveController = StreamController<ChatUnarchiveEvent>.broadcast();
  final _archiveController = StreamController<ChatArchiveEvent>.broadcast();
  final _deleteController = StreamController<ChatDeleteEvent>.broadcast();

  Stream<ChatUnarchiveEvent> get onChatUnarchived => _unarchiveController.stream;
  Stream<ChatArchiveEvent> get onChatArchived => _archiveController.stream;
  Stream<ChatDeleteEvent> get onChatDeleted => _deleteController.stream;

  void notifyChatUnarchived(String chatRoomId) {
    _unarchiveController.add(ChatUnarchiveEvent(chatRoomId));
  }

  void notifyChatArchived(String chatRoomId) {
    _archiveController.add(ChatArchiveEvent(chatRoomId));
  }

  void notifyChatDeleted(String chatRoomId) {
    _deleteController.add(ChatDeleteEvent(chatRoomId));
  }

  void dispose() {
    _unarchiveController.close();
    _archiveController.close();
    _deleteController.close();
  }
}
