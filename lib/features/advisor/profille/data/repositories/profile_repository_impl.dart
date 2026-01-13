// features/advisor/profile/data/repositories/profile_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import 'profile_repository.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService _apiService;

  ProfileRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, ProfileModel>> getAdvisorProfile() async {
    try {
      final response = await _apiService.get(endPoint: '${ApiEndPoint.profileData}/695689eb57683ad28d9173a4');

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final profile = ProfileModel.fromJson(data);
        return Right(profile);
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل جلب البروفايل'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
