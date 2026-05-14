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
    DateTime? parseSentAt(dynamic value) {
      if (value == null) return null;
      String s = value.toString();
      if (!s.endsWith('Z') && !s.contains('+')) s = '${s}Z';
      return DateTime.tryParse(s)?.toLocal();
    }

    // ✅ حوّل الـ content لـ display content مناسب
    // السيرفر بيرجع الـ URL الفعلي للـ audio/image/video في الـ content
    // لازم نحوّله لـ keyword عشان formatLastMessage يعرضه صح (🎤 / 📷 / 🎥)
    final rawContent = json['content']?.toString() ?? '';
    final contentType = (json['contentType'] ?? json['messageType'])
        ?.toString()
        .toLowerCase() ?? '';
    final displayContent = _normalizeContent(rawContent, contentType);

    return UserLastMessageModel(
      content: displayContent,
      sentAt: parseSentAt(json['sentAt']),
      status: json['status']?.toString(),
    );
  }

  /// يحوّل الـ content الخام لـ keyword مناسب للعرض في الـ chat list
  static String _normalizeContent(String rawContent, String contentType) {
    switch (contentType) {
      case 'record':
      case 'audio':
      case 'voice':
        return 'audio';
      case 'image':
      case 'photo':
      case 'media':
      case 'images/videos':
        // ✅ تحقق من الـ URL نفسه عشان نعرف image أو video
        if (rawContent.toLowerCase().contains('.mp4') ||
            rawContent.toLowerCase().contains('.mov') ||
            rawContent.toLowerCase().contains('.avi') ||
            rawContent.toLowerCase().contains('.webm')) {
          return 'video';
        }
        return 'image';
      case 'video':
        return 'video';
      case 'file':
      case 'document':
        return 'file';
      default:
        // text أو غير معروف — تحقق من الـ URL
        if (rawContent.startsWith('http://') || rawContent.startsWith('https://')) {
          final lower = rawContent.toLowerCase();
          if (lower.contains('.mp3') || lower.contains('.m4a') ||
              lower.contains('.wav') || lower.contains('.ogg') ||
              lower.contains('.aac')) return 'audio';
          if (lower.contains('.mp4') || lower.contains('.mov') ||
              lower.contains('.avi')) return 'video';
          if (lower.contains('.jpg') || lower.contains('.jpeg') ||
              lower.contains('.png') || lower.contains('.gif') ||
              lower.contains('.webp')) return 'image';
        }
        return rawContent;
    }
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
