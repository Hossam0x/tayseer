import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../../../../shared/profile/data/repositories/ratings_repository.dart';
import '../../../../shared/profile/data/models/rating_model.dart';

class RatingsRepositoryImpl implements RatingsRepository {
  final ApiService _apiService;

  RatingsRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, RatingsResponseModel>> getAdvisorRatings({
    required String advisorId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        endPoint: '/advisor-rating/advisor/$advisorId',
        query: {'page': page, 'limit': limit},
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final ratingsResponse = RatingsResponseModel.fromJson(data);
        return Right(ratingsResponse);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل جلب التقييمات'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, RatingModel>> submitRating({
    required String advisorId,
    required int rating,
    required String review,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: '/advisor-rating',
        data: {
          "rating": rating,
          "review": review,
          "advisorId": advisorId,
        },
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final ratingModel = RatingModel.fromJson(data);
        return Right(ratingModel);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل تقديم التقييم'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
