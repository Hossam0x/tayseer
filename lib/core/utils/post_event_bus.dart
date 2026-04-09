import 'dart:async';
import 'package:tayseer/core/models/post_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Event Types
// ─────────────────────────────────────────────────────────────────────────────

enum PostEventType {
  reacted,
  shared,
  saved,
  deleted,
  archived,
  unarchived,
  hidden,
  blocked,
  pollVoted,
  commentCountUpdated,
  commentCountSynced,
  commented,
  edited,
}

class PostEvent {
  final PostEventType type;
  final String postId;

  /// مصدر الـ event — كل cubit يتجاهل الـ events اللي هو بعتها
  final String? sourceId;

  // For reacted
  final ReactionType? reactionType;
  final int? likesCount;
  final List<TopReactionModel>? topReactions;

  // For shared
  final bool? isRepostedByMe;
  final int? sharesCount;

  // For saved
  final bool? isSaved;

  // For blocked
  final String? advisorId;

  // For poll voted
  final PollModel? pollModel;

  // For comment count
  final int? commentCountDelta;
  final int? commentCountTotal;
  final bool? isCommented;
  final bool? isAnonymous;

  // For edited
  final PostModel? updatedPost;

  // For unarchived — البوست اللي اتعمله unarchive عشان يتضاف في الـ feeds
  final PostModel? unarchivedPost;

  const PostEvent({
    required this.type,
    required this.postId,
    this.sourceId,
    this.reactionType,
    this.likesCount,
    this.topReactions,
    this.isRepostedByMe,
    this.sharesCount,
    this.isSaved,
    this.advisorId,
    this.pollModel,
    this.commentCountDelta,
    this.commentCountTotal,
    this.isCommented,
    this.isAnonymous,
    this.updatedPost,
    this.unarchivedPost,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Bus (Singleton)
// ─────────────────────────────────────────────────────────────────────────────

class PostEventBus {
  PostEventBus._();
  static final PostEventBus instance = PostEventBus._();

  final _controller = StreamController<PostEvent>.broadcast();
  Stream<PostEvent> get onPostEvent => _controller.stream;

  void fire(PostEvent event) => _controller.add(event);

  void dispose() => _controller.close();
}
