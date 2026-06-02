import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';

abstract class UserSettingsRepository {
  Future<Either<Failure, bool>> updatePhoneNumber({
    required String countryCode,
    required String phoneNumber,
    String otpMethod,
  });
  Future<Either<Failure, bool>> updateEmail({required String email});
}

class UserSettingsRepositoryImpl implements UserSettingsRepository {
  final ApiService _apiService;

  UserSettingsRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, bool>> updatePhoneNumber({
    required String countryCode,
    required String phoneNumber,
    String otpMethod = 'sms',
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: '/user/update-phone-number',
        data: {
          'countryCode': countryCode,
          'phone': phoneNumber,
          'otpMethod': otpMethod,
        },
      );

      if (response['success'] == true) {
        return const Right(true);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل تحديث الهاتف'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateEmail({required String email}) async {
    try {
      final response = await _apiService.post(
        endPoint: '/user/update-email',
        data: {'email': email},
      );

      if (response['success'] == true) {
        return const Right(true);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل تحديث الإيميل'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
