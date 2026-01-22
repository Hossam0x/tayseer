import 'package:dartz/dartz.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/advisor/session/data/models/advisor_session_response.dart';
import 'package:tayseer/features/user/my_space/data/model/pending_session.dart';

class AdvisorSessionRepo {
  final ApiService apiService;
  AdvisorSessionRepo(this.apiService);

  Future<Either<Failure, AdvisorSessionsModel>> getSessions() async {
    try {
      final response = await apiService.get(
        endPoint: ApiEndPoint.advisorsession,
      );
      return Right(AdvisorSessionsModel.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, PendingSessionResponse>> getpendingsession() async {
    try {
      final response = await apiService.get(
        endPoint: ApiEndPoint.getpendingsession,
      );

      return Right(PendingSessionResponse.fromJson(response));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, AdvisorSession>> acceptordeclinesession(
    String sessionId,
    String status,
  ) async {
    try {
      final response = await apiService.patch(
        endPoint: ApiEndPoint.acceptordeclinesession(sessionId),
        data: {"status": status},
      );

      return Right(AdvisorSession.fromJson(response['data']));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
