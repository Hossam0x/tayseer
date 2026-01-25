import 'package:dartz/dartz.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/my_import.dart';
import '../models/archive_models.dart';

abstract class ArchiveRepository {
  Future<Either<Failure, ArchivedChatsResponseModel>> getArchivedChats({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, void>> unarchiveChat(String chatId);

  Future<Either<Failure, List<ArchiveStoryModel>>> getArchivedStories({
    int page = 1,
    int limit = 20,
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

  Future<void> unarchivePost({required String postId});
}

class ArchiveRepositoryImpl implements ArchiveRepository {
  final ApiService _apiService;

  ArchiveRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, ArchivedChatsResponseModel>> getArchivedChats({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        endPoint: '/chat/archived',
        query: {'page': page, 'limit': limit},
      );

      // Debug: طباعة الـ response بالكامل
      print('📌 Full Response: $response');

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>?;
        if (data == null) {
          print('⚠️ Data is null');
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

        // Debug: طباعة الـ chatRooms
        if (data['chatRooms'] != null) {
          print('📦 Chat Rooms count: ${(data['chatRooms'] as List).length}');
          for (var i = 0; i < (data['chatRooms'] as List).length; i++) {
            print('   Chat $i: ${data['chatRooms'][i]}');
          }
        }

        final chatsResponse = ArchivedChatsResponseModel.fromJson(data);
        return Right(chatsResponse);
      } else {
        return Left(
          ServerFailure(
            response['message']?.toString() ?? 'فشل جلب المحادثات المؤرشفة',
          ),
        );
      }
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e, stackTrace) {
      print('❌ Error: $e');
      print('Stack Trace: $stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unarchiveChat(String chatId) async {
    try {
      final response = await _apiService.post(
        endPoint: '/chat/unarchive/$chatId',
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
        endPoint: '/posts/archive',
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
  Future<void> unarchivePost({required String postId}) async {
    try {
      await _apiService.post(endPoint: "/likes/$postId");
    } catch (e) {
      debugPrint('❌ Error unarchiving post: $e');
      rethrow;
    }
  }

  @override
  Future<Either<Failure, List<ArchiveStoryModel>>> getArchivedStories({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        endPoint: '/stories/archived',
        query: {'page': page, 'limit': limit},
      );

      // Debug: طباعة الـ response
      print('📌 Stories Response: $response');

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        print('📦 Stories count: ${data.length}');

        // Debug: طباعة كل قصة
        for (var i = 0; i < data.length; i++) {
          print('   Story $i: ${data[i]}');
        }

        final stories = data
            .map((story) => ArchiveStoryModel.fromJson(story))
            .toList();

        return Right(stories);
      } else {
        final errorMessage =
            response['message']?.toString() ?? 'فشل جلب القصص المؤرشفة';
        print('❌ Stories Error: $errorMessage');
        return Left(ServerFailure(errorMessage));
      }
    } on DioException catch (e) {
      print('❌ Stories Dio Error: ${e.message}');
      if (e.response != null) {
        print('❌ Response Data: ${e.response?.data}');
        print('❌ Response Status: ${e.response?.statusCode}');
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e, stackTrace) {
      print('❌ Stories General Error: $e');
      print('❌ Stack Trace: $stackTrace');
      return Left(ServerFailure(e.toString()));
    }
  }
}
