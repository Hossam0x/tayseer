import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';

abstract class AdvisorPackagesRepository {
  Future<Either<Failure, List<NewAdvisorSubModel>>> getPackages();
}

class AdvisorPackagesRepositoryImpl implements AdvisorPackagesRepository {
  final ApiService _apiService;

  AdvisorPackagesRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, List<NewAdvisorSubModel>>> getPackages() async {
    try {
      final response = await _apiService.get(endPoint: '/new-advisor-sub');

      if (response['success'] == true) {
        final List<dynamic> subsJson = response['data'] ?? [];
        final subs = subsJson
            .map((json) => NewAdvisorSubModel.fromJson(json))
            .toList();
        return Right(subs);
      } else {
        return Left(
          ServerFailure(
            response['message']?.toString() ?? 'فشل استرجاع الاشتراكات',
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
