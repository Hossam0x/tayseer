import 'package:dartz/dartz.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/stories/stories.dart';
import '../models/archive_models.dart';

export 'archive_repository_impl.dart';

abstract class ArchiveRepository {
  Future<Either<Failure, ArchivedChatsResponseModel>> getArchivedChats({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, void>> unarchiveChat(String chatId);
  Future<Either<Failure, void>> deleteChatRoom(String chatId);

  Future<Either<Failure, List<UserStoriesModel>>> getArchivedStories({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, List<PostModel>>> getArchivedPosts({
    required int page,
    required int limit,
  });

  Future<void> reactToArchivedPost({
    required String postId,
    required ReactionType? reactionType,
    required bool isRemove,
  });

  Future<Either<Failure, String>> shareArchivedPost({
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
  Future<Either<Failure, String>> unblockUser({required String userId});

  Future<Either<Failure, String>> archivePost({
    required String postId,
    required bool isRemove,
  });

  Future<void> unarchivePost({required String postId});
}
