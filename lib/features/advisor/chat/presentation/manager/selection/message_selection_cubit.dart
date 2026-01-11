import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/selection/message_selection_state.dart';

/// Cubit for managing message selection mode
class MessageSelectionCubit extends Cubit<MessageSelectionState> {
  MessageSelectionCubit() : super(const MessageSelectionState());

  /// Enter selection mode with an initial message
  void enterSelectionMode(ChatMessage message) {
    emit(
      MessageSelectionState(
        isSelectionMode: true,
        selectedMessageIds: {message.id},
        selectedMessages: [message],
      ),
    );
  }

  /// Exit selection mode and clear all selections
  void exitSelectionMode() {
    emit(const MessageSelectionState());
  }

  /// Toggle selection of a message
  void toggleMessageSelection(ChatMessage message) {
    if (!state.isSelectionMode) return;

    final newSelectedIds = Set<String>.from(state.selectedMessageIds);
    final newSelectedMessages = List<ChatMessage>.from(state.selectedMessages);

    if (newSelectedIds.contains(message.id)) {
      // Deselect
      newSelectedIds.remove(message.id);
      newSelectedMessages.removeWhere((msg) => msg.id == message.id);
    } else {
      // Select
      newSelectedIds.add(message.id);
      newSelectedMessages.add(message);
    }

    // If no messages selected, exit selection mode
    if (newSelectedIds.isEmpty) {
      exitSelectionMode();
      return;
    }

    emit(
      state.copyWith(
        selectedMessageIds: newSelectedIds,
        selectedMessages: newSelectedMessages,
      ),
    );
  }

  /// Select a message (without toggle)
  void selectMessage(ChatMessage message) {
    if (!state.isSelectionMode) return;
    if (state.selectedMessageIds.contains(message.id)) return;

    final newSelectedIds = Set<String>.from(state.selectedMessageIds)
      ..add(message.id);
    final newSelectedMessages = List<ChatMessage>.from(state.selectedMessages)
      ..add(message);

    emit(
      state.copyWith(
        selectedMessageIds: newSelectedIds,
        selectedMessages: newSelectedMessages,
      ),
    );
  }

  /// Deselect a message
  void deselectMessage(String messageId) {
    if (!state.isSelectionMode) return;

    final newSelectedIds = Set<String>.from(state.selectedMessageIds)
      ..remove(messageId);
    final newSelectedMessages = List<ChatMessage>.from(state.selectedMessages)
      ..removeWhere((msg) => msg.id == messageId);

    if (newSelectedIds.isEmpty) {
      exitSelectionMode();
      return;
    }

    emit(
      state.copyWith(
        selectedMessageIds: newSelectedIds,
        selectedMessages: newSelectedMessages,
      ),
    );
  }

  /// Select all messages
  void selectAll(List<ChatMessage> allMessages) {
    if (!state.isSelectionMode) return;

    emit(
      state.copyWith(
        selectedMessageIds: allMessages.map((m) => m.id).toSet(),
        selectedMessages: allMessages,
      ),
    );
  }

  /// Clear all selections (but stay in selection mode)
  void clearSelections() {
    if (!state.isSelectionMode) return;

    emit(state.copyWith(selectedMessageIds: {}, selectedMessages: []));
  }

  /// Get list of selected message IDs
  List<String> getSelectedMessageIds() {
    return state.selectedMessageIds.toList();
  }
}
