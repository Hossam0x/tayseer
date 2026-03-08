import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/my_import.dart';

abstract class StoriesRepository {
  Future<Either<Failure, List<UserStoriesModel>>> fetchStories({
    required int page,
    String? advisorId,
    bool isSpecial = false,
    required BuildContext context,
  });

  /// Context-free version for silent background fetches
  Future<Either<Failure, List<UserStoriesModel>>> fetchStoriesSilent({
    required int page,
    String? advisorId,
    bool isSpecial = false,
  });
  void markStoryAsViewed({required String storyId});
  void likeStory({required String storyId});
  Future<Either<Failure, StoryModel>> createStories({
    String? content,
    List<File>? images,
    List<XFile>? videos,
    double? videoDuration,
    Function(int sent, int total)? onSendProgress,
  });
  Future<Either<Failure, void>> toggleArchiveStory({
    required String storyId,
    required bool isArchive,
  });
  Future<Either<Failure, void>> deleteStory({required String storyId});
  Future<Either<Failure, void>> makeStorySpecial({required String storyId});
  Future<Either<Failure, void>> hideStory({required String storyId});
}
