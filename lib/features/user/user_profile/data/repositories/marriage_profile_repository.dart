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
      final response = await _apiService.get(
        endPoint: '/user/marry-profile-for-update',
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final profile = MarriageUserProfileModel.fromJson(data);
        await _saveProfileLocally(profile);
        return Right(profile);
      }

      return Left(ServerFailure(response['message'] ?? 'فشل جلب البيانات'));
    } on DioException catch (e) {
      final localProfile = await _loadProfileLocally();
      if (localProfile != null) {
        return Right(localProfile);
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ UPDATE MARRIAGE PROFILE
  // ✅ FIX: لا يعمل getMarriageProfile تلقائياً - الـ cubit هو المسؤول
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, bool>> updateMarriageProfile(
    MarriageUserProfileModel profile,
  ) async {
    try {  
      final requestData = _convertToServerFormat(profile);
      final response = await _apiService.patch(
        endPoint: '/user/update-marry-profile',
        data: requestData,
      );

      if (response['success'] == true) {
        return const Right(true);
      }

      return Left(ServerFailure(response['message'] ?? 'فشل التحديث'));
    } catch (e) {
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ CONVERT TO SERVER FORMAT
  // ════════════════════════════════════════════════════════════════
  Map<String, dynamic> _convertToServerFormat(
    MarriageUserProfileModel profile,
  ) {
    final List<Map<String, dynamic>> answers = [];

    String? cleanValue(String? value) {
      if (value == null) return null;
      final cleaned = value.trim();
      return cleaned.isEmpty ? null : cleaned;
    }

    // About Me
    if (profile.aboutMe != null) {
      final aboutMe = profile.aboutMe!;
      final fields = {
        'weight': aboutMe.weight,
        'height': aboutMe.height,
        'age': aboutMe.age,
        'socialStatus': aboutMe.socialStatus,
        'nationality': aboutMe.nationality,
        'country': aboutMe.country,
        'skinColor': aboutMe.skinColor,
        'healthStatus': aboutMe.healthStatus,
        'smoker': aboutMe.smoker,
        'drinkAlcohol': aboutMe.drinkAlcohol,
        'eatHalalOnly': aboutMe.eatHalalOnly,
        'religiousCommitment': aboutMe.religiousCommitment,
      };
      for (final entry in fields.entries) {
        final cleaned = cleanValue(entry.value);
        if (cleaned != null) {
          answers.add({'category': entry.key, 'answer': cleaned});
        }
      }
    }

    // Professional Life
    if (profile.professionalLife != null) {
      final pro = profile.professionalLife!;
      final fields = {
        'job': pro.job,
        'educationLevel': pro.educationLevel,
        'chooseEmployer': pro.chooseEmployer,
      };
      for (final entry in fields.entries) {
        final cleaned = cleanValue(entry.value);
        if (cleaned != null) {
          answers.add({'category': entry.key, 'answer': cleaned});
        }
      }
    }

    // Family
    if (profile.family != null) {
      final family = profile.family!;
      final fields = {
        'hasChildren': family.hasChildren,
        'childrenNumber': family.childrenNumber,
        'childrenLivingStatus': family.childrenLivingStatus,
      };
      for (final entry in fields.entries) {
        final cleaned = cleanValue(entry.value);
        if (cleaned != null) {
          answers.add({'category': entry.key, 'answer': cleaned});
        }
      }
    }

    // Hobbies
    if (profile.hobbies.isNotEmpty) {
      final interestHobbies = profile.hobbies
          .where((h) => h.startsWith('interest_'))
          .map((h) => h.trim())
          .where((h) => h.isNotEmpty)
          .toList();

      if (interestHobbies.isNotEmpty) {
        answers.add({
          'category': 'hobbies',
          'answer': interestHobbies.join(', '),
        });
      }
    }

    // Faith
    if (profile.faith.isNotEmpty) {
      answers.add({'category': 'faith', 'answer': profile.faith});
    }

    // Goals
    if (profile.yourGoals != null) {
      final goals = {
        'intendTravelAbroad': profile.yourGoals!.intendTravelAbroad,
        'familyAcceptance': profile.yourGoals!.familyAcceptance,
        'marriageIntentions': profile.yourGoals!.marry,
        'engagment': profile.yourGoals!.engagement,
      };
      for (final entry in goals.entries) {
        final cleaned = cleanValue(entry.value);
        if (cleaned != null) {
          answers.add({'category': entry.key, 'answer': cleaned});
        }
      }
    }

    final Map<String, dynamic> requestBody = {'answers': answers};

    if (profile.myDescription != null) {
      final cleanedBio = cleanValue(profile.myDescription);
      if (cleanedBio != null) {
        requestBody['mydescription'] = cleanedBio;
      }
    }

    if (profile.aboutMe?.age != null) {
      requestBody['age'] = int.tryParse(profile.aboutMe!.age!.trim()) ?? 25;
    }

    if (profile.answerCompletedPercentage != null) {
      requestBody['answerCompletedPercentage'] =
          profile.answerCompletedPercentage;
    }

    return requestBody;
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ UPLOAD IMAGE
  // ✅ FIX: لا يعمل getMarriageProfile تلقائياً
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, String>> uploadMarriageImage(File imageFile) async {
    try {
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
        // ✅ FIX: مش بنعمل getMarriageProfile هنا - الـ cubit هو المسؤول
        return const Right('uploaded');
      }

      return Left(ServerFailure(response['message'] ?? 'فشل رفع الصورة'));
    } catch (e) {
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ DELETE IMAGE
  // ✅ FIX: لا يعمل getMarriageProfile تلقائياً
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, bool>> deleteMarriageImage(String imageUrl) async {
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      debugPrint('⚠️ [DELETE_IMAGE] Invalid URL, skipping: $imageUrl');
      return const Right(false);
    }

    try {
      final response = await _apiService.delete(
        endPoint: '/user/delete-media',
        data: {'link': imageUrl},
      );

      if (response['success'] == true) {
        return const Right(true);
      }

      return Left(ServerFailure(response['message'] ?? 'فشل حذف الصورة'));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('⚠️ [DELETE_IMAGE] 404 - Already deleted: $imageUrl');
        return const Right(true);
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ UPLOAD VIDEO/AUDIO
  // ✅ FIX: لا يعمل getMarriageProfile تلقائياً
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, Map<String, String>>> uploadVideoAndAudio({
    File? videoFile,
    File? audioFile,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (audioFile != null) {
        data['audio'] = await MultipartFile.fromFile(
          audioFile.path,
          filename: 'audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
          contentType: DioMediaType('audio', 'mpeg'),
        );
      }

      if (videoFile != null) {
        data['video'] = await MultipartFile.fromFile(
          videoFile.path,
          filename: videoFile.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(data);

      final response = await _apiService.patch(
        endPoint: '/user/update-video-and-audio',
        data: formData,
      );

      if (response['success'] == true) {
        return Right({
          'video': response['data']['video'] ?? '',
          'audio': response['data']['audio'] ?? '',
        });
      }

      return Left(ServerFailure(response['message'] ?? 'فشل الرفع'));
    } catch (e) {
      return Left(ServerFailure('خطأ في الرفع: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ DELETE VIDEO
  // ✅ FIX: لا يعمل getMarriageProfile تلقائياً
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, bool>> deleteVideo(String videoUrl) async {
    if (videoUrl.isEmpty || !videoUrl.startsWith('http')) {
      debugPrint('⚠️ [DELETE_VIDEO] Invalid URL, skipping: $videoUrl');
      return const Right(false);
    }

    try {
      final response = await _apiService.delete(
        endPoint: '/user/delete-media',
        data: {'link': videoUrl},
      );

      if (response['success'] == true) {
        return const Right(true);
      }

      return Left(ServerFailure(response['message'] ?? 'فشل حذف الفيديو'));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('⚠️ [DELETE_VIDEO] 404 - Already deleted: $videoUrl');
        return const Right(true);
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ DELETE AUDIO
  // ✅ FIX: لا يعمل getMarriageProfile تلقائياً
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, bool>> deleteAudio(String audioUrl) async {
    if (audioUrl.isEmpty || !audioUrl.startsWith('http')) {
      debugPrint('⚠️ [DELETE_AUDIO] Invalid URL, skipping: $audioUrl');
      return const Right(false);
    }

    try {
      final response = await _apiService.delete(
        endPoint: '/user/delete-media',
        data: {'link': audioUrl},
      );

      if (response['success'] == true) {
        return const Right(true);
      }

      return Left(
        ServerFailure(response['message'] ?? 'فشل حذف التسجيل الصوتي'),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('⚠️ [DELETE_AUDIO] 404 - Already deleted: $audioUrl');
        return const Right(true);
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ UPLOAD SINGLE IMAGE
  // ✅ FIX: لا يعمل getMarriageProfile تلقائياً
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, String>> uploadSingleImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'single_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _apiService.post(
        endPoint: '/user/add-primary-image',
        data: formData,
      );

      if (response['success'] == true) {
        return const Right('uploaded');
      }

      return Left(ServerFailure(response['message'] ?? 'فشل رفع الصورة'));
    } catch (e) {
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ DELETE SINGLE IMAGE
  // ✅ FIX: لا يعمل getMarriageProfile تلقائياً
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, bool>> deleteSingleImage(String imageUrl) async {
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      debugPrint('⚠️ [DELETE_SINGLE] Invalid URL, skipping: $imageUrl');
      return const Right(false);
    }

    if (imageUrl.contains('cdn-icons-png.flaticon.com') ||
        imageUrl.contains('149071.png')) {
      debugPrint('⚠️ [DELETE_SINGLE] Default placeholder, skipping: $imageUrl');
      return const Right(false);
    }

    try {
      final response = await _apiService.delete(
        endPoint: '/user/delete-media',
        data: {'link': imageUrl},
      );

      if (response['success'] == true) {
        return const Right(true);
      }

      return Left(ServerFailure(response['message'] ?? 'فشل حذف الصورة'));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('⚠️ [DELETE_SINGLE] 404 - Already deleted: $imageUrl');
        return const Right(true);
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ REORDER IMAGES
  // ✅ FIX: يقبل فقط server URLs - لا يقبل local paths
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, bool>> reorderImages(
    Map<String, String> imagesIndex,
  ) async {
    // ✅ FIX: تأكد إن كل القيم URLs حقيقية مش local paths
    final validIndex = <String, String>{};
    int idx = 0;
    for (final entry in imagesIndex.entries) {
      if (entry.value.startsWith('http')) {
        validIndex[idx.toString()] = entry.value;
        idx++;
      } else {
        debugPrint('⚠️ [REORDER] Skipping local path: ${entry.value}');
      }
    }

    if (validIndex.isEmpty) {
      debugPrint('⚠️ [REORDER] No valid URLs to reorder, skipping');
      return const Right(true);
    }

    try {
      final response = await _apiService.patch(
        endPoint: '/user/update-marry-profile',
        data: {'answers': [], 'imagesIndex': validIndex},
      );

      if (response['success'] == true) {
        return const Right(true);
      }

      return Left(ServerFailure(response['message'] ?? 'فشل إعادة الترتيب'));
    } catch (e) {
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
    } catch (e) {
      debugPrint('⚠️ [STORAGE] Save failed: $e');
    }
  }

  Future<MarriageUserProfileModel?> _loadProfileLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);
      if (data != null) {
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
    } catch (e) {
      debugPrint('⚠️ [STORAGE] Clear failed: $e');
    }
  }
}
