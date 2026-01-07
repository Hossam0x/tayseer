import 'package:tayseer/core/enum/message_status_enum.dart';

class ChatMessagesResponse {
  final bool success;
  final String message;
  final ChatMessagesData data;

  ChatMessagesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ChatMessagesResponse.fromJson(Map<String, dynamic> json) {
    return ChatMessagesResponse(
      success: json['success'],
      message: json['message'],
      data: ChatMessagesData.fromJson(json['data']),
    );
  }
}

class ChatMessagesData {
  final List<ChatMessage> messages;
  final MessagePagination pagination;

  ChatMessagesData({required this.messages, required this.pagination});

  factory ChatMessagesData.fromJson(Map<String, dynamic> json) {
    return ChatMessagesData(
      messages: (json['messages'] as List)
          .map((e) => ChatMessage.fromJson(e))
          .toList(),
      pagination: MessagePagination.fromJson(json['pagination']),
    );
  }
}

/// Reply model for message replies
class ReplyInfo {
  final String? replyMessageId;
  final String? replyMessage;
  final bool isReply;

  ReplyInfo({this.replyMessageId, this.replyMessage, this.isReply = false});

  factory ReplyInfo.fromJson(dynamic jsonData) {
    // ✅ Handle null
    if (jsonData == null) return ReplyInfo(isReply: false);

    // ✅ Handle if it's not a Map
    if (jsonData is! Map<String, dynamic>) {
      print('⚠️ ReplyInfo: Unexpected type: ${jsonData.runtimeType}');
      return ReplyInfo(isReply: false);
    }

    final json = jsonData;

    // ✅ معالجة replyMessage سواء كان String أو List
    String? parseReplyMessage(dynamic data) {
      if (data == null) return null;
      if (data is List) {
        if (data.isEmpty) return null;
        final firstItem = data.first.toString();
        return firstItem.isNotEmpty ? firstItem : null;
      }
      final strValue = data.toString();
      return strValue.isNotEmpty ? strValue : null;
    }

    final replyMessageId = json['replyMessageId']?.toString();
    final replyMessage = parseReplyMessage(json['replyMessage']);
    final isReply = json['isReply'] ?? false;

    // ✅ Debug log
    if (isReply == true) {
      print(
        '✅ ReplyInfo parsed: isReply=$isReply, replyMessageId=$replyMessageId, replyMessage=$replyMessage',
      );
    }

    return ReplyInfo(
      replyMessageId: replyMessageId,
      replyMessage: replyMessage,
      isReply: isReply,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'replyMessageId': replyMessageId,
      'replyMessage': replyMessage,
      'isReply': isReply,
    };
  }
}

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String senderType;
  final bool isMe;
  final List<String> contentList;
  final String messageType;
  final String createdAt;
  final String updatedAt;
  bool isRead;
  final MessageStatusEnum status; // ✅ New field
  final ReplyInfo? reply;

  String get content => contentList.isNotEmpty ? contentList.first : '';

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.senderType,
    required this.isMe,
    required this.contentList,
    required this.messageType,
    required this.createdAt,
    required this.updatedAt,
    this.isRead = true,
    this.status = MessageStatusEnum.sent, // ✅ Default value
    this.reply,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    List<String> parseContentList(dynamic contentData) {
      if (contentData == null) return [];
      if (contentData is List) {
        return contentData.map((e) => e.toString()).toList();
      }
      return [contentData.toString()];
    }

    return ChatMessage(
      id: json['id']?.toString() ?? "",
      chatRoomId: json['chatRoomId']?.toString() ?? "",
      senderId: json['senderId']?.toString() ?? "",
      senderName: json['senderName']?.toString() ?? "",
      senderImage: json['senderImage']?.toString() ?? "",
      senderType: json['senderType']?.toString() ?? "",
      isMe: json['isMe'] ?? false,
      contentList: parseContentList(json['content']),
      messageType: json['messageType']?.toString() ?? "text",
      createdAt: json['createdAt']?.toString() ?? "",
      updatedAt: json['updatedAt']?.toString() ?? "",
      isRead: json['isRead'] ?? true,
      status: MessageStatusExtension.fromString(
        json['status']?.toString(),
      ), // ✅ Parse status
      reply: ReplyInfo.fromJson(json['reply']),
    );
  }

  // ✅ أضف هذا الـ copyWith
  ChatMessage copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? senderImage,
    String? senderType,
    bool? isMe,
    List<String>? contentList,
    String? messageType,
    String? createdAt,
    String? updatedAt,
    bool? isRead,
    MessageStatusEnum? status, // ✅ Add status
    ReplyInfo? reply,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      senderType: senderType ?? this.senderType,
      isMe: isMe ?? this.isMe,
      contentList: contentList ?? this.contentList,
      messageType: messageType ?? this.messageType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
      status: status ?? this.status, // ✅ Copy status
      reply: reply ?? this.reply,
    );
  }
}

class MessagePagination {
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  MessagePagination({
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory MessagePagination.fromJson(Map<String, dynamic> json) {
    return MessagePagination(
      totalCount: json['totalCount'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      pageSize: json['pageSize'],
    );
  }
}
