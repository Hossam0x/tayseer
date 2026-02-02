import 'package:dartz/dartz.dart';
import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart';
import 'package:tayseer/features/user/marriage/repositories/marriage_repository.dart';
import 'package:tayseer/my_import.dart';

class MarriageRepositoryImpl implements MarriageRepository {
  final ApiService _apiService;

  MarriageRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, UsersMarriageResponse>> getMarriageProfile() async {
    try {
      final response = await _apiService.get(endPoint: '/user/users-for-marry');
      debugPrint('Marriage Profile Data: $response');

      if (response['success'] == true) {
        final profile = UsersMarriageResponse.fromJson(response);
        return Right(profile);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل جلب الملف'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
