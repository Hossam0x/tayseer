import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/domain/repositories/i_chat_repository.dart';

/// Parameters for loading older messages
class LoadOlderMessagesParams {
  final String chatRoomId;
  final int cursorTimestamp;

  const LoadOlderMessagesParams({
    required this.chatRoomId,
    required this.cursorTimestamp,
  });
}

/// Use case for loading older messages (pagination)
/// Uses cursor-based pagination with sort_timestamp
class LoadOlderMessagesUseCase {
  final IChatRepository _repository;

  const LoadOlderMessagesUseCase(this._repository);

  /// Execute the use case
  /// Returns list of messages older than cursor
  Future<List<ChatMessage>> call(LoadOlderMessagesParams params) async {
    return await _repository.loadOlderMessages(
      params.chatRoomId,
      cursorTimestamp: params.cursorTimestamp,
    );
  }

  /// Get sort_timestamp for a message to use as cursor
  Future<int?> getCursorTimestamp(String messageId) async {
    return await _repository.getMessageSortTimestamp(messageId);
  }
}
