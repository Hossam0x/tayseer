import 'interaction_usermodel .dart';

class HistoryResponseModel {
  final bool success;
  final String message;
  final String userSubscription; // 'free', 'gold', 'ultra'
  final Map<String, HistoryDataSection> sections;

  HistoryResponseModel({
    required this.success,
    required this.message,
    required this.userSubscription,
    required this.sections,
  });

  bool get isSubscribed => userSubscription != 'free';

  factory HistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    // يقبل bool (legacy) أو String (new)
    final rawSub = data['userSubscription'];
    final String subscriptionType;
    if (rawSub is bool) {
      subscriptionType = rawSub ? 'gold' : 'free';
    } else {
      subscriptionType = (rawSub as String?)?.toLowerCase() ?? 'free';
    }

    return HistoryResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      userSubscription: subscriptionType,
      sections: {
        'favorites': HistoryDataSection.fromJson(data['userIamFavorites'] ?? {}),
        'liked_you': HistoryDataSection.fromJson(data['userIamLikes'] ?? {}),
        'met_them': HistoryDataSection.fromJson(data['userIamEncounteredThem'] ?? {}),
        'sent_compliment': HistoryDataSection.fromJson(data['userIamRegards'] ?? {}),
        'liked_me': HistoryDataSection.fromJson(data['userIamLiked'] ?? {}),
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
class NotificationCountModel {
  final int likes;
  final int favorites;
  final int regards;
  final int total;

  NotificationCountModel({
    required this.likes,
    required this.favorites,
    required this.regards,
    required this.total,
  });

  factory NotificationCountModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return NotificationCountModel(
      likes: (data['likes'] as num?)?.toInt() ?? 0,
      favorites: (data['favorites'] as num?)?.toInt() ?? 0,
      regards: (data['regards'] as num?)?.toInt() ?? 0,
      total: (data['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class PastMatchItem {
  final String chatRoomId;
  final String userId;
  final String name;
  final String image;
  final DateTime? expiredAt;

  PastMatchItem({
    required this.chatRoomId,
    required this.userId,
    required this.name,
    required this.image,
    this.expiredAt,
  });

  /// Human-readable reason derived from expiredAt
  String get reason => 'انتهي مدة التوافق بينكم';

  factory PastMatchItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return PastMatchItem(
      chatRoomId: json['chatRoomId']?.toString() ?? '',
      userId: user['id']?.toString() ?? '',
      name: user['name']?.toString() ?? '',
      image: user['image']?.toString() ?? '',
      expiredAt: json['expiredAt'] != null
          ? DateTime.tryParse(json['expiredAt'].toString())
          : null,
    );
  }
}

class PastMatchesResponse {
  final List<PastMatchItem> items;
  final PaginationModel pagination;

  PastMatchesResponse({required this.items, required this.pagination});

  factory PastMatchesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final list = data['data'] as List<dynamic>? ?? [];
    return PastMatchesResponse(
      items: list.map((e) => PastMatchItem.fromJson(e as Map<String, dynamic>)).toList(),
      pagination: PaginationModel.fromJson(
        data['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
