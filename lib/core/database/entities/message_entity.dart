import 'package:tayseer/core/enum/message_status_enum.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';

/// Entity class for SQLite message storage
/// Maps between ChatMessage model and SQLite database
class MessageEntity {
  final String id;
  final String? localId;
  final String chatRoomId;
  final String senderId;
  final String? senderName;
  final String? senderImage;
  final String? senderType;
  final bool isMe;
  final String content;
  final String messageType;
  final String createdAt;
  final String? updatedAt;
  final bool isRead;
  final String status;
  final String? replyMessageId;
  final String? replyMessage;
  final bool isReply;
  final bool isPending;
  final int sortTimestamp; // For proper sorting

  MessageEntity({
    required this.id,
    this.localId,
    required this.chatRoomId,
    required this.senderId,
    this.senderName,
    this.senderImage,
    this.senderType,
    required this.isMe,
    required this.content,
    required this.messageType,
    required this.createdAt,
    this.updatedAt,
    required this.isRead,
    required this.status,
    this.replyMessageId,
    this.replyMessage,
    required this.isReply,
    this.isPending = false,
    required this.sortTimestamp,
  });

  /// Convert from SQLite row to Entity
  factory MessageEntity.fromMap(Map<String, dynamic> map) {
    return MessageEntity(
      id: map['id'] as String,
      localId: map['local_id'] as String?,
      chatRoomId: map['chat_room_id'] as String,
      senderId: map['sender_id'] as String,
      senderName: map['sender_name'] as String?,
      senderImage: map['sender_image'] as String?,
      senderType: map['sender_type'] as String?,
      isMe: (map['is_me'] as int) == 1,
      content: map['content'] as String? ?? '',
      messageType: map['message_type'] as String? ?? 'text',
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String?,
      isRead: (map['is_read'] as int) == 1,
      status: map['status'] as String? ?? 'sent',
      replyMessageId: map['reply_message_id'] as String?,
      replyMessage: map['reply_message'] as String?,
      isReply: (map['is_reply'] as int) == 1,
      isPending: (map['is_pending'] as int) == 1,
      sortTimestamp: (map['sort_timestamp'] as int?) ?? 0,
    );
  }

  /// Convert Entity to SQLite map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'local_id': localId,
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_image': senderImage,
      'sender_type': senderType,
      'is_me': isMe ? 1 : 0,
      'content': content,
      'message_type': messageType,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_read': isRead ? 1 : 0,
      'status': status,
      'reply_message_id': replyMessageId,
      'reply_message': replyMessage,
      'is_reply': isReply ? 1 : 0,
      'is_pending': isPending ? 1 : 0,
      'sort_timestamp': sortTimestamp,
    };
  }

  /// Convert from ChatMessage model to Entity
  factory MessageEntity.fromChatMessage(
    ChatMessage message, {
    bool isPending = false,
    String? localId,
  }) {
    // Parse sortTimestamp from deliveredAt (ISO) > createdAt > current time
    int sortTimestamp;

    // First try deliveredAt (most reliable - ISO format from server)
    if (message.deliveredAt != null && message.deliveredAt!.isNotEmpty) {
      try {
        sortTimestamp = DateTime.parse(
          message.deliveredAt!,
        ).millisecondsSinceEpoch;
      } catch (_) {
        sortTimestamp = 0; // Will try createdAt next
      }
    } else {
      sortTimestamp = 0;
    }

    // If deliveredAt failed, try createdAt
    if (sortTimestamp == 0) {
      try {
        sortTimestamp = DateTime.parse(
          message.createdAt,
        ).millisecondsSinceEpoch;
      } catch (_) {
        // If createdAt is not valid (e.g., "الآن"), use current time
        sortTimestamp = DateTime.now().millisecondsSinceEpoch;
      }
    }

    return MessageEntity(
      id: message.id,
      localId: localId,
      chatRoomId: message.chatRoomId,
      senderId: message.senderId,
      senderName: message.senderName,
      senderImage: message.senderImage,
      senderType: message.senderType,
      isMe: message.isMe,
      content: message.contentList.join('|||'), // Store as delimited string
      messageType: message.messageType,
      createdAt: message.createdAt,
      updatedAt: message.updatedAt,
      isRead: message.isRead,
      status: message.status.toApiString(),
      replyMessageId: message.reply?.replyMessageId,
      replyMessage: message.reply?.replyMessage,
      isReply: message.reply?.isReply ?? false,
      isPending: isPending,
      sortTimestamp: sortTimestamp,
    );
  }

  /// Convert Entity to ChatMessage model
  ChatMessage toChatMessage() {
    return ChatMessage(
      id: id,
      chatRoomId: chatRoomId,
      senderId: senderId,
      senderName: senderName ?? '',
      senderImage: senderImage ?? '',
      senderType: senderType ?? '',
      isMe: isMe,
      contentList: content.isNotEmpty ? content.split('|||') : [],
      messageType: messageType,
      createdAt: createdAt,
      updatedAt: updatedAt ?? createdAt,
      isRead: isRead,
      status: MessageStatusExtension.fromString(status),
      reply: isReply
          ? ReplyInfo(
              replyMessageId: replyMessageId,
              replyMessage: replyMessage,
              isReply: true,
            )
          : null,
    );
  }

  /// Create a copy with updated fields
  MessageEntity copyWith({
    String? id,
    String? localId,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? senderImage,
    String? senderType,
    bool? isMe,
    String? content,
    String? messageType,
    String? createdAt,
    String? updatedAt,
    bool? isRead,
    String? status,
    String? replyMessageId,
    String? replyMessage,
    bool? isReply,
    bool? isPending,
    int? sortTimestamp,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      senderType: senderType ?? this.senderType,
      isMe: isMe ?? this.isMe,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
      status: status ?? this.status,
      replyMessageId: replyMessageId ?? this.replyMessageId,
      replyMessage: replyMessage ?? this.replyMessage,
      isReply: isReply ?? this.isReply,
      isPending: isPending ?? this.isPending,
      sortTimestamp: sortTimestamp ?? this.sortTimestamp,
    );
  }
}
