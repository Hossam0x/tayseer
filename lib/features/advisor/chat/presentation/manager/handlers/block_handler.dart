import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/domain/chat_domain.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/handlers/message_state_handler.dart';

// Consts (ensure these are available or move them here if tied to logic)
const String kBlockSystemMessage = 'تم حظر المستخدم';
const String kUnblockSystemMessage = 'تم إلغاء حظر المستخدم';

class BlockHandler {
  final BlockUserUseCase _blockUserUseCase;
  final UnblockUserUseCase _unblockUserUseCase;
  final MessageStateHandler _messageStateHandler;
  final String _listenerId;

  // State Updaters
  final void Function(bool isBlocked) onBlockStatusChanged;
  final void Function(List<ChatMessage> messages) onMessagesUpdated;

  BlockHandler({
    required BlockUserUseCase blockUserUseCase,
    required UnblockUserUseCase unblockUserUseCase,
    required MessageStateHandler messageStateHandler,
    required String listenerId,
    required this.onBlockStatusChanged,
    required this.onMessagesUpdated,
  }) : _blockUserUseCase = blockUserUseCase,
       _unblockUserUseCase = unblockUserUseCase,
       _messageStateHandler = messageStateHandler,
       _listenerId = listenerId;

  bool checkBlockStatusFromMessages(
    List<ChatMessage> messages,
    bool currentBlockedStatus,
  ) {
    for (int i = messages.length - 1; i >= 0; i--) {
      final msg = messages[i];
      if (msg.messageType == 'system') {
        if (msg.action.isUnblock) return false;
        if (msg.action.isBlock) return true;
      }
    }
    return currentBlockedStatus; // Fallback to current state
  }

  Future<Either<String, String>> blockUser({
    required String chatRoomId,
    required String blockedId,
  }) async {
    try {
      log('🚫 [$_listenerId] Blocking user: $blockedId');

      onBlockStatusChanged(true);

      final optimisticResult = await _blockUserUseCase.createOptimisticMessage(
        chatRoomId: chatRoomId,
        blockedId: blockedId,
      );

      _messageStateHandler.addPendingSystemMessageContent(
        kBlockSystemMessage.trim(),
      );

      final currentMessages = _messageStateHandler.getCurrentMessages();
      final updatedMessages = [
        ...currentMessages,
        optimisticResult.systemMessage,
      ];
      onMessagesUpdated(updatedMessages);

      log(
        '📤 [$_listenerId] Block system message saved locally: ${optimisticResult.localId}',
      );

      final result = await _blockUserUseCase.call(blockedId: blockedId);
      return result.fold(
        (error) {
          log('❌ [$_listenerId] Block user failed: $error');
          onBlockStatusChanged(false);
          _removeLocalSystemMessage(optimisticResult.localId);
          _messageStateHandler.removePendingSystemMessageContent(
            kBlockSystemMessage.trim(),
          );
          return Left(error);
        },
        (successMessage) {
          log('✅ [$_listenerId] Block user success: $successMessage');
          return Right(successMessage);
        },
      );
    } catch (e) {
      log('❌ [$_listenerId] Block user error: $e');
      onBlockStatusChanged(false);
      return const Left('حدث خطأ أثناء حظر المستخدم');
    }
  }

  Future<Either<String, String>> unblockUser({
    required String chatRoomId,
    required String blockedId,
  }) async {
    try {
      log('✅ [$_listenerId] Unblocking user: $blockedId');

      onBlockStatusChanged(false);

      final optimisticResult = await _unblockUserUseCase
          .createOptimisticMessage(
            chatRoomId: chatRoomId,
            blockedId: blockedId,
          );

      _messageStateHandler.addPendingSystemMessageContent(
        kUnblockSystemMessage.trim(),
      );

      final currentMessages = _messageStateHandler.getCurrentMessages();
      final updatedMessages = [
        ...currentMessages,
        optimisticResult.systemMessage,
      ];
      onMessagesUpdated(updatedMessages);

      log(
        '📤 [$_listenerId] Unblock system message saved locally: ${optimisticResult.localId}',
      );

      final result = await _unblockUserUseCase.call(blockedId: blockedId);
      return result.fold(
        (error) {
          log('❌ [$_listenerId] Unblock user failed: $error');
          onBlockStatusChanged(true);
          _removeLocalSystemMessage(optimisticResult.localId);
          _messageStateHandler.removePendingSystemMessageContent(
            kUnblockSystemMessage.trim(),
          );
          return Left(error);
        },
        (successMessage) {
          log('✅ [$_listenerId] Unblock user success: $successMessage');
          return Right(successMessage);
        },
      );
    } catch (e) {
      log('❌ [$_listenerId] Unblock user error: $e');
      onBlockStatusChanged(true);
      return const Left('حدث خطأ أثناء إلغاء حظر المستخدم');
    }
  }

  void _removeLocalSystemMessage(String localId) {
    final currentMessages = _messageStateHandler.getCurrentMessages();
    final updatedMessages = currentMessages
        .where((m) => m.id != localId)
        .toList();
    onMessagesUpdated(updatedMessages);

    // We need to delete it locally via handler or usecase
    // But handler handles message deletion via event.
    // Here we are manually reverting. We can use messageStateHandler to delete.
    _messageStateHandler.handleMessageDeleted(
      localId,
    ); // This updates state too, so redundant update but safe.
    // Wait, handleMessageDeleted calls deleteLocally usecase.
    // The previous implementation called deleteLocally directly.
    log('🗑️ [$_listenerId] Removed local system message: $localId');
  }
}
