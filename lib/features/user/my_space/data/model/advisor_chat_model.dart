/// ✅ Helper: يحول الـ string لـ DateTime بـ UTC صح
/// السيرفر بيبعت UTC بدون Z أحياناً، فنضيفها لو مش موجودة
DateTime? _parseUtc(String s) {
  if (s.isEmpty) return null;
  if (!s.endsWith('Z') && !s.contains('+')) s = '${s}Z';
  return DateTime.tryParse(s)?.toLocal();
}

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
    // Handle nested data structure: data.data.chatRooms or data.chatRooms
    Map<String, dynamic>? innerData;
    List? roomsList;

    // Check if there's a nested "data" object
    if (json['data'] is Map<String, dynamic>) {
      innerData = json['data'] as Map<String, dynamic>;
      roomsList = innerData['chatRooms'] as List?;
    } else if (json['chatRooms'] is List) {
      // Direct chatRooms array
      roomsList = json['chatRooms'] as List;
      innerData = json;
    } else if (json['data'] is List) {
      // data is directly the array
      roomsList = json['data'] as List;
      innerData = json;
    }

    return AdvisorChatData(
      chatRooms: (roomsList ?? [])
          .map((e) => AdvisorChatRoomModel.fromJson(e))
          .toList(),
      pagination: PaginationModel.fromJson(
        (innerData?['pagination'] ?? json['pagination']) ?? {},
      ),
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
          ? _parseUtc(json['lastMessageAt'].toString())
          : (json['lastMessage']?['sentAt'] != null 
             ? _parseUtc(json['lastMessage']['sentAt'].toString())
             : null),
      status: extractString(json['status']),
      sender: senderUser,
      createdAt: json['sentAt'] != null
          ? _parseUtc(json['sentAt'].toString()) ?? DateTime.now()
          : (json['createdAt'] != null
              ? _parseUtc(json['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
      updatedAt: json['updatedAt'] != null
          ? _parseUtc(json['updatedAt'].toString()) ?? DateTime.now()
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
  final String? status; // SENT, DELIVERED, READ

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
    this.status,
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    String extractString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is List && value.isNotEmpty) return value.first.toString();
      return value.toString();
    }

    final rawContent = json['content'];
    final messageType = extractString(json['contentType'] ?? json['messageType']);
    
    // ✅ حوّل الـ messageType لـ keyword موحد — الترجمة والـ emoji تتم في formatLastMessage
    String content;
    if (messageType == 'image' || messageType == 'images/videos') {
      content = 'image';
    } else if (messageType == 'video') {
      content = 'video';
    } else if (messageType == 'audio' || messageType == 'voice' || messageType == 'record') {
      content = 'audio';
    } else if (messageType == 'file' || messageType == 'document') {
      content = 'file';
    } else {
      // text أو system — ارجع الـ content الفعلي
      content = (rawContent is List)
          ? (rawContent.isEmpty ? '' : rawContent.first.toString())
          : extractString(rawContent);
    }

    return LastMessageModel(
      id: extractString(json['id'] ?? json['_id']),
      sender: extractString(json['sender'] ?? json['senderId']),
      senderType: extractString(json['senderType']),
      content: content,
      messageType: messageType,
      chatRoom: extractString(json['chatRoom']),
      createdAt: json['createdAt'] != null
          ? _parseUtc(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? _parseUtc(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      senderName: extractString(json['senderName']),
      timeAgo: extractString(json['timeAgo']),
      status: json['status']?.toString(),
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
      'status': status,
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
