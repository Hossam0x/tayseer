// marriage_profile_repository.dart - FIXED VERSION
// ════════════════════════════════════════════════════════════════
// ✅ الحل: تحويل البيانات لـ format السيرفر (answers array)
// ════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayseer/core/errors/failure.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';

class MarriageProfileRepository {
  final ApiService _apiService;
  static const String _storageKey = 'marriage_profile_data_v3';

  MarriageProfileRepository(this._apiService);

  // ⭐ GET MARRIAGE PROFILE
  Future<Either<Failure, MarriageUserProfileModel>> getMarriageProfile() async {
    try {
      debugPrint('📥 Fetching Marriage Profile...');

      final response = await _apiService.get(
        endPoint: '/user/marry-profile-for-update',
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final profile = MarriageUserProfileModel.fromJson(data);

        debugPrint('✅ Profile loaded - Images: ${profile.userMedia?.images.length}');
        await _saveProfileLocally(profile);
        return Right(profile);
      }
      
      return Left(ServerFailure(response['message'] ?? 'فشل جلب البيانات'));
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      
      final localProfile = await _loadProfileLocally();
      if (localProfile != null) {
        debugPrint('✅ Loaded from local storage');
        return Right(localProfile);
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      debugPrint('❌ Error: $e');
      return Left(ServerFailure('حدث خطأ: $e'));
    }
  }

  // ⭐⭐⭐ UPDATE PROFILE - FIXED VERSION
  Future<Either<Failure, MarriageUserProfileModel>> updateMarriageProfile(
    MarriageUserProfileModel profile,
  ) async {
    try {
      debugPrint('💾 Updating profile...');
      
      // ✅✅✅ تحويل البيانات للـ format الصحيح
      final requestData = _convertToServerFormat(profile);
      
      debugPrint('📤 Sending data: ${jsonEncode(requestData)}');

      final response = await _apiService.patch(
        endPoint: '/user/update-marry-profile',
        data: requestData,
      );

      debugPrint('📥 Response: ${jsonEncode(response)}');

      if (response['success'] == true) {
        debugPrint('✅ Profile updated successfully');
        
        await _saveProfileLocally(profile);
        
        debugPrint('🔄 Fetching updated profile...');
        final fetchResult = await getMarriageProfile();
        
        return fetchResult.fold(
          (failure) {
            debugPrint('⚠️ Failed to fetch after save, using local profile');
            return Right(profile);
          },
          (updatedProfile) {
            debugPrint('✅ Got updated profile from server');
            return Right(updatedProfile);
          },
        );
      }
      
      return Left(ServerFailure(response['message'] ?? 'فشل التحديث'));
    } on DioException catch (e) {
      debugPrint('❌ Update failed: ${e.response?.data}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      debugPrint('❌ Update error: $e');
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ✅✅✅ NEW METHOD: Convert profile to server format
  Map<String, dynamic> _convertToServerFormat(MarriageUserProfileModel profile) {
    final List<Map<String, dynamic>> answers = [];

    // Helper function to clean string values
    String? _cleanValue(String? value) {
      if (value == null) return null;
      final cleaned = value.trim();
      return cleaned.isEmpty ? null : cleaned;
    }

    // AboutMe fields → answers array
    if (profile.aboutMe != null) {
      final aboutMe = profile.aboutMe!;
      
      if (aboutMe.weight != null) {
        final cleaned = _cleanValue(aboutMe.weight);
        if (cleaned != null) answers.add({'category': 'weight', 'answer': cleaned});
      }
      if (aboutMe.height != null) {
        final cleaned = _cleanValue(aboutMe.height);
        if (cleaned != null) answers.add({'category': 'height', 'answer': cleaned});
      }
      if (aboutMe.age != null) {
        final cleaned = _cleanValue(aboutMe.age);
        if (cleaned != null) answers.add({'category': 'age', 'answer': cleaned});
      }
      if (aboutMe.socialStatus != null) {
        final cleaned = _cleanValue(aboutMe.socialStatus);
        if (cleaned != null) answers.add({'category': 'socialStatus', 'answer': cleaned});
      }
      if (aboutMe.nationality != null) {
        final cleaned = _cleanValue(aboutMe.nationality);
        if (cleaned != null) answers.add({'category': 'nationality', 'answer': cleaned});
      }
      if (aboutMe.country != null) {
        final cleaned = _cleanValue(aboutMe.country);
        if (cleaned != null) answers.add({'category': 'country', 'answer': cleaned});
      }
      if (aboutMe.skinColor != null) {
        final cleaned = _cleanValue(aboutMe.skinColor);
        if (cleaned != null) answers.add({'category': 'skinColor', 'answer': cleaned});
      }
      if (aboutMe.healthStatus != null) {
        final cleaned = _cleanValue(aboutMe.healthStatus);
        if (cleaned != null) answers.add({'category': 'healthStatus', 'answer': cleaned});
      }
      if (aboutMe.smoker != null) {
        final cleaned = _cleanValue(aboutMe.smoker);
        if (cleaned != null) answers.add({'category': 'smoker', 'answer': cleaned});
      }
      if (aboutMe.religiousCommitment != null) {
        final cleaned = _cleanValue(aboutMe.religiousCommitment);
        if (cleaned != null) answers.add({'category': 'religiousCommitment', 'answer': cleaned});
      }
    }

    // ProfessionalLife fields → answers array
    if (profile.professionalLife != null) {
      final pro = profile.professionalLife!;
      
      if (pro.job != null) {
        final cleaned = _cleanValue(pro.job);
        if (cleaned != null) answers.add({'category': 'job', 'answer': cleaned});
      }
      if (pro.educationLevel != null) {
        final cleaned = _cleanValue(pro.educationLevel);
        if (cleaned != null) answers.add({'category': 'educationLevel', 'answer': cleaned});
      }
      if (pro.chooseEmployer != null) {
        final cleaned = _cleanValue(pro.chooseEmployer);
        if (cleaned != null) answers.add({'category': 'chooseEmployer', 'answer': cleaned});
      }
    }

    // Family fields → answers array
    if (profile.family != null) {
      final family = profile.family!;
      
      if (family.hasChildren != null) {
        final cleaned = _cleanValue(family.hasChildren);
        if (cleaned != null) answers.add({'category': 'hasChildren', 'answer': cleaned});
      }
      if (family.childrenNumber != null) {
        final cleaned = _cleanValue(family.childrenNumber);
        if (cleaned != null) answers.add({'category': 'childrenNumber', 'answer': cleaned});
      }
      if (family.childrenLivingStatus != null) {
        final cleaned = _cleanValue(family.childrenLivingStatus);
        if (cleaned != null) answers.add({'category': 'childrenLivingStatus', 'answer': cleaned});
      }
    }

    // Hobbies → answers array
    if (profile.hobbies.isNotEmpty) {
      final cleanedHobbies = profile.hobbies
          .map((h) => h.trim())
          .where((h) => h.isNotEmpty)
          .join(', ');
      if (cleanedHobbies.isNotEmpty) {
        answers.add({'category': 'hobbies', 'answer': cleanedHobbies});
      }
    }

    // ✅ Build final request body (matching Postman format)
    final Map<String, dynamic> requestBody = {
      'answers': answers,
    };
// إضافة حقل الوصف الشخصي كحقل أساسي بناءً على صورة Postman
if (profile.myDescription != null) {
  final cleanedBio = _cleanValue(profile.myDescription);
  if (cleanedBio != null) {
    requestBody['mydescription'] = cleanedBio; 
  }
}
    // Top-level fields
    if (profile.aboutMe?.age != null) {
      requestBody['age'] = int.tryParse(profile.aboutMe!.age!.trim()) ?? 25;
    }
    
    // ⚠️⚠️⚠️ IMPORTANT: Don't send myDescription in update request
    // The server rejects it in PATCH but returns it in GET
    // Bio is handled separately through answers array or other endpoint

    // YourGoals (direct object, not in answers)
    if (profile.yourGoals != null) {
      final goalsMap = <String, String>{};
      
      if (profile.yourGoals!.travel != null) {
        final cleaned = _cleanValue(profile.yourGoals!.travel);
        if (cleaned != null) goalsMap['travel'] = cleaned;
      }
      if (profile.yourGoals!.children != null) {
        final cleaned = _cleanValue(profile.yourGoals!.children);
        if (cleaned != null) goalsMap['children'] = cleaned;
      }
      if (profile.yourGoals!.marry != null) {
        final cleaned = _cleanValue(profile.yourGoals!.marry);
        if (cleaned != null) goalsMap['marry'] = cleaned;
      }
      if (profile.yourGoals!.engagement != null) {
        final cleaned = _cleanValue(profile.yourGoals!.engagement);
        if (cleaned != null) goalsMap['engagment'] = cleaned; // Note: typo in API
      }
      
      if (goalsMap.isNotEmpty) {
        requestBody['yourGoals'] = goalsMap;
      }
    }

    debugPrint('✅ Converted to server format: ${answers.length} answers');
    return requestBody;
  }

  // ⭐ UPLOAD IMAGE
  Future<Either<Failure, String>> uploadMarriageImage(File imageFile) async {
    try {
      debugPrint('📤 Uploading image...');
      
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'marriage_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _apiService.post(
        endPoint: '/user/upload-marriage-image',
        data: formData,
      );

      if (response['success'] == true) {
        final imageUrl = response['data']['url'] as String;
        debugPrint('✅ Image uploaded: $imageUrl');
        return Right(imageUrl);
      }
      
      return Left(ServerFailure(response['message'] ?? 'فشل رفع الصورة'));
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ⭐ Local Storage - Save
  Future<void> _saveProfileLocally(MarriageUserProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(profile.toJson()));
      debugPrint('💾 Saved locally');
    } catch (e) {
      debugPrint('⚠️ Local save failed: $e');
    }
  }

  // ⭐ Local Storage - Load
  Future<MarriageUserProfileModel?> _loadProfileLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);
      if (data != null) {
        debugPrint('📂 Loading from local storage...');
        return MarriageUserProfileModel.fromJson(jsonDecode(data));
      }
    } catch (e) {
      debugPrint('⚠️ Local load failed: $e');
    }
    return null;
  }

  // ⭐ Clear Local Storage
  Future<void> clearLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      debugPrint('🗑️ Local storage cleared');
    } catch (e) {
      debugPrint('⚠️ Failed to clear local storage: $e');
    }
  }
}