import 'package:tayseer/core/functions/upload_imageandvideo_to_api.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/data/repository/stories_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../../my_import.dart';

class StoriesRepositoryImpl implements StoriesRepository {
  final ApiService apiService;

  StoriesRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, List<UserStoriesModel>>> fetchStories({
    required int page,
  }) async {
    try {
      var response = await apiService.get(
        endPoint: ApiEndPoint.stories,
        query: {'page': page},
      );
      final storiesResponse = StoriesResponseModel.fromJson(response);
      return Right(storiesResponse.data.result);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    }
  }

  @override
  void likeStory({required String storyId}) {
    apiService.post(
      isAuth: true,
      endPoint: ApiEndPoint.likeStory,
      data: {'storyId': storyId},
    );
  }

  @override
  void markStoryAsViewed({required String storyId}) {
    apiService.patch(endPoint: ApiEndPoint.storyViews + storyId);
  }

  @override
  Future<Either<Failure, void>> createStories({required XFile image}) async {
    try {
      final response = await apiService.post(
        endPoint: '/stories/create',
        isFromData: true,

        data: {'images': await uploadImageToApi(image)},
      );

      final success = response['success'] ?? false;

      if (success) {
        return right(null);
      } else {
        return left(ServerFailure(response['message'] ?? 'فشل إنشاء المنشور'));
      }
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ?? 'خطأ في الاتصال بالخادم';
      return left(ServerFailure(message));
    } catch (error) {
      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }
}
