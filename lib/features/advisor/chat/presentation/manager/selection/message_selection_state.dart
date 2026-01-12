import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';

/// State for message selection mode
class MessageSelectionState extends Equatable {
  /// Whether selection mode is active
  final bool isSelectionMode;

  /// Set of selected message IDs
  final Set<String> selectedMessageIds;

  /// All selected messages (for easy access)
  final List<ChatMessage> selectedMessages;

  const MessageSelectionState({
    this.isSelectionMode = false,
    this.selectedMessageIds = const {},
    this.selectedMessages = const [],
  });

  /// Check if a message is selected
  bool isSelected(String messageId) => selectedMessageIds.contains(messageId);

  /// Get the count of selected messages
  int get selectionCount => selectedMessageIds.length;

  /// Check if all selected messages are from current user (for delete for all option)
  bool get canDeleteForAll =>
      selectedMessages.isNotEmpty &&
      selectedMessages.every((msg) => msg.isMe == true);

  MessageSelectionState copyWith({
    bool? isSelectionMode,
    Set<String>? selectedMessageIds,
    List<ChatMessage>? selectedMessages,
  }) {
    return MessageSelectionState(
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedMessageIds: selectedMessageIds ?? this.selectedMessageIds,
      selectedMessages: selectedMessages ?? this.selectedMessages,
    );
  }

  @override
  List<Object?> get props => [
    isSelectionMode,
    selectedMessageIds,
    selectedMessages,
  ];
}
