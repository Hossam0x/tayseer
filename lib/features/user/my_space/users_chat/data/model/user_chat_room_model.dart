class UserChatRoomModel {
  final String id;
  final OtherUserModel otherUser;
  final String otherUserType;
  final UserLastMessageModel? lastMessage;
  final bool otherUserOnlineStatus;
  final int unreadCount;
  final bool blockExists;
  // ✅ isMe: true = أنت المحظور (هو بلّكك)، false = أنت الحاظر (أنت بلّكته)
  // بييجي من الـ backend في حالة وجود block
  final bool isBlockedByOther;
  // ✅ بييجي على مستوى الـ room مش جوه otherUser
  // false = سمحنا لهذا الشخص يشوف صورتنا (exception مفعّل)
  // true  = صورتنا مبلورة عنده (exception مش مفعّل)
  final bool blurMyImageFromOtherUser;

  /// هل أنا الحاظر؟ (أنت بلّكته)
  bool get amIBlocker => blockExists && !isBlockedByOther;

  /// هل أنا المحظور؟ (هو بلّكك)
  bool get amIBlocked => blockExists && isBlockedByOther;

  UserChatRoomModel({
    required this.id,
    required this.otherUser,
    required this.otherUserType,
    this.lastMessage,
    required this.otherUserOnlineStatus,
    required this.unreadCount,
    required this.blockExists,
    this.isBlockedByOther = false,
    this.blurMyImageFromOtherUser = true,
  });

  factory UserChatRoomModel.fromJson(Map<String, dynamic> json) {
    // ✅ من الـ API:
    // blockExists: true  + isMe: true  = أنت بلّكته (أنت الحاظر)
    // blockExists: true  + isMe: false = هو بلّكك   (أنت المحظور)
    // blockExists: false + isMe: false = مفيش block
    final blockExists = json['blockExists'] as bool? ?? false;
    final isMe = json['isMe'] as bool? ?? false;

    // isBlockedByOther: true = هو بلّكك (blockExists=true + isMe=false)
    // isBlockedByOther: false = أنت الحاظر (blockExists=true + isMe=true) أو مفيش block
    final isBlockedByOther = blockExists && !isMe;

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
      blockExists: blockExists,
      isBlockedByOther: isBlockedByOther,
      blurMyImageFromOtherUser: json['blurMyImageFromOtherUser'] ?? true,
    );
  }

  UserChatRoomModel copyWith({
    bool? blockExists,
    bool? isBlockedByOther,
    UserLastMessageModel? lastMessage,
    int? unreadCount,
    bool? otherUserOnlineStatus,
    bool? blurMyImageFromOtherUser,
  }) {
    return UserChatRoomModel(
      id: id,
      otherUser: otherUser,
      otherUserType: otherUserType,
      lastMessage: lastMessage ?? this.lastMessage,
      otherUserOnlineStatus:
          otherUserOnlineStatus ?? this.otherUserOnlineStatus,
      unreadCount: unreadCount ?? this.unreadCount,
      blockExists: blockExists ?? this.blockExists,
      isBlockedByOther: isBlockedByOther ?? this.isBlockedByOther,
      blurMyImageFromOtherUser:
          blurMyImageFromOtherUser ?? this.blurMyImageFromOtherUser,
    );
  }
}

class OtherUserModel {
  final String userId;
  final String name;
  final String? image;
  final bool imageBlur;
  // ✅ globalImageBlur = true يعني صورته مبلورة للكل (بغض النظر عن الـ exceptions)
  final bool globalImageBlur;
  final DateTime? lastActiveAt;

  OtherUserModel({
    required this.userId,
    required this.name,
    this.image,
    required this.imageBlur,
    this.globalImageBlur = false,
    this.lastActiveAt,
  });

  factory OtherUserModel.fromJson(Map<String, dynamic> json) {
    return OtherUserModel(
      userId: json['userId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString(),
      imageBlur: json['imageBlur'] ?? false,
      globalImageBlur: json['globalImageBlur'] ?? json['imageBlur'] ?? false,
      lastActiveAt: _parseLastActiveAt(
        json['lastActiveAt'] ?? json['last_active_at'],
      ),
    );
  }

  static DateTime? _parseLastActiveAt(dynamic value) {
    if (value == null) return null;
    String text = value.toString();
    if (!text.endsWith('Z') && !text.contains('+')) {
      text = '${text}Z';
    }
    return DateTime.tryParse(text)?.toLocal();
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
    final contentType =
        (json['contentType'] ?? json['messageType'])
            ?.toString()
            .toLowerCase() ??
        '';
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
        if (rawContent.startsWith('http://') ||
            rawContent.startsWith('https://')) {
          final lower = rawContent.toLowerCase();
          if (lower.contains('.mp3') ||
              lower.contains('.m4a') ||
              lower.contains('.wav') ||
              lower.contains('.ogg') ||
              lower.contains('.aac'))
            return 'audio';
          if (lower.contains('.mp4') ||
              lower.contains('.mov') ||
              lower.contains('.avi'))
            return 'video';
          if (lower.contains('.jpg') ||
              lower.contains('.jpeg') ||
              lower.contains('.png') ||
              lower.contains('.gif') ||
              lower.contains('.webp'))
            return 'image';
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
  final bool myImageBlur; // ✅ added

  UserChatRoomsResponse({
    required this.chatRooms,
    required this.pendingRequestsCount,
    this.slotLimit = 3,
    this.totalCount = 0,
    this.myImageBlur = false, // ✅ added
  });

  factory UserChatRoomsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final dynamic innerData = data['data'];

    List<dynamic> chatRoomsList = [];
    Map<String, dynamic> paginationData = {};
    int slotLimit = 4;
    bool myImageBlur = false; // ✅ added

    if (innerData is List) {
      chatRoomsList = innerData;
      paginationData = data['pagination'] as Map<String, dynamic>? ?? {};
      slotLimit = data['slotLimit'] ?? 4;
      myImageBlur = data['myImageBlur'] ?? false; // ✅ added
    } else if (innerData is Map<String, dynamic>) {
      chatRoomsList =
          innerData['chatRooms'] as List? ?? innerData['data'] as List? ?? [];
      paginationData = innerData['pagination'] as Map<String, dynamic>? ?? {};
      slotLimit = innerData['slotLimit'] ?? data['slotLimit'] ?? 4;
      myImageBlur =
          innerData['myImageBlur'] ?? data['myImageBlur'] ?? false; // ✅ added
    } else {
      chatRoomsList = data['chatRooms'] as List? ?? [];
      paginationData = data['pagination'] as Map<String, dynamic>? ?? {};
      slotLimit = data['slotLimit'] ?? 4;
      myImageBlur = data['myImageBlur'] ?? false; // ✅ added
    }

    final totalCount =
        paginationData['totalCount'] as int? ?? chatRoomsList.length;

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
      myImageBlur: myImageBlur, // ✅ added
    );
  }
}
