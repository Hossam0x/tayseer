// features/user/user_profile/data/repositories/marriage_profile_repository.dart

import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/my_import.dart';

/// 🎭 MOCKUP Repository - استخدام البيانات المحلية بدلاً من API
/// هذا mockup مؤقت حتى يكتمل الباك إند
class MarriageProfileRepository {
  final ApiService _apiService;
  static const String _storageKey = 'marriage_profile_data';

  MarriageProfileRepository(this._apiService);

  // ========== GET MARRIAGE PROFILE ==========
  Future<Either<Failure, MarriageUserProfileModel>> getMarriageProfile() async {
    try {
      // محاكاة تأخير الشبكة
      await Future.delayed(const Duration(milliseconds: 800));

      final prefs = await SharedPreferences.getInstance();
      final profileData = prefs.getString(_storageKey);

      if (profileData != null) {
        // تحميل البروفايل المحفوظ
        final jsonData = jsonDecode(profileData) as Map<String, dynamic>;
        final profile = MarriageUserProfileModel.fromJson(jsonData);
        debugPrint('✅ تم تحميل ملف الزواج من التخزين المحلي');
        debugPrint('   نسبة الاكتمال: ${profile.marriageCompletionPercentage}%');
        return Right(profile);
      } else {
        // إنشاء بروفايل افتراضي جديد (فارغ)
        final defaultProfile = MarriageUserProfileModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'مستخدم جديد',
          username: 'user_${DateTime.now().millisecondsSinceEpoch}',
          isMe: true,
          following: 0,
          followers: 0,
          isAvailableForMarriage: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // حفظ البروفايل الافتراضي
        await _saveProfile(defaultProfile);
        debugPrint('✅ تم إنشاء ملف زواج افتراضي جديد');
        return Right(defaultProfile);
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحميل ملف الزواج: $e');
      return Left(ServerFailure('حدث خطأ في تحميل البيانات: $e'));
    }
  }

  // ========== UPDATE MARRIAGE PROFILE ==========
  Future<Either<Failure, MarriageUserProfileModel>> updateMarriageProfile(
    MarriageUserProfileModel profile,
  ) async {
    try {
      // محاكاة تأخير الشبكة
      await Future.delayed(const Duration(milliseconds: 600));

      // تحديث وقت التعديل
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
      );

      // حفظ البروفايل
      await _saveProfile(updatedProfile);

      debugPrint('✅ تم تحديث ملف الزواج بنجاح');
      debugPrint('   نسبة الاكتمال: ${updatedProfile.marriageCompletionPercentage}%');
      
      return Right(updatedProfile);
    } catch (e) {
      debugPrint('❌ خطأ في تحديث ملف الزواج: $e');
      return Left(ServerFailure('حدث خطأ في التحديث: $e'));
    }
  }

  // ========== UPLOAD IMAGE ==========
  Future<Either<Failure, String>> uploadMarriageImage(File imageFile) async {
    try {
      // محاكاة تأخير رفع الصورة
      await Future.delayed(const Duration(seconds: 1));

      // حفظ مسار الصورة المحلي
      final imagePath = imageFile.path;

      debugPrint('✅ تم رفع الصورة: $imagePath');
      return Right(imagePath);
    } catch (e) {
      debugPrint('❌ خطأ في رفع الصورة: $e');
      return Left(ServerFailure('حدث خطأ في رفع الصورة: $e'));
    }
  }

  // ========== DELETE IMAGE ==========
  Future<Either<Failure, void>> deleteMarriageImage(String imageUrl) async {
    try {
      // محاكاة تأخير الحذف
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('✅ تم حذف الصورة: $imageUrl');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ خطأ في حذف الصورة: $e');
      return Left(ServerFailure('حدث خطأ في حذف الصورة: $e'));
    }
  }

  // ========== HELPER: SAVE PROFILE ==========
  Future<void> _saveProfile(MarriageUserProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(profile.toJson());
    await prefs.setString(_storageKey, jsonData);
    debugPrint('💾 تم حفظ البروفايل محلياً');
  }

  // ========== HELPER: CLEAR ALL DATA (للاختبار) ==========
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    debugPrint('🗑️ تم مسح جميع بيانات ملف الزواج');
  }

  // ========== HELPER: CREATE SAMPLE PROFILE (للاختبار) ==========
  Future<Either<Failure, MarriageUserProfileModel>> createSampleProfile() async {
    try {
      final sampleProfile = MarriageUserProfileModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'أحمد محمد',
        username: 'ahmed_mohamed',
        description: 'مهندس برمجيات، أبحث عن شريكة حياة',
        image: 'https://via.placeholder.com/150',
        following: 120,
        followers: 350,
        isMe: true,
        isVerified: true,
        location: 'القاهرة، مصر',
        
        // معلومات الزواج
        country: 'مصر',
        nationality: 'مصري',
        religion: 'مسلم',
        age: 28,
        height: '170 - 180 سم',
        ethnicity: 'قمحاوي',
        maritalStatus: 'سليم',
        financialStatus: 'جيد جداً',
        smoking: 'لا',
        marriageImages: [
          'https://via.placeholder.com/300x300/FF69B4/FFFFFF?text=صورة+1',
          'https://via.placeholder.com/300x300/87CEEB/FFFFFF?text=صورة+2',
        ],
        occupation: 'مهندس برمجيات',
        jobTitle: 'مطور تطبيقات موبايل',
        professionalLevel: 'موظف',
        religiosity: 'متدين',
        isAvailableForMarriage: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

      await _saveProfile(sampleProfile);
      debugPrint('✅ تم إنشاء ملف زواج تجريبي كامل');
      debugPrint('   نسبة الاكتمال: ${sampleProfile.marriageCompletionPercentage}%');
      
      return Right(sampleProfile);
    } catch (e) {
      debugPrint('❌ خطأ في إنشاء البروفايل التجريبي: $e');
      return Left(ServerFailure('حدث خطأ: $e'));
    }
  }
}

// ========== 🔄 READY FOR REAL API ==========
// عندما يكتمل الباك إند، استبدل هذا الكود بالتالي:

/*
class MarriageProfileRepository {
  final ApiService _apiService;

  MarriageProfileRepository(this._apiService);

  Future<Either<Failure, MarriageUserProfileModel>> getMarriageProfile() async {
    try {
      final response = await _apiService.get(
        endPoint: '/user/marriage-profile',
      );

      if (response['success'] == true) {
        final profile = MarriageUserProfileModel.fromJson(
          response['data'] as Map<String, dynamic>,
        );
        return Right(profile);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل تحميل بيانات ملف الزواج'),
        );
      }
    } catch (e) {
      return Left(ServerFailure('حدث خطأ: $e'));
    }
  }

  Future<Either<Failure, MarriageUserProfileModel>> updateMarriageProfile(
    MarriageUserProfileModel profile,
  ) async {
    try {
      final response = await _apiService.patch(
        endPoint: '/user/marriage-profile',
        isFromData: true,
        data: profile.toJson(),
      );

      if (response['success'] == true) {
        final updatedProfile = MarriageUserProfileModel.fromJson(
          response['data'] as Map<String, dynamic>,
        );
        return Right(updatedProfile);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل تحديث بيانات ملف الزواج'),
        );
      }
    } catch (e) {
      return Left(ServerFailure('حدث خطأ: $e'));
    }
  }

  Future<Either<Failure, String>> uploadMarriageImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _apiService.post(
        endPoint: '/user/marriage-profile/image',
        data: formData,
      );

      if (response['success'] == true) {
        final imageUrl = response['data']['imageUrl'] as String;
        return Right(imageUrl);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل رفع الصورة'),
        );
      }
    } catch (e) {
      return Left(ServerFailure('حدث خطأ: $e'));
    }
  }

  Future<Either<Failure, void>> deleteMarriageImage(String imageUrl) async {
    try {
      final response = await _apiService.delete(
        endPoint: '/user/marriage-profile/image',
        data: {'imageUrl': imageUrl},
      );

      if (response['success'] == true) {
        return const Right(null);
      } else {
        return Left(
          ServerFailure(response['message'] ?? 'فشل حذف الصورة'),
        );
      }
    } catch (e) {
      return Left(ServerFailure('حدث خطأ: $e'));
    }
  }
}
*/