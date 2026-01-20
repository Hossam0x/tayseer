import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import 'ratings_repository.dart';
import '../models/rating_model.dart';

class RatingsRepositoryImpl implements RatingsRepository {
  final ApiService _apiService;

  RatingsRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, RatingsResponseModel>> getAdvisorRatings({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final advisorId = await _getAdvisorId();

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

  Future<String> _getAdvisorId() async {
    // TODO: استبدل هذا بآلية حقيقية لجلب الـ advisorId
    // يمكن أن يكون من SharedPreferences أو من Profile Cubit
    return '6947e98df9f8bce3bf355fc0'; // ID مؤقت للاختبار
  }
}
