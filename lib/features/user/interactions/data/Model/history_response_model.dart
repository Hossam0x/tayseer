import 'Iinteraction_usermodel .dart';

class HistoryResponseModel {
  final bool success;
  final String message;
  final bool userSubscription;
  final Map<String, HistoryDataSection> sections;

  HistoryResponseModel({
    required this.success,
    required this.message,
    required this.userSubscription,
    required this.sections,
  });

  factory HistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    return HistoryResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      userSubscription: data['userSubscription'] ?? false,
      sections: {
        'المفضلة': HistoryDataSection.fromJson(data['userIamFavorites'] ?? {}),
        'نال إعجابك': HistoryDataSection.fromJson(data['userIamLikes'] ?? {}),
        'صادفتهم': HistoryDataSection.fromJson(data['userIamEncounteredThem'] ?? {}),
        'أرسلت مجاملة': HistoryDataSection.fromJson(data['userIamRegards'] ?? {}),
        'اُعجب بك': HistoryDataSection.fromJson(data['userIamLiked'] ?? {}),
      },
    );
  }
}

class HistoryDataSection {
  final List<InteractionUserModel> users;
  final PaginationModel? pagination;

  HistoryDataSection({
    required this.users,
    this.pagination,
  });

  factory HistoryDataSection.fromJson(Map<String, dynamic> json) {
    // ✅ Safely parse pagination
    final paginationJson = json['pagination'] as Map<String, dynamic>?;
    PaginationModel? pagination;
    
    if (paginationJson != null && paginationJson.isNotEmpty) {
      try {
        pagination = PaginationModel.fromJson(paginationJson);
      } catch (e) {
        // If parsing fails, pagination remains null
        pagination = null;
      }
    }
    
    return HistoryDataSection(
      users: (json['data'] as List<dynamic>?)
              ?.map((e) => InteractionUserModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: pagination,
    );
  }
}
class PaginationModel {
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  PaginationModel({
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCount': totalCount,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'pageSize': pageSize,
    };
  }
}