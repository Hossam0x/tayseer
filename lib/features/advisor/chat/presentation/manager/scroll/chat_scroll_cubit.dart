import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_scroll_state.dart';

class ChatScrollCubit extends Cubit<ChatScrollState> {
  ChatScrollCubit() : super(const ChatScrollState());

  void setAtBottom(bool isAtBottom) {
    if (state.isAtBottom != isAtBottom) {
      emit(state.copyWith(isAtBottom: isAtBottom));
    }
  }

  void setScrollPosition(double position) {
    emit(state.copyWith(scrollPosition: position));
  }

  void setHighlightedMessageId(String? messageId) {
    emit(
      state.copyWith(
        highlightedMessageId: messageId,
        clearHighlightedMessageId: messageId == null,
      ),
    );
  }

  void clearHighlight() {
    emit(state.copyWith(clearHighlightedMessageId: true));
  }
}
