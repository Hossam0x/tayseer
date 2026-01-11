import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/domain/repositories/i_chat_repository.dart';

/// Use case for loading initial messages (local-first)
/// Returns cached messages immediately, then syncs with server in background
class LoadMessagesUseCase {
  final IChatRepository _repository;

  const LoadMessagesUseCase(this._repository);

  /// Execute the use case
  /// Returns list of messages from local cache
  Future<List<ChatMessage>> call(String chatRoomId) async {
    return await _repository.loadInitialMessages(chatRoomId);
  }

  /// Subscribe to message updates for reactive UI
  Stream<List<ChatMessage>> watch(String chatRoomId) {
    return _repository.watchMessages(chatRoomId);
  }

  /// Mark chat as read when opened
  Future<void> markAsRead(String chatRoomId) async {
    await _repository.markChatAsRead(chatRoomId);
  }
}
