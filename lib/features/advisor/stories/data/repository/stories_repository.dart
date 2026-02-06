import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/my_import.dart';

abstract class StoriesRepository {
  Future<Either<Failure, List<UserStoriesModel>>> fetchStories({
    required int page,
    String? advisorId,
    bool isSpecial = false,
  });
  void markStoryAsViewed({required String storyId});
  void likeStory({required String storyId});
  Future<Either<Failure, void>> createStories({required XFile image});
}
