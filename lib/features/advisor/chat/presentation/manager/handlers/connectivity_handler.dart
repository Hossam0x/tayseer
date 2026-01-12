import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/chat/domain/repositories/i_chat_repository.dart';

class ConnectivityHandler {
  final Connectivity _connectivity;
  final IChatRepository _repo;
  final tayseerSocketHelper _socketHelper;
  final String _listenerId;

  StreamSubscription? _connectivitySubscription;

  // State Updaters
  final void Function(bool isOnline) onConnectivityChanged;

  ConnectivityHandler({
    required Connectivity connectivity,
    required IChatRepository repo,
    required tayseerSocketHelper socketHelper,
    required String listenerId,
    required this.onConnectivityChanged,
  }) : _connectivity = connectivity,
       _repo = repo,
       _socketHelper = socketHelper,
       _listenerId = listenerId;

  void setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) {
      final isOnline =
          results.isNotEmpty && !results.contains(ConnectivityResult.none);
      onConnectivityChanged(isOnline);

      if (isOnline) {
        log('📶 [$_listenerId] Back online - retrying pending messages');
        _retryPendingMessages();
      }
    });
  }

  Future<void> _retryPendingMessages() async {
    final pendingMessages = await _repo.getPendingMessages();

    if (pendingMessages.isEmpty) {
      log('📶 [$_listenerId] No pending messages to retry');
      return;
    }

    for (final pending in pendingMessages) {
      log('🔄 [$_listenerId] Retrying message: ${pending.localId}');

      final tempId = pending.localId.startsWith('temp_')
          ? pending.localId.substring(5)
          : pending.localId;

      final messageData = <String, dynamic>{
        'receiverId': pending.receiverId,
        'content': pending.content,
        'tempId': tempId,
      };

      if (pending.replyMessageId != null &&
          !pending.replyMessageId!.startsWith('temp_')) {
        messageData['replyMessageId'] = pending.replyMessageId;
      }

      _socketHelper.send('send_message', messageData, (ack) {
        log('✅ [$_listenerId] Retry ACK for ${pending.localId}: $ack');
      });
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
