import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';

/// Base class لكل الـ socket events الخاصة بالـ chat
abstract class ChatSocketEvent {
  const ChatSocketEvent();
}

/// Event لرسالة جديدة
class NewMessageSocketEvent extends ChatSocketEvent {
  final ChatMessage message;
  const NewMessageSocketEvent(this.message);

  factory NewMessageSocketEvent.fromJson(Map<String, dynamic> json) {
    return NewMessageSocketEvent(
      ChatMessage.fromJson(json['message'] as Map<String, dynamic>),
    );
  }
}

/// Event لحذف رسائل
class MessageDeletedSocketEvent extends ChatSocketEvent {
  final List<String> messageIds;
  const MessageDeletedSocketEvent(this.messageIds);

  factory MessageDeletedSocketEvent.fromJson(Map<String, dynamic> json) {
    return MessageDeletedSocketEvent(
      (json['chatMessageIds'] as List).map((e) => e.toString()).toList(),
    );
  }
}

/// Event لحالة الكتابة (typing)
class TypingSocketEvent extends ChatSocketEvent {
  final String chatRoomId;
  final bool isTyping;
  const TypingSocketEvent({
    required this.chatRoomId,
    required this.isTyping,
  });

  factory TypingSocketEvent.fromJson(Map<String, dynamic> json) {
    return TypingSocketEvent(
      chatRoomId: json['chatRoomId']?.toString() ?? '',
      isTyping: json['isTyping'] as bool? ?? false,
    );
  }
}

/// Event لتحديث حالة الرسالة (sent, delivered, read)
class MessageStateSocketEvent extends ChatSocketEvent {
  final String status;
  final List<String> messageIds;
  const MessageStateSocketEvent({
    required this.status,
    required this.messageIds,
  });

  factory MessageStateSocketEvent.fromJson(Map<String, dynamic> json) {
    return MessageStateSocketEvent(
      status: json['status']?.toString() ?? '',
      messageIds: (json['messageIds'] as List).map((e) => e.toString()).toList(),
    );
  }
}

/// Event لتغيير حالة الحظر
class BlockStatusSocketEvent extends ChatSocketEvent {
  final bool isBlocked;
  final BlockType blockType; // blocker أو blocked
  
  const BlockStatusSocketEvent({
    required this.isBlocked,
    required this.blockType,
  });

  factory BlockStatusSocketEvent.fromJson(
    Map<String, dynamic> json,
    BlockType type,
  ) {
    return BlockStatusSocketEvent(
      isBlocked: json['newBlockStatus'] as bool? ?? false,
      blockType: type,
    );
  }
}

/// نوع الحظر
enum BlockType {
  blocker, // أنا اللي حاظر (يظهر لي حذف المحادثة أو إلغاء الحظر)
  blocked, // أنا محظور (مقدرش أبعت رسائل)
}

/// Event للانضمام لـ chat room
class ChatRoomJoinedSocketEvent extends ChatSocketEvent {
  final String chatRoomId;
  final bool blockExists;
  final int? freeChatMinsLeft;
  const ChatRoomJoinedSocketEvent({
    required this.chatRoomId,
    required this.blockExists,
    this.freeChatMinsLeft,
  });

  factory ChatRoomJoinedSocketEvent.fromJson(Map<String, dynamic> json) {
    return ChatRoomJoinedSocketEvent(
      chatRoomId: json['chatRoomId']?.toString() ?? '',
      blockExists: json['blockExists'] as bool? ?? false,
      freeChatMinsLeft: json['freeChatMinsLeft'] as int?,
    );
  }
}

/// Reaction على رسالة
class MessageReaction {
  final String userId;
  final String emoji;

  const MessageReaction({
    required this.userId,
    required this.emoji,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      userId: json['userId']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'emoji': emoji,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageReaction &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          emoji == other.emoji;

  @override
  int get hashCode => userId.hashCode ^ emoji.hashCode;
}

/// Event لتحديث reactions على رسالة
class MessageReactionSocketEvent extends ChatSocketEvent {
  final String chatMessageId;
  final List<MessageReaction> reactions;

  const MessageReactionSocketEvent({
    required this.chatMessageId,
    required this.reactions,
  });

  factory MessageReactionSocketEvent.fromJson(Map<String, dynamic> json) {
    final reactionsList = json['reactions'] as List? ?? [];
    return MessageReactionSocketEvent(
      chatMessageId: json['chatMessageId']?.toString() ?? '',
      reactions: reactionsList
          .map((r) => MessageReaction.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}
