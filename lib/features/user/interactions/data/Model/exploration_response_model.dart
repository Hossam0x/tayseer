import 'package:tayseer/core/models/pagination_model.dart';
import 'interaction_usermodel .dart';

class ExplorationResponseModel {
  final bool success;
  final String message;
  final bool answerCompleted; 
  final Map<String, CategoryData> categories;

  ExplorationResponseModel({
    required this.success,
    required this.message,
    required this.answerCompleted, // ✅ NEW
    required this.categories,
  });
factory ExplorationResponseModel.fromJson(Map<String, dynamic> json) {
  final data = json['data'] as Map<String, dynamic>? ?? {};
  
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

  final usersMap = data['users'] as Map<String, dynamic>? ?? {};
  
  // ✅ recentlyJoined
  if (usersMap.containsKey('recentlyJoined')) {
    categoriesMap['منضم حديثاً'] = CategoryData.fromJson(usersMap['recentlyJoined']);
  }
  
  // ✅ sentRegards - هنا كانت المشكلة
  if (usersMap.containsKey('sentRegards')) {
    categoriesMap['ارسل تحية'] = CategoryData.fromJson(usersMap['sentRegards']);
  }

  return ExplorationResponseModel(
    success: json['success'] ?? false,
    message: json['message'] ?? '',
    answerCompleted: data['answerCompleted'] ?? true,
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