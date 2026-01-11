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
}
