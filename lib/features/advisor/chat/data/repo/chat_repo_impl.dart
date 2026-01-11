import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/send_media_message_response.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo.dart';
import 'package:tayseer/my_import.dart';

class ChatRepoImpl extends ChatRepo {
  final ApiService apiService;

  ChatRepoImpl(this.apiService);

  @override
  Future<Either<String, ChatRoomsResponse>> getAllChatRooms() async {
    final response = await apiService.get(
      endPoint: ApiEndPoint.getAllchatRooms,
    );
    if (response['success'] == true) {
      final chatRoomsResponse = ChatRoomsResponse.fromJson(response);
      return Right(chatRoomsResponse);
    } else {
      return Left('Failed to fetch chat rooms');
    }
  }

  @override
  Future<Either<String, ChatMessagesResponse>> getChatMessages(
    String chatRoomId,
  ) async {
    final response = await apiService.get(
      endPoint: ApiEndPoint.getChatMessages(chatRoomId),
    );
    if (response['success'] == true) {
      final chatMessagesResponse = ChatMessagesResponse.fromJson(response);
      return Right(chatMessagesResponse);
    } else {
      return Left('Failed to fetch chat messages');
    }
  }

  @override
  Future<Either<String, SendMessageResponse>> sendMediaMessage({
    required String chatRoomId,
    required String messageType,
    List<File>? images,
    List<File>? videos,
    String? audio,
    String? replyMessageId, // ✅ للرد على رسالة بالميديا
  }) async {
    final Map<String, dynamic> formDataMap = {
      'messageType': messageType,
      'chatRoomId': chatRoomId,
    };

    // ✅ إضافة replyMessageId لو موجود
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

    final response = await apiService.post(
      endPoint: ApiEndPoint.sendChatMedia,
      isAuth: true,
      data: formData,
    );

    if (response['success'] == true) {
      return Right(SendMessageResponse.fromJson(response));
    } else {
      return Left(response['message'] ?? 'Failed to send message');
    }
  }

  @override
  Future<Either<String, bool>> deleteChatRoom(String chatRoomId) async {
    try {
      final response = await apiService.delete(
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

  @override
  Future<Either<String, bool>> archiveChatRoom(String chatRoomId) async {
    try {
      final response = await apiService.patch(
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
