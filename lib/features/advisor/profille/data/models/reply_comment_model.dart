import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/home/model/comment_model.dart';

class ReplyModel extends Equatable {
  final String id;
  final String comment;
  final int likes;
  final String timeAgo;
  final String createdAt;
  final bool isLiked;
  final bool isOwner;
  final bool isFollowing;
  final CommenterModel commenter;

  const ReplyModel({
    required this.id,
    required this.comment,
    required this.likes,
    required this.timeAgo,
    required this.createdAt,
    required this.isLiked,
    required this.isOwner,
    required this.isFollowing,
    required this.commenter,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      id: json['id'] as String,
      comment: json['comment'] as String,
      likes: json['likes'] as int,
      timeAgo: json['timeAgo'] as String,
      createdAt: json['createdAt'] as String,
      isLiked: json['isLiked'] as bool,
      isOwner: json['isOwner'] as bool,
      isFollowing: json['isFollowing'] as bool,
      commenter: CommenterModel.fromJson(
        Map<String, dynamic>.from(json['commenter']),
      ),
    );
  }

  @override
  List<Object?> get props => [
    id,
    comment,
    likes,
    timeAgo,
    createdAt,
    isLiked,
    isOwner,
    isFollowing,
    commenter,
  ];
}

class RepliesResponseModel extends Equatable {
  final List<ReplyModel> replies;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;

  const RepliesResponseModel({
    required this.replies,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasMore,
  });

  factory RepliesResponseModel.fromJson(Map<String, dynamic> json) {
    final repliesList = (json['replies'] as List)
        .map((reply) => ReplyModel.fromJson(Map<String, dynamic>.from(reply)))
        .toList();

    final pagination = Map<String, dynamic>.from(json['pagination']);

    return RepliesResponseModel(
      replies: repliesList,
      currentPage: pagination['currentPage'] as int,
      totalPages: pagination['totalPages'] as int,
      totalCount: pagination['totalCount'] as int,
      hasMore: pagination['currentPage'] < pagination['totalPages'],
    );
  }

  @override
  List<Object?> get props => [
    replies,
    currentPage,
    totalPages,
    totalCount,
    hasMore,
  ];
}
