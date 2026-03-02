import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../models/package_model.dart';

abstract class AdvisorPackagesRepository {
  Future<Either<Failure, List<AdvisorPackageModel>>> getPackages();
}

class AdvisorPackagesRepositoryImpl implements AdvisorPackagesRepository {
  final ApiService _apiService;

  AdvisorPackagesRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, List<AdvisorPackageModel>>> getPackages() async {
    try {
      final response = await _apiService.get(endPoint: '/package');

      if (response['success'] == true) {
        final List<dynamic> packagesJson =
            response['data']?['packagesDto'] ?? [];
        final packages = packagesJson
            .map((json) => AdvisorPackageModel.fromJson(json))
            .toList();
        return Right(packages);
      } else {
        return Left(
          ServerFailure(
            response['message']?.toString() ?? 'فشل استرجاع الباقات',
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
