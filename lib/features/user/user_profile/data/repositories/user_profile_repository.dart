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
      // إنشاء FormData
      final formData = FormData();

      // إضافة الحقول النصية
      formData.fields.addAll([
        MapEntry('name', name),
        MapEntry('username', username),
        MapEntry('mydescription', description),
      ]);

      // إضافة ملف الصورة إذا كان موجوداً
      if (imageFile != null && await imageFile.exists()) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
              // contentType: MediaType('image', 'jpeg'),
            ),
          ),
        );
      }

      debugPrint('📤 إرسال بيانات تحديث الملف الشخصي:');
      debugPrint('   - الاسم: $name');
      debugPrint('   - اسم المستخدم: $username');
      debugPrint('   - الوصف: $description');
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
      debugPrint('   - الحالة: ${e.response?.statusCode}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      debugPrint('❌ خطأ غير متوقع في تحديث الملف الشخصي: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
