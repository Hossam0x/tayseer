import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/chat/domain/repositories/i_chat_repository.dart';

/// Parameters for deleting messages
class DeleteMessagesParams {
  final List<String> messageIds;
  final String chatRoomId;
  final String deleteType; // 'me' or 'everyone'

  const DeleteMessagesParams({
    required this.messageIds,
    required this.chatRoomId,
    required this.deleteType,
  });

  /// Factory for deleting a single message
  factory DeleteMessagesParams.single({
    required String messageId,
    required String chatRoomId,
    required String deleteType,
  }) {
    return DeleteMessagesParams(
      messageIds: [messageId],
      chatRoomId: chatRoomId,
      deleteType: deleteType,
    );
  }

  bool get isSingleMessage => messageIds.length == 1;
}

/// Use case for deleting messages
/// Supports single and multiple message deletion
class DeleteMessagesUseCase {
  final IChatRepository _repository;

  const DeleteMessagesUseCase(this._repository);

  /// Execute the use case
  /// Automatically uses single or multiple delete based on count
  Future<Either<String, void>> call(DeleteMessagesParams params) async {
    if (params.messageIds.isEmpty) {
      return const Left('لا توجد رسائل للحذف');
    }

    if (params.isSingleMessage) {
      return await _repository.deleteMessage(
        messageId: params.messageIds.first,
        chatRoomId: params.chatRoomId,
        deleteType: params.deleteType,
      );
    } else {
      return await _repository.deleteMessages(
        messageIds: params.messageIds,
        chatRoomId: params.chatRoomId,
        deleteType: params.deleteType,
      );
    }
  }

  /// Delete message from local DB only (for socket events)
  Future<void> deleteLocally(String messageId) async {
    await _repository.deleteMessageLocally(messageId);
  }
}
