import 'package:tayseer/core/models/pagination_model.dart';
import 'Iinteraction_usermodel .dart';

class ExplorationResponseModel {
  final bool success;
  final String message;
  final bool answerCompleted; // ✅ NEW
  final Map<String, CategoryData> categories;

  ExplorationResponseModel({
    required this.success,
    required this.message,
    required this.answerCompleted, // ✅ NEW
    required this.categories,
  });

factory ExplorationResponseModel.fromJson(Map<String, dynamic> json) {
  final data = json['data'] as Map<String, dynamic>? ?? {};
  
  // ✅ مفيش 'users' key - الـ categories موجودة directly في data
  const categoryMapping = {
    'userIamLikes': 'من ضمن اختياراتك',
    'userIamFavorites': 'من خارج اختياراتك',
    'userIamEncounteredThem': 'يرغبون في التفاعل معك',
    'userIamRegards': 'ارسل تحية',
    'userIamLiked': 'الزيارات المحفزة',
  };

  final Map<String, CategoryData> categoriesMap = {};
  
  categoryMapping.forEach((apiKey, displayName) {
    if (data.containsKey(apiKey)) {
      categoriesMap[displayName] = CategoryData.fromJson(data[apiKey]);
    }
  });

  return ExplorationResponseModel(
    success: json['success'] ?? false,
    message: json['message'] ?? '',
    answerCompleted: data['answerCompleted'] ?? false,
    categories: categoriesMap,
  );
}
}

class CategoryData {
  final List<InteractionUserModel> users;
  final PaginationModel? pagination;

  CategoryData({
    required this.users,
    this.pagination,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      users: (json['data'] as List<dynamic>?)
              ?.map((e) => InteractionUserModel.fromJson(e))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}