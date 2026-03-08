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
    required BuildContext context,
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
          final Map<String, List<Map<String, dynamic>>> groupedRaw = {};
          for (var rawItem in data) {
            final rawMap = rawItem as Map<String, dynamic>;
            String uid = '';
            if (rawMap['userId'] is String) {
              uid = rawMap['userId'];
            } else if (rawMap['userId'] is Map) {
              uid = rawMap['userId']['_id'] ?? '';
            }
            groupedRaw.putIfAbsent(uid, () => []).add(rawMap);
          }
          final List<UserStoriesModel> userStoriesList = [];
          groupedRaw.forEach((userId, rawStories) {
            final List<StoryModel> stories = rawStories
                .map((e) => StoryModel.fromJson(e))
                .toList();
            // isViewedByMe: true if ANY story has isViewedByMe=true in raw JSON
            final isViewedByMe = rawStories.any(
              (s) => s['isViewedByMe'] == true || s['isViewed'] == true,
            );
            // allViewed: true if ALL stories are viewed
            final allViewed = rawStories.every(
              (s) => s['isViewedByMe'] == true || s['isViewed'] == true,
            );
            userStoriesList.add(
              UserStoriesModel(
                userId: userId,
                name: stories.isNotEmpty
                    ? (stories.first.isMine ? context.tr("your_story") : "")
                    : "",
                image: stories.isNotEmpty ? stories.first.image : "",
                isFollowed: false,
                isViewedByMe: isViewedByMe,
                allViewed: allViewed,
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
        // الباك بيرجع special stories كـ object واحد (UserStoriesModel) مباشرة في data
        if (data.containsKey('stories')) {
          final userStories = UserStoriesModel.fromJson(
            Map<String, dynamic>.from(data),
          );
          return Right([userStories]);
        }
        // الحالة العادية: data فيها result + pagination
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
  Future<Either<Failure, List<UserStoriesModel>>> fetchStoriesSilent({
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
      if (data == null) return const Right([]);

      if (data is List) {
        if (data.isEmpty) return const Right([]);
        final firstItem = data.first as Map<String, dynamic>;

        if (firstItem.containsKey('id') &&
            firstItem.containsKey('userId') &&
            !firstItem.containsKey('stories')) {
          final Map<String, List<Map<String, dynamic>>> groupedRaw = {};
          for (var rawItem in data) {
            final rawMap = rawItem as Map<String, dynamic>;
            String uid = '';
            if (rawMap['userId'] is String) {
              uid = rawMap['userId'];
            } else if (rawMap['userId'] is Map) {
              uid = rawMap['userId']['_id'] ?? '';
            }
            groupedRaw.putIfAbsent(uid, () => []).add(rawMap);
          }
          final List<UserStoriesModel> userStoriesList = [];
          groupedRaw.forEach((userId, rawStories) {
            final List<StoryModel> stories = rawStories
                .map((e) => StoryModel.fromJson(e))
                .toList();
            final isViewedByMe = rawStories.any(
              (s) => s['isViewedByMe'] == true || s['isViewed'] == true,
            );
            final allViewed = rawStories.every(
              (s) => s['isViewedByMe'] == true || s['isViewed'] == true,
            );
            userStoriesList.add(
              UserStoriesModel(
                userId: userId,
                name: '',
                image: stories.isNotEmpty ? stories.first.image : '',
                isFollowed: false,
                isViewedByMe: isViewedByMe,
                allViewed: allViewed,
                storiesCount: stories.length,
                stories: stories,
              ),
            );
          });
          return Right(userStoriesList);
        } else {
          final storiesList = data
              .map((e) => UserStoriesModel.fromJson(e as Map<String, dynamic>))
              .toList();
          return Right(storiesList);
        }
      } else if (data is Map) {
        // الباك بيرجع special stories كـ object واحد (UserStoriesModel) مباشرة في data
        if (data.containsKey('stories')) {
          final userStories = UserStoriesModel.fromJson(
            Map<String, dynamic>.from(data),
          );
          return Right([userStories]);
        }
        // الحالة العادية: data فيها result + pagination
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
  Future<Either<Failure, StoryModel>> createStories({
    String? content,
    List<File>? images,
    List<XFile>? videos,
    double? videoDuration,
    Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final List<MultipartFile> uploadedImages = [];
      if (images != null) {
        for (final file in images) {
          final filename = file.path.split(Platform.pathSeparator).isNotEmpty
              ? file.path.split(Platform.pathSeparator).last
              : (file.uri.pathSegments.isNotEmpty
                    ? file.uri.pathSegments.last
                    : 'file');
          uploadedImages.add(
            await MultipartFile.fromFile(file.path, filename: filename),
          );
        }
      }

      final List<MultipartFile> uploadedVideos = [];
      if (videos != null) {
        for (final video in videos) {
          uploadedVideos.add(await uploadVideoToApi(video));
        }
      }

      final data = <String, dynamic>{
        if (content != null) 'content': content,
        if (uploadedImages.isNotEmpty) 'images': uploadedImages,
        if (uploadedVideos.isNotEmpty) 'videos': uploadedVideos,
        if (videoDuration != null && videoDuration > 0)
          'videoDuration': videoDuration,
      };

      final response = await apiService.post(
        endPoint: '/stories/create',
        isFromData: true,
        isAuth: true,
        data: data,
        onSendProgress: onSendProgress,
      );

      final success = response['success'] ?? false;

      if (success && response['data'] != null) {
        final createdStory = StoryModel.fromJson(response['data']);
        return right(createdStory);
      } else {
        return left(ServerFailure(response['message'] ?? 'فشل إنشاء القصة'));
      }
    } on DioException catch (error) {
      final message =
          error.response?.data['message'] ?? 'خطأ في الاتصال بالخادم';
      return left(ServerFailure(message));
    } catch (error) {
      return left(ServerFailure('حدث خطأ غير متوقع: $error'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleArchiveStory({
    required String storyId,
    required bool isArchive,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: '/stories/toggle-archive/$storyId',
        query: {'action': isArchive ? 'add' : 'remove'},
      );
      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل أرشفة القصة'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteStory({required String storyId}) async {
    try {
      final response = await apiService.delete(
        endPoint: '/stories/delete/$storyId',
      );
      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل حذف القصة'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> makeStorySpecial({
    required String storyId,
  }) async {
    try {
      final response = await apiService.patch(
        endPoint: '/stories/make-special/$storyId',
      );
      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل تمييز القصة كـ Special'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> hideStory({required String storyId}) async {
    try {
      final response = await apiService.post(
        endPoint: '/hidden/story',
        query: {'action': 'add'},
        data: {'storyId': storyId},
      );
      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل إخفاء القصة'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
