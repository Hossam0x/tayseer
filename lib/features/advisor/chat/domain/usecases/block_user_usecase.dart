import 'package:dartz/dartz.dart';
import 'package:tayseer/core/enum/message_status_enum.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/domain/repositories/i_chat_repository.dart';

/// System message content for block action
const String kBlockSystemMessage =
    ' المستخدم محظور من إرسال الرسائل في هذه الدردشة';

/// Result of blocking a user
class BlockUserResult {
  final ChatMessage systemMessage;
  final String localId;

  const BlockUserResult({required this.systemMessage, required this.localId});
}

/// Use case for blocking a user
/// Creates optimistic system message and calls API
class BlockUserUseCase {
  final IChatRepository _repository;

  const BlockUserUseCase(this._repository);

  /// Create optimistic system message for immediate UI update
  Future<BlockUserResult> createOptimisticMessage({
    required String chatRoomId,
    required String blockedId,
  }) async {
    final localId = 'temp_block_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now().toIso8601String();

    final systemMessage = ChatMessage(
      id: localId,
      chatRoomId: chatRoomId,
      senderId: blockedId,
      senderName: '',
      senderImage: '',
      senderType: 'system',
      isMe: true,
      contentList: [kBlockSystemMessage],
      messageType: 'system',
      createdAt: 'الآن',
      updatedAt: now,
      isRead: false,
      status: MessageStatusEnum.sent,
      action: SystemMessageAction.block,
    );

    // Save to local DB
    await _repository.saveMessageLocally(systemMessage, localId: localId);

    return BlockUserResult(systemMessage: systemMessage, localId: localId);
  }

  /// Execute the actual block API call
  Future<Either<String, String>> call({required String blockedId}) async {
    return await _repository.blockUser(blockedId: blockedId);
  }

  /// Rollback on failure - remove optimistic message
  Future<void> rollback(String localId) async {
    await _repository.deleteMessageLocally(localId);
  }
}
