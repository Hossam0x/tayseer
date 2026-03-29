import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';

/// Shared abstract contract for account management.
/// Advisor and user implementations inject different endpoints.
abstract class AccountManagementRepository {
  Future<Either<Failure, void>> suspendAccount();
  Future<Either<Failure, void>> deleteAccount();
}

class AccountManagementRepositoryImpl implements AccountManagementRepository {
  final ApiService _apiService;
  final String _suspendEndpoint;
  final String _deleteEndpoint;
  final String _deleteMethod; // 'patch' or 'delete'

  const AccountManagementRepositoryImpl({
    required ApiService apiService,
    required String suspendEndpoint,
    required String deleteEndpoint,
    String deleteMethod = 'delete',
  }) : _apiService = apiService,
       _suspendEndpoint = suspendEndpoint,
       _deleteEndpoint = deleteEndpoint,
       _deleteMethod = deleteMethod;

  @override
  Future<Either<Failure, void>> suspendAccount() async {
    try {
      final response = await _apiService.patch(endPoint: _suspendEndpoint);
      if (response['success'] == true) return const Right(null);
      return Left(
        ServerFailure(response['message']?.toString() ?? 'suspend_failed'),
      );
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final Map<String, dynamic> response;
      if (_deleteMethod == 'patch') {
        response = await _apiService.patch(endPoint: _deleteEndpoint);
      } else {
        response = await _apiService.delete(endPoint: _deleteEndpoint);
      }
      if (response['success'] == true) return const Right(null);
      return Left(
        ServerFailure(response['message']?.toString() ?? 'delete_failed'),
      );
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
