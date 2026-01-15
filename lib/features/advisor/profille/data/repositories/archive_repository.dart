import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../models/archive_models.dart';

abstract class ArchiveRepository {
  Future<Either<Failure, ArchivedChatsResponseModel>> getArchivedChats({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, void>> unarchiveChat(String chatId);

  Future<Either<Failure, List<ArchivePostModel>>> getArchivedPosts({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, List<ArchiveStoryModel>>> getArchivedStories({
    int page = 1,
    int limit = 20,
  });
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
  Future<Either<Failure, List<ArchivePostModel>>> getArchivedPosts({
    int page = 1,
    int limit = 20,
  }) async {
    // TODO: استبدل هذا بالـ endpoint الحقيقي عندما يكون جاهزاً
    try {
      await Future.delayed(const Duration(seconds: 1));

      // بيانات تجريبية
      final posts = [
        ArchivePostModel(
          id: '1',
          title: 'منشور مؤرشف 1',
          image: 'https://example.com/image1.jpg',
          createdAt: '2024-01-13T10:00:00Z',
          likes: 15,
          comments: 3,
        ),
        ArchivePostModel(
          id: '2',
          title: 'منشور مؤرشف 2',
          image: 'https://example.com/image2.jpg',
          createdAt: '2024-01-12T10:00:00Z',
          likes: 25,
          comments: 5,
        ),
      ];

      return Right(posts);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ArchiveStoryModel>>> getArchivedStories({
    int page = 1,
    int limit = 20,
  }) async {
    // TODO: استبدل هذا بالـ endpoint الحقيقي عندما يكون جاهزاً
    try {
      await Future.delayed(const Duration(seconds: 1));

      // بيانات تجريبية
      final stories = [
        ArchiveStoryModel(
          id: '1',
          image: 'https://example.com/story1.jpg',
          createdAt: '2024-01-13T10:00:00Z',
          views: 150,
        ),
        ArchiveStoryModel(
          id: '2',
          image: 'https://example.com/story2.jpg',
          createdAt: '2024-01-12T10:00:00Z',
          views: 200,
        ),
      ];

      return Right(stories);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
