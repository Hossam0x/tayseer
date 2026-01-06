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
    return UserStoriesModel(
      userId: json['userId'],
      name: json['name'],
      image: json['image'],
      isFollowed: json['isFollowed'],
      isViewedByMe: json['isViewedByMe'],
      allViewed: json['allViewed'],
      storiesCount: json['storiesCount'],
      stories: List<StoryModel>.from(
        json['stories'].map((x) => StoryModel.fromJson(x)),
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
  final String image;
  final bool isMine;
  final bool isSpecial;
  final int viewsCount;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StoryModel({
    required this.id,
    required this.image,
    required this.isMine,
    required this.isSpecial,
    required this.viewsCount,
    required this.likesCount,
    required this.isLiked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'],
      image:
          json['image'] ??
          "https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=600&q=80",
      isMine: json['isMine'] ?? false,
      isSpecial: json['isSpecial'] ?? false,
      viewsCount: json['viewsCount'] ?? 0,
      likesCount: json['likesCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  StoryModel copyWith({
    String? id,
    String? image,
    bool? isMine,
    bool? isSpecial,
    int? viewsCount,
    int? likesCount,
    bool? isLiked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoryModel(
      id: id ?? this.id,
      image: image ?? this.image,
      isMine: isMine ?? this.isMine,
      isSpecial: isSpecial ?? this.isSpecial,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    image,
    isMine,
    isSpecial,
    viewsCount,
    likesCount,
    isLiked,
    createdAt,
    updatedAt,
  ];
}

class StoryUserModel {
  final String id;
  final String name;
  final String image;

  StoryUserModel({required this.id, required this.name, required this.image});

  factory StoryUserModel.fromJson(Map<String, dynamic> json) {
    return StoryUserModel(
      id: json['_id'],
      name: json['name'],
      image: json['image'],
    );
  }
}
