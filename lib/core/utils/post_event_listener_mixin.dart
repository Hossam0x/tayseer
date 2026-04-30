import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/utils/post_event_bus.dart';

/// Mixin يضيف الاستماع لـ PostEventBus لأي Cubit عنده list of PostModel.
/// الـ Cubit اللي بيستخدمه لازم يـ implement [getPostList] و [applyUpdatedPosts].
/// [cubitsourceId] بيُستخدم لتجنب معالجة الـ events اللي الـ cubit نفسه بعتها.
mixin PostEventListenerMixin<S> on Cubit<S> {
  StreamSubscription<PostEvent>? _postEventSub;

  /// ID مميز للـ cubit — يُستخدم لتجاهل الـ events الصادرة منه
  String get cubitsourceId => runtimeType.toString();

  /// يرجع الـ list الحالية من الـ state
  List<PostModel> getPostList();

  /// يعمل emit بالـ list الجديدة
  void applyUpdatedPosts(List<PostModel> posts);

  void subscribeToPostEvents() {
    _postEventSub = PostEventBus.instance.onPostEvent.listen((event) {
      if (isClosed) return;
      // تجاهل الـ events اللي الـ cubit نفسه بعتها
      if (event.sourceId == cubitsourceId) return;
      _handlePostEvent(event);
    });
  }

  void cancelPostEventSubscription() {
    _postEventSub?.cancel();
  }

  /// يبعت event على الـ bus مع الـ sourceId الخاص بالـ cubit
  void firePostEvent(PostEvent event) {
    PostEventBus.instance.fire(
      PostEvent(
        type: event.type,
        postId: event.postId,
        sourceId: cubitsourceId,
        reactionType: event.reactionType,
        likesCount: event.likesCount,
        topReactions: event.topReactions,
        isRepostedByMe: event.isRepostedByMe,
        sharesCount: event.sharesCount,
        isSaved: event.isSaved,
        advisorId: event.advisorId,
        pollModel: event.pollModel,
        commentCountDelta: event.commentCountDelta,
        commentCountTotal: event.commentCountTotal,
        isCommented: event.isCommented,
        isAnonymous: event.isAnonymous,
        updatedPost: event.updatedPost,
        unarchivedPost: event.unarchivedPost,
        createdPost: event.createdPost,
        categoryName: event.categoryName,
      ),
    );
  }

  void _handlePostEvent(PostEvent event) {
    final posts = getPostList();
    final postId = event.postId;
    final idx = posts.indexWhere((p) => p.postId == postId);

    switch (event.type) {
      case PostEventType.reacted:
        if (idx == -1) return;
        final p = posts[idx];
        applyUpdatedPosts(
          _replace(
            posts,
            idx,
            p.copyWith(
              likesCount: event.likesCount ?? p.likesCount,
              topReactions: event.topReactions ?? p.topReactions,
              myReaction: event.reactionType,
              clearMyReaction: event.reactionType == null,
            ),
          ),
        );
        break;

      case PostEventType.shared:
        if (idx == -1) return;
        final p = posts[idx];
        applyUpdatedPosts(
          _replace(
            posts,
            idx,
            p.copyWith(
              sharesCount: event.sharesCount ?? p.sharesCount,
              isRepostedByMe: event.isRepostedByMe ?? p.isRepostedByMe,
            ),
          ),
        );
        break;

      case PostEventType.saved:
        if (idx == -1) return;
        final p = posts[idx];
        applyUpdatedPosts(
          _replace(posts, idx, p.copyWith(isSaved: event.isSaved ?? p.isSaved)),
        );
        break;

      case PostEventType.deleted:
        if (idx == -1) return;
        applyUpdatedPosts(posts.where((p) => p.postId != postId).toList());
        break;

      case PostEventType.archived:
        if (idx == -1) return;
        applyUpdatedPosts(posts.where((p) => p.postId != postId).toList());
        break;

      case PostEventType.hidden:
        if (idx == -1) return;
        applyUpdatedPosts(
          _replace(posts, idx, posts[idx].copyWith(isHidden: true)),
        );
        break;

      case PostEventType.blocked:
        if (event.advisorId == null) return;
        applyUpdatedPosts(
          posts
              .map((p) {
                if (p.postId == postId) return p.copyWith(isBlocked: true);
                if (p.advisorId == event.advisorId) return null;
                return p;
              })
              .whereType<PostModel>()
              .toList(),
        );
        break;

      case PostEventType.pollVoted:
        if (idx == -1 || event.pollModel == null) return;
        applyUpdatedPosts(
          _replace(posts, idx, posts[idx].copyWith(pollModel: event.pollModel)),
        );
        break;

      case PostEventType.commentCountUpdated:
        if (idx == -1 || event.commentCountDelta == null) return;
        final p = posts[idx];
        applyUpdatedPosts(
          _replace(
            posts,
            idx,
            p.copyWith(
              commentsCount: (p.commentsCount + event.commentCountDelta!).clamp(
                0,
                999999,
              ),
              isCommented: event.isCommented ?? p.isCommented,
              isAnonymous: event.isAnonymous ?? p.isAnonymous,
            ),
          ),
        );
        break;

      case PostEventType.commentCountSynced:
        if (idx == -1 || event.commentCountTotal == null) return;
        applyUpdatedPosts(
          _replace(
            posts,
            idx,
            posts[idx].copyWith(commentsCount: event.commentCountTotal),
          ),
        );
        break;

      case PostEventType.commented:
        if (idx == -1) return;
        final p = posts[idx];
        applyUpdatedPosts(
          _replace(
            posts,
            idx,
            p.copyWith(
              isCommented: true,
              isAnonymous: event.isAnonymous ?? p.isAnonymous,
            ),
          ),
        );
        break;

      case PostEventType.edited:
        if (idx == -1 || event.updatedPost == null) return;
        applyUpdatedPosts(_replace(posts, idx, event.updatedPost!));
        break;

      case PostEventType.unarchived:
        // الـ mixin cubits مش محتاجة تضيف البوست - بس HomeCubit و ProfileCubit بيعملوا كده
        break;

      case PostEventType.created:
        // الـ mixin cubits مش محتاجة تضيف البوست الجديد - بس HomeCubit و ProfileCubit بيعملوا كده
        break;
    }
  }

  List<PostModel> _replace(List<PostModel> list, int idx, PostModel updated) {
    final copy = List<PostModel>.from(list);
    copy[idx] = updated;
    return copy;
  }
}
