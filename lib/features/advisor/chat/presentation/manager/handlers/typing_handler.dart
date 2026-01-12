import 'dart:async';

import 'package:tayseer/features/advisor/chat/data/model/chat_message/typing_model.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';

class TypingHandler {
  final tayseerSocketHelper _socketHelper;

  Timer? _typingTimer;

  // State Updaters
  final void Function(bool isTyping, TypingModel? typingInfo)
  onTypingStatusChanged;

  TypingHandler({
    required tayseerSocketHelper socketHelper,
    required this.onTypingStatusChanged,
  }) : _socketHelper = socketHelper;

  void handleUserTyping(String userId, String userName, String chatRoomId) {
    _typingTimer?.cancel();

    onTypingStatusChanged(
      true,
      TypingModel(userId: userId, userName: userName, chatRoomId: chatRoomId),
    );

    _typingTimer = Timer(const Duration(seconds: 3), () {
      resetTypingStatus();
    });
  }

  void resetTypingStatus() {
    onTypingStatusChanged(false, null);
  }

  void typingStart(String chatRoomId) {
    _socketHelper.send('typing_start', {'chatRoomId': chatRoomId}, (ack) {});
  }

  void typingStop(String chatRoomId) {
    _socketHelper.send('typing_stop', {'chatRoomId': chatRoomId}, (ack) {});
  }

  void dispose() {
    _typingTimer?.cancel();
  }
}
