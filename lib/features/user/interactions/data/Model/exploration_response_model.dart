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
    final data = json['data'] as Map<String, dynamic>? ?? {}; // ✅ Get data object
    final usersData = data['users'] as Map<String, dynamic>? ?? {};
    
    final Map<String, CategoryData> categoriesMap = {};
    
    // Map API keys to display names
    const categoryMapping = {
      'favoritedMe': 'من ضمن اختياراتك',
      'likesFromOutsideChoices': 'من خارج اختياراتك',
      'wantToInteract': 'يرغبون في التفاعل معك',
      "visitedMe": 'الزيارات المحفزة',
      'recentlyJoined': 'منضم حديثاً',
      'sentRegards': 'ارسل تحية',
    };

    categoryMapping.forEach((apiKey, displayName) {
      if (usersData.containsKey(apiKey)) {
        categoriesMap[displayName] = CategoryData.fromJson(usersData[apiKey]);
      }
    });

    return ExplorationResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      answerCompleted: data['answerCompleted'] ?? false, // ✅ NEW
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