class ChatRoomsResponse {
  final bool success;
  final String message;
  final ChatRoomsData data;

  ChatRoomsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ChatRoomsResponse.fromJson(Map<String, dynamic> json) {
    return ChatRoomsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      data: ChatRoomsData.fromJson(json['data'] ?? {}),
    );
  }
}

class ChatRoomsData {
  final List<ChatRoom> rooms;
  final Pagination pagination;

  ChatRoomsData({required this.rooms, required this.pagination});

  factory ChatRoomsData.fromJson(Map<String, dynamic> json) {
    return ChatRoomsData(
      rooms:
          (json['chatRooms'] as List?)
              ?.map((e) => ChatRoom.fromJson(e))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  // ✅ أضف هذا
  ChatRoomsData copyWith({List<ChatRoom>? rooms, Pagination? pagination}) {
    return ChatRoomsData(
      rooms: rooms ?? this.rooms,
      pagination: pagination ?? this.pagination,
    );
  }
}

class ChatRoom {
  final String id;
  final List<ChatUser> users;
  final LastMessage? lastMessage;
  final DateTime? lastMessageAt;
  final String status;
  final ChatUser sender;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int unreadCount;
  final bool isBlocked;

  ChatRoom({
    required this.id,
    required this.users,
    this.lastMessage,
    required this.lastMessageAt,
    required this.status,
    required this.sender,
    required this.createdAt,
    required this.updatedAt,
    required this.unreadCount,
    this.isBlocked = false,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id']?.toString() ?? "",
      users:
          (json['users'] as List?)?.map((e) => ChatUser.fromJson(e)).toList() ??
          [],
      lastMessage:
          json['lastMessage'] != null &&
              json['lastMessage'] is Map<String, dynamic>
          ? LastMessage.fromJson(json['lastMessage'])
          : null,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'])
          : null,
      status: json['status']?.toString() ?? "",
      sender: ChatUser.fromJson(json['sender'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isBlocked: json['isBlocked'] ?? false,
    );
  }

  // ✅ أضف هذا
  ChatRoom copyWith({
    String? id,
    List<ChatUser>? users,
    LastMessage? lastMessage,
    DateTime? lastMessageAt,
    String? status,
    ChatUser? sender,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? unreadCount,
    bool? isBlocked,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      users: users ?? this.users,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      status: status ?? this.status,
      sender: sender ?? this.sender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isBlocked: isBlocked ?? this.isBlocked,
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
      id: json['id']?.toString() ?? "",
      name: json['name']?.toString() ?? "",
      image: json['image']?.toString(),
      userType: json['userType']?.toString(),
    );
  }
}

class LastMessage {
  final String id;
  final String chatRoom;
  final String sender;
  final String senderType;
  final String content;
  final String messageType;
  final String senderName;
  final String timeAgo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LastMessage({
    required this.id,
    required this.chatRoom,
    required this.sender,
    required this.senderType,
    required this.content,
    required this.messageType,
    required this.senderName,
    required this.timeAgo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    String parseContent(dynamic contentData) {
      if (contentData == null) return "";
      if (contentData is List) {
        if (contentData.isEmpty) return "";
        return contentData.map((e) => e.toString()).join(" ");
      }
      return contentData.toString();
    }

    return LastMessage(
      id: json['id']?.toString() ?? "",
      chatRoom: json['chatRoom']?.toString() ?? "",
      sender: json['sender']?.toString() ?? "",
      senderType: json['senderType']?.toString() ?? "",
      content: parseContent(json['content']),
      messageType: json['messageType']?.toString() ?? "text",
      senderName: json['senderName']?.toString() ?? "",
      timeAgo: json['timeAgo']?.toString() ?? "",
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  // ✅ أضف هذا
  LastMessage copyWith({
    String? id,
    String? chatRoom,
    String? sender,
    String? senderType,
    String? content,
    String? messageType,
    String? senderName,
    String? timeAgo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LastMessage(
      id: id ?? this.id,
      chatRoom: chatRoom ?? this.chatRoom,
      sender: sender ?? this.sender,
      senderType: senderType ?? this.senderType,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      senderName: senderName ?? this.senderName,
      timeAgo: timeAgo ?? this.timeAgo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Pagination {
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  Pagination({
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
    );
  }
}
