import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:tayseer/core/database/entities/pending_message_entity.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/send_media_message_response.dart';

/// Chat Repository Interface
/// Defines the contract for chat data operations
/// Following Dependency Inversion Principle - domain depends on abstraction
abstract class IChatRepository {
  /// Get all chat rooms
  Future<Either<String, ChatRoomsResponse>> getAllChatRooms();

  /// Delete chat room
  Future<Either<String, bool>> deleteChatRoom(String chatRoomId);

  /// Archive chat room
  Future<Either<String, bool>> archiveChatRoom(String chatRoomId);

  // ══════════════════════════════════════════════════════════════════════════
  // MESSAGE LOADING
  // ══════════════════════════════════════════════════════════════════════════

  /// Load initial messages for a chat room (local-first)
  /// Returns cached messages immediately, then syncs with server
  Future<List<ChatMessage>> loadInitialMessages(String chatRoomId);

  /// Load older messages (cursor-based pagination)
  /// [cursorTimestamp] = sortTimestamp of the oldest displayed message
  Future<List<ChatMessage>> loadOlderMessages(
    String chatRoomId, {
    required int cursorTimestamp,
  });

  /// Get sort_timestamp for a message by ID
  Future<int?> getMessageSortTimestamp(String messageId);

  /// Sync messages with server (background)
  Future<void> syncMessagesWithServer(String chatRoomId);

  /// Stream of messages for a chat room (for reactive UI)
  Stream<List<ChatMessage>> watchMessages(String chatRoomId);

  // ══════════════════════════════════════════════════════════════════════════
  // MESSAGE SENDING
  // ══════════════════════════════════════════════════════════════════════════

  /// Save a message locally (for optimistic UI)
  Future<void> saveMessageLocally(ChatMessage message, {String? localId});

  /// Update message after server confirms
  Future<void> confirmMessageSent(String localId, String serverId);

  /// Update message status (sent/delivered/read)
  Future<void> updateMessageStatus(String messageId, String status);

  /// Send media message (via HTTP)
  Future<Either<String, SendMessageResponse>> sendMediaMessage({
    required String chatRoomId,
    required String messageType,
    List<File>? images,
    List<File>? videos,
    String? audio,
    String? replyMessageId,
    String? tempId,
  });

  // ══════════════════════════════════════════════════════════════════════════
  // MESSAGE DELETION
  // ══════════════════════════════════════════════════════════════════════════

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

  // ══════════════════════════════════════════════════════════════════════════
  // CHAT ROOMS
  // ══════════════════════════════════════════════════════════════════════════

  /// Mark all messages in a chat as read
  Future<void> markChatAsRead(String chatRoomId);

  /// Get all chat rooms (local-first)
  Future<List<ChatRoom>> getChatRooms();

  /// Sync chat rooms with server
  Future<void> syncChatRooms();

  // ══════════════════════════════════════════════════════════════════════════
  // PENDING QUEUE (OFFLINE SUPPORT)
  // ══════════════════════════════════════════════════════════════════════════

  /// Get pending messages for retry
  Future<List<PendingMessageEntity>> getPendingMessages();

  /// Add message to pending queue
  Future<void> addToPendingQueue(PendingMessageEntity pending);

  /// Remove message from pending queue
  Future<void> removeFromPendingQueue(String localId);

  // ══════════════════════════════════════════════════════════════════════════
  // BLOCK/UNBLOCK
  // ══════════════════════════════════════════════════════════════════════════

  /// Block a user
  Future<Either<String, String>> blockUser({required String blockedId});

  /// Unblock a user
  Future<Either<String, String>> unblockUser({required String blockedId});

  // ══════════════════════════════════════════════════════════════════════════
  // CACHE MANAGEMENT
  // ══════════════════════════════════════════════════════════════════════════

  /// Run cache cleanup
  Future<void> cleanupCache();

  /// Clear all local data (for logout)
  Future<void> clearAllData();
}
