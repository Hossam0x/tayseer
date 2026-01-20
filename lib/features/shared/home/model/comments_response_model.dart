
import 'package:tayseer/core/models/pagination_model.dart';
import 'package:tayseer/features/shared/home/model/comment_model.dart';

class CommentsResponseModel {
  final List<CommentModel> comments;
  final PaginationModel pagination; // افترضت وجود موديل للباجينشن

  CommentsResponseModel({
    required this.comments,
    required this.pagination,
  });

  factory CommentsResponseModel.fromJson(Map<String, dynamic> json) {
    // 1. الوصول لطبقة الداتا لو موجودة
    var data = json['data'] ?? json;

    // 2. البحث عن القائمة سواء كان اسمها comments أو replies
    List<dynamic> list = [];
    if (data['comments'] != null) {
      list = data['comments'];
    } else if (data['replies'] != null) {
      list = data['replies'];
    }

    return CommentsResponseModel(
      comments: list.map((e) => CommentModel.fromJson(e)).toList(),
      pagination: PaginationModel.fromJson(data['pagination'] ?? {}),
    );
  }
}