import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/my_import.dart';

/// Contract — any cubit driving a profile posts tab implements this.
/// Getters delegate to state so the widget reads from the cubit directly.
abstract class ProfilePostsCubitContract<S> extends Cubit<S> {
  ProfilePostsCubitContract(super.initialState);

  List<PostModel> get posts;
  CubitStates get postsState;
  String? get postsErrorMessage;
  bool get hasMore;
  bool get isLoadingMore;

  CubitStates get shareActionState;
  String? get shareMessage;
  bool? get isShareAdded;

  CubitStates get saveActionState;
  String? get saveMessage;

  CubitStates get deletePostActionState;
  String? get deletePostMessage;

  CubitStates get archivePostActionState;
  String? get archivePostMessage;

  CubitStates get blockUserActionState;
  String? get blockUserMessage;

  void reactToPost({required String postId, ReactionType? reactionType});
  Future<void> toggleSharePost({required String postId});
  Future<void> toggleSavePost({required String postId});
  void deletePost({required String postId});
  void toggleHidePost({required String postId});
  void archivePost({required String postId});
  Future<void> blockUser({String? visiblePostId, required String advisorId});
  Future<void> fetchPosts({bool loadMore = false});
  void updatePostLocally(PostModel updatedPost);
  void voteInPoll({required String postId, required String choiceText});
  void markPostAsCommented({required String postId, required bool isAnonymous});
  void updateCommentCountByDelta({
    required String postId,
    required int countDelta,
    bool? isCommented,
    bool? isAnonymous,
  });
  void syncCommentCountFromBackend({
    required String postId,
    required int totalCount,
  });
}
