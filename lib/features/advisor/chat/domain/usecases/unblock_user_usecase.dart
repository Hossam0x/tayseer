import 'package:dartz/dartz.dart';
import 'package:tayseer/core/enum/message_status_enum.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/domain/repositories/i_chat_repository.dart';

/// System message content for unblock action
const String kUnblockSystemMessage =
    'المستخدم غير محظور من إرسال الرسائل في هذه الدردشة';

/// Result of unblocking a user
class UnblockUserResult {
  final ChatMessage systemMessage;
  final String localId;

  const UnblockUserResult({required this.systemMessage, required this.localId});
}

/// Use case for unblocking a user
/// Creates optimistic system message and calls API
class UnblockUserUseCase {
  final IChatRepository _repository;

  const UnblockUserUseCase(this._repository);

  /// Create optimistic system message for immediate UI update
  Future<UnblockUserResult> createOptimisticMessage({
    required String chatRoomId,
    required String blockedId,
  }) async {
    final localId = 'temp_unblock_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now().toIso8601String();

    final systemMessage = ChatMessage(
      id: localId,
      chatRoomId: chatRoomId,
      senderId: blockedId,
      senderName: '',
      senderImage: '',
      senderType: 'system',
      isMe: true,
      contentList: [kUnblockSystemMessage],
      messageType: 'system',
      createdAt: 'الآن',
      updatedAt: now,
      isRead: false,
      status: MessageStatusEnum.sent,
      action: SystemMessageAction.unblock,
    );

    // Save to local DB
    await _repository.saveMessageLocally(systemMessage, localId: localId);

    return UnblockUserResult(systemMessage: systemMessage, localId: localId);
  }

  /// Execute the actual unblock API call
  Future<Either<String, String>> call({required String blockedId}) async {
    return await _repository.unblockUser(blockedId: blockedId);
  }

  /// Rollback on failure - remove optimistic message
  Future<void> rollback(String localId) async {
    await _repository.deleteMessageLocally(localId);
  }
}
