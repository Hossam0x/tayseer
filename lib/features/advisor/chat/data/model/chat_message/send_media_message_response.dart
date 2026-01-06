import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';

class SendMessageResponse {
  final bool success;
  final String message;
  final SentMessage data;

  SendMessageResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SendMessageResponse.fromJson(Map<String, dynamic> json) {
    return SendMessageResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: SentMessage.fromJson(json['data'] ?? {}),
    );
  }
}

class SentMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final bool isRead;
  final String? senderImage;
  final String senderType;
  final bool isMe;
  final List<String> contentList;
  final String messageType;
  final String createdAt;
  final String updatedAt;
  final ReplyInfo? reply; // ✅ إضافة معلومات الرد

  // getter للتوافق مع الكود القديم
  String get content => contentList.isNotEmpty ? contentList.first : '';

  SentMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.isRead,
    required this.senderImage,
    required this.senderType,
    required this.isMe,
    required this.contentList,
    required this.messageType,
    required this.createdAt,
    required this.updatedAt,
    this.reply,
  });

  factory SentMessage.fromJson(Map<String, dynamic> json) {
    // دالة مساعدة لاستخراج المحتوى كقائمة
    List<String> parseContentList(dynamic contentData) {
      if (contentData == null) return [];
      if (contentData is List) {
        return contentData.map((e) => e.toString()).toList();
      }
      return [contentData.toString()];
    }

    return SentMessage(
      id: json['id']?.toString() ?? '',
      chatRoomId: json['chatRoomId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      isRead: json['isRead'] ?? false,
      senderImage: json['senderImage']?.toString(),
      senderType: json['senderType']?.toString() ?? '',
      isMe: json['isMe'] ?? false,
      contentList: parseContentList(json['content']),
      messageType: json['messageType']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      reply: ReplyInfo.fromJson(json['reply']), // ✅ parse الـ reply
    );
  }
}
