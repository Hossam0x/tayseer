import 'package:tayseer/core/models/pagination_model.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';

class PostsResponseModel {
  final bool success;
  final String message;
  final List<PostModel> posts;
  final PaginationModel pagination;

  PostsResponseModel({
    required this.success,
    required this.message,
    required this.posts,
    required this.pagination,
  });

  factory PostsResponseModel.fromJson(Map<String, dynamic> json) {
    return PostsResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      posts:
          (json['data']?['postsDto'] as List<dynamic>?)
              ?.map((e) => PostModel.fromJson(e))
              .toList() ??
          [],
      pagination: PaginationModel.fromJson(json['data']?['pagination'] ?? {}),
    );
  }
}
