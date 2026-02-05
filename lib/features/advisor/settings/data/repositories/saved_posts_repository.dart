import 'package:dartz/dartz.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/core/models/post_model.dart';

abstract class SavedPostsRepository {
  Future<Either<Failure, List<PostModel>>> fetchSavedPosts({required int page});

  Future<void> removeFromSaved({required String postId});

  Future<void> reactToPost({
    required String postId,
    required ReactionType? reactionType,
    required bool isRemove,
  });

  Future<Either<Failure, String>> sharePost({
    required String postId,
    required String action,
  });

  Future<Either<Failure, String>> toggleSavePost({
    required String postId,
    required bool isRemove,
  });

  Future<Either<Failure, String>> deletePost({required String postId});

  void toggleHidePost({required String postId, required bool isHide});

  Future<Either<Failure, String>> blockUser({required String userId});

  Future<Either<Failure, String>> archivePost({required String postId});
}
