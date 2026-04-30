import 'package:flutter/material.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';

class ChatInputState {
  final ChatMessage? replyingToMessage;
  final bool showEmojiPicker;
  final TextDirection textDirection;

  ChatInputState({
    this.replyingToMessage,
    this.showEmojiPicker = false,
    TextDirection? textDirection,
  }) : textDirection =
           textDirection ?? (isArabic ? TextDirection.rtl : TextDirection.ltr);

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
