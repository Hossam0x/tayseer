class AdvisorChatModel {
  final bool success;
  final String message;
  final AdvisorChatData data;

  AdvisorChatModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AdvisorChatModel.fromJson(Map<String, dynamic> json) {
    return AdvisorChatModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: AdvisorChatData.fromJson(json['data'] ?? {}),
    );
  }
}



class AdvisorChatData {
  final List<AdvisorChatRoomModel> chatRooms;
  final PaginationModel pagination;

  AdvisorChatData({
    required this.chatRooms,
    required this.pagination,
  });

  factory AdvisorChatData.fromJson(Map<String, dynamic> json) {
    return AdvisorChatData(
      chatRooms: (json['data'] as List? ?? json['chatRooms'] as List? ?? [])
          .map((e) => AdvisorChatRoomModel.fromJson(e))
          .toList(),
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }
}

class AdvisorChatRoomModel {
  final String id;
  final bool isBlocked;
  final bool isHaveSession;
  final List<ChatUserModel> users;
  final LastMessageModel? lastMessage;
  final DateTime? lastMessageAt;
  final String status;
  final ChatUserModel sender; // <--- هنا
  final DateTime createdAt;
  final DateTime updatedAt;
  final int unreadCount;
  final bool isSystemChat;
  final String? systemChatImage;

  AdvisorChatRoomModel({
    required this.id,
    required this.isBlocked,
    required this.isHaveSession,
    required this.users,
    this.lastMessage,
    this.lastMessageAt,
    required this.status,
    required this.sender,
    required this.createdAt,
    required this.updatedAt,
    required this.unreadCount,
    this.isSystemChat = false,
    this.systemChatImage,
  });

  /// Display title للـ chat room (System أو اسم المستخدم)
  String get displayTitle => isSystemChat ? 'System' : _getOtherUser().name;

  /// Display image للـ chat room (صورة System أو صورة المستخدم)
  String? get displayImage =>
      isSystemChat ? systemChatImage : _getOtherUser().image;

  /// Display receiver ID للـ chat room (system أو ID المستخدم)
  String get displayReceiverId => isSystemChat ? 'system' : _getOtherUser().id;

  /// الحصول على المستخدم الآخر في المحادثة
  ChatUserModel _getOtherUser() {
    return users.isNotEmpty
        ? users.firstWhere(
            (user) => user.id == sender.id,
            orElse: () => users.first,
          )
        : sender;
  }

  factory AdvisorChatRoomModel.fromJson(Map<String, dynamic> json) {
    String extractString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is List && value.isNotEmpty) return value.first.toString();
      return value.toString();
    }

    // Get system chat image from systemChatData
    final String? systemImage = json['systemChatData']?['image']?.toString();
    final bool isSystemChat = json['systemChat'] ?? false;

    // New API format uses 'otherUser'
    final otherUserJson = json['otherUser'] as Map<String, dynamic>?;
    final otherUser = otherUserJson != null ? ChatUserModel.fromJson(otherUserJson) : null;
    
    // Fallback for older systems
    final users = (json['users'] as List? ?? [])
        .map((e) => ChatUserModel.fromJson(e is Map<String, dynamic> ? e : {}))
        .toList();
    if (otherUser != null && !users.any((u) => u.id == otherUser.id)) {
      users.add(otherUser);
    }

    // If system chat, create a system user with the image
    ChatUserModel senderUser;
    if (isSystemChat) {
      senderUser = ChatUserModel(
        id: 'system',
        name: 'System',
        image: systemImage,
        userType: 'System',
      );
    } else {
      senderUser = otherUser ?? ChatUserModel.fromJson(
        json['sender'] is Map<String, dynamic> ? json['sender'] : {},
      );
    }

    return AdvisorChatRoomModel(
      id: extractString(json['id'] ?? json['_id']),
      isBlocked: json['blockExists'] ?? json['isBlocked'] ?? false,
      isHaveSession: json['isHaveSession'] ?? false,
      users: users,
      lastMessage: json['lastMessage'] is Map<String, dynamic>
          ? LastMessageModel.fromJson(json['lastMessage'])
          : null,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'].toString()) ??
              DateTime.now()
          : (json['lastMessage']?['sentAt'] != null 
             ? DateTime.tryParse(json['lastMessage']['sentAt'].toString())
             : null),
      status: extractString(json['status']),
      sender: senderUser,
      createdAt: json['sentAt'] != null
          ? DateTime.tryParse(json['sentAt'].toString()) ?? DateTime.now()
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      unreadCount: json['unreadCount'] ?? 0,
      isSystemChat: isSystemChat,
      systemChatImage: systemImage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'isBlocked': isBlocked,
      'blockExists': isBlocked,
      'isHaveSession': isHaveSession,
      'users': users.map((u) => u.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'status': status,
      'sender': sender.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'unreadCount': unreadCount,
      'systemChat': isSystemChat,
      'systemChatData': isSystemChat && systemChatImage != null
          ? {'image': systemChatImage}
          : null,
    };
  }
}




class ChatUserModel {
  final String id;
  final String name;
  final String? image;
  final String userType;

  ChatUserModel({
    required this.id,
    required this.name,
    this.image,
    required this.userType,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    String extractString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is List && value.isNotEmpty) return value.first.toString();
      return value.toString();
    }

    return ChatUserModel(
      id: extractString(json['userId'] ?? json['id'] ?? json['_id']),
      name: extractString(json['name']),
      image: json['image']?.toString(),
      userType: extractString(json['userType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'userId': id,
      'name': name,
      'image': image,
      'userType': userType,
    };
  }
}



class LastMessageModel {
  final String id;
  final String sender;
  final String senderType;
  final String content;
  final String messageType;
  final String chatRoom;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String senderName;
  final String timeAgo;

  LastMessageModel({
    required this.id,
    required this.sender,
    required this.senderType,
    required this.content,
    required this.messageType,
    required this.chatRoom,
    required this.createdAt,
    required this.updatedAt,
    required this.senderName,
    required this.timeAgo,
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    String extractString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is List && value.isNotEmpty) return value.first.toString();
      return value.toString();
    }

    final rawContent = json['content'];
    final content = (rawContent is List)
        ? (rawContent.isEmpty ? '' : rawContent.first.toString())
        : extractString(rawContent);

    return LastMessageModel(
      id: extractString(json['id'] ?? json['_id']),
      sender: extractString(json['sender'] ?? json['senderId']),
      senderType: extractString(json['senderType']),
      content: content,
      messageType: extractString(json['contentType'] ?? json['messageType']),
      chatRoom: extractString(json['chatRoom']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      senderName: extractString(json['senderName']),
      timeAgo: extractString(json['timeAgo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'sender': sender,
      'senderId': sender,
      'senderType': senderType,
      'content': content,
      'messageType': messageType,
      'contentType': messageType,
      'chatRoom': chatRoom,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'senderName': senderName,
      'timeAgo': timeAgo,
    };
  }
}


class PaginationModel {
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  PaginationModel({
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
    );
  }
}
