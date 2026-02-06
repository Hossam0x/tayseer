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
    String? advisorId,
    bool isSpecial = false,
  }) async {
    try {
      var response = await apiService.get(
        endPoint: isSpecial
            ? ApiEndPoint.specialStories(advisorId)
            : ApiEndPoint.allStories,
        query: {'page': page},
      );

      final data = response['data'];
      debugPrint("Stories Debug: data type is ${data.runtimeType}");
      debugPrint("Stories Debug: isSpecial is $isSpecial");

      if (data == null) {
        return const Right([]);
      }

      if (data is List) {
        if (data.isEmpty) return const Right([]);

        // فحص أول عنصر، لو هو Story فردية (فيها id و userId) ولا UserStory (فيها stories list)
        final firstItem = data.first as Map<String, dynamic>;

        if (firstItem.containsKey('id') &&
            firstItem.containsKey('userId') &&
            !firstItem.containsKey('stories')) {
          // دي حالة الـ special stories: دي قائمة قصص خام
          final allStoryModels = data
              .map((e) => StoryModel.fromJson(e as Map<String, dynamic>))
              .toList();

          // تجميع القصص حسب الـ userId (غالباً هيكون مستخدم واحد في البروفايل بس بنعملها بشكل عام)
          final Map<String, List<StoryModel>> grouped = {};
          for (var story in allStoryModels) {
            grouped.putIfAbsent(story.userId, () => []).add(story);
          }

          final List<UserStoriesModel> userStoriesList = [];
          grouped.forEach((userId, stories) {
            userStoriesList.add(
              UserStoriesModel(
                userId: userId,
                name: "", // الباك مش باعت الاسم في الـ list
                image: "", // الباك مش باعت الصورة في الـ list
                isFollowed: false,
                isViewedByMe: stories.every((s) => s.viewsCount > 0),
                allViewed: stories.every((s) => s.viewsCount > 0),
                storiesCount: stories.length,
                stories: stories,
              ),
            );
          });
          return Right(userStoriesList);
        } else {
          // دي الحالة العادية لو الباك باعت List of UserStories مباشرة
          final storiesList = data
              .map((e) => UserStoriesModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return Right(storiesList);
        }
      } else if (data is Map) {
        final storiesResponse = StoriesResponseModel.fromJson(response);
        return Right(storiesResponse.data.result);
      } else {
        return Left(ServerFailure('تنسيق استجابة غير متوقع'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('فشل تحليل بيانات القصص: ${e.toString()}'));
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
