import 'package:dartz/dartz.dart';
import 'package:tayseer/features/user/marriage_filter/repo/marriage_filter_repo.dart';
import 'package:tayseer/my_import.dart';

class MarriageFilterRepoImpl implements MarriageFilterRepo {
  MarriageFilterRepoImpl(this._apiService);
  final ApiService _apiService;
  @override
  Future<Either<Failure, void>> marriageFilter({
    required Map<String, dynamic> filters,
  }) async {
    try {
      final response = await _apiService.get(
        endPoint: '/user/users-for-marry',
        query: filters,
      );

      if (response['success'] == true) {
        return Right(null);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل ارسال التحيه'));
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}, Response: ${e.response}');
      return Future.value(Left(ServerFailure.fromDioError(e)));
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return Future.value(Left(ServerFailure(e.toString())));
    }
  }
}
