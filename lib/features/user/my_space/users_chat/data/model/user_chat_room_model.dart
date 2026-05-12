class UserChatRoomModel {
  final String id;
  final OtherUserModel otherUser;
  final String otherUserType;
  final UserLastMessageModel? lastMessage;
  final bool otherUserOnlineStatus;
  final int unreadCount;
  final bool blockExists;

  UserChatRoomModel({
    required this.id,
    required this.otherUser,
    required this.otherUserType,
    this.lastMessage,
    required this.otherUserOnlineStatus,
    required this.unreadCount,
    required this.blockExists,
  });

  factory UserChatRoomModel.fromJson(Map<String, dynamic> json) {
    return UserChatRoomModel(
      id: json['id']?.toString() ?? '',
      otherUser: OtherUserModel.fromJson(
        json['otherUser'] as Map<String, dynamic>? ?? {},
      ),
      otherUserType: json['otherUserType']?.toString() ?? 'User',
      lastMessage: json['lastMessage'] is Map<String, dynamic>
          ? UserLastMessageModel.fromJson(json['lastMessage'])
          : null,
      otherUserOnlineStatus: json['otherUserOnlineStatus'] ?? false,
      unreadCount: json['unreadCount'] ?? 0,
      blockExists: json['blockExists'] ?? false,
    );
  }
}

class OtherUserModel {
  final String userId;
  final String name;
  final String? image;
  final bool imageBlur;

  OtherUserModel({
    required this.userId,
    required this.name,
    this.image,
    required this.imageBlur,
  });

  factory OtherUserModel.fromJson(Map<String, dynamic> json) {
    return OtherUserModel(
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      imageBlur: json['imageBlur'] ?? false,
    );
  }
}

class UserLastMessageModel {
  final String content;
  final DateTime? sentAt;
  final String? status;

  UserLastMessageModel({required this.content, this.sentAt, this.status});

  factory UserLastMessageModel.fromJson(Map<String, dynamic> json) {
    // ✅ نضمن إن الـ sentAt يتعامل معاه كـ UTC
    // السيرفر بيبعت UTC بدون Z أحياناً، فـ DateTime.tryParse بيعتبره local
    DateTime? parseSentAt(dynamic value) {
      if (value == null) return null;
      String s = value.toString();
      if (!s.endsWith('Z') && !s.contains('+')) s = '${s}Z';
      return DateTime.tryParse(s)?.toLocal();
    }

    return UserLastMessageModel(
      content: json['content']?.toString() ?? '',
      sentAt: parseSentAt(json['sentAt']),
      status: json['status']?.toString(),
    );
  }
}

class UserChatRoomsResponse {
  final List<UserChatRoomModel> chatRooms;
  final int pendingRequestsCount;
  final int slotLimit;
  final int totalCount;

  UserChatRoomsResponse({
    required this.chatRooms,
    required this.pendingRequestsCount,
    this.slotLimit = 3,
    this.totalCount = 0,
  });

  factory UserChatRoomsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final dynamic innerData = data['data'];

    List<dynamic> chatRoomsList = [];
    Map<String, dynamic> paginationData = {};
    int slotLimit = 4;

    if (innerData is List) {
      chatRoomsList = innerData;
      paginationData = data['pagination'] as Map<String, dynamic>? ?? {};
      slotLimit = data['slotLimit'] ?? 4;
    } else if (innerData is Map<String, dynamic>) {
      chatRoomsList =
          innerData['chatRooms'] as List? ?? innerData['data'] as List? ?? [];
      paginationData = innerData['pagination'] as Map<String, dynamic>? ?? {};
      slotLimit = innerData['slotLimit'] ?? data['slotLimit'] ?? 4;
    } else {
      chatRoomsList = data['chatRooms'] as List? ?? [];
      paginationData = data['pagination'] as Map<String, dynamic>? ?? {};
      slotLimit = data['slotLimit'] ?? 4;
    }

    final totalCount =
        paginationData['totalCount'] as int? ?? chatRoomsList.length;

    // ✅ فلتر الـ system chats — دي مش من مسؤولية UserChatCubit
    // الـ system chats بتتعرض من MySpaceCubit في الـ Marriage tab
    final userOnlyRooms = chatRoomsList
        .where((e) => e is Map<String, dynamic> && e['systemChat'] != true)
        .toList();

    return UserChatRoomsResponse(
      chatRooms: userOnlyRooms
          .map((e) => UserChatRoomModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pendingRequestsCount:
          data['pendingRequestsCount'] ??
          paginationData['pendingRequestsCount'] ??
          0,
      slotLimit: slotLimit,
      totalCount: totalCount,
    );
  }
}
