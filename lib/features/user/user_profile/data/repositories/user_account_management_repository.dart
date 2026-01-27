import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';

abstract class UserAccountManagementRepository {
  Future<Either<Failure, void>> suspendAccount();
  Future<Either<Failure, void>> deleteAccount();
}

class UserAccountManagementRepositoryImpl
    implements UserAccountManagementRepository {
  final ApiService _apiService;

  UserAccountManagementRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, void>> suspendAccount() async {
    try {
      final response = await _apiService.patch(endPoint: '/user/suspend-user');

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(
            response['message']?.toString() ?? 'فشل إيقاف الحساب مؤقتاً',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final response = await _apiService.patch(endPoint: '/user/delete-user');

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response['message']?.toString() ?? 'فشل حذف الحساب'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
