import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/send_media_message_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_requests/chat_request_model.dart';
import 'package:tayseer/my_import.dart';

/// Chat Repository — aligned with the new /new-chat backend.
class ChatRepoSimple {
  final ApiService _apiService;

  ChatRepoSimple(this._apiService);

  // ==================== MESSAGES ====================

  /// Load messages for [chatRoomId] (cursor-based, newest first).
  Future<List<ChatMessage>> loadMessages(
    String chatRoomId, {
    String? before,
    int limit = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'chatRoomId': chatRoomId,
        'limit': limit,
      };
      if (before != null) {
        queryParams['before'] = before;
      }

      final response = await _apiService.get(
        endPoint: ApiEndPoint.getChatMessages,
        data: queryParams,
      );

      if (response['success'] == true) {
        final serverResponse = ChatMessagesResponse.fromJson(response);
        return serverResponse.messages;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Send media message (image/video/audio).
  Future<Either<String, SendMessageResponse>> sendMediaMessage({
    required String chatRoomId,
    required String contentType,
    List<File>? images,
    List<File>? videos,
    File? audio,
    String? replyToMessageId,
    String? tempId,
    Function(int sent, int total)? onProgress,
  }) async {
    // Map contentType based on user's requirements: enum [ "images/videos", "record" ]
    String mappedContentType = contentType;
    if (contentType == 'image' || contentType == 'video') {
      mappedContentType = 'images/videos';
    } else if (contentType == 'audio' ||
        contentType == 'voice' ||
        contentType == 'record') {
      mappedContentType = 'record';
    }

    final Map<String, dynamic> formDataMap = {
      'chatRoomId': chatRoomId,
      'contentType': mappedContentType,
    };

    if (tempId != null && tempId.isNotEmpty) {
      formDataMap['tempId'] = tempId;
    }

    if (replyToMessageId != null && replyToMessageId.isNotEmpty) {
      formDataMap['replyToMessageId'] = replyToMessageId;
    }

    final List<MultipartFile> mediaFiles = [];

    if (images != null && images.isNotEmpty) {
      for (final image in images) {
        mediaFiles.add(
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        );
      }
    }

    if (videos != null && videos.isNotEmpty) {
      for (final video in videos) {
        mediaFiles.add(
          await MultipartFile.fromFile(
            video.path,
            filename: video.path.split('/').last,
          ),
        );
      }
    }

    if (audio != null) {
      mediaFiles.add(
        await MultipartFile.fromFile(
          audio.path,
          filename: audio.path.split('/').last,
        ),
      );
    }

    if (mediaFiles.isNotEmpty) {
      // Changed from 'media[]' to 'media' to fix MulterError: Unexpected field
      formDataMap['media'] = mediaFiles;
    }

    final formData = FormData.fromMap(formDataMap);

    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.sendChatMedia,
        isAuth: true,
        data: formData,
        onSendProgress: onProgress != null
            ? (sent, total) => onProgress(sent, total)
            : null,
      );

      if (response['success'] == true) {
        final result = SendMessageResponse.fromJson(response);
        return Right(result);
      } else {
        return Left(
          response['message']?.toString() ?? 'Failed to send message',
        );
      }
    } catch (e) {
      return Left('Failed to send message: $e');
    }
  }

  // ==================== DELETE MESSAGES ====================

  /// Delete a single message.
  Future<Either<String, void>> deleteMessage({
    required String messageId,
    required String chatRoomId,
    required String deleteType,
  }) async {
    return deleteMessages(
      messageIds: [messageId],
      chatRoomId: chatRoomId,
      deleteType: deleteType,
    );
  }

  /// Delete one or more messages.
  Future<Either<String, void>> deleteMessages({
    required List<String> messageIds,
    required String chatRoomId,
    required String deleteType,
  }) async {
    try {
      final response = await _apiService.delete(
        endPoint: ApiEndPoint.deleteChatMessage,
        data: {'chatMessageIds': messageIds, 'deleteType': deleteType},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(response['message']?.toString() ?? 'فشل حذف الرسالة');
      }
    } catch (e) {
      return Left('فشل حذف الرسالة: $e');
    }
  }

  // ==================== BLOCK/UNBLOCK ====================

  Future<Either<String, String>> blockUser({required String blockedId}) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.blockuser,
        isAuth: true,
        data: {'blockedId': blockedId},
      );

      if (response['success'] == true) {
        return Right(
          response['message']?.toString() ?? 'تم حظر المستخدم بنجاح',
        );
      } else {
        return Left(response['message']?.toString() ?? 'فشل حظر المستخدم');
      }
    } catch (e) {
      return Left('فشل حظر المستخدم: $e');
    }
  }

  Future<Either<String, String>> unblockUser({
    required String blockedId,
  }) async {
    try {
      final response = await _apiService.delete(
        endPoint: ApiEndPoint.unblockuser,
        data: {'blockedId': blockedId},
      );

      if (response['success'] == true) {
        return Right(
          response['message']?.toString() ?? 'تم إلغاء حظر المستخدم بنجاح',
        );
      } else {
        return Left(
          response['message']?.toString() ?? 'فشل إلغاء حظر المستخدم',
        );
      }
    } catch (e) {
      return Left('فشل إلغاء حظر المستخدم: $e');
    }
  }

  // ==================== CHAT ROOMS ====================

  Future<Either<String, ChatRoomsResponse>> getAllChatRooms() async {
    try {
      final response = await _apiService.get(
        endPoint: ApiEndPoint.getAllchatRooms,
      );
      if (response['success'] == true) {
        final chatRoomsResponse = ChatRoomsResponse.fromJson(response);
        return Right(chatRoomsResponse);
      } else {
        return const Left('Failed to fetch chat rooms');
      }
    } catch (e) {
      return Left('Failed to fetch chat rooms: $e');
    }
  }


  Future<Either<String, bool>> deleteChatRoom(String chatRoomId) async {
    try {
      final response = await _apiService.delete(
        endPoint: ApiEndPoint.deleteChatRoom,
        data: {'chatRoomId': chatRoomId},
      );
      if (response['success'] == true) {
        return const Right(true);
      } else {
        return Left(
          response['message']?.toString() ?? 'Failed to delete chat room',
        );
      }
    } catch (e) {
      return Left('Failed to delete chat room: $e');
    }
  }

  Future<Either<String, bool>> archiveChatRoom(String chatRoomId) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.archiveChatRoom,
        data: {'chatRoomId': chatRoomId},
      );
      if (response['success'] == true) {
        return const Right(true);
      } else {
        return Left(
          response['message']?.toString() ?? 'Failed to archive chat room',
        );
      }
    } catch (e) {
      return Left('Failed to archive chat room: $e');
    }
  }

  // ==================== CHAT REQUESTS ====================

  Future<Either<String, ChatRequestsResponse>> getChatRequests() async {
    try {
      final response = await _apiService.get(
        endPoint: ApiEndPoint.getChatRequests,
      );
      if (response['success'] == true) {
        final chatRequestsResponse = ChatRequestsResponse.fromJson(response);
        return Right(chatRequestsResponse);
      } else {
        return Left(response['message']?.toString() ?? 'فشل جلب الطلبات');
      }
    } catch (e) {
      return Left('فشل جلب الطلبات: $e');
    }
  }

  // ==================== UNARCHIVE ====================

  Future<Either<String, bool>> unarchiveChatRoom(String chatRoomId) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.unarchiveChatRoom,
        data: {'chatRoomId': chatRoomId},
      );
      if (response['success'] == true) {
        return const Right(true);
      } else {
        return Left(
          response['message']?.toString() ?? 'Failed to unarchive chat room',
        );
      }
    } catch (e) {
      return Left('Failed to unarchive chat room: $e');
    }
  }
}
