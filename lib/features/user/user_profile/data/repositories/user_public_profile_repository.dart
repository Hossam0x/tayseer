// features/user/user_public_profile/data/repositories/user_public_profile_repository.dart
import 'package:dartz/dartz.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart'; // ⭐ استيراد الـ Model الموحد
import 'package:tayseer/my_import.dart';

abstract class UserPublicProfileRepository {
  Future<Either<Failure, UserProfileModel>> getUserPublicProfile(
    // ⭐ تغيير النوع
    String userId,
  );
  Future<Either<Failure, String>> deleteUserAccount();
  Future<Either<Failure, String>> blockUser(String userId);
  Future<Either<Failure, String>> reportUser({
    required String reportedId,
    required String reason,
    required String reasonDetails,
  });
}

// features/user/user_public_profile/data/repositories/user_public_profile_repository_impl.dart
class UserPublicProfileRepositoryImpl implements UserPublicProfileRepository {
  final ApiService _apiService;

  UserPublicProfileRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, UserProfileModel>> getUserPublicProfile(
    // ⭐ تغيير النوع
    String userId,
  ) async {
    try {
      final response = await _apiService.get(endPoint: '/user/profile/$userId');

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final profile = UserProfileModel.fromJson(
          data,
        ); // ⭐ استخدام الـ Model الموحد
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
  Future<Either<Failure, String>> deleteUserAccount() async {
    try {
      final response = await _apiService.patch(endPoint: '/user/delete-user');

      if (response['success'] == true) {
        return Right(response['message'] ?? 'تم حذف الحساب بنجاح');
      } else {
        return Left(ServerFailure(response['message'] ?? 'فشل حذف الحساب'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> blockUser(String userId) async {
    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.blockuser,
        data: {"blockedId": userId},
      );
      if (response['success'] == true || response['status'] == 'success') {
        return Right(response['message'] ?? 'تم حظر المستخدم بنجاح');
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> reportUser({
    required String reportedId,
    required String reason,
    required String reasonDetails,
  }) async {
    try {
      final response = await _apiService.post(
        endPoint: '/personal-reports/',
        data: {
          "reportedId": reportedId,
          "reason": reason,
          "reasonDetails": reasonDetails,
        },
      );
      if (response['success'] == true || response['status'] == 'success') {
        return Right(response['message'] ?? 'تم إرسال الإبلاغ بنجاح');
      }
      return Left(ServerFailure(response['message'] ?? 'حدث خطأ'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
