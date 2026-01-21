import 'package:dartz/dartz.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/core/models/post_model.dart';

abstract class SavedPostsRepository {
  Future<Either<Failure, List<PostModel>>> fetchSavedPosts({required int page});

  Future<void> removeFromSaved({required String postId});
}
