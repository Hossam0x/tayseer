import 'package:sqflite/sqflite.dart';
import 'package:tayseer/core/database/chat_database.dart';
import 'package:tayseer/core/database/entities/message_entity.dart';
import 'package:tayseer/core/database/entities/chat_room_entity.dart';
import 'package:tayseer/core/database/entities/pending_message_entity.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';

/// Local data source for chat operations
/// This is the single source of truth for chat data
class ChatLocalDataSource {
  final ChatDatabase _chatDatabase;

  /// Maximum messages to keep per chat room
  static const int maxMessagesPerChat = 20000;

  /// Default page size for pagination
  static const int defaultPageSize = 20;

  ChatLocalDataSource(this._chatDatabase);

  // ==================== MESSAGE OPERATIONS ====================

  /// Insert a single message
  Future<void> insertMessage(MessageEntity message) async {
    final db = await _chatDatabase.database;
    await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple messages (batch insert)
  Future<void> insertMessages(List<MessageEntity> messages) async {
    if (messages.isEmpty) return;

    final db = await _chatDatabase.database;
    final batch = db.batch();

    for (final message in messages) {
      batch.insert(
        'messages',
        message.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Get latest messages for a chat room (initial load)
  Future<List<ChatMessage>> getLatestMessages(
    String chatRoomId, {
    int limit = defaultPageSize,
  }) async {
    final db = await _chatDatabase.database;
    final results = await db.query(
      'messages',
      where: 'chat_room_id = ?',
      whereArgs: [chatRoomId],
      orderBy: 'sort_timestamp DESC',
      limit: limit,
    );

    return results
        .map((row) => MessageEntity.fromMap(row).toChatMessage())
        .toList()
        .reversed
        .toList(); // Reverse to get chronological order
  }

  /// Get messages before a cursor (cursor-based pagination)
  /// Uses sort_timestamp as cursor for consistent pagination
  Future<List<ChatMessage>> getMessagesBeforeCursor(
    String chatRoomId, {
    required int cursorTimestamp,
    int limit = defaultPageSize,
  }) async {
    final db = await _chatDatabase.database;
    final results = await db.query(
      'messages',
      where: 'chat_room_id = ? AND sort_timestamp < ?',
      whereArgs: [chatRoomId, cursorTimestamp],
      orderBy: 'sort_timestamp DESC',
      limit: limit,
    );

    return results
        .map((row) => MessageEntity.fromMap(row).toChatMessage())
        .toList()
        .reversed
        .toList();
  }

  /// Get a single message by ID
  Future<ChatMessage?> getMessageById(String messageId) async {
    final db = await _chatDatabase.database;
    final results = await db.query(
      'messages',
      where: 'id = ?',
      whereArgs: [messageId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return MessageEntity.fromMap(results.first).toChatMessage();
  }

  /// Get message by local ID (for pending messages)
  Future<ChatMessage?> getMessageByLocalId(String localId) async {
    final db = await _chatDatabase.database;
    final results = await db.query(
      'messages',
      where: 'local_id = ?',
      whereArgs: [localId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return MessageEntity.fromMap(results.first).toChatMessage();
  }

  /// Update message status
  Future<void> updateMessageStatus(String messageId, String status) async {
    final db = await _chatDatabase.database;
    await db.update(
      'messages',
      {'status': status},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  /// Update message ID (when server returns real ID for pending message)
  Future<void> updateMessageId(String localId, String serverId) async {
    final db = await _chatDatabase.database;
    await db.update(
      'messages',
      {'id': serverId, 'is_pending': 0, 'status': 'sent'},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  /// Mark messages as read in a chat room
  Future<void> markMessagesAsRead(String chatRoomId) async {
    final db = await _chatDatabase.database;
    await db.update(
      'messages',
      {'is_read': 1, 'status': 'read'},
      where: 'chat_room_id = ? AND is_me = 0',
      whereArgs: [chatRoomId],
    );
  }

  /// Get unread count for a chat room
  Future<int> getUnreadCount(String chatRoomId) async {
    final db = await _chatDatabase.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM messages WHERE chat_room_id = ? AND is_read = 0 AND is_me = 0',
      [chatRoomId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get all pending messages (for retry on reconnection)
  Future<List<MessageEntity>> getPendingMessages() async {
    final db = await _chatDatabase.database;
    final results = await db.query(
      'messages',
      where: 'is_pending = 1',
      orderBy: 'created_at ASC',
    );

    return results.map((row) => MessageEntity.fromMap(row)).toList();
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    final db = await _chatDatabase.database;
    await db.delete('messages', where: 'id = ?', whereArgs: [messageId]);
  }

  /// Get message count for a chat room
  Future<int> getMessageCount(String chatRoomId) async {
    final db = await _chatDatabase.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM messages WHERE chat_room_id = ?',
      [chatRoomId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Check if we have messages for a chat room
  Future<bool> hasMessages(String chatRoomId) async {
    final count = await getMessageCount(chatRoomId);
    return count > 0;
  }

  /// Get oldest message timestamp for a chat room
  Future<int?> getOldestMessageSortTimestamp(String chatRoomId) async {
    final db = await _chatDatabase.database;
    final result = await db.rawQuery(
      'SELECT sort_timestamp FROM messages WHERE chat_room_id = ? ORDER BY sort_timestamp ASC LIMIT 1',
      [chatRoomId],
    );
    if (result.isEmpty) return null;
    return result.first['sort_timestamp'] as int?;
  }

  /// Get sort_timestamp for a specific message by ID
  Future<int?> getMessageSortTimestamp(String messageId) async {
    final db = await _chatDatabase.database;
    final result = await db.rawQuery(
      'SELECT sort_timestamp FROM messages WHERE id = ? LIMIT 1',
      [messageId],
    );
    if (result.isEmpty) return null;
    return result.first['sort_timestamp'] as int?;
  }

  // ==================== CHAT ROOM OPERATIONS ====================

  /// Insert or update a chat room
  Future<void> upsertChatRoom(ChatRoomEntity room) async {
    final db = await _chatDatabase.database;
    await db.insert(
      'chat_rooms',
      room.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert multiple chat rooms
  Future<void> upsertChatRooms(List<ChatRoomEntity> rooms) async {
    if (rooms.isEmpty) return;

    final db = await _chatDatabase.database;
    final batch = db.batch();

    for (final room in rooms) {
      batch.insert(
        'chat_rooms',
        room.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Get all chat rooms
  Future<List<ChatRoom>> getAllChatRooms() async {
    final db = await _chatDatabase.database;
    final results = await db.query(
      'chat_rooms',
      orderBy: 'last_message_time DESC',
    );

    return results
        .map((row) => ChatRoomEntity.fromMap(row).toChatRoom())
        .toList();
  }

  /// Get a single chat room by ID
  Future<ChatRoom?> getChatRoomById(String chatRoomId) async {
    final db = await _chatDatabase.database;
    final results = await db.query(
      'chat_rooms',
      where: 'id = ?',
      whereArgs: [chatRoomId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return ChatRoomEntity.fromMap(results.first).toChatRoom();
  }

  /// Update unread count for a chat room
  Future<void> updateUnreadCount(String chatRoomId, int count) async {
    final db = await _chatDatabase.database;
    await db.update(
      'chat_rooms',
      {'unread_count': count},
      where: 'id = ?',
      whereArgs: [chatRoomId],
    );
  }

  /// Increment unread count for a chat room
  Future<void> incrementUnreadCount(String chatRoomId) async {
    final db = await _chatDatabase.database;
    await db.rawUpdate(
      'UPDATE chat_rooms SET unread_count = unread_count + 1 WHERE id = ?',
      [chatRoomId],
    );
  }

  /// Reset unread count when chat is opened
  Future<void> resetUnreadCount(String chatRoomId) async {
    await updateUnreadCount(chatRoomId, 0);
  }

  /// Update last message for a chat room
  Future<void> updateLastMessage(
    String chatRoomId, {
    required String message,
    required String messageType,
    required String timestamp,
  }) async {
    final db = await _chatDatabase.database;
    await db.update(
      'chat_rooms',
      {
        'last_message': message,
        'last_message_type': messageType,
        'last_message_time': timestamp,
        'updated_at': timestamp,
      },
      where: 'id = ?',
      whereArgs: [chatRoomId],
    );
  }

  // ==================== PENDING MESSAGES QUEUE ====================

  /// Add message to pending queue
  Future<void> addToPendingQueue(PendingMessageEntity pending) async {
    final db = await _chatDatabase.database;
    await db.insert(
      'pending_messages',
      pending.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all pending messages from queue
  Future<List<PendingMessageEntity>> getPendingQueue() async {
    final db = await _chatDatabase.database;
    final results = await db.query(
      'pending_messages',
      orderBy: 'created_at ASC',
    );

    return results.map((row) => PendingMessageEntity.fromMap(row)).toList();
  }

  /// Remove message from pending queue
  Future<void> removeFromPendingQueue(String localId) async {
    final db = await _chatDatabase.database;
    await db.delete(
      'pending_messages',
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  /// Increment retry count for pending message
  Future<void> incrementRetryCount(String localId) async {
    final db = await _chatDatabase.database;
    await db.rawUpdate(
      'UPDATE pending_messages SET retry_count = retry_count + 1 WHERE local_id = ?',
      [localId],
    );
  }

  /// Clear pending queue
  Future<void> clearPendingQueue() async {
    final db = await _chatDatabase.database;
    await db.delete('pending_messages');
  }

  // ==================== CACHE CLEANUP ====================

  /// Delete old messages to keep cache size under control
  /// Keeps only the latest [maxMessagesPerChat] messages per chat
  Future<void> cleanupOldMessages(String chatRoomId) async {
    final db = await _chatDatabase.database;
    final count = await getMessageCount(chatRoomId);

    if (count <= maxMessagesPerChat) return;

    final toDelete = count - maxMessagesPerChat;

    // Delete oldest messages
    await db.rawDelete(
      '''
      DELETE FROM messages 
      WHERE id IN (
        SELECT id FROM messages 
        WHERE chat_room_id = ? 
        ORDER BY sort_timestamp ASC 
        LIMIT ?
      )
    ''',
      [chatRoomId, toDelete],
    );

    print('🧹 Cleaned up $toDelete old messages from chat $chatRoomId');
  }

  /// Run cleanup for all chat rooms
  Future<void> cleanupAllChats() async {
    final db = await _chatDatabase.database;
    final chatRooms = await db.query('chat_rooms', columns: ['id']);

    for (final room in chatRooms) {
      final chatRoomId = room['id'] as String;
      await cleanupOldMessages(chatRoomId);
    }
  }

  /// Clear all messages for a chat room
  Future<void> clearChatMessages(String chatRoomId) async {
    final db = await _chatDatabase.database;
    await db.delete(
      'messages',
      where: 'chat_room_id = ?',
      whereArgs: [chatRoomId],
    );
  }

  /// Clear all data (for logout)
  Future<void> clearAllData() async {
    await _chatDatabase.clearAll();
  }

  // ==================== SYNC HELPERS ====================

  /// Get the latest message sort_timestamp for a chat (for sync)
  Future<int?> getLatestMessageSortTimestamp(String chatRoomId) async {
    final db = await _chatDatabase.database;
    final result = await db.rawQuery(
      'SELECT sort_timestamp FROM messages WHERE chat_room_id = ? AND is_pending = 0 ORDER BY sort_timestamp DESC LIMIT 1',
      [chatRoomId],
    );
    if (result.isEmpty) return null;
    return result.first['sort_timestamp'] as int?;
  }

  /// Check if a message already exists
  Future<bool> messageExists(String messageId) async {
    final db = await _chatDatabase.database;
    final result = await db.rawQuery(
      'SELECT 1 FROM messages WHERE id = ? LIMIT 1',
      [messageId],
    );
    return result.isNotEmpty;
  }

  /// Insert only new messages (skip duplicates)
  Future<int> insertNewMessages(List<ChatMessage> messages) async {
    if (messages.isEmpty) return 0;

    int insertedCount = 0;
    final db = await _chatDatabase.database;

    for (final message in messages) {
      final exists = await messageExists(message.id);
      if (!exists) {
        await db.insert(
          'messages',
          MessageEntity.fromChatMessage(message).toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        insertedCount++;
      }
    }

    return insertedCount;
  }
}
