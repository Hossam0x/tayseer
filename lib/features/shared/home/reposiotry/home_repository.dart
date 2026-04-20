// lib/features/advisor/home/repository/home_repository.dart

import 'package:dartz/dartz.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/features/shared/home/model/image_and_name_model.dart';
import 'package:tayseer/features/shared/home/model/categories_response_model.dart';
import 'package:tayseer/core/models/comment_model.dart';
import 'package:tayseer/features/shared/home/model/comments_response_model.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/home/model/post_response_model.dart';
import 'package:tayseer/features/shared/home/model/best_advisor_model.dart';
import 'package:tayseer/features/shared/home/model/similar_user_model.dart';
import 'package:tayseer/features/shared/home/model/past_match_model.dart';

abstract class HomeRepository {
  Future<Either<Failure, PostsResponseModel>> fetchPosts({
    required int page,
    double? nextCursor,
    String? categoryId,
  });

  Future<Either<Failure, String>> reactToPost({
    required String postId,
    required ReactionType? reactionType,
    required bool isRemove,
  });

  Future<Either<Failure, String>> sharePost({
    required String postId,
    required String action,
  });

  Future<Either<Failure, CommentsResponseModel>> fetchComments({
    required String postId,
    required int page,
  });

  Future<Either<Failure, CommentsResponseModel>> fetchReplies({
    required String commentId,
    required int page,
  });

  Future<Either<Failure, CommentModel>> addComment({
    required String postId,
    required String comment,
    required bool anonymous,
  });

  Future<Either<Failure, String>> deleteComment({required String commentId});

  Future<Either<Failure, String>> deleteReply({required String replyId});

  void hideComment({required String commentId, required bool isHide});
  void hideReply({required String replyId, required bool isHide});

  Future<Either<Failure, CommentModel>> addReply({
    required String commentId,
    required String reply,
    required bool anonymous,
  });

  Future<void> likeToggle({
    String? commentId,
    String? replyId,
    required bool isRemove,
  });

  Future<Either<Failure, CommentModel>> editComment({
    required String commentId,
    required String comment,
  });
  Future<Either<Failure, CommentModel>> editReply({
    required String replyId,
    required String reply,
  });
  Future<Either<Failure, List<PostModel>>> getReels({
    required int page,
    int limit,
  });

  Future<Either<Failure, ImageAndNameModel>> fetchNameAndImage();
  Future<Either<Failure, CategoriesResponseModel>> fetchAllCategories(
    final int page,
  );

  Future<Either<Failure, String>> savedPost({
    required String postId,
    required bool isRemove,
  });
  Future<Either<Failure, String>> deletePost({required String postId});
  Future<Either<Failure, String>> hidePost({
    required String postId,
    required bool isHide,
  });
  Future<Either<Failure, String>> blockUser({required String userId});
  Future<Either<Failure, String>> archivePost({required String postId});

  Future<Either<Failure, bool>> voteInPoll({
    required String postId,
    required String choiceIndex,
  });

  Future<Either<Failure, String>> followAdvisor({
    required String advisorId,
    required bool isAdding,
  });

  Future<Either<Failure, PostModel>> fetchPostById({required String postId});

  Future<Either<Failure, String>> sharePostToStory({required String postId});

  Future<Either<Failure, BestAdvisorResponse>> fetchBestAdvisors();
  Future<Either<Failure, SimilarUserResponse>> fetchSimilarUsers();
  Future<Either<Failure, PastMatchesResponse>> fetchPastMatches();
}
