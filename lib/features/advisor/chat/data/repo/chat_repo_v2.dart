import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:tayseer/core/database/entities/message_entity.dart';
import 'package:tayseer/core/database/entities/chat_room_entity.dart';
import 'package:tayseer/core/database/entities/pending_message_entity.dart';
import 'package:tayseer/core/enum/message_status_enum.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/advisor/chat/data/local/chat_local_datasource.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/send_media_message_response.dart';
import 'package:tayseer/my_import.dart';

/// Enhanced Chat Repository with Local-First Strategy
///
/// Flow for loading messages:
/// 1. Load from Local DB immediately (no waiting for server)
/// 2. Sync with server in background
/// 3. Store new messages to local DB
/// 4. Notify UI of updates
///
/// Flow for sending messages:
/// 1. Save message locally with status=sending
/// 2. Display immediately in UI
/// 3. Send to server
/// 4. Update local message with server ID and status
abstract class ChatRepoV2 {
  /// Load initial messages for a chat room (local-first)
  /// Returns cached messages immediately, then syncs with server
  Future<List<ChatMessage>> loadInitialMessages(String chatRoomId);

  /// Load older messages (cursor-based pagination)
  /// Cursor = sortTimestamp of the oldest displayed message
  Future<List<ChatMessage>> loadOlderMessages(
    String chatRoomId, {
    required int cursorTimestamp,
  });

  /// Get sort_timestamp for a message by ID
  Future<int?> getMessageSortTimestamp(String messageId);

  /// Save a message locally (for optimistic UI)
  Future<void> saveMessageLocally(ChatMessage message, {String? localId});

  /// Update message after server confirms
  Future<void> confirmMessageSent(String localId, String serverId);

  /// Update message status (sent/delivered/read)
  Future<void> updateMessageStatus(String messageId, String status);

  /// Mark all messages in a chat as read
  Future<void> markChatAsRead(String chatRoomId);

  /// Get all chat rooms (local-first)
  Future<List<ChatRoom>> getChatRooms();

  /// Sync chat rooms with server
  Future<void> syncChatRooms();

  /// Send media message (via HTTP)
  Future<Either<String, SendMessageResponse>> sendMediaMessage({
    required String chatRoomId,
    required String messageType,
    List<File>? images,
    List<File>? videos,
    String? audio,
    String? replyMessageId,
  });

  /// Get pending messages for retry
  Future<List<PendingMessageEntity>> getPendingMessages();

  /// Add message to pending queue
  Future<void> addToPendingQueue(PendingMessageEntity pending);

  /// Remove message from pending queue
  Future<void> removeFromPendingQueue(String localId);

  /// Sync messages with server (background)
  Future<void> syncMessagesWithServer(String chatRoomId);

  /// Run cache cleanup
  Future<void> cleanupCache();

  /// Clear all local data (for logout)
  Future<void> clearAllData();

  /// Stream of messages for a chat room (for reactive UI)
  Stream<List<ChatMessage>> watchMessages(String chatRoomId);

  /// Delete a single message
  /// [deleteType] can be 'me' or 'everyone'
  Future<Either<String, void>> deleteMessage({
    required String messageId,
    required String chatRoomId,
    required String deleteType,
  });

  /// Delete multiple messages
  /// [deleteType] can be 'me' or 'everyone'
  Future<Either<String, void>> deleteMessages({
    required List<String> messageIds,
    required String chatRoomId,
    required String deleteType,
  });

  /// Delete message from local database only (for socket events)
  Future<void> deleteMessageLocally(String messageId);

  /// Block a user
  Future<Either<String, String>> blockUser({required String blockedId});

  /// Unblock a user
  Future<Either<String, String>> unblockUser({required String blockedId});
}

class ChatRepoV2Impl implements ChatRepoV2 {
  final ApiService _apiService;
  final ChatLocalDataSource _localDataSource;

  /// Stream controllers for reactive updates
  final Map<String, StreamController<List<ChatMessage>>> _messageStreams = {};

  ChatRepoV2Impl(this._apiService, this._localDataSource);

  // ==================== MESSAGE LOADING ====================

  @override
  Future<List<ChatMessage>> loadInitialMessages(String chatRoomId) async {
    // Step 1: Load from local DB immediately
    final localMessages = await _localDataSource.getLatestMessages(
      chatRoomId,
      limit: 20,
    );

    // Notify listeners immediately with cached data
    _notifyMessageListeners(chatRoomId, localMessages);

    // Step 2: Sync with server in background (don't await)
    _syncMessagesInBackground(chatRoomId, localMessages);

    return localMessages;
  }

  /// Sync messages with server in background
  /// Adds NEW messages and updates STATUS of existing ones
  void _syncMessagesInBackground(
    String chatRoomId,
    List<ChatMessage> currentMessages,
  ) async {
    try {
      final response = await _apiService.get(
        endPoint: ApiEndPoint.getChatMessages(chatRoomId),
      );

      if (response['success'] == true) {
        final serverResponse = ChatMessagesResponse.fromJson(response);
        final serverMessages = serverResponse.data.messages;

        // Create a map of existing messages for fast lookup (excluding temp_ messages)
        final existingMessagesMap = {
          for (final m in currentMessages)
            if (!m.id.startsWith('temp_')) m.id: m,
        };

        // Get temp messages for matching
        final tempMessages = currentMessages
            .where((m) => m.id.startsWith('temp_'))
            .toList();

        // Find truly new messages AND messages with updated status
        final newMessages = <ChatMessage>[];
        bool dataUpdated = false;

        for (final serverMsg in serverMessages) {
          final existingMsg = existingMessagesMap[serverMsg.id];

          if (existingMsg == null) {
            // Check if it exists in DB by server ID
            final existsInDb = await _localDataSource.messageExists(
              serverMsg.id,
            );

            if (!existsInDb) {
              // Check if there's a matching temp message (same content & type)
              final matchingTempIndex = tempMessages.indexWhere(
                (temp) =>
                    temp.messageType == serverMsg.messageType &&
                    temp.content.trim() == serverMsg.content.trim(),
              );

              if (matchingTempIndex != -1) {
                // Found matching temp message - update its ID
                final tempMsg = tempMessages[matchingTempIndex];
                await _localDataSource.updateMessageId(
                  tempMsg.id,
                  serverMsg.id,
                );
                // Remove from temp list to avoid duplicate matches
                tempMessages.removeAt(matchingTempIndex);
                dataUpdated = true;
                print(
                  '🔄 Updated temp message ID: ${tempMsg.id} -> ${serverMsg.id}',
                );
              } else {
                // Truly new message
                newMessages.add(serverMsg);
              }
            }
          } else {
            // Existing message - check if status changed
            if (existingMsg.status != serverMsg.status) {
              await _localDataSource.updateMessageStatus(
                serverMsg.id,
                serverMsg.status.toApiString(),
              );
              dataUpdated = true;
              print(
                '🔄 Updated status for ${serverMsg.id}: ${existingMsg.status} -> ${serverMsg.status}',
              );
            }
          }
        }

        // Insert truly new messages to local DB
        if (newMessages.isNotEmpty) {
          await _localDataSource.insertMessages(
            newMessages.map((m) => MessageEntity.fromChatMessage(m)).toList(),
          );
          print('✅ Synced ${newMessages.length} new messages to local DB');
          dataUpdated = true;
        }

        // Reload and notify UI if anything changed
        if (dataUpdated) {
          final updatedMessages = await _localDataSource.getLatestMessages(
            chatRoomId,
            limit: 20,
          );
          _notifyMessageListeners(chatRoomId, updatedMessages);
        }

        // Run cleanup after sync
        await _localDataSource.cleanupOldMessages(chatRoomId);
      }
    } catch (e) {
      print('⚠️ Background sync failed: $e');
      // Ignore errors - we already have local data
    }
  }

  @override
  Future<List<ChatMessage>> loadOlderMessages(
    String chatRoomId, {
    required int cursorTimestamp,
  }) async {
    // Step 1: Try loading from local DB first
    var olderMessages = await _localDataSource.getMessagesBeforeCursor(
      chatRoomId,
      cursorTimestamp: cursorTimestamp,
      limit: 20,
    );

    // Step 2: If local is empty, fetch from server
    if (olderMessages.isEmpty) {
      try {
        // Note: Backend uses page-based pagination
        // We adapt by fetching and filtering
        final response = await _apiService.get(
          endPoint: ApiEndPoint.getChatMessages(chatRoomId),
          // Add page parameter if your API supports it
        );

        if (response['success'] == true) {
          final serverResponse = ChatMessagesResponse.fromJson(response);
          final serverMessages = serverResponse.data.messages;

          // Filter messages older than cursor timestamp
          final cursorDateTime = DateTime.fromMillisecondsSinceEpoch(
            cursorTimestamp,
          );
          final olderFromServer = serverMessages.where((m) {
            try {
              final msgTime = DateTime.parse(m.createdAt);
              return msgTime.isBefore(cursorDateTime);
            } catch (_) {
              return false; // Skip messages with invalid timestamps
            }
          }).toList();

          // Store to local DB
          if (olderFromServer.isNotEmpty) {
            await _localDataSource.insertMessages(
              olderFromServer
                  .map((m) => MessageEntity.fromChatMessage(m))
                  .toList(),
            );
            olderMessages = olderFromServer;
          }
        }
      } catch (e) {
        print('⚠️ Failed to load older messages from server: $e');
      }
    }

    return olderMessages;
  }

  @override
  Future<int?> getMessageSortTimestamp(String messageId) async {
    return await _localDataSource.getMessageSortTimestamp(messageId);
  }

  @override
  Future<void> syncMessagesWithServer(String chatRoomId) async {
    try {
      final response = await _apiService.get(
        endPoint: ApiEndPoint.getChatMessages(chatRoomId),
      );

      if (response['success'] == true) {
        final serverResponse = ChatMessagesResponse.fromJson(response);
        final insertedCount = await _localDataSource.insertNewMessages(
          serverResponse.data.messages,
        );

        if (insertedCount > 0) {
          final messages = await _localDataSource.getLatestMessages(chatRoomId);
          _notifyMessageListeners(chatRoomId, messages);
        }
      }
    } catch (e) {
      print('⚠️ Sync failed: $e');
    }
  }

  // ==================== MESSAGE SENDING ====================

  @override
  Future<void> saveMessageLocally(
    ChatMessage message, {
    String? localId,
  }) async {
    final entity = MessageEntity.fromChatMessage(
      message,
      isPending: true,
      localId: localId,
    );
    await _localDataSource.insertMessage(entity);
    // Don't notify stream here - the cubit already updates UI immediately
    // Notifying would cause the stream to override cubit's state
  }

  @override
  Future<void> confirmMessageSent(String localId, String serverId) async {
    await _localDataSource.updateMessageId(localId, serverId);
    await _localDataSource.removeFromPendingQueue(localId);
  }

  @override
  Future<void> updateMessageStatus(String messageId, String status) async {
    await _localDataSource.updateMessageStatus(messageId, status);
  }

  @override
  Future<void> markChatAsRead(String chatRoomId) async {
    await _localDataSource.markMessagesAsRead(chatRoomId);
    await _localDataSource.resetUnreadCount(chatRoomId);
  }

  // ==================== CHAT ROOMS ====================

  @override
  Future<List<ChatRoom>> getChatRooms() async {
    // Load from local first
    final localRooms = await _localDataSource.getAllChatRooms();

    // Sync in background
    _syncChatRoomsInBackground();

    return localRooms;
  }

  void _syncChatRoomsInBackground() async {
    try {
      await syncChatRooms();
    } catch (e) {
      print('⚠️ Chat rooms sync failed: $e');
    }
  }

  @override
  Future<void> syncChatRooms() async {
    final response = await _apiService.get(
      endPoint: ApiEndPoint.getAllchatRooms,
    );

    if (response['success'] == true) {
      final serverResponse = ChatRoomsResponse.fromJson(response);
      final entities = serverResponse.data.rooms
          .map((r) => ChatRoomEntity.fromChatRoom(r))
          .toList();
      await _localDataSource.upsertChatRooms(entities);
    }
  }

  // ==================== MEDIA MESSAGES ====================

  @override
  Future<Either<String, SendMessageResponse>> sendMediaMessage({
    required String chatRoomId,
    required String messageType,
    List<File>? images,
    List<File>? videos,
    String? audio,
    String? replyMessageId,
  }) async {
    final Map<String, dynamic> formDataMap = {
      'messageType': messageType,
      'chatRoomId': chatRoomId,
    };

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
      );

      if (response['success'] == true) {
        final result = SendMessageResponse.fromJson(response);

        // Save sent message to local DB
        final sentMsg = result.data;
        final message = ChatMessage(
          id: sentMsg.id,
          chatRoomId: chatRoomId,
          senderId: sentMsg.senderId,
          senderName: sentMsg.senderName,
          senderImage: sentMsg.senderImage ?? '',
          senderType: sentMsg.senderType,
          isMe: sentMsg.isMe,
          contentList: sentMsg.contentList,
          messageType: sentMsg.messageType,
          createdAt: sentMsg.createdAt,
          updatedAt: sentMsg.updatedAt,
          isRead: sentMsg.isRead,
          reply: sentMsg.reply,
        );
        await _localDataSource.insertMessage(
          MessageEntity.fromChatMessage(message),
        );

        return Right(result);
      } else {
        return Left(response['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      return Left('Failed to send message: $e');
    }
  }

  // ==================== PENDING QUEUE ====================

  @override
  Future<List<PendingMessageEntity>> getPendingMessages() async {
    return await _localDataSource.getPendingQueue();
  }

  @override
  Future<void> addToPendingQueue(PendingMessageEntity pending) async {
    await _localDataSource.addToPendingQueue(pending);
  }

  @override
  Future<void> removeFromPendingQueue(String localId) async {
    await _localDataSource.removeFromPendingQueue(localId);
  }

  // ==================== CACHE MANAGEMENT ====================

  @override
  Future<void> cleanupCache() async {
    await _localDataSource.cleanupAllChats();
  }

  @override
  Future<void> clearAllData() async {
    await _localDataSource.clearAllData();
    _messageStreams.forEach((_, controller) => controller.close());
    _messageStreams.clear();
  }

  // ==================== REACTIVE STREAMS ====================

  @override
  Stream<List<ChatMessage>> watchMessages(String chatRoomId) {
    if (!_messageStreams.containsKey(chatRoomId)) {
      _messageStreams[chatRoomId] =
          StreamController<List<ChatMessage>>.broadcast();
    }
    return _messageStreams[chatRoomId]!.stream;
  }

  void _notifyMessageListeners(String chatRoomId, List<ChatMessage> messages) {
    if (_messageStreams.containsKey(chatRoomId)) {
      _messageStreams[chatRoomId]!.add(messages);
    }
  }

  /// Notify about a single message update (for BlocSelector efficiency)
  void notifyMessageUpdate(String chatRoomId, ChatMessage message) async {
    final messages = await _localDataSource.getLatestMessages(chatRoomId);
    _notifyMessageListeners(chatRoomId, messages);
  }

  // ==================== DELETE MESSAGES ====================

  @override
  Future<Either<String, void>> deleteMessage({
    required String messageId,
    required String chatRoomId,
    required String deleteType,
  }) async {
    try {
      // Call API to delete message
      final response = await _apiService.delete(
        endPoint: '${ApiEndPoint.deleteChatMessage}?deleteType=$deleteType',
        data: {'messageId': messageId},
      );

      if (response['success'] == true) {
        // Delete from local DB
        await _localDataSource.deleteMessage(messageId);

        // Don't notify here - cubit handles state update
        // This prevents unnecessary scroll behavior

        print('✅ Deleted message: $messageId (deleteType: $deleteType)');
        return const Right(null);
      } else {
        return Left(response['message'] ?? 'فشل حذف الرسالة');
      }
    } catch (e) {
      print('❌ Error deleting message: $e');
      return Left('فشل حذف الرسالة: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteMessages({
    required List<String> messageIds,
    required String chatRoomId,
    required String deleteType,
  }) async {
    try {
      // Call API to delete multiple messages
      final response = await _apiService.delete(
        endPoint:
            '${ApiEndPoint.deleteChatMessage}?deleteType=$deleteType&multiple=true',
        data: {'messagesIds': messageIds},
      );

      if (response['success'] == true) {
        // Delete from local DB
        for (final messageId in messageIds) {
          await _localDataSource.deleteMessage(messageId);
        }

        // Don't notify here - cubit handles state update
        // This prevents unnecessary scroll behavior

        print(
          '✅ Deleted ${messageIds.length} messages (deleteType: $deleteType)',
        );
        return const Right(null);
      } else {
        return Left(response['message'] ?? 'فشل حذف الرسائل');
      }
    } catch (e) {
      print('❌ Error deleting messages: $e');
      return Left('فشل حذف الرسائل: $e');
    }
  }

  @override
  Future<void> deleteMessageLocally(String messageId) async {
    try {
      await _localDataSource.deleteMessage(messageId);
      print('✅ Deleted message from local DB: $messageId');
    } catch (e) {
      print('❌ Error deleting message from local DB: $e');
    }
  }

  @override
  Future<Either<String, String>> blockUser({required String blockedId}) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.blockuser,
        isAuth: true,
        data: {'blockedId': blockedId},
      );

      if (response['success'] == true) {
        final message = response['message'] ?? 'تم حظر المستخدم بنجاح';
        print('✅ User blocked successfully: $blockedId');
        return Right(message);
      } else {
        final errorMessage = response['message'] ?? 'فشل حظر المستخدم';
        print('❌ Failed to block user: $errorMessage');
        return Left(errorMessage);
      }
    } catch (e) {
      print('❌ Error blocking user: $e');
      return Left('فشل حظر المستخدم: $e');
    }
  }

  @override
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
        print('✅ User unblocked successfully: $blockedId');
        return Right(message);
      } else {
        final errorMessage = response['message'] ?? 'فشل إلغاء حظر المستخدم';
        print('❌ Failed to unblock user: $errorMessage');
        return Left(errorMessage);
      }
    } catch (e) {
      print('❌ Error unblocking user: $e');
      return Left('فشل إلغاء حظر المستخدم: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _messageStreams.forEach((_, controller) => controller.close());
    _messageStreams.clear();
  }
}
