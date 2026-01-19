import 'package:dartz/dartz.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/my_import.dart';
import '../models/profile_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileModel>> getAdvisorProfile();

  Future<Either<Failure, List<PostModel>>> fetchSavedPosts({required int page});

  // ⭐️ أضف هذه الوظائف
  Future<void> reactToPost({
    required String postId,
    required ReactionType? reactionType,
    required bool isRemove,
  });

  Future<Either<Failure, String>> sharePost({
    required String postId,
    required String action,
  });
}
