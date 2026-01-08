import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite Database Helper for Chat Feature
/// This is the single source of truth for all chat data
class ChatDatabase {
  static final ChatDatabase instance = ChatDatabase._init();
  static Database? _database;

  ChatDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tayseer_chat.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Upgraded for sort_timestamp
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Messages Table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        local_id TEXT,
        chat_room_id TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        sender_name TEXT,
        sender_image TEXT,
        sender_type TEXT,
        is_me INTEGER NOT NULL DEFAULT 0,
        content TEXT,
        message_type TEXT NOT NULL DEFAULT 'text',
        created_at TEXT NOT NULL,
        updated_at TEXT,
        is_read INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'sending',
        reply_message_id TEXT,
        reply_message TEXT,
        is_reply INTEGER NOT NULL DEFAULT 0,
        is_pending INTEGER NOT NULL DEFAULT 0,
        sort_timestamp INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create indexes for fast queries
    await db.execute(
      'CREATE INDEX idx_messages_chat_room ON messages(chat_room_id)',
    );
    await db.execute(
      'CREATE INDEX idx_messages_sort ON messages(sort_timestamp DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_messages_pending ON messages(is_pending)',
    );
    await db.execute(
      'CREATE INDEX idx_messages_local_id ON messages(local_id)',
    );

    // Chat Rooms Table
    await db.execute('''
      CREATE TABLE chat_rooms (
        id TEXT PRIMARY KEY,
        other_user_id TEXT,
        other_user_name TEXT,
        other_user_image TEXT,
        other_user_type TEXT,
        last_message TEXT,
        last_message_type TEXT,
        last_message_time TEXT,
        unread_count INTEGER NOT NULL DEFAULT 0,
        status TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_chat_rooms_updated ON chat_rooms(updated_at DESC)',
    );

    // Pending Messages Queue (for offline support)
    await db.execute('''
      CREATE TABLE pending_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_id TEXT NOT NULL UNIQUE,
        chat_room_id TEXT NOT NULL,
        receiver_id TEXT NOT NULL,
        content TEXT NOT NULL,
        message_type TEXT NOT NULL DEFAULT 'text',
        reply_message_id TEXT,
        created_at TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0,
        media_paths TEXT
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_pending_created ON pending_messages(created_at)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations
    if (oldVersion < 2) {
      // Add sort_timestamp column
      await db.execute(
        'ALTER TABLE messages ADD COLUMN sort_timestamp INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'CREATE INDEX idx_messages_sort ON messages(sort_timestamp DESC)',
      );
      // Drop old index if exists
      try {
        await db.execute('DROP INDEX IF EXISTS idx_messages_created_at');
      } catch (_) {}
    }
  }

  /// Close database connection
  Future<void> close() async {
    final db = await instance.database;
    db.close();
    _database = null;
  }

  /// Clear all data (for logout)
  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('messages');
    await db.delete('chat_rooms');
    await db.delete('pending_messages');
  }
}
