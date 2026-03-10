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
      chatRooms: (json['chatRooms'] as List? ?? [])
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

  AdvisorChatRoomModel({
    required this.id,
    required this.isBlocked,
    required this.isHaveSession,
    required this.users,
    this.lastMessage,
    this.lastMessageAt,
    required this.status,
    required this.sender, // <--- هنا
    required this.createdAt,
    required this.updatedAt,
    required this.unreadCount,
  });

  factory AdvisorChatRoomModel.fromJson(Map<String, dynamic> json) {
    String extractString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is List && value.isNotEmpty) return value.first.toString();
      return value.toString();
    }

    return AdvisorChatRoomModel(
      id: extractString(json['id']),
      isBlocked: json['isBlocked'] ?? false,
      isHaveSession: json['isHaveSession'] ?? false,
      users: (json['users'] as List? ?? [])
          .map((e) => ChatUserModel.fromJson(e is Map<String, dynamic> ? e : {}))
          .toList(),
      lastMessage: json['lastMessage'] is Map<String, dynamic>
          ? LastMessageModel.fromJson(json['lastMessage'])
          : null,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'].toString()) ??
              DateTime.now()
          : null,
      status: extractString(json['status']),
      sender: ChatUserModel.fromJson(
        json['sender'] is Map<String, dynamic> ? json['sender'] : {},
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      unreadCount: json['unreadCount'] ?? 0,
    );
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
      id: extractString(json['id']),
      name: extractString(json['name']),
      image: json['image']?.toString(),
      userType: extractString(json['userType']),
    );
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

    return LastMessageModel(
      id: extractString(json['id']),
      sender: extractString(json['sender']),
      senderType: extractString(json['senderType']),
      content: extractString(json['content']),
      messageType: extractString(json['messageType']),
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
