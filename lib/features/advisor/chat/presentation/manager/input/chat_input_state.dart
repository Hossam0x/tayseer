import 'package:flutter/material.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';

class ChatInputState {
  final ChatMessage? replyingToMessage;
  final bool showEmojiPicker;
  final TextDirection textDirection;

  const ChatInputState({
    this.replyingToMessage,
    this.showEmojiPicker = false,
    this.textDirection = TextDirection.rtl,
  });

  ChatInputState copyWith({
    ChatMessage? replyingToMessage,
    bool clearReplyingToMessage = false,
    bool? showEmojiPicker,
    TextDirection? textDirection,
  }) {
    return ChatInputState(
      replyingToMessage: clearReplyingToMessage
          ? null
          : (replyingToMessage ?? this.replyingToMessage),
      showEmojiPicker: showEmojiPicker ?? this.showEmojiPicker,
      textDirection: textDirection ?? this.textDirection,
    );
  }
}
