/// Chat Database exports for local-first architecture
///
/// This module provides SQLite-based storage for chat messages with:
/// - Local-first data loading (UI never waits for server)
/// - Cursor-based pagination using createdAt
/// - Offline message queue with auto-retry
/// - Automatic cache cleanup (max 20,000 messages per chat)

export 'chat_database.dart';
export 'cache_cleanup_manager.dart';
export 'message_queue_manager.dart';
export 'entities/message_entity.dart';
export 'entities/chat_room_entity.dart';
export 'entities/pending_message_entity.dart';
