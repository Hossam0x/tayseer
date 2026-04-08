import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/user/user_profile/data/models/new_user_sub_model.dart';

abstract class UserPackagesRepository {
  Future<Either<Failure, List<NewUserSubModel>>> getPackages();
}

class UserPackagesRepositoryImpl implements UserPackagesRepository {
  final ApiService _apiService;

  UserPackagesRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, List<NewUserSubModel>>> getPackages() async {
    try {
      final response = await _apiService.get(endPoint: '/new-user-sub');
      if (response['success'] == true) {
        final List<dynamic> subsJson = response['data'] ?? [];
        final subs = subsJson
            .map((json) => NewUserSubModel.fromJson(json))
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
