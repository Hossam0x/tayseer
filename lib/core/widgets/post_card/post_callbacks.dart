// lib/core/types/post_callbacks.dart

import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/my_import.dart';

/// Callback when user reacts to a post
typedef ReactionCallback = void Function(String postId, ReactionType? type);

/// Callback when user shares/reposts
typedef ShareCallback = void Function(String postId);

/// Callback when user taps a hashtag
typedef HashtagCallback = void Function(String hashtag);

/// Callback for navigating to post details
typedef NavigateToDetailsCallback = void Function(
  BuildContext context,
  PostModel post,
  VideoPlayerController? controller,
);

/// Bundle of post-related callbacks for easy passing
class PostCallbacks {
  final ReactionCallback? onReactionChanged;
  final ShareCallback? onShareTap;
  final HashtagCallback? onHashtagTap;
  final VoidCallback? onMoreTap;
  final Stream<PostModel>? postUpdatesStream;

  const PostCallbacks({
    this.onReactionChanged,
    this.onShareTap,
    this.onHashtagTap,
    this.onMoreTap,
    this.postUpdatesStream,
  });

  /// Empty callbacks (for optional usage)
  static const empty = PostCallbacks();

  /// Check if any callback is provided
  bool get hasCallbacks =>
      onReactionChanged != null ||
      onShareTap != null ||
      onHashtagTap != null ||
      onMoreTap != null;
}