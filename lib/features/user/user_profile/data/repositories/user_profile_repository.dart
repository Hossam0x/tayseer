import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../models/user_profile_model.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfileModel>> getUserProfile();
}

class UserProfileRepositoryImpl implements UserProfileRepository {
  final ApiService _apiService;

  UserProfileRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, UserProfileModel>> getUserProfile() async {
    try {
      final response = await _apiService.get(endPoint: '/user/profile');

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final profile = UserProfileModel.fromJson(data);
        return Right(profile);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل جلب ملف المستخدم'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
