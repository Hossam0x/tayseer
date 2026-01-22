export 'advisor_chat_screen.dart';

import 'advisor_chat_screen.dart';

class ChatScreenWithOverlay extends AdvisorChatScreen {
  const ChatScreenWithOverlay({
    super.key,
    super.chatRoomId,
    super.receiverId,
    super.username,
    super.userimage,
    super.isBlocked,
    super.isHaveSession,
    super.onBlockStatusChanged,
  });
}
