// lib/features/advisor/home/repository/home_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/home/model/comment_model.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/advisor/home/model/post_response_model.dart';
import 'package:tayseer/features/advisor/home/model/comments_response_model.dart';
import 'package:tayseer/features/advisor/home/reposiotry/home_repository.dart';
import '../../../../my_import.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiService apiService;

  HomeRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, List<PostModel>>> fetchPosts({
    required int page,
  }) async {
    try {
      var response = await apiService.get(
        endPoint: ApiEndPoint.posts,
        query: {'page': page},
      );
      final postsResponse = PostsResponseModel.fromJson(response);
      return Right(postsResponse.posts);
    } on DioException catch (error) {
      if (error.response != null && error.response!.data != null) {
        final errorMessage = error.response!.data['message'] ?? 'Unknown error';
        return Left(ServerFailure(errorMessage));
      } else {
        return Left(ServerFailure(error.message ?? 'Unknown error'));
      }
    }
  }

  @override
  Future<void> reactToPost({
    required String postId,
    required ReactionType? reactionType,
    required bool isRemove,
  }) async {
    final Map<String, dynamic> requestData = {
      "postId": postId,
      "action": isRemove ? "remove" : "add",
    };
    if (!isRemove) {
      requestData["type"] = reactionType!.name;
    }
    apiService.post(endPoint: ApiEndPoint.like, data: requestData);
  }

  @override
  Future<Either<Failure, String>> sharePost({
    required String postId,
    required String action,
  }) async {
    try {
      final Map<String, dynamic> requestData = {"postId": postId};
      var response = await apiService.post(
        endPoint: "${ApiEndPoint.share}?action=$action",
        data: requestData,
      );
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (error) {
      if (error.response != null && error.response!.data != null) {
        final errorMessage = error.response!.data['message'] ?? 'Unknown error';
        return Left(ServerFailure(errorMessage));
      } else {
        return Left(ServerFailure(error.message ?? 'Unknown error'));
      }
    }
  }

  @override
  Future<Either<Failure, CommentsResponseModel>> fetchComments({
    required String postId,
    required int page,
  }) async {
    try {
      var response = await apiService.get(
        endPoint: '${ApiEndPoint.comments}/$postId/comments',
        query: {'page': page},
      );
      final commentsResponse = CommentsResponseModel.fromJson(response);
      return Right(commentsResponse);
    } on DioException catch (error) {
      if (error.response != null && error.response!.data != null) {
        final errorMessage = error.response!.data['message'] ?? 'Unknown error';
        return Left(ServerFailure(errorMessage));
      } else {
        return Left(ServerFailure(error.message ?? 'Unknown error'));
      }
    }
  }

  @override
  Future<Either<Failure, CommentsResponseModel>> fetchReplies({
    required String commentId,
    required int page,
  }) async {
    try {
      var response = await apiService.get(
        endPoint: '${ApiEndPoint.replies}$commentId',
        query: {'page': page, "limit": 5},
      );
      final repliesResponse = CommentsResponseModel.fromJson(response);
      return Right(repliesResponse);
    } on DioException catch (error) {
      if (error.response != null && error.response!.data != null) {
        final errorMessage = error.response!.data['message'] ?? 'Unknown error';
        return Left(ServerFailure(errorMessage));
      } else {
        return Left(ServerFailure(error.message ?? 'Unknown error'));
      }
    }
  }

  @override
  Future<Either<Failure, CommentModel>> addComment({
    required String postId,
    required String comment,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        "postId": postId,
        "comment": comment,
      };
      var response = await apiService.post(
        endPoint: ApiEndPoint.comments,
        data: requestData,
      );
      final commentModel = CommentModel.fromJson(response['data']);
      return Right(commentModel);
    } on DioException catch (error) {
      if (error.response != null && error.response!.data != null) {
        final errorMessage = error.response!.data['message'] ?? 'Unknown error';
        return Left(ServerFailure(errorMessage));
      } else {
        return Left(ServerFailure(error.message ?? 'Unknown error'));
      }
    }
  }

  @override
  Future<Either<Failure, CommentModel>> addReply({
    required String commentId,
    required String reply,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        "commentId": commentId,
        "reply": reply,
      };
      var response = await apiService.post(
        endPoint: ApiEndPoint.createReply,
        data: requestData,
      );
      final replyModel = CommentModel.fromJson(response['data']);
      return Right(replyModel);
    } on DioException catch (error) {
      if (error.response != null && error.response!.data != null) {
        final errorMessage = error.response!.data['message'] ?? 'Unknown error';
        return Left(ServerFailure(errorMessage));
      } else {
        return Left(ServerFailure(error.message ?? 'Unknown error'));
      }
    }
  }

  @override
  Future<void> likeToggle({
    String? commentId,
    String? replyId,
    required bool isRemove,
  }) async {
    final Map<String, dynamic> requestData = {};
    if (commentId != null) {
      requestData["commentId"] = commentId;
    }
    if (replyId != null) {
      requestData["replyId"] = replyId;
    }
    await apiService.post(
      endPoint:
          '${ApiEndPoint.commentLike}?action=${isRemove ? "remove" : "add"}',
      data: requestData,
    );
  }

  @override
  Future<Either<Failure, String>> editComment({
    required String commentId,
    required String comment,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        "comment": comment,
        "commentId": commentId,
      };
      var response = await apiService.patch(
        endPoint: ApiEndPoint.comments,
        data: requestData,
      );
      return Right(response['message'] ?? 'تم تعديل التعليق بنجاح');
    } on DioException catch (error) {
      if (error.response != null && error.response!.data != null) {
        final errorMessage = error.response!.data['message'] ?? 'Unknown error';
        return Left(ServerFailure(errorMessage));
      } else {
        return Left(ServerFailure(error.message ?? 'Unknown error'));
      }
    }
  }

  @override
  Future<Either<Failure, String>> editReply({
    required String replyId,
    required String reply,
  }) async {
    try {
      final Map<String, dynamic> requestData = {"reply": reply};
      var response = await apiService.patch(
        endPoint: '${ApiEndPoint.replies}$replyId',
        data: requestData,
      );
      return Right(response['message'] ?? 'تم تعديل الرد بنجاح');
    } on DioException catch (error) {
      if (error.response != null && error.response!.data != null) {
        final errorMessage = error.response!.data['message'] ?? 'Unknown error';
        return Left(ServerFailure(errorMessage));
      } else {
        return Left(ServerFailure(error.message ?? 'Unknown error'));
      }
    }
  }
}
