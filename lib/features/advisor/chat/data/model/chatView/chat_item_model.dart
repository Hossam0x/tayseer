/// Response for GET /new-chat/rooms
class ChatRoomsResponse {
  final bool success;
  final List<ChatRoom> rooms;

  ChatRoomsResponse({required this.success, required this.rooms});

  factory ChatRoomsResponse.fromJson(Map<String, dynamic> json) {
    // Handle multiple server structure variations:
    // 1. { "success": true, "data": { "data": [ ... ] } }
    // 2. { "success": true, "data": { "chatRooms": [ ... ] } }
    final dataObj = json['data'];
    final roomsList = (dataObj is Map<String, dynamic>)
        ? (dataObj['data'] ?? dataObj['chatRooms'])
        : null;

    return ChatRoomsResponse(
      success: json['success'] ?? false,
      rooms: (roomsList as List?)
              ?.map((e) => ChatRoom.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ChatRoom {
  final String id;
  final List<ChatUser> participants;
  final LastMessage? lastMessage;
  final DateTime? createdAt;
  final int unreadCount;
  final bool isBlocked;
  final bool isSystemChat;

  ChatRoom({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.createdAt,
    required this.unreadCount,
    this.isBlocked = false,
    this.isSystemChat = false,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    final List<ChatUser> parts = [];
    if (json['otherUser'] != null) {
      parts.add(ChatUser.fromJson(json['otherUser'] as Map<String, dynamic>));
    } else if (json['systemChat'] == true) {
      // Create a dummy system user if it's a system chat
      parts.add(ChatUser(id: 'system', name: 'System'));
    }

    return ChatRoom(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      participants: parts,
      lastMessage:
          json['lastMessage'] != null &&
              json['lastMessage'] is Map<String, dynamic>
          ? LastMessage.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      createdAt: json['lastMessage']?['sentAt'] != null
          ? DateTime.tryParse(json['lastMessage']['sentAt'].toString())
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null),
      unreadCount: json['unreadCount'] ?? 0,
      isBlocked: json['blockExists'] ?? json['isBlocked'] ?? false,
      isSystemChat: json['systemChat'] ?? false,
    );
  }

  ChatRoom copyWith({
    String? id,
    List<ChatUser>? participants,
    LastMessage? lastMessage,
    DateTime? createdAt,
    int? unreadCount,
    bool? isBlocked,
    bool? isSystemChat,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isBlocked: isBlocked ?? this.isBlocked,
      isSystemChat: isSystemChat ?? this.isSystemChat,
    );
  }
}

class ChatUser {
  final String id;
  final String name;
  final String? image;
  final String? userType;

  ChatUser({required this.id, required this.name, this.image, this.userType});

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['userId']?.toString() ?? json['_id']?.toString() ?? '',
      name:
          json['name']?.toString() ??
          json['displayName']?.toString() ??
          'Unknown',
      image: json['image']?.toString() ?? json['avatar']?.toString(),
      userType: json['userType']?.toString(),
    );
  }
}

class LastMessage {
  final String content;
  final DateTime? sentAt;

  LastMessage({required this.content, required this.sentAt});

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      content: _parseContent(json['content']),
      sentAt: json['sentAt'] != null
          ? DateTime.tryParse(json['sentAt'].toString())
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null),
    );
  }

  static String _parseContent(dynamic contentData) {
    if (contentData == null) return '';
    if (contentData is List) {
      return contentData.isEmpty ? '' : contentData.first.toString();
    }
    return contentData.toString();
  }

  LastMessage copyWith({String? content, DateTime? sentAt}) {
    return LastMessage(
      content: content ?? this.content,
      sentAt: sentAt ?? this.sentAt,
    );
  }
}
