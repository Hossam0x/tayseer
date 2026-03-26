import 'package:equatable/equatable.dart';

// ============================================
// 📌 USER MODEL
// ============================================
class ArchiveUserModel extends Equatable {
  final String id;
  final String name;
  final String? image;
  final String userType;

  const ArchiveUserModel({
    required this.id,
    required this.name,
    this.image,
    required this.userType,
  });

  factory ArchiveUserModel.fromJson(Map<String, dynamic> json) {
    return ArchiveUserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'مستخدم',
      image: json['image']?.toString(),
      userType: json['userType']?.toString() ?? 'User',
    );
  }

  @override
  List<Object?> get props => [id, name, image, userType];
}

// ============================================
// 📌 LAST MESSAGE MODEL
// ============================================
class ArchiveLastMessageModel extends Equatable {
  final String id;
  final String sender;
  final String senderType;
  final String content;
  final String messageType;
  final String chatRoom;
  final String createdAt;
  final String updatedAt;
  final String senderName;
  final String timeAgo;

  const ArchiveLastMessageModel({
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

  factory ArchiveLastMessageModel.fromJson(Map<String, dynamic> json) {
    return ArchiveLastMessageModel(
      id: json['id']?.toString() ?? '',
      sender: json['sender']?.toString() ?? '',
      senderType: json['senderType']?.toString() ?? 'User',
      content: json['content']?.toString() ?? '',
      messageType: json['messageType']?.toString() ?? 'text',
      chatRoom: json['chatRoom']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      timeAgo: json['timeAgo']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    sender,
    senderType,
    content,
    messageType,
    chatRoom,
    createdAt,
    updatedAt,
    senderName,
    timeAgo,
  ];
}

// ============================================
// 📌 CHAT ROOM MODEL
// ============================================
class ArchiveChatRoomModel extends Equatable {
  final String id;
  final bool isBlocked;
  final bool isHaveSession;
  final List<ArchiveUserModel> users;
  final ArchiveLastMessageModel? lastMessage;
  final String? lastMessageAt;
  final String status;
  final ArchiveUserModel? sender;
  final String createdAt;
  final String updatedAt;
  final int unreadCount;

  const ArchiveChatRoomModel({
    required this.id,
    required this.isBlocked,
    required this.isHaveSession,
    required this.users,
    this.lastMessage,
    this.lastMessageAt,
    required this.status,
    this.sender,
    required this.createdAt,
    required this.updatedAt,
    required this.unreadCount,
  });

  ArchiveChatRoomModel copyWith({
    String? id,
    bool? isBlocked,
    bool? isHaveSession,
    List<ArchiveUserModel>? users,
    ArchiveLastMessageModel? lastMessage,
    String? lastMessageAt,
    String? status,
    ArchiveUserModel? sender,
    String? createdAt,
    String? updatedAt,
    int? unreadCount,
  }) {
    return ArchiveChatRoomModel(
      id: id ?? this.id,
      isBlocked: isBlocked ?? this.isBlocked,
      isHaveSession: isHaveSession ?? this.isHaveSession,
      users: users ?? this.users,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      status: status ?? this.status,
      sender: sender ?? this.sender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  factory ArchiveChatRoomModel.fromJson(Map<String, dynamic> json) {
    List<ArchiveUserModel> usersList = [];
    try {
      if (json['users'] is List) {
        usersList = (json['users'] as List)
            .map(
              (user) => ArchiveUserModel.fromJson(
                user is Map<String, dynamic>
                    ? user
                    : (user as Map).cast<String, dynamic>(),
              ),
            )
            .toList();
      }
    } catch (_) {}

    ArchiveLastMessageModel? lastMessage;
    try {
      if (json['lastMessage'] is Map) {
        lastMessage = ArchiveLastMessageModel.fromJson(
          (json['lastMessage'] as Map).cast<String, dynamic>(),
        );
      }
    } catch (_) {}

    ArchiveUserModel? sender;
    try {
      if (json['sender'] is Map) {
        sender = ArchiveUserModel.fromJson(
          (json['sender'] as Map).cast<String, dynamic>(),
        );
      }
    } catch (_) {}

    return ArchiveChatRoomModel(
      id: json['id']?.toString() ?? '',
      isBlocked: json['isBlocked'] as bool? ?? false,
      isHaveSession: json['isHaveSession'] as bool? ?? false,
      users: usersList,
      lastMessage: lastMessage,
      lastMessageAt: json['lastMessageAt']?.toString(),
      status: json['status']?.toString() ?? 'active',
      sender: sender,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  ArchiveUserModel? getOtherUser(String currentUserId) {
    try {
      for (final user in users) {
        if (user.id != currentUserId) return user;
      }
      if (sender != null && sender!.id != currentUserId) return sender;
      return null;
    } catch (_) {
      return null;
    }
  }

  ArchiveUserModel? getOtherUserBasedOnSender(String currentUserId) {
    try {
      if (sender != null && sender!.id == currentUserId) {
        for (final user in users) {
          if (user.id != currentUserId) return user;
        }
      } else if (sender != null) {
        return sender;
      }
      for (final user in users) {
        if (user.id != currentUserId) return user;
      }
      return users.isNotEmpty ? users.first : null;
    } catch (_) {
      return null;
    }
  }

  String get lastMessageContent => lastMessage?.content ?? '';

  String get formattedLastMessageTime {
    try {
      if (lastMessageAt != null) return _formatToEgyptTime(lastMessageAt!);
      return '--:--';
    } catch (_) {
      return '--:--';
    }
  }

  String _formatToEgyptTime(String dateString) {
    try {
      final date = DateTime.parse(dateString).toUtc();
      final egyptTime = date.add(const Duration(hours: 2));
      final now = DateTime.now().toUtc().add(const Duration(hours: 2));
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(
        egyptTime.year,
        egyptTime.month,
        egyptTime.day,
      );

      final hour = egyptTime.hour;
      final minute = egyptTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'م' : 'ص';
      final hour12 = hour % 12;
      final displayHour = hour12 == 0 ? 12 : hour12;

      if (messageDate == today) {
        return '$displayHour:$minute $period';
      } else if (messageDate.isAfter(today.subtract(const Duration(days: 1)))) {
        return 'أمس $displayHour:$minute $period';
      } else if (messageDate.isAfter(today.subtract(const Duration(days: 7)))) {
        return '${_getArabicDayName(egyptTime.weekday)} $displayHour:$minute $period';
      } else {
        return '${egyptTime.day}/${egyptTime.month} $displayHour:$minute $period';
      }
    } catch (_) {
      return '--:--';
    }
  }

  String _getArabicDayName(int weekday) {
    const days = [
      '',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return weekday >= 1 && weekday <= 7 ? days[weekday] : '';
  }

  @override
  List<Object?> get props => [
    id,
    isBlocked,
    isHaveSession,
    users,
    lastMessage,
    lastMessageAt,
    status,
    sender,
    createdAt,
    updatedAt,
    unreadCount,
  ];
}

// ============================================
// 📌 ARCHIVED CHATS RESPONSE
// ============================================
class ArchivedChatsResponseModel extends Equatable {
  final List<ArchiveChatRoomModel> chatRooms;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;

  const ArchivedChatsResponseModel({
    required this.chatRooms,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasMore,
  });

  factory ArchivedChatsResponseModel.fromJson(Map<String, dynamic> json) {
    List<ArchiveChatRoomModel> chatRoomsList = [];
    try {
      if (json['chatRooms'] is List) {
        chatRoomsList = (json['chatRooms'] as List).map((chatRoom) {
          return ArchiveChatRoomModel.fromJson(
            chatRoom is Map<String, dynamic>
                ? chatRoom
                : (chatRoom as Map).cast<String, dynamic>(),
          );
        }).toList();
      }
    } catch (_) {}

    Map<String, dynamic> pagination = {};
    try {
      if (json['pagination'] is Map) {
        pagination = (json['pagination'] as Map).cast<String, dynamic>();
      }
    } catch (_) {}

    final currentPage = (pagination['currentPage'] as num?)?.toInt() ?? 1;
    final totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;

    return ArchivedChatsResponseModel(
      chatRooms: chatRoomsList,
      currentPage: currentPage,
      totalPages: totalPages,
      totalCount: (pagination['totalCount'] as num?)?.toInt() ?? 0,
      hasMore: currentPage < totalPages,
    );
  }

  @override
  List<Object?> get props => [
    chatRooms,
    currentPage,
    totalPages,
    totalCount,
    hasMore,
  ];
}
