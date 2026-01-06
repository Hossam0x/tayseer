import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/typinn_model.dart';

class ChatMessagesState {
  final CubitStates? getChatMessages;
  final CubitStates? sendMediaMessage;
  final List<ChatMessage>? messages;
  final dynamic pagination;
  final String? errorMessage;
  final ChatMessage? sentMessage;
  final bool isUserTyping;
  final TypinnModel? typingInfo;
  final ChatMessage? replyingToMessage; // ✅ الرسالة اللي بنرد عليها

  ChatMessagesState({
    this.getChatMessages,
    this.sendMediaMessage,
    this.messages,
    this.pagination,
    this.errorMessage,
    this.sentMessage,
    this.isUserTyping = false,
    this.typingInfo,
    this.replyingToMessage,
  });

  ChatMessagesState copyWith({
    CubitStates? getChatMessages,
    CubitStates? sendMediaMessage,
    List<ChatMessage>? messages,
    dynamic pagination,
    String? errorMessage,
    ChatMessage? sentMessage,
    bool? isUserTyping,
    TypinnModel? typingInfo,
    bool clearTypingInfo = false,
    ChatMessage? replyingToMessage,
    bool clearReplyingToMessage = false,
  }) {
    return ChatMessagesState(
      getChatMessages: getChatMessages ?? this.getChatMessages,
      sendMediaMessage: sendMediaMessage ?? this.sendMediaMessage,
      messages: messages ?? this.messages,
      pagination: pagination ?? this.pagination,
      errorMessage: errorMessage ?? this.errorMessage,
      sentMessage: sentMessage ?? this.sentMessage,
      isUserTyping: isUserTyping ?? this.isUserTyping,
      typingInfo: clearTypingInfo ? null : (typingInfo ?? this.typingInfo),
      replyingToMessage: clearReplyingToMessage
          ? null
          : (replyingToMessage ?? this.replyingToMessage),
    );
  }

  @override
  String toString() {
    return 'ChatMessagesState(isUserTyping: $isUserTyping, typingInfo: ${typingInfo?.userName}, messagesCount: ${messages?.length}, replyingTo: ${replyingToMessage?.id})';
  }
}
