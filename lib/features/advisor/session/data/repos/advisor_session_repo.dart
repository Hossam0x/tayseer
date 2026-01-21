import 'package:dartz/dartz.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/advisor/session/data/models/advisor_session_response.dart';

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
}
