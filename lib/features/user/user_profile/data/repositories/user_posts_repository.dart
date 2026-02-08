import 'package:dartz/dartz.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/my_import.dart';

abstract class UserPostsRepository {
  Future<Either<Failure, List<PostModel>>> fetchUserPosts({
    required String userId,
    required int page,
  });
  Future<void> reactToPost({
    required String postId,
    required ReactionType? reactionType,
    required bool isRemove,
  });
  Future<Either<Failure, String>> sharePost({
    required String postId,
    required String action,
  });
  Future<Either<Failure, String>> blockUser({required String userId});
  Future<Either<Failure, String>> savedPost({
    required String postId,
    required bool isRemove,
  });
  Future<Either<Failure, String>> deletePost({required String postId});
  void hidePost({required String postId, required bool isHide});
  Future<Either<Failure, String>> archivePost({required String postId});
}

// features/user/user_profile/data/repositories/user_posts_repository_impl.dart
class UserPostsRepositoryImpl implements UserPostsRepository {
  final ApiService _apiService;

  UserPostsRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, List<PostModel>>> fetchUserPosts({
    required String userId,
    required int page,
  }) async {
    try {
      final response = await _apiService.get(
        endPoint: '/user/shared-posts',
        query: {'page': page, 'userId': userId, 'limit': 10},
      );

      if (response['success'] == true) {
        final postsList =
            (response['data']?['postsDto'] as List<dynamic>?)
                ?.map((e) => PostModel.fromJson(e))
                .toList() ??
            [];
        return Right(postsList);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل جلب المنشورات'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
    await _apiService.post(endPoint: ApiEndPoint.like, data: requestData);
  }

  @override
  Future<Either<Failure, String>> sharePost({
    required String postId,
    required String action,
  }) async {
    try {
      final Map<String, dynamic> requestData = {"postId": postId};
      var response = await _apiService.post(
        endPoint: "${ApiEndPoint.share}?action=$action",
        data: requestData,
      );
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> blockUser({required String userId}) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.blockuser,
        data: {"blockedId": userId},
      );
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> savedPost({
    required String postId,
    required bool isRemove,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.savePost,
        data: {"postId": postId, "action": isRemove ? "remove" : "add"},
      );
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deletePost({required String postId}) async {
    try {
      final response = await _apiService.delete(
        endPoint: "/posts/delete/$postId",
      );
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  void hidePost({required String postId, required bool isHide}) async {
    final String action = isHide ? "add" : "remove";
    await _apiService.post(
      endPoint: '/posts/toggle-hide-post?postId=$postId&action=$action',
    );
  }

  @override
  Future<Either<Failure, String>> archivePost({required String postId}) async {
    try {
      final response = await _apiService.post(
        endPoint: "/posts/toggle-archive-post",
        data: {"postId": postId},
      );
      return Right(response['message'] ?? 'تمت العملية بنجاح');
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
