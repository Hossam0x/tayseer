import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/send_media_message_response.dart';

abstract class ChatRepo {
  Future<Either<String, ChatRoomsResponse>> getAllChatRooms();

  Future<Either<String, ChatMessagesResponse>> getChatMessages(
    String chatRoomId,
  );

  Future<Either<String, SendMessageResponse>> sendMediaMessage({
    required String chatRoomId,
    required String messageType,
    List<File>? images,
    List<File>? videos,
    String? audio,
    String? replyMessageId, // ✅ للرد على رسالة بالميديا
  });
}
