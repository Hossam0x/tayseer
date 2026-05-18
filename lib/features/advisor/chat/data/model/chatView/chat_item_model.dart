/// Response for GET /new-chat/rooms
class ChatRoomsResponse {
  final bool success;
  final List<ChatRoom> rooms;
  final int pendingRequestsCount;

  ChatRoomsResponse({
    required this.success,
    required this.rooms,
    this.pendingRequestsCount = 0,
  });

  factory ChatRoomsResponse.fromJson(Map<String, dynamic> json) {
    // Handle multiple server structure variations:
    // 1. { "success": true, "data": { "data": { "chatRooms": [...], "pendingRequestsCount": 1 } } }
    // 2. { "success": true, "data": { "chatRooms": [ ... ] } }
    final dataObj = json['data'];
    
    Map<String, dynamic>? innerData;
    List? roomsList;
    int pendingCount = 0;

    if (dataObj is Map<String, dynamic>) {
      // Check if there's a nested "data" object
      if (dataObj['data'] is Map<String, dynamic>) {
        innerData = dataObj['data'] as Map<String, dynamic>;
        roomsList = innerData['chatRooms'] as List?;
        pendingCount = innerData['pendingRequestsCount'] ?? 0;
      } else {
        // Direct chatRooms array
        roomsList = dataObj['chatRooms'] as List? ?? dataObj['data'] as List?;
        pendingCount = dataObj['pendingRequestsCount'] ?? 0;
      }
    }

    return ChatRoomsResponse(
      success: json['success'] ?? false,
      rooms: (roomsList)
              ?.map((e) => ChatRoom.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pendingRequestsCount: pendingCount,
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
  final String? systemChatImage;

  ChatRoom({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.createdAt,
    required this.unreadCount,
    this.isBlocked = false,
    this.isSystemChat = false,
    this.systemChatImage,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    final List<ChatUser> parts = [];
    String? systemImage;
    
    if (json['otherUser'] != null) {
      parts.add(ChatUser.fromJson(json['otherUser'] as Map<String, dynamic>));
    } else if (json['systemChat'] == true) {
      // Get system chat image from systemChatData
      systemImage = json['systemChatData']?['image']?.toString();
      // Create a dummy system user if it's a system chat
      parts.add(ChatUser(id: 'system', name: 'System', image: systemImage));
    }

    return ChatRoom(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      participants: parts,
      lastMessage:
          json['lastMessage'] != null &&
              json['lastMessage'] is Map<String, dynamic>
          ? LastMessage.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      createdAt: () {
        DateTime? parseSentAt(dynamic value) {
          if (value == null) return null;
          String s = value.toString();
          if (!s.endsWith('Z') && !s.contains('+') && !s.contains('-', 10)) {
            s = '${s}Z';
          }
          return DateTime.tryParse(s)?.toLocal();
        }
        return parseSentAt(json['lastMessage']?['sentAt']) ??
            parseSentAt(json['createdAt']);
      }(),
      unreadCount: json['unreadCount'] ?? 0,
      isBlocked: json['blockExists'] ?? json['isBlocked'] ?? false,
      isSystemChat: json['systemChat'] ?? false,
      systemChatImage: systemImage,
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
    String? systemChatImage,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isBlocked: isBlocked ?? this.isBlocked,
      isSystemChat: isSystemChat ?? this.isSystemChat,
      systemChatImage: systemChatImage ?? this.systemChatImage,
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
    final contentType = (json['contentType'] ?? json['messageType'])
        ?.toString()
        .toLowerCase() ?? '';
    final rawContent = json['content'];

    // ✅ helper يضمن إن الـ DateTime دايماً UTC ثم local
    DateTime? parseSentAt(dynamic value) {
      if (value == null) return null;
      String s = value.toString();
      // لو مفيش Z أو offset، افترض إنه UTC وأضف Z
      if (!s.endsWith('Z') && !s.contains('+') && !s.contains('-', 10)) {
        s = '${s}Z';
      }
      return DateTime.tryParse(s)?.toLocal();
    }

    return LastMessage(
      content: _normalizeContent(rawContent, contentType),
      sentAt: parseSentAt(json['sentAt']) ?? parseSentAt(json['createdAt']),
    );
  }

  /// ✅ يحوّل الـ content لـ keyword موحد — الترجمة والـ emoji في formatLastMessage
  static String _normalizeContent(dynamic contentData, String contentType) {
    switch (contentType) {
      case 'record':
      case 'audio':
      case 'voice':
        return 'audio';
      case 'image':
      case 'photo':
      case 'media':
      case 'images/videos':
        return 'image';
      case 'video':
        return 'video';
      case 'file':
      case 'document':
        return 'file';
      default:
        return _parseContent(contentData);
    }
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
