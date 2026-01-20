import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../models/rating_model.dart';

abstract class RatingsRepository {
  Future<Either<Failure, RatingsResponseModel>> getAdvisorRatings({
    int page = 1,
    int limit = 10,
  });
}
