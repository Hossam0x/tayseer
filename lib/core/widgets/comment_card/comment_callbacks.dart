
import 'package:flutter/material.dart';
import 'package:tayseer/core/models/comment_model.dart';
import 'package:tayseer/core/widgets/comment_card/comment_actions_menu.dart';

// ==========================================
// Comment Callback Type Definitions
// ==========================================

/// Callback for simple actions on a comment (like, delete, report, hide, etc.)
typedef CommentActionCallback = void Function(String commentId);

/// Callback for actions requiring content (edit, reply)
typedef CommentContentCallback = void Function(String commentId, String content);

/// Callback for actions requiring isReply flag
typedef CommentToggleCallback = void Function(String commentId, bool isReply);

/// Callback for menu actions
typedef CommentMenuCallback = void Function(
  String commentId,
  CommentMenuAction action,
  bool isReply,
);

/// Callback for liking (needs to know if it's a reply)
typedef CommentLikeCallback = void Function(
  CommentModel comment,
  bool isReply,
);

/// Callback for save edit (needs content + isReply flag)
typedef CommentSaveEditCallback = void Function(
  String commentId,
  String content,
  bool isReply,
);

/// Callback for sending reply
typedef CommentReplyCallback = void Function(
  String parentCommentId,
  String replyText,
);

/// Callback for loading replies
typedef CommentLoadRepliesCallback = void Function(String commentId);

/// Callback for blocking user
typedef CommentBlockUserCallback = void Function(
  String commentId,
  String userId,
);

// ==========================================
// ✅ Bundle of Comment Callbacks
// ==========================================

class CommentCallbacks {
  // ════════════════════════════════════════
  // Main Comment Actions
  // ════════════════════════════════════════
  
  /// Toggle like on comment or reply
  final CommentLikeCallback? onLike;
  
  /// Toggle reply mode for a comment
  final CommentActionCallback? onReplyToggle;
  
  /// Toggle edit mode for a comment
  final CommentActionCallback? onEditToggle;
  
  /// Cancel edit mode
  final VoidCallback? onCancelEdit;
  
  /// Cancel reply mode
  final VoidCallback? onCancelReply;
  
  /// Save edited comment/reply
  final CommentSaveEditCallback? onSaveEdit;
  
  /// Send a new reply
  final CommentReplyCallback? onSendReply;
  
  /// Load replies for a comment
  final CommentLoadRepliesCallback? onLoadReplies;

  // ════════════════════════════════════════
  // Menu Actions (Owner)
  // ════════════════════════════════════════
  
  /// Delete comment/reply
  final CommentActionCallback? onDelete;
  final CommentActionCallback? onDeleteReply;

  // ════════════════════════════════════════
  // Menu Actions (Guest)
  // ════════════════════════════════════════
  
  /// Report comment/reply
  final CommentActionCallback? onReport;
  
  /// Hide comment/reply
  final CommentActionCallback? onHide;
  
  /// Block comment author
  final CommentBlockUserCallback? onBlock;

  // ════════════════════════════════════════
  // Utility
  // ════════════════════════════════════════
  
  /// General menu action handler (alternative to individual callbacks)
  final CommentMenuCallback? onMenuAction;

  const CommentCallbacks({
    // Main actions
    this.onLike,
    this.onReplyToggle,
    this.onEditToggle,
    this.onCancelEdit,
    this.onCancelReply,
    this.onSaveEdit,
    this.onSendReply,
    this.onLoadReplies,
    // Menu actions - Owner
    this.onDelete,
    this.onDeleteReply,
    // Menu actions - Guest
    this.onReport,
    this.onHide,
    this.onBlock,
    // General
    this.onMenuAction,
  });

  /// Empty callbacks (for optional usage)
  static const empty = CommentCallbacks();

  /// Check if any callback is provided
  bool get hasCallbacks =>
      onLike != null ||
      onReplyToggle != null ||
      onEditToggle != null ||
      onCancelEdit != null ||
      onCancelReply != null ||
      onSaveEdit != null ||
      onSendReply != null ||
      onLoadReplies != null ||
      onDelete != null ||
      onDeleteReply != null ||
      onReport != null ||
      onHide != null ||
      onBlock != null ||
      onMenuAction != null;

  /// Copy with method for flexibility
  CommentCallbacks copyWith({
    CommentLikeCallback? onLike,
    CommentActionCallback? onReplyToggle,
    CommentActionCallback? onEditToggle,
    VoidCallback? onCancelEdit,
    VoidCallback? onCancelReply,
    CommentSaveEditCallback? onSaveEdit,
    CommentReplyCallback? onSendReply,
    CommentLoadRepliesCallback? onLoadReplies,
    CommentActionCallback? onDelete,
    CommentActionCallback? onDeleteReply,
    CommentActionCallback? onReport,
    CommentActionCallback? onHide,
    CommentBlockUserCallback? onBlock,
    CommentMenuCallback? onMenuAction,
  }) {
    return CommentCallbacks(
      onLike: onLike ?? this.onLike,
      onReplyToggle: onReplyToggle ?? this.onReplyToggle,
      onEditToggle: onEditToggle ?? this.onEditToggle,
      onCancelEdit: onCancelEdit ?? this.onCancelEdit,
      onCancelReply: onCancelReply ?? this.onCancelReply,
      onSaveEdit: onSaveEdit ?? this.onSaveEdit,
      onSendReply: onSendReply ?? this.onSendReply,
      onLoadReplies: onLoadReplies ?? this.onLoadReplies,
      onDelete: onDelete ?? this.onDelete,
      onDeleteReply: onDeleteReply ?? this.onDeleteReply,
      onReport: onReport ?? this.onReport,
      onHide: onHide ?? this.onHide,
      onBlock: onBlock ?? this.onBlock,
      onMenuAction: onMenuAction ?? this.onMenuAction,
    );
  }
}