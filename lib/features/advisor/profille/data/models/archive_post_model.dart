import 'package:equatable/equatable.dart';
import 'package:tayseer/core/models/post_model.dart';

class ArchivePostModel extends Equatable {
  final String id;
  final String userName;
  final String? userImage;
  final String? advisorId;
  final String? content;
  final List<ImageModel>? images;
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
    List<String>? imagesList;
    if (json['images'] is List) {
      imagesList = (json['images'] as List).whereType<String>().toList();
    }

    PostContentType? parsedContentType;
    if (json['contentType'] != null) {
      switch (json['contentType'].toString().toLowerCase()) {
        case 'poll':
          parsedContentType = PostContentType.poll;
          break;
        case 'event':
          parsedContentType = PostContentType.event;
          break;
        case 'reel':
          parsedContentType = PostContentType.reel;
          break;
        default:
          parsedContentType = PostContentType.post;
      }
    }

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
      images: imagesList
          ?.map((_) => ImageModel(image: '', width: 0, height: 0))
          .toList(),
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
  }

  PostModel toPostModel() {
    return PostModel(
      postId: id,
      name: userName.split(' ').first,
      userName: userName,
      advisorId: advisorId ?? '',
      isFollowing: false,
      avatar: userImage ?? '',
      isVerified: false,
      category: category ?? 'عام',
      timeAgo: _formatTimeAgo(createdAt),
      content: content ?? '',
      images: images ?? [],
      contentType: contentType ?? PostContentType.post,
      videoUrl: video,
      commentsCount: commentsCount ?? 0,
      sharesCount: sharesCount ?? 0,
      likesCount: likesCount ?? 0,
      topReactions: [],
      myReaction: myReaction,
      isRepostedByMe: isRepostedByMe ?? false,
      isSaved: true,
      userType: 'Advisor',
    );
  }

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

  String _formatTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      final difference = DateTime.now().toLocal().difference(date);

      if (difference.inSeconds < 60) return 'الآن';
      if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} دقيقة';
      if (difference.inHours < 24) return 'منذ ${difference.inHours} ساعة';
      if (difference.inDays < 30) return 'منذ ${difference.inDays} يوم';
      if (difference.inDays < 365)
        return 'منذ ${(difference.inDays / 30).floor()} شهر';
      return 'منذ ${(difference.inDays / 365).floor()} سنة';
    } catch (_) {
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
          } catch (_) {
            return ArchivePostModel(
              id: '',
              userName: 'مستخدم',
              createdAt: DateTime.now().toIso8601String(),
            );
          }
        }).toList();
      }
    } catch (_) {}

    Map<String, dynamic> pagination = {};
    try {
      if (json['pagination'] is Map) {
        pagination = (json['pagination'] as Map).cast<String, dynamic>();
      } else if (json['data']?['pagination'] is Map) {
        pagination = (json['data']['pagination'] as Map)
            .cast<String, dynamic>();
      }
    } catch (_) {}

    final currentPage = (pagination['currentPage'] as num?)?.toInt() ?? 1;
    final totalPages = (pagination['totalPages'] as num?)?.toInt() ?? 1;

    return ArchivedPostsResponseModel(
      posts: postsList,
      currentPage: currentPage,
      totalPages: totalPages,
      totalCount: (pagination['totalCount'] as num?)?.toInt() ?? 0,
      hasMore: currentPage < totalPages,
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
