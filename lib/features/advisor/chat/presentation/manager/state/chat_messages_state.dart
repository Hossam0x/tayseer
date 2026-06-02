import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/typing_model.dart';

part 'chat_messages_state.freezed.dart';

/// Enhanced state for local-first chat messages using Freezed
/// Provides immutable state with union types for better pattern matching
@freezed
class ChatMessagesState with _$ChatMessagesState {
  const ChatMessagesState._();

  /// Initial state before loading
  const factory ChatMessagesState.initial({
    @Default(false) bool isBlocked,
  }) = ChatMessagesInitial;

  /// Loading state for initial messages
  const factory ChatMessagesState.loading({
    @Default(false) bool isBlocked,
  }) = ChatMessagesLoading;

  /// Loaded state with all chat data
  const factory ChatMessagesState.loaded({
    /// All messages in the current chat (from local DB)
    required List<ChatMessage> messages,

    /// Whether there are more older messages to load
    @Default(true) bool hasMoreMessages,

    /// Whether the chat is connected/online
    @Default(true) bool isOnline,

    /// Number of pending messages (unsent)
    @Default(0) int pendingCount,

    /// Whether the other user is blocked
    @Default(false) bool isBlocked,

    /// Typing indicator state
    @Default(false) bool isUserTyping,

    /// Typing user info
    TypingModel? typingInfo,

    /// Message being replied to
    ChatMessage? replyingToMessage,

    /// Pagination state for loading older messages
    @Default(CubitStates.initial) CubitStates paginationState,

    /// Media sending statew
    @Default(CubitStates.initial) CubitStates sendMediaState,

    /// Free chat minutes left (for user side)
    int? freeChatMinsLeft,

    /// Chat expiry date (for user-user chat)
    DateTime? chatExpiresAt,
  }) = ChatMessagesLoaded;

  /// Loading more messages (pagination)
  const factory ChatMessagesState.loadingMore({
    required List<ChatMessage> messages,
    @Default(true) bool hasMoreMessages,
    @Default(true) bool isOnline,
    @Default(0) int pendingCount,
    @Default(false) bool isBlocked,
    @Default(false) bool isUserTyping,
    TypingModel? typingInfo,
    ChatMessage? replyingToMessage,
    int? freeChatMinsLeft,
  }) = ChatMessagesLoadingMore;

  /// Failure state
  const factory ChatMessagesState.failure({
    required String message,

    /// Cached messages to show while in error state
    List<ChatMessage>? cachedMessages,
  }) = ChatMessagesFailure;

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER GETTERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Get messages from any state that has them
  List<ChatMessage> get messagesOrEmpty => maybeMap(
    loaded: (state) => state.messages,
    loadingMore: (state) => state.messages,
    failure: (state) => state.cachedMessages ?? [],
    orElse: () => [],
  );

  /// Check if we can load more messages
  bool get canLoadMore => maybeMap(
    loaded: (state) =>
        state.hasMoreMessages && state.paginationState != CubitStates.loading,
    loadingMore: (_) => false,
    orElse: () => false,
  );

  /// Check if currently loading (initial or pagination)
  bool get isLoading => maybeMap(
    loading: (_) => true,
    loadingMore: (_) => true,
    orElse: () => false,
  );

  /// Check if in blocked state
  bool get isBlockedStatus => maybeMap(
    initial: (state) => state.isBlocked,
    loading: (state) => state.isBlocked,
    loaded: (state) => state.isBlocked,
    loadingMore: (state) => state.isBlocked,
    orElse: () => false,
  );

  /// Get a specific message by ID
  ChatMessage? getMessageById(String id) {
    try {
      return messagesOrEmpty.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get a specific message by local ID
  ChatMessage? getMessageByLocalId(String localId) {
    try {
      return messagesOrEmpty.firstWhere(
        (m) => m.id == localId || m.id.startsWith('temp_$localId'),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get loading state for compatibility
  CubitStates get loadingState => map(
    initial: (_) => CubitStates.initial,
    loading: (_) => CubitStates.loading,
    loaded: (_) => CubitStates.success,
    loadingMore: (_) => CubitStates.success,
    failure: (_) => CubitStates.failure,
  );

  /// Get error message
  String? get errorMessage =>
      maybeMap(failure: (state) => state.message, orElse: () => null);

  /// Check online status
  bool get isOnline => maybeMap(
    loaded: (state) => state.isOnline,
    loadingMore: (state) => state.isOnline,
    orElse: () => true,
  );

  /// Get pending messages count
  int get pendingCount => maybeMap(
    loaded: (state) => state.pendingCount,
    loadingMore: (state) => state.pendingCount,
    orElse: () => 0,
  );

  /// Get free chat minutes left
  int? get freeChatMinutes => maybeMap(
    loaded: (state) => state.freeChatMinsLeft,
    loadingMore: (state) => state.freeChatMinsLeft,
    orElse: () => null,
  );

  /// Get chat expiry date
  DateTime? get chatExpiresAt => maybeMap(
    loaded: (state) => state.chatExpiresAt,
    orElse: () => null,
  );

  /// Get messages directly (alias for messagesOrEmpty for easier migration)
  List<ChatMessage> get messages => messagesOrEmpty;

  /// Alias for isBlockedStatus for compatibility
  bool get isBlocked => isBlockedStatus;
}
