import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:tayseer/core/enum/message_status_enum.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/send_media_message_response.dart';
import 'package:tayseer/features/advisor/chat/domain/repositories/i_chat_repository.dart';

/// Parameters for sending media message
class SendMediaParams {
  final String chatRoomId;
  final String messageType;
  final List<File>? images;
  final List<File>? videos;
  final String? audio;
  final String? replyMessageId;
  final ChatMessage? replyToMessage;
  final String? tempId;

  const SendMediaParams({
    required this.chatRoomId,
    required this.messageType,
    this.images,
    this.videos,
    this.audio,
    this.replyMessageId,
    this.replyToMessage,
    this.tempId,
  });

  /// Get all local file paths for optimistic display
  List<String> get localFilePaths {
    final paths = <String>[];
    if (images != null) {
      paths.addAll(images!.map((f) => f.path));
    }
    if (videos != null) {
      paths.addAll(videos!.map((f) => f.path));
    }
    return paths;
  }
}

/// Result of sending a media message (optimistic)
class SendMediaResult {
  final ChatMessage localMessage;
  final String localId;
  final String tempId;

  const SendMediaResult({
    required this.localMessage,
    required this.localId,
    required this.tempId,
  });
}

/// Use case for sending media messages (images, videos, audio)
/// Uses HTTP instead of socket for file upload
/// Supports optimistic UI: creates local message first, then uploads
class SendMediaUseCase {
  final IChatRepository _repository;

  const SendMediaUseCase(this._repository);

  /// Create optimistic local message for immediate UI display
  /// Returns [SendMediaResult] with local message
  Future<SendMediaResult> createOptimisticMessage(
    SendMediaParams params,
  ) async {
    const uuid = Uuid();
    final tempId = uuid.v4();
    final localId = 'temp_$tempId';
    final now = DateTime.now().toIso8601String();

    // Create reply info if replying
    ReplyInfo? replyInfo;
    if (params.replyMessageId != null && params.replyToMessage != null) {
      // Extract content from ChatMessage
      String? replyMessageContent;

      // For media messages, prefer localFilePaths if available (for local messages)
      if (params.replyToMessage!.localFilePaths != null &&
          params.replyToMessage!.localFilePaths!.isNotEmpty) {
        replyMessageContent = params.replyToMessage!.localFilePaths!.first;
      } else if (params.replyToMessage!.contentList.isNotEmpty) {
        replyMessageContent = params.replyToMessage!.contentList.first;
      }

      replyInfo = ReplyInfo(
        replyMessageId: params.replyMessageId,
        replyMessage: replyMessageContent,
        isReply: true,
      );
    }

    // Create optimistic message with local file paths
    final localMessage = ChatMessage(
      id: localId,
      tempId: tempId,
      chatRoomId: params.chatRoomId,
      senderId: '', // Will be set by server
      senderName: 'Me',
      senderImage: '',
      senderType: 'user',
      isMe: true,
      contentList: [], // Empty until server responds with URLs
      messageType: params.messageType,
      createdAt: now,
      updatedAt: now,
      isRead: false,
      status: MessageStatusEnum.pending,
      reply: replyInfo,
      localFilePaths: params.localFilePaths,
    );

    // Save to local DB
    await _repository.saveMessageLocally(localMessage, localId: localId);

    return SendMediaResult(
      localMessage: localMessage,
      localId: localId,
      tempId: tempId,
    );
  }

  /// Upload media to server
  /// Returns [SendMessageResponse] on success or error string on failure
  Future<Either<String, SendMessageResponse>> upload(
    SendMediaParams params,
  ) async {
    return await _repository.sendMediaMessage(
      chatRoomId: params.chatRoomId,
      messageType: params.messageType,
      images: params.images,
      videos: params.videos,
      audio: params.audio,
      replyMessageId: params.replyMessageId,
      tempId: params.tempId,
    );
  }

  /// Legacy method for backward compatibility
  /// Directly uploads without optimistic UI
  Future<Either<String, SendMessageResponse>> call(
    SendMediaParams params,
  ) async {
    return await upload(params);
  }
}
