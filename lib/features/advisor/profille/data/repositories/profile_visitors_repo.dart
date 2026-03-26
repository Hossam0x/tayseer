import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/core/utils/api_service.dart';
import '../models/profile_visitors_model.dart';

abstract class ProfileVisitorsRepo {
  Future<Either<Failure, ProfileVisitorsData>> getProfileVisitors();
}

class ProfileVisitorsRepoImpl implements ProfileVisitorsRepo {
  final ApiService apiService;

  ProfileVisitorsRepoImpl(this.apiService);

  @override
  Future<Either<Failure, ProfileVisitorsData>> getProfileVisitors() async {
    try {
      var data = await apiService.get(endPoint: '/advisor/vistors');
      var response = ProfileVisitorsResponse.fromJson(data);

      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}
