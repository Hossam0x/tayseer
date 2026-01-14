import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/home/model/comments_response_model.dart';
import 'package:tayseer/features/advisor/profille/data/models/reply_comment_model.dart';
import 'package:tayseer/my_import.dart';

abstract class CommentsRepository {
  Future<Either<Failure, CommentsResponseModel>> getAdvisorComments({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, RepliesResponseModel>> getCommentReplies({
    required String commentId,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, void>> createReply({
    required String commentId,
    required String reply,
  });

  Future<Either<Failure, void>> deleteReply(String replyId);

  Future<Either<Failure, void>> deleteComment(String commentId);

  Future<Either<Failure, void>> toggleLikeComment(String commentId);

  Future<Either<Failure, void>> toggleLikeReply(String replyId);
}

class CommentsRepositoryImpl implements CommentsRepository {
  final ApiService _apiService;

  CommentsRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, CommentsResponseModel>> getAdvisorComments({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        endPoint: '/comments/advisor/comments',
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final commentsResponse = CommentsResponseModel.fromJson(data);
        return Right(commentsResponse);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل جلب التعليقات'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RepliesResponseModel>> getCommentReplies({
    required String commentId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        endPoint: '/comment-replies/comment/$commentId',
        query: {'page': page, 'limit': limit},
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final repliesResponse = RepliesResponseModel.fromJson(data);
        return Right(repliesResponse);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل جلب الردود'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createReply({
    required String commentId,
    required String reply,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: '/comment-replies/create',
        data: {'commentId': commentId, 'reply': reply},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل إضافة الرد'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReply(String replyId) async {
    try {
      final response = await _apiService.delete(
        endPoint: '/comment-replies/delete/$replyId',
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل حذف الرد'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      final response = await _apiService.delete(
        endPoint: '/comments/$commentId',
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل حذف التعليق'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleLikeComment(String commentId) async {
    try {
      final response = await _apiService.post(
        endPoint: '/comments/like/$commentId',
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل تحديث الإعجاب'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleLikeReply(String replyId) async {
    try {
      final response = await _apiService.post(
        endPoint: '/comment-replies/like/$replyId',
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل تحديث إعجاب الرد'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
