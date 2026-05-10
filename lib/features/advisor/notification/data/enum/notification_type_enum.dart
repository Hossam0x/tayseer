enum NotificationType {
  // ─── From API ───────────────────────────────────────
  accountRejected,
  accountApproved,
  newChat,
  newMessage,
  contentReported,
  userBlocked,
  newFollower,
  sessionPaid,
  eventShare,
  eventReservation,
  storyLike,
  storyView,
  replyLike,
  commentReply,
  commentLike,
  newPostFromFollowing,
  postSuggestion,
  postShare,
  postComment,
  postLike,
  regardRequest,
  system,
  unknown;

  static NotificationType fromType(String? type) {
    switch (type) {
      // ─── Original values ──────────────────────────

      // ─── API values ───────────────────────────────
      case 'content_reported':
        return NotificationType.contentReported;
      case 'user_blocked':
        return NotificationType.userBlocked;
      //////////////////////////////////////////////////////////////////////////
      case 'account_rejected':
        return NotificationType.accountRejected;
      case 'account_approved':
        return NotificationType.accountApproved;
      //////////////////////////////////////////////////////////////////////////
      case 'new_chat':
        return NotificationType.newChat;
      case 'new_message':
        return NotificationType.newMessage; //done
      //////////////////////////////////////////////////////////////////////////

      case 'new_follower':
        return NotificationType.newFollower; //done
      /////////////////////////////////////////////////////////////////////////
      case 'session_paid':
        return NotificationType.sessionPaid; //gone session
      /////////////////////////////////////////////////////////////////////////
      case 'event_share':
        return NotificationType.eventShare; //done
      case 'event_reservation':
        return NotificationType.eventReservation;
      ////////////////////////////////////////////////////////////////////////
      case 'story_like':
        return NotificationType.storyLike;
      case 'story_view':
        return NotificationType.storyView;
      //go home//done
      ///////////////////////////////////////////////////////////////////////  //done
      case 'reply_like':
        return NotificationType.replyLike;
      case 'comment_reply':
        return NotificationType.commentReply;
      case 'comment_like':
        return NotificationType.commentLike;
      case 'new_post_from_following':
        return NotificationType.newPostFromFollowing;
      case 'post_suggestion':
        return NotificationType.postSuggestion;
      case 'post_share':
        return NotificationType.postShare;
      case 'post_comment':
        return NotificationType.postComment;
      case 'post_like':
        return NotificationType.postLike;
      case 'regard_request':
        return NotificationType.regardRequest;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.unknown;
    }
  }
}
