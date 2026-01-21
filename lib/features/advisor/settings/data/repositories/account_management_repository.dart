import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';

abstract class AccountManagementRepository {
  Future<Either<Failure, void>> suspendAccount();
  Future<Either<Failure, void>> deleteAccount();
}

class AccountManagementRepositoryImpl implements AccountManagementRepository {
  final ApiService _apiService;

  AccountManagementRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, void>> suspendAccount() async {
    try {
      final response = await _apiService.patch(endPoint: '/advisor/suspend');

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
      final response = await _apiService.delete(
        endPoint: '/advisor/deleteUser',
      );

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
