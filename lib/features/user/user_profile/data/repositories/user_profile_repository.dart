import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:tayseer/my_import.dart';
import '../models/user_profile_model.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfileModel>> getUserProfile();
  Future<Either<Failure, UserProfileModel>> updateUserProfile({
    String? name,
    String? username,
    String? description,
    File? imageFile,
    int? age,
    String? gender,
  });
  Future<Either<Failure, void>> toggleAnonymousStatus(bool isAnonymous);
  Future<Either<Failure, void>> toggleMarriageStatus(bool enable);
  Future<Either<Failure, void>> updateImageBlur(bool blurEnabled);
}

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
    String? name,
    String? username,
    String? description,
    File? imageFile,
    int? age,
    String? gender,
  }) async {
    try {
      final formData = FormData();

      // إضافة الحقول النصية إذا كانت موجودة
      if (name != null) formData.fields.add(MapEntry('name', name));
      if (username != null) formData.fields.add(MapEntry('username', username));
      if (description != null)
        formData.fields.add(MapEntry('description', description));
      if (age != null) formData.fields.add(MapEntry('age', age.toString()));
      if (gender != null) formData.fields.add(MapEntry('gender', gender));

      // إضافة ملف الصورة إذا كان موجوداً
      if (imageFile != null && await imageFile.exists()) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          ),
        );
      }

      debugPrint('📤 إرسال تحديث الملف الشخصي:');
      if (name != null) debugPrint('   - الاسم: $name');
      if (username != null) debugPrint('   - اسم المستخدم: $username');
      if (description != null) debugPrint('   - الوصف: $description');
      if (age != null) debugPrint('   - السن: $age');
      if (gender != null) debugPrint('   - النوع: $gender');
      debugPrint('   - يوجد صورة: ${imageFile != null}');

      final response = await _apiService.patch(
        endPoint: '/user/update-profile',
        data: formData,
      );

      debugPrint('📥 استجابة تحديث الملف الشخصي: $response');

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final profile = UserProfileModel.fromJson(data);
        return Right(profile);
      } else {
        debugPrint('❌ فشل تحديث الملف الشخصي: ${response['message']}');
        return Left(
          ServerFailure(response['message'] ?? 'فشل تحديث الملف الشخصي'),
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ خطأ Dio في تحديث الملف الشخصي: ${e.message}');
      debugPrint('   - الاستجابة: ${e.response?.data}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      debugPrint('❌ خطأ غير متوقع في تحديث الملف الشخصي: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleAnonymousStatus(bool isAnonymous) async {
    try {
      final response = await _apiService.post(
        endPoint: '/user/be-anonymous',
        data: {'Anonymous': isAnonymous},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل تحديث حالة المجهول'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleMarriageStatus(bool enable) async {
    try {
      final response = await _apiService.patch(
        endPoint: '/user/change-avaliable-for-marry',
        data: {'action': enable ? 'enable' : 'disable'},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل تحديث حالة الزواج'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateImageBlur(bool blurEnabled) async {
    try {
      final response = await _apiService.patch(
        endPoint: '/auth/change-image-blur',
        data: {'blurEnabled': blurEnabled},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل تحديث إعدادات الصورة'),
        );
      }
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
