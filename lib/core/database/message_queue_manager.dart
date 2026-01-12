import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tayseer/core/database/entities/pending_message_entity.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/chat/data/local/chat_local_datasource.dart';

/// Message Queue Manager for Offline Support
///
/// Handles:
/// - Storing messages when offline
/// - Auto-retry when connection restored
/// - Max retry attempts
/// - Cleanup of failed messages
class MessageQueueManager {
  final ChatLocalDataSource _localDataSource;
  final tayseerSocketHelper _socketHelper;
  final Connectivity _connectivity = Connectivity();

  StreamSubscription? _connectivitySubscription;
  Timer? _retryTimer;

  static const int maxRetryAttempts = 5;
  static const Duration retryInterval = Duration(seconds: 30);

  bool _isRetrying = false;
  bool _isOnline = true;

  MessageQueueManager(this._localDataSource)
    : _socketHelper = getIt.get<tayseerSocketHelper>() {
    _setupConnectivityListener();
  }

  /// Setup connectivity listener
  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final wasOnline = _isOnline;
      _isOnline =
          results.isNotEmpty && !results.contains(ConnectivityResult.none);

      log('📶 MessageQueue: Connectivity changed - Online: $_isOnline');

      // If we just came back online, retry pending messages
      if (_isOnline && !wasOnline) {
        log('📶 MessageQueue: Back online - processing queue');
        processQueue();
      }
    });
  }

  /// Add a message to the pending queue
  Future<void> enqueue(PendingMessageEntity message) async {
    await _localDataSource.addToPendingQueue(message);
    log('📥 MessageQueue: Enqueued message ${message.localId}');

    // Try to send immediately if online
    if (_isOnline && _socketHelper.isConnected) {
      processQueue();
    }
  }

  /// Process all pending messages in the queue
  Future<void> processQueue() async {
    if (_isRetrying) {
      log('⏳ MessageQueue: Already processing queue');
      return;
    }

    _isRetrying = true;

    try {
      final pendingMessages = await _localDataSource.getPendingQueue();

      if (pendingMessages.isEmpty) {
        log('✅ MessageQueue: Queue is empty');
        _isRetrying = false;
        return;
      }

      log('📤 MessageQueue: Processing ${pendingMessages.length} messages');

      for (final pending in pendingMessages) {
        // Skip if max retries exceeded
        if (pending.retryCount >= maxRetryAttempts) {
          log('❌ MessageQueue: Max retries exceeded for ${pending.localId}');
          await _localDataSource.removeFromPendingQueue(pending.localId);
          continue;
        }

        // Check if socket is connected
        if (!_socketHelper.isConnected) {
          log('⚠️ MessageQueue: Socket not connected, stopping');
          break;
        }

        await _sendPendingMessage(pending);

        // Small delay between messages
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      log('❌ MessageQueue: Error processing queue: $e');
    } finally {
      _isRetrying = false;
    }
  }

  /// Send a single pending message
  Future<void> _sendPendingMessage(PendingMessageEntity pending) async {
    log(
      '📤 MessageQueue: Sending ${pending.localId} (attempt ${pending.retryCount + 1})',
    );

    // Increment retry count
    await _localDataSource.incrementRetryCount(pending.localId);

    // Extract tempId from localId (format: "temp_<uuid>")
    final tempId = pending.localId.startsWith('temp_')
        ? pending.localId.substring(5)
        : pending.localId;

    final messageData = <String, dynamic>{
      'receiverId': pending.receiverId,
      'content': pending.content,
      'tempId': tempId, // ✅ Include tempId for reliable matching
    };

    if (pending.replyMessageId != null) {
      messageData['replyMessageId'] = pending.replyMessageId;
    }

    _socketHelper.send('send_message', messageData, (ack) {
      log('✅ MessageQueue: ACK for ${pending.localId}: $ack');
      // Note: Actual removal from queue happens when server confirms via new_message event
    });
  }

  /// Remove a message from the queue (called when server confirms)
  Future<void> dequeue(String localId) async {
    await _localDataSource.removeFromPendingQueue(localId);
    log('🗑️ MessageQueue: Dequeued $localId');
  }

  /// Get pending messages count
  Future<int> getPendingCount() async {
    final pending = await _localDataSource.getPendingQueue();
    return pending.length;
  }

  /// Clear all pending messages
  Future<void> clearQueue() async {
    await _localDataSource.clearPendingQueue();
    log('🧹 MessageQueue: Queue cleared');
  }

  /// Start periodic retry timer
  void startRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(retryInterval, (_) {
      if (_isOnline) {
        processQueue();
      }
    });
    log('⏰ MessageQueue: Retry timer started');
  }

  /// Stop periodic retry timer
  void stopRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
    log('⏰ MessageQueue: Retry timer stopped');
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
    log('🔴 MessageQueue: Disposed');
  }
}
