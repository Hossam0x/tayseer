import 'package:dartz/dartz.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<PostModel>>> fetchPosts({required int page});

  Future<void> reactToPost({
    required String postId,
    required ReactionType? reactionType,
    required bool isRemove,
  });
}
