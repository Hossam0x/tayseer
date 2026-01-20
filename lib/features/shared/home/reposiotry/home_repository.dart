// lib/features/advisor/home/repository/home_repository.dart

import 'package:dartz/dartz.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/features/shared/home/model/Image_and_name_model.dart';
import 'package:tayseer/features/shared/home/model/categories_response_model.dart';
import 'package:tayseer/features/shared/home/model/comment_model.dart';
import 'package:tayseer/features/shared/home/model/comments_response_model.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<PostModel>>> fetchPosts({required int page, String? categoryId});

  Future<void> reactToPost({
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
  });

  Future<Either<Failure, CommentModel>> addReply({
    required String commentId,
    required String reply,
  });

  Future<void> likeToggle({
    String? commentId,
    String? replyId,
    required bool isRemove,
  });

  Future<Either<Failure, String>> editComment({
    required String commentId,
    required String comment,
  });
  Future<Either<Failure, String>> editReply({
    required String replyId,
    required String reply,
  });
  Future<Either<Failure, List<PostModel>>> getReels({
    required int page,
    int limit,
  });

  Future<Either<Failure, ImageAndNameModel>> fetchNameAndImage();
  Future<Either<Failure, CategoriesResponseModel>> fetchAllCategories(
    final int page
  );

}
