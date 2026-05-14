import 'package:dartz/dartz.dart';
import 'package:tayseer/features/user/sessions/data/models/user_session_model.dart';
import 'package:tayseer/my_import.dart';

class UserSessionsRepo {
  final ApiService _apiService;

  UserSessionsRepo(this._apiService);

  Future<Either<Failure, UserSessionsResponse>> getUserSessions({
    required int page,
    required int limit,
    String? status,
    String? paymentStatus,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (paymentStatus != null && paymentStatus.isNotEmpty) {
        queryParams['paymentStatus'] = paymentStatus;
      }

      final response = await _apiService.get(
        endPoint: ApiEndPoint.getUserSessions,
        query: queryParams,
      );

      return Right(UserSessionsResponse.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
