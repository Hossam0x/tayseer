// marriage_profile_repository.dart - COMPLETE FIXED VERSION
// ════════════════════════════════════════════════════════════════
// ✅ FIX: لا نرسل answerCompletedPercentage للسيرفر
// ✅ نعتمد على النسبة اللي بيرجعها السيرفر
// ✅ Reload بعد كل update/upload/delete
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

  // ════════════════════════════════════════════════════════════════
  // ⭐ GET MARRIAGE PROFILE
  // ════════════════════════════════════════════════════════════════
Future<Either<Failure, MarriageUserProfileModel>> getMarriageProfile() async {
  try {
    debugPrint('📥 [GET] Fetching Marriage Profile...');

    final response = await _apiService.get(
      endPoint: '/user/marry-profile-for-update',
    );

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      
      // 🐛🐛🐛 DEBUG: طباعة الـ raw data من السيرفر
      debugPrint('═══════════════════════════════════════════');
      debugPrint('📥 [GET] Raw API Response:');
      debugPrint('   answerCompletedPercentage: ${data['answerCompletedPercentage']}');
      debugPrint('   Full data keys: ${data.keys.toList()}');
      debugPrint('═══════════════════════════════════════════');
      
      final profile = MarriageUserProfileModel.fromJson(data);

      debugPrint('✅ [GET] Profile loaded - Progress: ${profile.answerCompletedPercentage}%');
      await _saveProfileLocally(profile);
      return Right(profile);
    }

    return Left(ServerFailure(response['message'] ?? 'فشل جلب البيانات'));
  } on DioException catch (e) {
    debugPrint('❌ [GET] DioException: ${e.message}');

    final localProfile = await _loadProfileLocally();
    if (localProfile != null) {
      debugPrint('✅ [GET] Loaded from local storage');
      return Right(localProfile);
    }
    return Left(ServerFailure.fromDioError(e));
  } catch (e) {
    debugPrint('❌ [GET] Error: $e');
    return Left(ServerFailure('حدث خطأ: $e'));
  }
}
  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ UPDATE PROFILE - FIXED WITH RELOAD
  // ════════════════════════════════════════════════════════════════
Future<Either<Failure, MarriageUserProfileModel>> updateMarriageProfile(
  MarriageUserProfileModel profile,
) async {
  try {
    debugPrint('💾 [UPDATE] Updating profile...');

    // ⭐⭐⭐ FIX: لا نرسل answerCompletedPercentage
    final requestData = _convertToServerFormat(profile);

    // 🐛🐛🐛 DEBUG: طباعة الـ request بالكامل
    debugPrint('═══════════════════════════════════════════');
    debugPrint('📤 [UPDATE] Full Request Body:');
    debugPrint(JsonEncoder.withIndent('  ').convert(requestData));
    debugPrint('═══════════════════════════════════════════');

    final response = await _apiService.patch(
      endPoint: '/user/update-marry-profile',
      data: requestData,
    );

    // 🐛🐛🐛 DEBUG: طباعة الـ response بالكامل
    debugPrint('═══════════════════════════════════════════');
    debugPrint('📥 [UPDATE] Full Response:');
    debugPrint(JsonEncoder.withIndent('  ').convert(response));
    debugPrint('═══════════════════════════════════════════');

    if (response['success'] == true) {
      debugPrint('✅ [UPDATE] Profile updated successfully');

      // ⭐⭐⭐ نجيب البروفايل المحدث
      debugPrint('🔄 [UPDATE] Fetching updated profile from server...');
      final fetchResult = await getMarriageProfile();

      return fetchResult.fold(
        (failure) {
          debugPrint('⚠️ [UPDATE] Failed to fetch after save: ${failure.message}');
          return Left(failure);
        },
        (updatedProfile) {
          // 🐛🐛🐛 DEBUG: طباعة النسبة الجديدة
          debugPrint('═══════════════════════════════════════════');
          debugPrint('✅ [UPDATE] Got fresh profile from server:');
          debugPrint('   Old Progress (sent): ${profile.answerCompletedPercentage}%');
          debugPrint('   New Progress (received): ${updatedProfile.answerCompletedPercentage}%');
          debugPrint('═══════════════════════════════════════════');
          return Right(updatedProfile);
        },
      );
    }

    return Left(ServerFailure(response['message'] ?? 'فشل التحديث'));
  } on DioException catch (e) {
    debugPrint('❌ [UPDATE] DioException: ${e.response?.data}');
    return Left(ServerFailure.fromDioError(e));
  } catch (e) {
    debugPrint('❌ [UPDATE] Error: $e');
    return Left(ServerFailure('خطأ: $e'));
  }
}
  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ CONVERT TO SERVER FORMAT (WITHOUT PERCENTAGE)
  // ════════════════════════════════════════════════════════════════
  Map<String, dynamic> _convertToServerFormat(
    MarriageUserProfileModel profile,
  ) {
    final List<Map<String, dynamic>> answers = [];

    String? _cleanValue(String? value) {
      if (value == null) return null;
      final cleaned = value.trim();
      return cleaned.isEmpty ? null : cleaned;
    }

    // ⭐ About Me
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

    // ⭐ Professional Life
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

    // ⭐ Family
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

    // ⭐ Hobbies
    if (profile.hobbies.isNotEmpty) {
      final cleanedHobbies = profile.hobbies
          .map((h) => h.trim())
          .where((h) => h.isNotEmpty)
          .join(', ');
      if (cleanedHobbies.isNotEmpty) {
        answers.add({'category': 'hobbies', 'answer': cleanedHobbies});
      }
    }

    // ⭐ Build Request Body
    final Map<String, dynamic> requestBody = {'answers': answers};

    // ⭐ My Description
    if (profile.myDescription != null) {
      final cleanedBio = _cleanValue(profile.myDescription);
      if (cleanedBio != null) {
        requestBody['mydescription'] = cleanedBio;
      }
    }

    // ⭐ Age (separate field)
    if (profile.aboutMe?.age != null) {
      requestBody['age'] = int.tryParse(profile.aboutMe!.age!.trim()) ?? 25;
    }

    // ⭐ Your Goals
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
        if (cleaned != null) goalsMap['engagment'] = cleaned; // API typo
      }

      if (goalsMap.isNotEmpty) {
        requestBody['yourGoals'] = goalsMap;
      }
    }

    // ⭐⭐⭐ FIX: DON'T SEND answerCompletedPercentage
    // ❌ requestBody['answerCompletedPercentage'] = ...;

    debugPrint('✅ [CONVERT] Prepared ${answers.length} answers');
    return requestBody;
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ UPLOAD IMAGE - WITH RELOAD
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, String>> uploadMarriageImage(File imageFile) async {
    try {
      debugPrint('📤 [UPLOAD_IMAGE] Uploading image...');

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'marriage_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _apiService.post(
        endPoint: '/user/add-image',
        data: formData,
      );

      if (response['success'] == true) {
        debugPrint('✅ [UPLOAD_IMAGE] Image uploaded successfully');

        // ⭐⭐⭐ نعمل reload عشان نجيب النسبة المحدثة
        debugPrint('🔄 [UPLOAD_IMAGE] Reloading profile...');
        final profileResult = await getMarriageProfile();

        return profileResult.fold(
          (failure) {
            debugPrint('⚠️ [UPLOAD_IMAGE] Could not reload profile');
            return const Right('uploaded');
          },
          (profile) {
            debugPrint('✅ [UPLOAD_IMAGE] Profile reloaded - Progress: ${profile.answerCompletedPercentage}%');
            return const Right('uploaded');
          },
        );
      }

      return Left(ServerFailure(response['message'] ?? 'فشل رفع الصورة'));
    } catch (e) {
      debugPrint('❌ [UPLOAD_IMAGE] Error: $e');
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ DELETE IMAGE - WITH RELOAD
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, bool>> deleteMarriageImage(String imageUrl) async {
    try {
      debugPrint('🗑️ [DELETE_IMAGE] Deleting: $imageUrl');

      final response = await _apiService.delete(
        endPoint: '/user/delete-media',
        data: {'link': imageUrl},
      );

      debugPrint('📥 [DELETE_IMAGE] Response: ${jsonEncode(response)}');

      if (response['success'] == true) {
        debugPrint('✅ [DELETE_IMAGE] Image deleted successfully');

        // ⭐⭐⭐ نعمل reload عشان نجيب النسبة المحدثة
        debugPrint('🔄 [DELETE_IMAGE] Reloading profile...');
        await getMarriageProfile();

        return const Right(true);
      }

      return Left(ServerFailure(response['message'] ?? 'فشل حذف الصورة'));
    } on DioException catch (e) {
      debugPrint('❌ [DELETE_IMAGE] DioException: ${e.response?.data}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      debugPrint('❌ [DELETE_IMAGE] Error: $e');
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ UPLOAD VIDEO/AUDIO - WITH RELOAD
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, Map<String, String>>> uploadVideoAndAudio({
    File? videoFile,
    File? audioFile,
  }) async {
    try {
      debugPrint('📤 [UPLOAD_MEDIA] Uploading video/audio...');

      final Map<String, dynamic> data = {};

      if (audioFile != null) {
        data['audio'] = await MultipartFile.fromFile(
          audioFile.path,
          filename: 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
          contentType: DioMediaType('audio', 'mpeg'),
        );
        debugPrint('📤 [UPLOAD_MEDIA] Audio file added');
      }

      if (videoFile != null) {
        data['video'] = await MultipartFile.fromFile(
          videoFile.path,
          filename: videoFile.path.split('/').last,
        );
        debugPrint('📤 [UPLOAD_MEDIA] Video file added');
      }

      final formData = FormData.fromMap(data);

      final response = await _apiService.patch(
        endPoint: '/user/update-video-and-audio',
        data: formData,
      );

      if (response['success'] == true) {
        debugPrint('✅ [UPLOAD_MEDIA] Media uploaded successfully');

        // ⭐⭐⭐ نعمل reload عشان نجيب النسبة المحدثة
        debugPrint('🔄 [UPLOAD_MEDIA] Reloading profile...');
        await getMarriageProfile();

        return Right({
          'video': response['data']['video'] ?? '',
          'audio': response['data']['audio'] ?? '',
        });
      }

      return Left(ServerFailure(response['message'] ?? 'فشل الرفع'));
    } catch (e) {
      debugPrint('❌ [UPLOAD_MEDIA] Error: $e');
      return Left(ServerFailure('خطأ في الرفع: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ DELETE VIDEO - WITH RELOAD
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, bool>> deleteVideo(String videoUrl) async {
    try {
      debugPrint('🗑️ [DELETE_VIDEO] Deleting: $videoUrl');

      final response = await _apiService.delete(
        endPoint: '/user/delete-media',
        data: {'link': videoUrl},
      );

      if (response['success'] == true) {
        debugPrint('✅ [DELETE_VIDEO] Video deleted successfully');

        // ⭐⭐⭐ نعمل reload عشان نجيب النسبة المحدثة
        debugPrint('🔄 [DELETE_VIDEO] Reloading profile...');
        await getMarriageProfile();

        return const Right(true);
      }

      return Left(ServerFailure(response['message'] ?? 'فشل حذف الفيديو'));
    } on DioException catch (e) {
      debugPrint('❌ [DELETE_VIDEO] DioException: ${e.response?.data}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      debugPrint('❌ [DELETE_VIDEO] Error: $e');
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ DELETE AUDIO - WITH RELOAD
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, bool>> deleteAudio(String audioUrl) async {
    try {
      debugPrint('🗑️ [DELETE_AUDIO] Deleting: $audioUrl');

      final response = await _apiService.delete(
        endPoint: '/user/delete-media',
        data: {'link': audioUrl},
      );

      if (response['success'] == true) {
        debugPrint('✅ [DELETE_AUDIO] Audio deleted successfully');

        // ⭐⭐⭐ نعمل reload عشان نجيب النسبة المحدثة
        debugPrint('🔄 [DELETE_AUDIO] Reloading profile...');
        await getMarriageProfile();

        return const Right(true);
      }

      return Left(ServerFailure(response['message'] ?? 'فشل حذف التسجيل الصوتي'));
    } on DioException catch (e) {
      debugPrint('❌ [DELETE_AUDIO] DioException: ${e.response?.data}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      debugPrint('❌ [DELETE_AUDIO] Error: $e');
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ LOCAL STORAGE
  // ════════════════════════════════════════════════════════════════
  Future<void> _saveProfileLocally(MarriageUserProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(profile.toJson()));
      debugPrint('💾 [STORAGE] Saved locally');
    } catch (e) {
      debugPrint('⚠️ [STORAGE] Save failed: $e');
    }
  }

  Future<MarriageUserProfileModel?> _loadProfileLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);
      if (data != null) {
        debugPrint('📂 [STORAGE] Loading from local...');
        return MarriageUserProfileModel.fromJson(jsonDecode(data));
      }
    } catch (e) {
      debugPrint('⚠️ [STORAGE] Load failed: $e');
    }
    return null;
  }

  Future<void> clearLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      debugPrint('🗑️ [STORAGE] Cleared');
    } catch (e) {
      debugPrint('⚠️ [STORAGE] Clear failed: $e');
    }
  }
}