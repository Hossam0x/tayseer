// Backward compatibility wrapper
// This file maintains the old API while using the new refactored implementation
export 'advisor_chat_screen.dart';

// For backward compatibility, we export AdvisorChatScreen as ChatScreenWithOverlay
// This allows existing code to continue working without changes
import 'advisor_chat_screen.dart';

/// Backward compatibility wrapper for ChatScreenWithOverlay
/// This maintains the old API while using the new refactored implementation
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
