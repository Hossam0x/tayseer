import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';
import '../models/user_profile_model.dart';

// features/user/user_profile/data/repositories/user_profile_repository.dart
abstract class UserProfileRepository {
  Future<Either<Failure, UserProfileModel>> getUserProfile();
  Future<Either<Failure, UserProfileModel>> updateUserProfile({
    required String name,
    required String username,
    required String description,
    File? imageFile,
  });
}

// features/user/user_profile/data/repositories/user_profile_repository_impl.dart
class UserProfileRepositoryImpl implements UserProfileRepository {
  final ApiService _apiService;

  UserProfileRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, UserProfileModel>> getUserProfile() async {
    try {
      final response = await _apiService.get(endPoint: '/user/profile');

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final profile = UserProfileModel.fromJson(data);
        return Right(profile);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل جلب ملف المستخدم'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfileModel>> updateUserProfile({
    required String name,
    required String username,
    required String description,
    File? imageFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'username': username,
        'descreption': description,
      });

      if (imageFile != null) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: 'profile_image.jpg',
            ),
          ),
        );
      }

      final response = await _apiService.patch(
        endPoint: '/user/profile',
        data: formData,
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final profile = UserProfileModel.fromJson(data);
        return Right(profile);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل تحديث الملف الشخصي'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
