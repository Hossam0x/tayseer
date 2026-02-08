import 'package:dartz/dartz.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/advisor/profille/data/models/analytics_model.dart';
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

  Future<Either<Failure, AnalyticsModel>> getAnalytics();

  Future<Either<Failure, String>> toggleSavePost({
    required String postId,
    required bool isRemove,
  });

  Future<Either<Failure, String>> deletePost({required String postId});

  void toggleHidePost({required String postId, required bool isHide});

  Future<Either<Failure, String>> blockUser({required String userId});

  Future<Either<Failure, String>> archivePost({required String postId});
}
