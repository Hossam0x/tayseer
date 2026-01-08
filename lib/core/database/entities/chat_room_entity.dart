import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';

/// Entity class for SQLite chat room storage
class ChatRoomEntity {
  final String id;
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserImage;
  final String? otherUserType;
  final String? lastMessage;
  final String? lastMessageType;
  final String? lastMessageTime;
  final int unreadCount;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  ChatRoomEntity({
    required this.id,
    this.otherUserId,
    this.otherUserName,
    this.otherUserImage,
    this.otherUserType,
    this.lastMessage,
    this.lastMessageType,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert from SQLite row to Entity
  factory ChatRoomEntity.fromMap(Map<String, dynamic> map) {
    return ChatRoomEntity(
      id: map['id'] as String,
      otherUserId: map['other_user_id'] as String?,
      otherUserName: map['other_user_name'] as String?,
      otherUserImage: map['other_user_image'] as String?,
      otherUserType: map['other_user_type'] as String?,
      lastMessage: map['last_message'] as String?,
      lastMessageType: map['last_message_type'] as String?,
      lastMessageTime: map['last_message_time'] as String?,
      unreadCount: map['unread_count'] as int? ?? 0,
      status: map['status'] as String?,
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  /// Convert Entity to SQLite map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'other_user_id': otherUserId,
      'other_user_name': otherUserName,
      'other_user_image': otherUserImage,
      'other_user_type': otherUserType,
      'last_message': lastMessage,
      'last_message_type': lastMessageType,
      'last_message_time': lastMessageTime,
      'unread_count': unreadCount,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Convert from ChatRoom model to Entity
  factory ChatRoomEntity.fromChatRoom(ChatRoom room, {String? currentUserId}) {
    // Find the other user (not the current user)
    ChatUser? otherUser;
    if (room.users.isNotEmpty) {
      otherUser = room.users.firstWhere(
        (u) => u.id != currentUserId,
        orElse: () => room.users.first,
      );
    }

    return ChatRoomEntity(
      id: room.id,
      otherUserId: otherUser?.id,
      otherUserName: otherUser?.name,
      otherUserImage: otherUser?.image,
      otherUserType: otherUser?.userType,
      lastMessage: room.lastMessage?.content,
      lastMessageType: room.lastMessage?.messageType,
      lastMessageTime: room.lastMessageAt?.toIso8601String(),
      unreadCount: room.unreadCount,
      status: room.status,
      createdAt: room.createdAt?.toIso8601String(),
      updatedAt: room.updatedAt?.toIso8601String(),
    );
  }

  /// Convert Entity to ChatRoom model
  ChatRoom toChatRoom() {
    final otherUser = ChatUser(
      id: otherUserId ?? '',
      name: otherUserName ?? '',
      image: otherUserImage,
      userType: otherUserType,
    );

    return ChatRoom(
      id: id,
      users: [otherUser],
      lastMessage: lastMessage != null
          ? LastMessage(
              id: '',
              chatRoom: id,
              sender: otherUserId ?? '',
              senderType: otherUserType ?? '',
              content: lastMessage ?? '',
              messageType: lastMessageType ?? 'text',
              senderName: otherUserName ?? '',
              timeAgo: '',
              createdAt: lastMessageTime != null
                  ? DateTime.tryParse(lastMessageTime!)
                  : null,
              updatedAt: null,
            )
          : null,
      lastMessageAt: lastMessageTime != null
          ? DateTime.tryParse(lastMessageTime!)
          : null,
      status: status ?? '',
      sender: otherUser,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
      unreadCount: unreadCount,
    );
  }

  /// Create a copy with updated fields
  ChatRoomEntity copyWith({
    String? id,
    String? otherUserId,
    String? otherUserName,
    String? otherUserImage,
    String? otherUserType,
    String? lastMessage,
    String? lastMessageType,
    String? lastMessageTime,
    int? unreadCount,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return ChatRoomEntity(
      id: id ?? this.id,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserImage: otherUserImage ?? this.otherUserImage,
      otherUserType: otherUserType ?? this.otherUserType,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
