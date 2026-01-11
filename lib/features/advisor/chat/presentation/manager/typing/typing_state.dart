import 'package:tayseer/features/advisor/chat/data/model/chat_message/typing_model.dart';

class TypingState {
  final bool isUserTyping;
  final TypingModel? typingInfo;

  const TypingState({this.isUserTyping = false, this.typingInfo});

  TypingState copyWith({
    bool? isUserTyping,
    TypingModel? typingInfo,
    bool clearTypingInfo = false,
  }) {
    return TypingState(
      isUserTyping: isUserTyping ?? this.isUserTyping,
      typingInfo: clearTypingInfo ? null : (typingInfo ?? this.typingInfo),
    );
  }
}
