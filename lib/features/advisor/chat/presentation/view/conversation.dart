// This file has been refactored for better maintainability and scalability
// The implementation has been split into multiple files following SOLID principles
//
// New structure:
// - base_chat_screen.dart: Base implementation for all chat screens
// - advisor_chat_screen.dart: Advisor-specific implementation
// - handler/message_actions_handler.dart: Handles message actions (delete, reply, etc.)
// - handler/scroll_behavior_handler.dart: Handles scroll behavior
// - handler/overlay_manager.dart: Manages overlay and message highlighting
// - widget/conversation/chat_context_menu_overlay.dart: Context menu overlay widget
//
// For backward compatibility, we export the new implementation with the old name

export 'advisor_chat_screen.dart' show AdvisorChatScreen;

import 'advisor_chat_screen.dart';

/// ChatScreenWithOverlay - Refactored version
///
/// This class now extends AdvisorChatScreen which is built on top of BaseChatScreen.
/// The refactoring provides:
///
/// 1. **Better Separation of Concerns**:
///    - Message actions are handled by MessageActionsHandler
///    - Scroll behavior is managed by ScrollBehaviorHandler
///    - Overlay management is done by OverlayManager
///
/// 2. **Easier to Extend**:
///    - BaseChatScreen can be extended for User chat screens
///    - Common functionality is shared between implementations
///
/// 3. **Better Testability**:
///    - Each handler can be tested independently
///    - Smaller, focused classes are easier to test
///
/// 4. **Follows SOLID Principles**:
///    - Single Responsibility: Each class has one clear purpose
///    - Open/Closed: Easy to extend without modifying existing code
///    - Liskov Substitution: Subclasses can replace base classes
///    - Interface Segregation: Small, focused interfaces
///    - Dependency Inversion: Depends on abstractions, not concretions
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
