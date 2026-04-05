import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../models/rating_model.dart';

abstract class RatingsRepository {
  Future<Either<Failure, RatingsResponseModel>> getAdvisorRatings({
    required String advisorId,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, RatingModel>> submitRating({
    required String advisorId,
    required int rating,
    required String review,
  });
}
