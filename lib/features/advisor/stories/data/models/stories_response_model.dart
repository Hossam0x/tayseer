import 'package:equatable/equatable.dart';
import 'package:tayseer/core/models/pagination_model.dart';

class StoriesResponseModel {
  final bool success;
  final String message;
  final StoriesDataModel data;

  StoriesResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StoriesResponseModel.fromJson(Map<String, dynamic> json) {
    return StoriesResponseModel(
      success: json['success'],
      message: json['message'],
      data: StoriesDataModel.fromJson(json['data']),
    );
  }
}

class StoriesDataModel {
  final List<UserStoriesModel> result;
  final PaginationModel pagination;

  StoriesDataModel({required this.result, required this.pagination});

  factory StoriesDataModel.fromJson(Map<String, dynamic> json) {
    return StoriesDataModel(
      result: List<UserStoriesModel>.from(
        json['result'].map((x) => UserStoriesModel.fromJson(x)),
      ),
      pagination: PaginationModel.fromJson(json['pagination']),
    );
  }
}

class UserStoriesModel extends Equatable {
  final String userId;
  final String name;
  final String image;
  final bool isFollowed;
  final bool isViewedByMe;
  final bool allViewed;
  final int storiesCount;
  final List<StoryModel> stories;

  const UserStoriesModel({
    required this.userId,
    required this.name,
    required this.image,
    required this.isFollowed,
    required this.isViewedByMe,
    required this.allViewed,
    required this.storiesCount,
    required this.stories,
  });

  factory UserStoriesModel.fromJson(Map<String, dynamic> json) {
    String userIdStr = "";
    if (json['userId'] is String) {
      userIdStr = json['userId'];
    } else if (json['userId'] is Map) {
      userIdStr = json['userId']['_id'] ?? "";
    }

    return UserStoriesModel(
      userId: userIdStr,
      name: json['name'] ?? "",
      image: json['image'] ?? "",
      isFollowed: json['isFollowed'] ?? false,
      isViewedByMe: json['isViewedByMe'] ?? false,
      allViewed: json['allViewed'] ?? false,
      storiesCount: json['storiesCount'] ?? 0,
      stories: List<StoryModel>.from(
        (json['stories'] as List? ?? []).map(
          (x) => StoryModel.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  UserStoriesModel copyWith({
    String? userId,
    String? name,
    String? image,
    bool? isFollowed,
    bool? isViewedByMe,
    bool? allViewed,
    int? storiesCount,
    List<StoryModel>? stories,
  }) {
    return UserStoriesModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      image: image ?? this.image,
      isFollowed: isFollowed ?? this.isFollowed,
      isViewedByMe: isViewedByMe ?? this.isViewedByMe,
      allViewed: allViewed ?? this.allViewed,
      storiesCount: storiesCount ?? this.storiesCount,
      stories: stories ?? this.stories,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    name,
    image,
    isFollowed,
    isViewedByMe,
    allViewed,
    storiesCount,
    stories,
  ];
}

class StoryModel extends Equatable {
  final String id;
  final String userId;
  final String image;
  final String? video;
  final bool isMine;
  final bool isSpecial;
  final int viewsCount;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime updatedAt;

  final double? videoDuration;
  final List<StoryUserModel>? likedBy;

  const StoryModel({
    required this.id,
    required this.userId,
    required this.image,
    this.video,
    this.videoDuration,
    required this.isMine,
    required this.isSpecial,
    required this.viewsCount,
    required this.likesCount,
    required this.isLiked,
    this.likedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    String userIdStr = "";
    if (json['userId'] is String) {
      userIdStr = json['userId'];
    } else if (json['userId'] is Map) {
      userIdStr = json['userId']['_id'] ?? "";
    }

    // Try multiple ID fields because the backend might be inconsistent
    final storyId = json['id']?.toString() ?? json['_id']?.toString() ?? "";

    // Check for viewed status from multiple possible fields
    int viewsCount = 0;
    if (json['viewsCount'] != null) {
      viewsCount = json['viewsCount'];
    } else if (json['isViewedByMe'] == true) {
      viewsCount = 1;
    } else if (json['isViewed'] == true) {
      viewsCount = 1;
    }

    return StoryModel(
      id: storyId,
      userId: userIdStr,
      image:
          json['image']?.toString() ??
          "https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=600&q=80",
      video: json['video']?.toString(),
      videoDuration: (json['videoDuration'] as num?)?.toDouble(),
      isMine: json['isMine'] ?? false,
      isSpecial: json['isSpecial'] ?? false,
      viewsCount: viewsCount,
      likesCount: json['likesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      likedBy: json['likedBy'] != null
          ? List<StoryUserModel>.from(
              json['likedBy'].map((x) => StoryUserModel.fromJson(x)),
            )
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  bool get isViewed => viewsCount > 0;

  StoryModel copyWith({
    String? id,
    String? userId,
    String? image,
    String? video,
    double? videoDuration,
    bool? isMine,
    bool? isSpecial,
    int? viewsCount,
    int? likesCount,
    bool? isLiked,
    List<StoryUserModel>? likedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      image: image ?? this.image,
      video: video ?? this.video,
      videoDuration: videoDuration ?? this.videoDuration,
      isMine: isMine ?? this.isMine,
      isSpecial: isSpecial ?? this.isSpecial,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    image,
    video,
    videoDuration,
    isMine,
    isSpecial,
    viewsCount,
    likesCount,
    isLiked,
    likedBy,
    createdAt,
    updatedAt,
  ];
}

class StoryUserModel {
  final String id;
  final String name;
  final String image;
  final String userType; // 'User' or 'Advisor'

  StoryUserModel({
    required this.id,
    required this.name,
    required this.image,
    required this.userType,
  });

  factory StoryUserModel.fromJson(Map<String, dynamic> json) {
    return StoryUserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      userType: json['userType'] ?? 'User',
    );
  }
}
