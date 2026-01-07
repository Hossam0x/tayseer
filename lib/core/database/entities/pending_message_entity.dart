/// Entity class for pending messages in offline queue
class PendingMessageEntity {
  final int? id;
  final String localId;
  final String chatRoomId;
  final String receiverId;
  final String content;
  final String messageType;
  final String? replyMessageId;
  final String createdAt;
  final int retryCount;
  final String? mediaPaths;

  PendingMessageEntity({
    this.id,
    required this.localId,
    required this.chatRoomId,
    required this.receiverId,
    required this.content,
    required this.messageType,
    this.replyMessageId,
    required this.createdAt,
    this.retryCount = 0,
    this.mediaPaths,
  });

  /// Convert from SQLite row to Entity
  factory PendingMessageEntity.fromMap(Map<String, dynamic> map) {
    return PendingMessageEntity(
      id: map['id'] as int?,
      localId: map['local_id'] as String,
      chatRoomId: map['chat_room_id'] as String,
      receiverId: map['receiver_id'] as String,
      content: map['content'] as String,
      messageType: map['message_type'] as String? ?? 'text',
      replyMessageId: map['reply_message_id'] as String?,
      createdAt: map['created_at'] as String,
      retryCount: map['retry_count'] as int? ?? 0,
      mediaPaths: map['media_paths'] as String?,
    );
  }

  /// Convert Entity to SQLite map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'local_id': localId,
      'chat_room_id': chatRoomId,
      'receiver_id': receiverId,
      'content': content,
      'message_type': messageType,
      'reply_message_id': replyMessageId,
      'created_at': createdAt,
      'retry_count': retryCount,
      'media_paths': mediaPaths,
    };
  }

  /// Create a copy with updated fields
  PendingMessageEntity copyWith({
    int? id,
    String? localId,
    String? chatRoomId,
    String? receiverId,
    String? content,
    String? messageType,
    String? replyMessageId,
    String? createdAt,
    int? retryCount,
    String? mediaPaths,
  }) {
    return PendingMessageEntity(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      replyMessageId: replyMessageId ?? this.replyMessageId,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      mediaPaths: mediaPaths ?? this.mediaPaths,
    );
  }
}
