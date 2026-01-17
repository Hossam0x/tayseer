import 'package:dartz/dartz.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
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
    try {
      await _apiService.delete(endPoint: "/posts/delete/$postId");
    } catch (e) {
      debugPrint('❌ Error removing from saved: $e');
      rethrow;
    }
  }
}
