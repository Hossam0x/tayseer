import '../enum/notification_type_enum.dart';

class NotificationsModel {
  NotificationsModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool? success;
  final String? message;
  final NotificationsModelData? data;

  factory NotificationsModel.fromJson(Map<String, dynamic> json) {
    return NotificationsModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null
          ? null
          : NotificationsModelData.fromJson(json["data"]),
    );
  }
}
class NotificationsModelData {
  NotificationsModelData({
    required this.notifications,
    required this.pagination,
  });

  final List<NotificationModel> notifications;
  final PaginationModel? pagination;

  factory NotificationsModelData.fromJson(Map<String, dynamic> json) {
    return NotificationsModelData(
      notifications: json["notifications"] == null
          ? []
          : List<NotificationModel>.from(
              json["notifications"].map((x) => NotificationModel.fromJson(x)),
            ),
      pagination: json["pagination"] == null
          ? null
          : PaginationModel.fromJson(json["pagination"]),
    );
  }
}

class NotificationModel {
  NotificationModel({
    required this.id,
    required this.type,
    this.key,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.isRead,
    required this.likeType,
    required this.senderImage,
    required this.data,
  });

  final String? id;
  final NotificationType type;
  final String? key;
  final String? likeType;
  final String? title;
  final String? description;
  final DateTime? dateTime;
  final bool? isRead;
  final String? senderImage;
  final NotificationData? data;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["id"],
      type:NotificationType.fromType(json["type"]),
      key: json["key"],
      likeType:json["likeType"],
      title: json["title"],
      description: json["description"],
      dateTime: DateTime.tryParse(json["dateTime"] ?? ""),
      isRead: json["isRead"],
      senderImage: json["senderImage"],
      data: json["data"] == null
          ? null
          : NotificationData.fromJson(json["data"]),
    );
  }
}

class NotificationData {
  NotificationData({
    required this.postId,
    required this.storyId,
    required this.commentId,
    required this.replyId,
    required this.chatId,
    required this.eventId,
    required this.senderId,
  });

  final String? postId;
  final String? storyId;
  final String? commentId;
  final String? replyId;
  final String? chatId;
  final String? eventId;
  final String? senderId;

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      postId: json["postId"],
      storyId: json["storyId"],
      commentId: json["commentId"]?.toString(),
      replyId: json["replyId"]?.toString(),
      chatId: json["chatId"]?.toString(),
      eventId: json["eventId"]?.toString(),
      senderId: json["senderId"],
    );
  }
}

class PaginationModel {
  PaginationModel({
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  final int? totalCount;
  final int? totalPages;
  final int? currentPage;
  final int? pageSize;

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      totalCount: _parseInt(json["totalCount"]),
      totalPages: _parseInt(json["totalPages"]),
      currentPage: _parseInt(json["currentPage"]),
      pageSize: _parseInt(json["pageSize"]),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
