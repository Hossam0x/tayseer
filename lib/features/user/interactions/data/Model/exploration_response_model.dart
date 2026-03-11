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
    required this.answerCompleted,
    required this.categories,
  });

  factory ExplorationResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    const categoryMapping = {
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

    if (usersMap.containsKey('recentlyJoined')) {
      categoriesMap['منضم حديثاً'] =
          CategoryData.fromJson(usersMap['recentlyJoined']);
    }

    if (usersMap.containsKey('sentRegards')) {
      categoriesMap['ارسل تحية'] =
          CategoryData.fromJson(usersMap['sentRegards']);
    }

    return ExplorationResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      answerCompleted: data['answerCompleted'] ?? true,
      categories: categoriesMap,
    );
  }

  // ✅ Merge /recently-joined-users → "منضم حديثاً"
  ExplorationResponseModel withRecentlyJoined(
      Map<String, dynamic> recentlyJoinedJson) {
    final updatedCategories = Map<String, CategoryData>.from(categories);
    final data = recentlyJoinedJson['data'] as Map<String, dynamic>? ?? {};
    updatedCategories['منضم حديثاً'] = CategoryData.fromFlatJson(data);
    return ExplorationResponseModel(
      success: success,
      message: message,
      answerCompleted: answerCompleted,
      categories: updatedCategories,
    );
  }

  // ✅ Merge /users-liked-me → "الإعجابات"
  ExplorationResponseModel withLikedMe(Map<String, dynamic> likedMeJson) {
    final updatedCategories = Map<String, CategoryData>.from(categories);
    final data = likedMeJson['data'] as Map<String, dynamic>? ?? {};
    updatedCategories['الإعجابات'] = CategoryData.fromFlatJson(data);
    return ExplorationResponseModel(
      success: success,
      message: message,
      answerCompleted: answerCompleted,
      categories: updatedCategories,
    );
  }

  // ✅ Merge /users-to-send-regards-to → "ارسل تحية"
  ExplorationResponseModel withSendRegards(Map<String, dynamic> sendRegardsJson) {
    final updatedCategories = Map<String, CategoryData>.from(categories);
    final data = sendRegardsJson['data'] as Map<String, dynamic>? ?? {};
    updatedCategories['ارسل تحية'] = CategoryData.fromFlatJson(data);
    return ExplorationResponseModel(
      success: success,
      message: message,
      answerCompleted: answerCompleted,
      categories: updatedCategories,
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

  // For nested categories inside /discovered-users
  // Shape: { data: [...], pagination: {} }
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

  // For flat endpoints: /recently-joined-users, /users-liked-me, /users-to-send-regards-to
  // Shape: { users: [...], pagination: {} }
  factory CategoryData.fromFlatJson(Map<String, dynamic> json) {
    return CategoryData(
      users: (json['users'] as List<dynamic>?)
              ?.map((e) => InteractionUserModel.fromJson(e))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}