// lib/features/advisor/home/repository/home_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:tayseer/features/shared/home/model/Image_and_name_model.dart';
import 'package:tayseer/features/shared/home/model/categories_response_model.dart';
import 'package:tayseer/core/models/comment_model.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/home/model/post_response_model.dart';
import 'package:tayseer/features/shared/home/model/comments_response_model.dart';
import 'package:tayseer/features/shared/home/reposiotry/home_repository.dart';
import '../../../../my_import.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiService apiService;

  HomeRepositoryImpl(this.apiService);

  // ================= Posts =================

  @override
  Future<Either<Failure, List<PostModel>>> fetchPosts({
    required int page,
    String? categoryId,
  }) async {
    try {
      final response = await apiService.get(
        endPoint: ApiEndPoint.posts,
        query: {'page': page, if (categoryId != null) 'categoryId': categoryId},
      );
      final postsResponse = PostsResponseModel.fromJson(response);
      return Right(postsResponse.posts);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<void> reactToPost({
    required String postId,
    required ReactionType? reactionType,
    required bool isRemove,
  }) async {
    final data = {"postId": postId, if (!isRemove) "type": reactionType!.name};

    await apiService.post(
      endPoint: ApiEndPoint.like,
      query: {'action': isRemove ? 'remove' : 'add'},
      data: data,
    );
  }

  @override
  Future<Either<Failure, String>> sharePost({
    required String postId,
    required String action,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: ApiEndPoint.share,
        query: {'action': action},
        data: {"postId": postId},
      );
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  // ================= Comments =================

  @override
  Future<Either<Failure, CommentsResponseModel>> fetchComments({
    required String postId,
    required int page,
  }) async {
    try {
      final response = await apiService.get(
        endPoint: '${ApiEndPoint.comments}/$postId/comments',
        query: {'page': page},
      );
      return Right(CommentsResponseModel.fromJson(response));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, CommentsResponseModel>> fetchReplies({
    required String commentId,
    required int page,
  }) async {
    try {
      final response = await apiService.get(
        endPoint: '${ApiEndPoint.replies}$commentId',
        query: {'page': page, 'limit': 5},
      );
      return Right(CommentsResponseModel.fromJson(response));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, CommentModel>> addComment({
    required String postId,
    required String comment,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: ApiEndPoint.comments,
        data: {"postId": postId, "comment": comment},
      );
      return Right(CommentModel.fromJson(response['data']));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, CommentModel>> addReply({
    required String commentId,
    required String reply,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: ApiEndPoint.createReply,
        data: {"commentId": commentId, "reply": reply},
      );
      return Right(CommentModel.fromJson(response['data']));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<void> likeToggle({
    String? commentId,
    String? replyId,
    required bool isRemove,
  }) async {
    await apiService.post(
      endPoint: ApiEndPoint.commentLike,
      query: {'action': isRemove ? 'remove' : 'add'},
      data: {
        if (commentId != null) "commentId": commentId,
        if (replyId != null) "replyId": replyId,
      },
    );
  }

  @override
  Future<Either<Failure, String>> editComment({
    required String commentId,
    required String comment,
  }) async {
    try {
      final response = await apiService.patch(
        endPoint: ApiEndPoint.comments,
        data: {"commentId": commentId, "comment": comment},
      );
      return Right(response['message'] ?? 'تم تعديل التعليق بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, String>> editReply({
    required String replyId,
    required String reply,
  }) async {
    try {
      final response = await apiService.patch(
        endPoint: '${ApiEndPoint.updateReply}$replyId',
        data: {"reply": reply},
      );
      return Right(response['message'] ?? 'تم تعديل الرد بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }


@override
Future<Either<Failure, String>> deleteComment({
    required String commentId,
  }) async {
    try {
      final response = await apiService.delete(
        endPoint: "${ApiEndPoint.comments}/$commentId",
      );

      if (response['success'] == true || response['status'] == 'success') {
        return Right(response['message'] ?? 'تم حذف التعليق بنجاح');
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }
  // ================= Reels =================

  @override
  Future<Either<Failure, List<PostModel>>> getReels({
    required int page,
    int limit = 5,
  }) async {
    try {
      final response = await apiService.get(
        endPoint: ApiEndPoint.reels,
        query: {'page': page, 'limit': limit},
      );

      final reels =
          (response['data']?['reelsDto'] as List<dynamic>?)
              ?.map((e) => PostModel.fromJson(e))
              .toList() ??
          [];

      return Right(reels);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  // ================= Profile =================

  @override
  Future<Either<Failure, ImageAndNameModel>> fetchNameAndImage() async {
    try {
      final response = await apiService.get(endPoint: ApiEndPoint.nameAndImage);
      return Right(ImageAndNameModel.fromJson(response['data']));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  // ================= Categories =================

  @override
  Future<Either<Failure, CategoriesResponseModel>> fetchAllCategories(
    int page,
  ) async {
    try {
      final response = await apiService.get(
        endPoint: ApiEndPoint.category,
        query: {'page': page},
      );
      return Right(CategoriesResponseModel.fromJson(response));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  // ================= Post Actions =================

  @override
  Future<Either<Failure, String>> savedPost({
    required String postId,
    required bool isRemove,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: ApiEndPoint.savePost,
        query: {'action': isRemove ? 'remove' : 'add'},
        data: {"postId": postId},
      );
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, String>> deletePost({required String postId}) async {
    try {
      final response = await apiService.delete(
        endPoint: "${ApiEndPoint.deletePost}$postId",
      );

      if (response['success'] == true || response['status'] == 'success') {
        return Right(response['message'] ?? 'تم حذف المنشور بنجاح');
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  void hidePost({required String postId, required bool isHide}) {
    apiService.post(
      endPoint: ApiEndPoint.hidePost,
      query: {'action': isHide ? 'add' : 'remove'},
      data: {"postId": postId},
    );
  }

  @override
  Future<Either<Failure, String>> blockUser({required String userId}) async {
    try {
      final response = await apiService.post(
        endPoint: ApiEndPoint.blockuser,
        data: {"blockedId": userId},
      );

      if (response['success'] == true || response['status'] == 'success') {
        return Right(response['message'] ?? 'تم حظر المستخدم بنجاح');
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  Future<Either<Failure, String>> archivePost({required String postId}) async {
    try {
      final response = await apiService.post(
        endPoint: "${ApiEndPoint.archivePost}$postId",
        query: {'action': 'add'},
      );

      if (response['success'] == true || response['status'] == 'success') {
        return Right(response['message'] ?? 'تم أرشفة المنشور بنجاح');
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }
}
