import 'package:dartz/dartz.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/stories/stories.dart';
import '../models/archive_models.dart';

abstract class ArchiveRepository {
  Future<Either<Failure, ArchivedChatsResponseModel>> getArchivedChats({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, void>> unarchiveChat(String chatId);
  Future<Either<Failure, void>> deleteChatRoom(String chatId);

  Future<Either<Failure, List<UserStoriesModel>>> getArchivedStories({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, List<PostModel>>> getArchivedPosts({
    required int page,
    required int limit,
  });

  // ⭐️ أضف methods للـ Like و Share
  Future<void> reactToArchivedPost({
    required String postId,
    required ReactionType? reactionType,
    required bool isRemove,
  });

  Future<Either<Failure, String>> shareArchivedPost({
    required String postId,
    required String action,
  });

  Future<Either<Failure, String>> toggleSavePost({
    required String postId,
    required bool isRemove,
  });

  Future<Either<Failure, String>> deletePost({required String postId});

  void toggleHidePost({required String postId, required bool isHide});

  Future<Either<Failure, String>> blockUser({required String userId});
  Future<Either<Failure, String>> unblockUser({required String userId});

  Future<Either<Failure, String>> archivePost({
    required String postId,
    required bool isRemove,
  });

  Future<void> unarchivePost({required String postId});
}

class ArchiveRepositoryImpl implements ArchiveRepository {
  final ApiService _apiService;

  ArchiveRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, ArchivedChatsResponseModel>> getArchivedChats({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        endPoint: '/chat/archived',
        query: {'page': page, 'limit': limit},
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>?;
        if (data == null) {
          return Right(
            ArchivedChatsResponseModel(
              chatRooms: [],
              currentPage: 1,
              totalPages: 1,
              totalCount: 0,
              hasMore: false,
            ),
          );
        }

        return Right(ArchivedChatsResponseModel.fromJson(data));
      } else {
        final errorMessage =
            response['message']?.toString() ?? 'فشل جلب المحادثات المؤرشفة';
        return Left(ServerFailure(errorMessage));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unarchiveChat(String chatId) async {
    try {
      final response = await _apiService.patch(
        endPoint: '/chat/$chatId/unarchive', // ✅ تصحيح المسار
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(
            response['message']?.toString() ?? 'فشل إلغاء أرشفة المحادثة',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostModel>>> getArchivedPosts({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await _apiService.get(
        endPoint: '/posts/archived',
        query: {'page': page, 'limit': limit},
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
          ServerFailure(response['message'] ?? 'فشل جلب المنشورات المؤرشفة'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> reactToArchivedPost({
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
  Future<Either<Failure, String>> shareArchivedPost({
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
  Future<Either<Failure, String>> archivePost({
    required String postId,
    required bool isRemove,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: "${ApiEndPoint.archivePost}$postId",
        query: {'action': isRemove ? 'remove' : 'add'},
      );
      if (response['success'] == true || response['status'] == 'success') {
        return Right(
          response['message'] ??
              (isRemove ? 'تم إلغاء الأرشفة بنجاح' : 'تم أرشفة المنشور بنجاح'),
        );
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
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
  Future<Either<Failure, String>> unblockUser({required String userId}) async {
    try {
      final response = await _apiService.delete(
        endPoint: ApiEndPoint.unblockuser,
        data: {"blockedId": userId},
      );
      if (response['success'] == true || response['status'] == 'success') {
        return Right(response['message'] ?? 'تم إلغاء حظر المستخدم بنجاح');
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> unarchivePost({required String postId}) async {
    await archivePost(postId: postId, isRemove: true);
  }

  @override
  Future<Either<Failure, List<UserStoriesModel>>> getArchivedStories({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        endPoint: '/stories/archived',
        query: {'page': page, 'limit': limit},
      );

      if (response['success'] != true) {
        final errorMsg =
            response['message']?.toString() ?? 'فشل جلب القصص المؤرشفة';
        return Left(ServerFailure(errorMsg));
      }

      final dataObj = response['data'] as Map<String, dynamic>?;
      if (dataObj == null) return const Right([]);

      final List<dynamic> resultList =
          dataObj['result'] as List<dynamic>? ?? [];

      final userStories = resultList
          .map((item) {
            try {
              return UserStoriesModel.fromJson(item as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<UserStoriesModel>()
          .toList();

      return Right(userStories);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChatRoom(String chatId) async {
    try {
      final response = await _apiService.delete(endPoint: '/chat/$chatId');
      if (response['success'] == true) {
        return const Right(null);
      }
      return Left(
        ServerFailure(response['message']?.toString() ?? 'فشل حذف المحادثة'),
      );
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
