import 'package:equatable/equatable.dart';
import 'package:tayseer/core/models/post_model.dart';

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
// في features/advisor/profille/data/models/archive_models.dart

// ============================================
// 📌 ARCHIVE POST MODEL (محدث)
// ============================================
class ArchivePostModel extends Equatable {
  final String id;
  final String userName;
  final String? userImage;
  final String? advisorId;
  final String? content;
  final List<String>? images;
  final String? video;
  final PostContentType? contentType;
  final int? commentsCount;
  final int? sharesCount;
  final int? likesCount;
  final String? category;
  final String createdAt;
  final ReactionType? myReaction;
  final bool? isRepostedByMe;

  const ArchivePostModel({
    required this.id,
    required this.userName,
    this.userImage,
    this.advisorId,
    this.content,
    this.images,
    this.video,
    this.contentType,
    this.commentsCount,
    this.sharesCount,
    this.likesCount,
    this.category,
    required this.createdAt,
    this.myReaction,
    this.isRepostedByMe,
  });

  factory ArchivePostModel.fromJson(Map<String, dynamic> json) {
    print('📌 Parsing ArchivePostModel: $json');

    try {
      // Parse images list
      List<String>? imagesList;
      if (json['images'] is List) {
        imagesList = (json['images'] as List).whereType<String>().toList();
      }

      // Parse content type
      PostContentType? parsedContentType;
      if (json['contentType'] != null) {
        switch (json['contentType'].toString().toLowerCase()) {
          case 'video':
            parsedContentType = PostContentType.video;
            break;
          case 'reel':
            parsedContentType = PostContentType.reel;
            break;
          case 'post':
          default:
            parsedContentType = PostContentType.post;
        }
      }

      // Parse myReaction
      ReactionType? parsedReaction;
      if (json['myReaction'] != null) {
        switch (json['myReaction'].toString().toLowerCase()) {
          case 'love':
            parsedReaction = ReactionType.love;
            break;
          case 'care':
            parsedReaction = ReactionType.care;
            break;
          case 'dislike':
            parsedReaction = ReactionType.dislike;
            break;
        }
      }

      return ArchivePostModel(
        id: json['id']?.toString() ?? '',
        userName: json['userName']?.toString() ?? 'مستخدم',
        userImage: json['userImage']?.toString(),
        advisorId: json['advisorId']?.toString(),
        content: json['content']?.toString(),
        images: imagesList,
        video: json['video']?.toString(),
        contentType: parsedContentType,
        commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
        sharesCount: (json['sharesCount'] as num?)?.toInt() ?? 0,
        likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
        category: json['category']?.toString(),
        createdAt:
            json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
        myReaction: parsedReaction,
        isRepostedByMe: json['isRepostedByMe'] as bool? ?? false,
      );
    } catch (e) {
      print('❌ Error parsing ArchivePostModel: $e');
      print('❌ Problematic JSON: $json');
      rethrow;
    }
  }

  // Convert to PostModel for use with PostCard
  PostModel toPostModel() {
    return PostModel(
      postId: id,
      name: userName.split(' ').first,
      userName: userName,
      advisorId: advisorId ?? '',
      isFollowing:
          false, // Default - يمكن تعديله إذا كان الـ API يوفر هذه المعلومة
      avatar: userImage ?? '',
      isVerified:
          false, // Default - يمكن تعديله إذا كان الـ API يوفر هذه المعلومة
      category: category ?? 'عام',
      timeAgo: _formatTimeAgo(createdAt),
      content: content ?? '',
      images: images ?? [],
      contentType: contentType ?? PostContentType.post,
      videoUrl: video,
      commentsCount: commentsCount ?? 0,
      sharesCount: sharesCount ?? 0,
      likesCount: likesCount ?? 0,
      topReactions: [], // يمكن تعديله إذا كان الـ API يوفر هذه المعلومة
      myReaction: myReaction,
      isRepostedByMe: isRepostedByMe ?? false,
      isSaved: true, // المنشورات المؤرشفة تكون محفوظة تلقائياً
    );
  }

  // Copy with method for updates
  ArchivePostModel copyWith({
    int? likesCount,
    ReactionType? myReaction,
    int? sharesCount,
    bool? isRepostedByMe,
  }) {
    return ArchivePostModel(
      id: id,
      userName: userName,
      userImage: userImage,
      advisorId: advisorId,
      content: content,
      images: images,
      video: video,
      contentType: contentType,
      commentsCount: commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      likesCount: likesCount ?? this.likesCount,
      category: category,
      createdAt: createdAt,
      myReaction: myReaction ?? this.myReaction,
      isRepostedByMe: isRepostedByMe ?? this.isRepostedByMe,
    );
  }

  // Helper method to format time ago
  String _formatTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      final now = DateTime.now().toLocal();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'الآن';
      } else if (difference.inMinutes < 60) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else if (difference.inHours < 24) {
        return 'منذ ${difference.inHours} ساعة';
      } else if (difference.inDays < 30) {
        return 'منذ ${difference.inDays} يوم';
      } else if (difference.inDays < 365) {
        return 'منذ ${(difference.inDays / 30).floor()} شهر';
      } else {
        return 'منذ ${(difference.inDays / 365).floor()} سنة';
      }
    } catch (e) {
      return 'منذ فترة';
    }
  }

  @override
  List<Object?> get props => [
    id,
    userName,
    userImage,
    advisorId,
    content,
    images,
    video,
    contentType,
    commentsCount,
    sharesCount,
    likesCount,
    category,
    createdAt,
    myReaction,
    isRepostedByMe,
  ];
}

// ============================================
// 📌 ARCHIVED POSTS RESPONSE
// ============================================
class ArchivedPostsResponseModel extends Equatable {
  final List<ArchivePostModel> posts;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;

  const ArchivedPostsResponseModel({
    required this.posts,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasMore,
  });

  factory ArchivedPostsResponseModel.fromJson(Map<String, dynamic> json) {
    print('📦 Parsing ArchivedPostsResponseModel');

    // معالجة posts
    List<ArchivePostModel> postsList = [];
    try {
      if (json['posts'] is List) {
        postsList = (json['posts'] as List).map((post) {
          try {
            return ArchivePostModel.fromJson(
              post is Map<String, dynamic>
                  ? post
                  : (post as Map).cast<String, dynamic>(),
            );
          } catch (e) {
            print('❌ Error parsing individual post: $e');
            print('❌ Post data: $post');
            return ArchivePostModel(
              id: '',
              userName: 'مستخدم',
              createdAt: DateTime.now().toIso8601String(),
            );
          }
        }).toList();
      }
    } catch (e) {
      print('❌ Error parsing posts list: $e');
    }

    // معالجة pagination
    Map<String, dynamic> pagination = {};
    try {
      if (json['pagination'] is Map) {
        pagination = (json['pagination'] as Map).cast<String, dynamic>();
      } else if (json['data'] != null && json['data']['pagination'] is Map) {
        // محاولة بديلة إذا كان الـ pagination داخل data
        pagination = (json['data']['pagination'] as Map)
            .cast<String, dynamic>();
      }
    } catch (e) {
      print('❌ Error parsing pagination: $e');
    }

    return ArchivedPostsResponseModel(
      posts: postsList,
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
    posts,
    currentPage,
    totalPages,
    totalCount,
    hasMore,
  ];
}

// ============================================
// 📌 STORY MODEL (Placeholder - اضف الموديل الخاص بالقصص)
// ============================================
class ArchiveStoryModel extends Equatable {
  final String id;
  final String userId;
  final bool isMine;
  final String? image;
  final String? video;
  final double videoDuration;
  final String? content;
  final bool isSaved;
  final bool isSpecial;
  final String mediaType; // 'image' أو 'video'
  final bool isLiked;
  final String createdAt;
  final String updatedAt;
  final List<String> likedBy;

  const ArchiveStoryModel({
    required this.id,
    required this.userId,
    required this.isMine,
    this.image,
    this.video,
    this.videoDuration = 0,
    this.content,
    required this.isSaved,
    required this.isSpecial,
    required this.mediaType,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
    required this.likedBy,
  });

  factory ArchiveStoryModel.fromJson(Map<String, dynamic> json) {
    print('📌 Parsing story: $json');

    try {
      return ArchiveStoryModel(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        isMine: json['isMine'] as bool? ?? false,
        image: json['image']?.toString(),
        video: json['video']?.toString(),
        videoDuration: (json['videoDuration'] as num?)?.toDouble() ?? 0,
        content: json['content']?.toString(),
        isSaved: json['isSaved'] as bool? ?? false,
        isSpecial: json['isSpecial'] as bool? ?? false,
        mediaType: json['mediaType']?.toString() ?? 'image',
        isLiked: json['isLiked'] as bool? ?? false,
        createdAt: json['createdAt']?.toString() ?? '',
        updatedAt: json['updatedAt']?.toString() ?? '',
        likedBy:
            (json['likedBy'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
    } catch (e) {
      print('❌ Error parsing ArchiveStoryModel: $e');
      print('❌ Problematic JSON: $json');
      rethrow;
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    isMine,
    image,
    video,
    videoDuration,
    content,
    isSaved,
    isSpecial,
    mediaType,
    isLiked,
    createdAt,
    updatedAt,
    likedBy,
  ];
}
