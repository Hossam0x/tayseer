// lib/core/types/post_callbacks.dart

import 'package:flutter/material.dart';
import 'package:tayseer/core/models/post_model.dart';
// import 'package:tayseer/my_import.dart'; // تأكد من المسار الصحيح لو مش موجود
// تأكد من استيراد VideoPlayerController لو مستخدم
import 'package:video_player/video_player.dart';

/// Callback when user reacts to a post
typedef ReactionCallback = void Function(String postId, ReactionType? type);

/// Callback when user shares/reposts
typedef ShareCallback = void Function(String postId);

/// Callback when user taps a hashtag
typedef HashtagCallback = void Function(String hashtag);

/// Callback for navigating to post details
typedef NavigateToDetailsCallback =
    void Function(
      BuildContext context,
      PostModel post,
      VideoPlayerController? controller,
    );

// ==========================================
// ✅ New Typedefs for Bottom Sheet Options
// ==========================================

/// Generic callback for actions requiring just the Post ID (Delete, Archive, Hide, Save, Report)
typedef PostActionCallback = void Function(String postId);

/// Callback specifically for editing (might need the full model or just ID)
typedef EditPostCallback = void Function(PostModel post);

/// Callback for blocking a user
typedef BlockUserCallback =
    void Function(String visiblePostId, String advisorId);

/// Callback for voting in a poll
typedef PollVoteCallback = void Function(String postId, String choiceText);

/// Callback when user adds a comment (to update isCommented/isAnonymous)
typedef CommentedCallback = void Function(String postId, bool isAnonymous);

/// Callback for updating comment counts dynamically with deltas
typedef CommentCountDeltaCallback =
    void Function({
      required String postId,
      required int countDelta,
      bool? isCommented,
      bool? isAnonymous,
    });

/// Bundle of post-related callbacks for easy passing
class PostCallbacks {
  // Existing callbacks
  final ReactionCallback? onReactionChanged;
  final ShareCallback? onShareTap;
  final HashtagCallback? onHashtagTap;
  final Stream<PostModel?>? postUpdatesStream;
  // ✅ New callbacks for Options Bottom Sheet
  final EditPostCallback? onEdit;
  final PostActionCallback? onDelete;
  final PostActionCallback? onArchive;
  final PostActionCallback? onReport;
  final PostActionCallback? onHide;
  final PostActionCallback? onSave;
  final BlockUserCallback? onBlock; // Takes userId
  final PollVoteCallback? onPollVote;
  final CommentedCallback? onCommented;
  final CommentCountDeltaCallback? onCommentCountDelta;

  const PostCallbacks({
    this.onReactionChanged,
    this.onShareTap,
    this.onHashtagTap,
    this.postUpdatesStream,
    // New ones
    this.onEdit,
    this.onDelete,
    this.onArchive,
    this.onReport,
    this.onHide,
    this.onSave,
    this.onBlock,
    this.onPollVote,
    this.onCommented,
    this.onCommentCountDelta,
  });

  /// Empty callbacks (for optional usage)
  static const empty = PostCallbacks();

  /// Check if any callback is provided (Updated)
  bool get hasCallbacks =>
      onReactionChanged != null ||
      onShareTap != null ||
      onHashtagTap != null ||
      onEdit != null ||
      onDelete != null ||
      onArchive != null ||
      onReport != null ||
      onHide != null ||
      onSave != null ||
      onBlock != null ||
      onPollVote != null ||
      onCommented != null ||
      onCommentCountDelta != null;
}
