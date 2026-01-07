import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/typinn_model.dart';

/// Enhanced state for local-first chat messages
class ChatMessagesStateV2 {
  /// Loading state for initial messages
  final CubitStates? loadingState;

  /// Loading state for pagination (loading older messages)
  final CubitStates? paginationState;

  /// Loading state for sending media
  final CubitStates? sendMediaState;

  /// All messages in the current chat (from local DB)
  final List<ChatMessage> messages;

  /// Whether there are more older messages to load
  final bool hasMoreMessages;

  /// Error message if any
  final String? errorMessage;

  /// Typing indicator state
  final bool isUserTyping;

  /// Typing user info
  final TypinnModel? typingInfo;

  /// Message being replied to
  final ChatMessage? replyingToMessage;

  /// Whether the chat is connected/online
  final bool isOnline;

  /// Number of pending messages (unsent)
  final int pendingCount;

  ChatMessagesStateV2({
    this.loadingState,
    this.paginationState,
    this.sendMediaState,
    this.messages = const [],
    this.hasMoreMessages = true,
    this.errorMessage,
    this.isUserTyping = false,
    this.typingInfo,
    this.replyingToMessage,
    this.isOnline = true,
    this.pendingCount = 0,
  });

  ChatMessagesStateV2 copyWith({
    CubitStates? loadingState,
    CubitStates? paginationState,
    CubitStates? sendMediaState,
    List<ChatMessage>? messages,
    bool? hasMoreMessages,
    String? errorMessage,
    bool? isUserTyping,
    TypinnModel? typingInfo,
    bool clearTypingInfo = false,
    ChatMessage? replyingToMessage,
    bool clearReplyingToMessage = false,
    bool? isOnline,
    int? pendingCount,
  }) {
    return ChatMessagesStateV2(
      loadingState: loadingState ?? this.loadingState,
      paginationState: paginationState ?? this.paginationState,
      sendMediaState: sendMediaState ?? this.sendMediaState,
      messages: messages ?? this.messages,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      errorMessage: errorMessage ?? this.errorMessage,
      isUserTyping: isUserTyping ?? this.isUserTyping,
      typingInfo: clearTypingInfo ? null : (typingInfo ?? this.typingInfo),
      replyingToMessage: clearReplyingToMessage
          ? null
          : (replyingToMessage ?? this.replyingToMessage),
      isOnline: isOnline ?? this.isOnline,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }

  /// Get a specific message by ID (for BlocSelector)
  ChatMessage? getMessageById(String id) {
    try {
      return messages.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get a specific message by local ID (for pending messages)
  ChatMessage? getMessageByLocalId(String localId) {
    try {
      return messages.firstWhere(
        (m) => m.id == localId || m.id.startsWith('temp_$localId'),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() {
    return 'ChatMessagesStateV2(loadingState: $loadingState, messagesCount: ${messages.length}, '
        'hasMore: $hasMoreMessages, isTyping: $isUserTyping, isOnline: $isOnline, pending: $pendingCount)';
  }
}
