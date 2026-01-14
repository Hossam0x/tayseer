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
// 📌 CHAT ROOM MODEL
// ============================================
class ArchiveChatRoomModel extends Equatable {
  final String id;
  final bool isBlocked;
  final List<ArchiveUserModel> users;
  final String? lastMessage;
  final String? lastMessageAt;
  final String status;
  final ArchiveUserModel? sender;
  final String createdAt;
  final String updatedAt;
  final int unreadCount;

  const ArchiveChatRoomModel({
    required this.id,
    required this.isBlocked,
    required this.users,
    this.lastMessage,
    this.lastMessageAt,
    required this.status,
    this.sender,
    required this.createdAt,
    required this.updatedAt,
    required this.unreadCount,
  });

  factory ArchiveChatRoomModel.fromJson(Map<String, dynamic> json) {
    // Debug print
    print('📌 Parsing chat room: $json');

    // معالجة users
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
    } catch (e) {
      print('❌ Error parsing users: $e');
    }

    // معالجة sender
    ArchiveUserModel? sender;
    try {
      if (json['sender'] != null && json['sender'] is Map) {
        sender = ArchiveUserModel.fromJson(
          (json['sender'] as Map).cast<String, dynamic>(),
        );
      }
    } catch (e) {
      print('❌ Error parsing sender: $e');
    }

    // معالجة الحقول النصية
    final lastMessage = json['lastMessage'];
    final lastMessageAt = json['lastMessageAt'];

    print('📝 lastMessage type: ${lastMessage.runtimeType}');
    print('📝 lastMessage value: "$lastMessage"');

    return ArchiveChatRoomModel(
      id: json['id']?.toString() ?? '',
      isBlocked: json['isBlocked'] as bool? ?? false,
      users: usersList,
      lastMessage: lastMessage is String
          ? (lastMessage.isEmpty ? null : lastMessage)
          : null,
      lastMessageAt: lastMessageAt is String
          ? (lastMessageAt.isEmpty ? null : lastMessageAt)
          : null,
      status: json['status']?.toString() ?? 'active',
      sender: sender,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  // الحصول على المستخدم الآخر
  ArchiveUserModel? getOtherUser(String currentUserId) {
    try {
      for (final user in users) {
        if (user.id != currentUserId) {
          return user;
        }
      }
      return users.isNotEmpty ? users.first : null;
    } catch (e) {
      print('❌ Error in getOtherUser: $e');
      return null;
    }
  }

  @override
  List<Object?> get props => [
    id,
    isBlocked,
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
    print('📦 Parsing ArchivedChatsResponseModel');

    // معالجة chatRooms
    List<ArchiveChatRoomModel> chatRoomsList = [];
    try {
      if (json['chatRooms'] is List) {
        chatRoomsList = (json['chatRooms'] as List).map((chatRoom) {
          try {
            return ArchiveChatRoomModel.fromJson(
              chatRoom is Map<String, dynamic>
                  ? chatRoom
                  : (chatRoom as Map).cast<String, dynamic>(),
            );
          } catch (e) {
            print('❌ Error parsing individual chat room: $e');
            print('❌ Chat room data: $chatRoom');
            return ArchiveChatRoomModel(
              id: '',
              isBlocked: false,
              users: [],
              status: 'active',
              createdAt: '',
              updatedAt: '',
              unreadCount: 0,
            );
          }
        }).toList();
      }
    } catch (e) {
      print('❌ Error parsing chatRooms list: $e');
    }

    // معالجة pagination
    Map<String, dynamic> pagination = {};
    try {
      if (json['pagination'] is Map) {
        pagination = (json['pagination'] as Map).cast<String, dynamic>();
      }
    } catch (e) {
      print('❌ Error parsing pagination: $e');
    }

    return ArchivedChatsResponseModel(
      chatRooms: chatRoomsList,
      currentPage: (pagination['currentPage'] as num?)?.toInt() ?? 1,
      totalPages: (pagination['totalPages'] as num?)?.toInt() ?? 1,
      totalCount: (pagination['totalCount'] as num?)?.toInt() ?? 0,
      hasMore:
          ((pagination['currentPage'] as num?)?.toInt() ?? 1) <
          ((pagination['totalPages'] as num?)?.toInt() ?? 1),
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

// ============================================
// 📌 POST MODEL (Placeholder - اضف الموديل الخاص بالمنشورات)
// ============================================

class ArchivePostModel extends Equatable {
  final String id;
  final String title;
  final String? image;
  final String createdAt;
  final int likes;
  final int comments;

  const ArchivePostModel({
    required this.id,
    required this.title,
    this.image,
    required this.createdAt,
    required this.likes,
    required this.comments,
  });

  factory ArchivePostModel.fromJson(Map<String, dynamic> json) {
    return ArchivePostModel(
      id: json['id'] as String,
      title: json['title'] as String,
      image: json['image'] as String?,
      createdAt: json['createdAt'] as String,
      likes: json['likes'] as int,
      comments: json['comments'] as int,
    );
  }

  @override
  List<Object?> get props => [id, title, image, createdAt, likes, comments];
}

// ============================================
// 📌 STORY MODEL (Placeholder - اضف الموديل الخاص بالقصص)
// ============================================
class ArchiveStoryModel extends Equatable {
  final String id;
  final String? image;
  final String createdAt;
  final int views;

  const ArchiveStoryModel({
    required this.id,
    this.image,
    required this.createdAt,
    required this.views,
  });

  factory ArchiveStoryModel.fromJson(Map<String, dynamic> json) {
    return ArchiveStoryModel(
      id: json['id'] as String,
      image: json['image'] as String?,
      createdAt: json['createdAt'] as String,
      views: json['views'] as int,
    );
  }

  @override
  List<Object?> get props => [id, image, createdAt, views];
}
