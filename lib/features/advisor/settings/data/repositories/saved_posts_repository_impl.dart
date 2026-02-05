import 'package:dartz/dartz.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/my_import.dart';
import 'saved_posts_repository.dart';

class SavedPostsRepositoryImpl implements SavedPostsRepository {
  final ApiService _apiService;

  SavedPostsRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, List<PostModel>>> fetchSavedPosts({
    required int page,
  }) async {
    try {
      final response = await _apiService.get(
        endPoint: '/saved-posts',
        query: {'page': page},
      );

      if (response['success'] == true) {
        final postsList =
            (response['data']?['postsDto'] as List<dynamic>?)
                ?.map((e) => PostModel.fromJson(e))
                .toList() ??
            [];
        return Right(postsList);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل جلب المنشورات المحفوظة'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> removeFromSaved({required String postId}) async {
    await toggleSavePost(postId: postId, isRemove: true);
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
  Future<Either<Failure, String>> toggleSavePost({
    required String postId,
    required bool isRemove,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.savePost,
        query: {'action': isRemove ? 'remove' : 'add'},
        data: {"postId": postId},
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
        endPoint: "${ApiEndPoint.deletePost}$postId",
      );
      if (response['success'] == true || response['status'] == 'success') {
        return Right(response['message'] ?? 'تم حذف المنشور بنجاح');
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  void toggleHidePost({required String postId, required bool isHide}) {
    _apiService.post(
      endPoint: ApiEndPoint.hidePost,
      query: {'action': isHide ? 'add' : 'remove'},
      data: {"postId": postId},
    );
  }

  @override
  Future<Either<Failure, String>> blockUser({required String userId}) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.blockuser,
        data: {"blockedId": userId},
      );
      if (response['success'] == true || response['status'] == 'success') {
        return Right(response['message'] ?? 'تم حظر المستخدم بنجاح');
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> archivePost({required String postId}) async {
    try {
      final response = await _apiService.post(
        endPoint: "${ApiEndPoint.archivePost}$postId",
        query: {'action': 'add'},
      );
      if (response['success'] == true || response['status'] == 'success') {
        return Right(response['message'] ?? 'تم أرشفة المنشور بنجاح');
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
