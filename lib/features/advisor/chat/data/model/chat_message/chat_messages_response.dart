import 'package:tayseer/core/enum/message_status_enum.dart';
import 'package:tayseer/core/services/socket_events/chat_socket_events.dart';
import 'package:tayseer/my_import.dart';

/// Response for GET /new-chat/messages/room-messages
class ChatMessagesResponse {
  final bool success;
  final List<ChatMessage> messages;
  final bool hasMore;

  ChatMessagesResponse({
    required this.success,
    required this.messages,
    required this.hasMore,
  });

  factory ChatMessagesResponse.fromJson(Map<String, dynamic> json) {
    return ChatMessagesResponse(
      success: json['success'] ?? false,
      messages:
          (json['data'] as List?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hasMore: json['hasMore'] ?? false,
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
    if (jsonData == null) return ReplyInfo(isReply: false);
    if (jsonData is! Map<String, dynamic>) return ReplyInfo(isReply: false);

    final json = jsonData;

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

    // New API returns the full message object in 'reply'
    return ReplyInfo(
      replyMessageId: (json['id'] ?? json['_id'] ?? json['replyMessageId'])
          ?.toString(),
      replyMessage: parseReplyMessage(json['content'] ?? json['replyMessage']),
      isReply: json['isReply'] ?? true,
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

/// System message action types for block/unblock
enum SystemMessageAction {
  block,
  unblock,
  none;

  static SystemMessageAction fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'block':
        return SystemMessageAction.block;
      case 'unblock':
        return SystemMessageAction.unblock;
      default:
        return SystemMessageAction.none;
    }
  }

  bool get isBlock => this == SystemMessageAction.block;
  bool get isUnblock => this == SystemMessageAction.unblock;
}

class ChatMessage {
  final String id;
  final String? tempId;
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
  final String? deliveredAt;
  bool isRead;
  final MessageStatusEnum status;
  final ReplyInfo? reply;
  final SystemMessageAction action;
  final List<String>? localFilePaths;
  final double? uploadProgress;
  final List<MessageReaction> reactions;

  String get content => contentList.isNotEmpty ? contentList.first : '';

  bool get hasLocalFiles =>
      localFilePaths != null && localFilePaths!.isNotEmpty;

  bool get isUploading =>
      uploadProgress != null && uploadProgress! < 1.0 && uploadProgress! >= 0.0;

  ChatMessage({
    required this.id,
    this.tempId,
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
    this.deliveredAt,
    this.isRead = true,
    this.status = MessageStatusEnum.sent,
    this.reply,
    this.action = SystemMessageAction.none,
    this.localFilePaths,
    this.uploadProgress,
    this.reactions = const [],
  });

  static String _mapMessageType(Map<String, dynamic> json) {
    final rawType =
        json['contentType']?.toString() ?? json['messageType']?.toString();
    if (rawType == null) return 'text';

    if (rawType == 'images/videos') {
      // Try to determine if it's actually a video from the first content object
      final content = json['content'];
      if (content is List && content.isNotEmpty) {
        final first = content.first;
        if (first is Map) {
          final mediaType = first['mediaType']?.toString();
          final mediaUrl = first['media']?.toString() ?? '';
          if (mediaType == 'video' ||
              mediaUrl.toLowerCase().endsWith('.mp4') ||
              mediaUrl.toLowerCase().endsWith('.mov')) {
            return 'video';
          }
        }
      }
      return 'image';
    }

    if (rawType == 'record') {
      return 'audio';
    }

    return rawType;
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    List<String> parseContentList(dynamic contentData) {
      if (contentData == null) return [];
      if (contentData is List) {
        return contentData.map((e) {
          if (e is Map) {
            // Handle new media object structure: { "media": "url", "mediaType": "image" }
            return e['media']?.toString() ??
                e['url']?.toString() ??
                e.toString();
          }
          return e.toString();
        }).toList();
      }
      return [contentData.toString()];
    }

    List<MessageReaction> parseReactions(dynamic reactionsData) {
      if (reactionsData == null) return [];
      if (reactionsData is List) {
        return reactionsData
            .map((e) => MessageReaction.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    }

    // sender can be an object or a plain id string
    final senderData = json['sender'];
    String senderId = json['senderId']?.toString() ?? '';
    String senderName = '';
    String senderImage = '';
    String senderType = '';

    if (senderData is Map<String, dynamic>) {
      senderId =
          senderData['_id']?.toString() ??
          senderData['userId']?.toString() ??
          senderId;
      senderName = senderData['name']?.toString() ?? '';
      senderImage =
          senderData['avatar']?.toString() ??
          senderData['image']?.toString() ??
          '';
      senderType = senderData['userType']?.toString() ?? '';
    } else if (senderData != null) {
      senderId = senderData.toString();
    }

    return ChatMessage(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      tempId: json['tempId']?.toString(),
      chatRoomId:
          json['chatRoomId']?.toString() ??
          (json['chatRoom'] is String
              ? json['chatRoom'].toString()
              : (json['chatRoom'] as Map<String, dynamic>?)?['_id']
                        ?.toString() ??
                    ''),
      senderId: senderId,
      senderName: senderName,
      senderImage: senderImage,
      senderType: senderType,
      isMe: json['isMe'] ?? (senderId == kCurrentUserData?.id),
      contentList: parseContentList(json['content']),
      messageType: _mapMessageType(json),
      createdAt:
          json['sentAt']?.toString() ?? json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      deliveredAt: json['deliveredAt']?.toString(),
      isRead: json['isRead'] ?? true,
      status: MessageStatusExtension.fromString(json['status']?.toString()),
      reply: ReplyInfo.fromJson(json['reply']),
      action: SystemMessageAction.fromString(json['action']?.toString()),
      reactions: parseReactions(json['reactions']),
    );
  }

  ChatMessage copyWith({
    String? id,
    String? tempId,
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
    String? deliveredAt,
    bool? isRead,
    MessageStatusEnum? status,
    ReplyInfo? reply,
    SystemMessageAction? action,
    List<String>? localFilePaths,
    bool clearLocalFilePaths = false,
    double? uploadProgress,
    bool clearUploadProgress = false,
    List<MessageReaction>? reactions,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      tempId: tempId ?? this.tempId,
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
      deliveredAt: deliveredAt ?? this.deliveredAt,
      isRead: isRead ?? this.isRead,
      status: status ?? this.status,
      reply: reply ?? this.reply,
      action: action ?? this.action,
      localFilePaths: clearLocalFilePaths
          ? null
          : (localFilePaths ?? this.localFilePaths),
      uploadProgress: clearUploadProgress
          ? null
          : (uploadProgress ?? this.uploadProgress),
      reactions: reactions ?? this.reactions,
    );
  }
}
