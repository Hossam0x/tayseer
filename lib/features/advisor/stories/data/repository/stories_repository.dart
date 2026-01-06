import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';

import '../../../../../core/errors/failure.dart';

abstract class StoriesRepository {
  Future<Either<Failure, List<UserStoriesModel>>> fetchStories({
    required int page,
  });
  void markStoryAsViewed({required String storyId});
  void likeStory({required String storyId});
}
