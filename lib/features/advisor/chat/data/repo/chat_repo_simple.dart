import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/send_media_message_response.dart';
import 'package:tayseer/my_import.dart';

/// Simplified Chat Repository - No Local Cache
///
/// All data comes directly from the server.
/// No local database, no caching, no complexity.
class ChatRepoSimple {
  final ApiService _apiService;

  ChatRepoSimple(this._apiService);

  // ==================== MESSAGES ====================

  /// Load messages from server
  Future<List<ChatMessage>> loadMessages(String chatRoomId) async {
    try {
      final response = await _apiService.get(
        endPoint: ApiEndPoint.getChatMessages(chatRoomId),
      );

      if (response['success'] == true) {
        final serverResponse = ChatMessagesResponse.fromJson(response);
        return serverResponse.data.messages;
      }
      return [];
    } catch (e) {
      print('❌ Error loading messages: $e');
      return [];
    }
  }

  /// Send media message (image/video)
  Future<Either<String, SendMessageResponse>> sendMediaMessage({
    required String chatRoomId,
    required String messageType,
    List<File>? images,
    List<File>? videos,
    String? audio,
    String? replyMessageId,
    String? tempId,
    Function(int sent, int total)? onProgress,
  }) async {
    final Map<String, dynamic> formDataMap = {
      'messageType': messageType,
      'chatRoomId': chatRoomId,
    };

    if (tempId != null && tempId.isNotEmpty) {
      formDataMap['tempId'] = tempId;
    }

    if (replyMessageId != null && replyMessageId.isNotEmpty) {
      formDataMap['replyMessageId'] = replyMessageId;
    }

    if (messageType == 'image' && images != null && images.isNotEmpty) {
      final List<MultipartFile> imageFiles = [];
      for (var image in images) {
        imageFiles.add(
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        );
      }
      formDataMap['images'] = imageFiles;
    }

    if (messageType == 'video' && videos != null && videos.isNotEmpty) {
      final List<MultipartFile> videoFiles = [];
      for (var video in videos) {
        videoFiles.add(
          await MultipartFile.fromFile(
            video.path,
            filename: video.path.split('/').last,
          ),
        );
      }
      formDataMap['videos'] = videoFiles;
    }

    if (messageType == 'audio' && audio != null) {
      formDataMap['audio'] = audio;
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
        return Left(response['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      return Left('Failed to send message: $e');
    }
  }

  // ==================== DELETE MESSAGES ====================

  Future<Either<String, void>> deleteMessage({
    required String messageId,
    required String chatRoomId,
    required String deleteType,
  }) async {
    try {
      final response = await _apiService.delete(
        endPoint: '${ApiEndPoint.deleteChatMessage}?deleteType=$deleteType',
        data: {'messageId': messageId},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(response['message'] ?? 'فشل حذف الرسالة');
      }
    } catch (e) {
      return Left('فشل حذف الرسالة: $e');
    }
  }

  Future<Either<String, void>> deleteMessages({
    required List<String> messageIds,
    required String chatRoomId,
    required String deleteType,
  }) async {
    try {
      final response = await _apiService.delete(
        endPoint:
            '${ApiEndPoint.deleteChatMessage}?deleteType=$deleteType&multiple=true',
        data: {'messagesIds': messageIds},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(response['message'] ?? 'فشل حذف الرسائل');
      }
    } catch (e) {
      return Left('فشل حذف الرسائل: $e');
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
        final message = response['message'] ?? 'تم حظر المستخدم بنجاح';
        return Right(message);
      } else {
        final errorMessage = response['message'] ?? 'فشل حظر المستخدم';
        return Left(errorMessage);
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
        final message = response['message'] ?? 'تم إلغاء حظر المستخدم بنجاح';
        return Right(message);
      } else {
        final errorMessage = response['message'] ?? 'فشل إلغاء حظر المستخدم';
        return Left(errorMessage);
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
        endPoint: ApiEndPoint.deleteChatRoom(chatRoomId),
      );
      if (response['success'] == true) {
        return const Right(true);
      } else {
        return Left(response['message'] ?? 'Failed to delete chat room');
      }
    } catch (e) {
      return Left('Failed to delete chat room: $e');
    }
  }

  Future<Either<String, bool>> archiveChatRoom(String chatRoomId) async {
    try {
      final response = await _apiService.patch(
        endPoint: ApiEndPoint.archiveChatRoom(chatRoomId),
      );
      if (response['success'] == true) {
        return const Right(true);
      } else {
        return Left(response['message'] ?? 'Failed to archive chat room');
      }
    } catch (e) {
      return Left('Failed to archive chat room: $e');
    }
  }
}
