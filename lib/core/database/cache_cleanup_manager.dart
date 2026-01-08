import 'dart:async';
import 'dart:developer';

import 'package:tayseer/features/advisor/chat/data/local/chat_local_datasource.dart';

/// Cache Cleanup Manager
///
/// Handles automatic cleanup of old messages to prevent database bloat.
/// Strategy:
/// - Keep max 20,000 messages per chat room
/// - Delete oldest messages when threshold exceeded
/// - Run cleanup on app startup and periodically
class CacheCleanupManager {
  final ChatLocalDataSource _localDataSource;
  Timer? _cleanupTimer;

  /// Run cleanup every 24 hours
  static const Duration cleanupInterval = Duration(hours: 24);

  /// Max messages per chat room
  static const int maxMessagesPerChat = 20000;

  CacheCleanupManager(this._localDataSource);

  /// Initialize and run initial cleanup
  Future<void> initialize() async {
    log('🧹 CacheCleanup: Initializing...');

    // Run initial cleanup
    await runCleanup();

    // Start periodic cleanup
    startPeriodicCleanup();
  }

  /// Run cleanup for all chat rooms
  Future<void> runCleanup() async {
    try {
      log('🧹 CacheCleanup: Running cleanup...');
      final startTime = DateTime.now();

      await _localDataSource.cleanupAllChats();

      final duration = DateTime.now().difference(startTime);
      log('✅ CacheCleanup: Completed in ${duration.inMilliseconds}ms');
    } catch (e) {
      log('❌ CacheCleanup: Error during cleanup: $e');
    }
  }

  /// Run cleanup for a specific chat room
  Future<void> cleanupChat(String chatRoomId) async {
    try {
      log('🧹 CacheCleanup: Cleaning chat $chatRoomId...');
      await _localDataSource.cleanupOldMessages(chatRoomId);
      log('✅ CacheCleanup: Chat $chatRoomId cleaned');
    } catch (e) {
      log('❌ CacheCleanup: Error cleaning chat $chatRoomId: $e');
    }
  }

  /// Start periodic cleanup timer
  void startPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(cleanupInterval, (_) {
      runCleanup();
    });
    log(
      '⏰ CacheCleanup: Periodic cleanup started (every ${cleanupInterval.inHours}h)',
    );
  }

  /// Stop periodic cleanup timer
  void stopPeriodicCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    log('⏰ CacheCleanup: Periodic cleanup stopped');
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      // This would require additional methods in local datasource
      // For now, return basic info
      return {
        'maxMessagesPerChat': maxMessagesPerChat,
        'cleanupInterval': '${cleanupInterval.inHours} hours',
        'isPeriodicCleanupActive': _cleanupTimer != null,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    log('🔴 CacheCleanup: Disposed');
  }
}
