import 'package:dartz/dartz.dart';
import '../../../../../my_import.dart';

abstract class OrderManagementRepository {
  Future<Either<Failure, Map<String, dynamic>>> changeAvailability({
    required bool isAvailable,
  });
}

class OrderManagementRepositoryImpl implements OrderManagementRepository {
  final ApiService _apiService;

  OrderManagementRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, Map<String, dynamic>>> changeAvailability({
    required bool isAvailable,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.changeIsAvaliableForSessions,
        data: {"isAvaliableForSessions": isAvailable},
      );

      if (response['success'] == true || response['status'] == true) {
        return Right(response);
      } else {
        return Left(
          ServerFailure(
            response['message']?.toString() ?? 'Failed to update availability',
          ),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
