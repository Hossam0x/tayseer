import 'package:dartz/dartz.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/my_import.dart';
import '../models/archive_models.dart';

abstract class ArchiveRepository {
  Future<Either<Failure, ArchivedChatsResponseModel>> getArchivedChats({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, void>> unarchiveChat(String chatId);

  Future<Either<Failure, List<ArchiveStoryModel>>> getArchivedStories({
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

      print('✅ Archived Chats Response received');

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>?;
        if (data == null) {
          print('⚠️ Data is null in archived chats');
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

        final chatsResponse = ArchivedChatsResponseModel.fromJson(data);
        print('✅ Parsed ${chatsResponse.chatRooms.length} archived chats');

        return Right(chatsResponse);
      } else {
        final errorMessage =
            response['message']?.toString() ?? 'فشل جلب المحادثات المؤرشفة';
        print('❌ Archived chats error: $errorMessage');
        return Left(ServerFailure(errorMessage));
      }
    } on DioException catch (e) {
      print('❌ Dio Error in archived chats: ${e.message}');
      if (e.response != null) {
        print('❌ Response: ${e.response?.data}');
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e, stackTrace) {
      print('❌ Error in archived chats: $e');
      print('Stack Trace: $stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unarchiveChat(String chatId) async {
    try {
      final response = await _apiService.patch(
        endPoint: '/chat/$chatId/unarchive', // ✅ تصحيح المسار
      );

      print('✅ Unarchive response: $response');

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
      print('❌ Dio Error in unarchiveChat: ${e.message}');
      print('❌ Response data: ${e.response?.data}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      print('❌ General Error in unarchiveChat: $e');
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

      print('🔍 API Response for archived posts: ${response.toString()}');

      if (response['success'] == true) {
        // ⭐️ استخدم نفس parsing مثل Home
        final postsList =
            (response['data']?['postsDto'] as List<dynamic>?)
                ?.map((e) => PostModel.fromJson(e))
                .toList() ??
            [];

        print('🔍 Parsed ${postsList.length} archived posts');
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
  Future<void> unarchivePost({required String postId}) async {
    await archivePost(postId: postId, isRemove: true);
  }

  @override
  Future<Either<Failure, List<ArchiveStoryModel>>> getArchivedStories({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        endPoint: '/stories/archived',
        query: {'page': page, 'limit': limit},
      );

      print('📌 Stories Response: $response');

      if (response['success'] != true) {
        final errorMsg =
            response['message']?.toString() ?? 'فشل جلب القصص المؤرشفة';
        return Left(ServerFailure(errorMsg));
      }

      // ────────────────────────────────────────────────
      //           ✅ الحل الصحيح
      // ────────────────────────────────────────────────
      final dataObj = response['data'] as Map<String, dynamic>?;

      if (dataObj == null) {
        print('⚠️ "data" field is null or not a map');
        return const Right([]);
      }

      // ✅ نستخرج الـ result من داخل data
      final List<dynamic> resultList =
          dataObj['result'] as List<dynamic>? ?? [];

      print('📦 عدد القصص المُسترجعة: ${resultList.length}');

      final stories = resultList
          .map((item) {
            try {
              return ArchiveStoryModel.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              print('❌ فشل تحليل قصة واحدة: $e');
              print('   البيانات: $item');
              return null;
            }
          })
          .whereType<ArchiveStoryModel>()
          .toList();

      return Right(stories);
    } on DioException catch (e) {
      print('❌ DioException in getArchivedStories: ${e.message}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e, stack) {
      print('❌ Unexpected error in getArchivedStories: $e');
      print(stack);
      return Left(ServerFailure(e.toString()));
    }
  }
}
