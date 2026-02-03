  // Future<void> _pickVideo(BuildContext context) async {
  //   try {
  //     final ImagePicker picker = ImagePicker();
  //     final XFile? video = await picker.pickVideo(
  //       source: ImageSource.gallery,
  //       maxDuration: const Duration(minutes: 2), // Max 2 minutes
  //     );

  //     if (video != null) {
  //       final file = File(video.path);

  //       // Check file size (max 50MB)
  //       final fileSize = await file.length();
  //       if (fileSize > 50 * 1024 * 1024) {
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             CustomSnackBar(
  //               context,
  //               text: 'حجم الفيديو كبير جداً (الحد الأقصى 50 ميجا)',
  //               isError: true,
  //             ),
  //           );
  //         }
  //         return;
  //       }

  //       // Show loading
  //       if (mounted) {
  //         ScaffoldMessenger.of(
  //           context,
  //         ).showSnackBar(CustomSnackBar(context, text: 'جاري رفع الفيديو...'));
  //       }

  //       // Upload
  //       await widget.cubit.uploadVideo(file);
  //     }
  //   } catch (e) {
  //     debugPrint('❌ Error picking video: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         CustomSnackBar(context, text: 'خطأ في اختيار الفيديو', isError: true),
  //       );
  //     }
  //   }
  // }

// marriage_profile_repository.dart - AUDIO UPLOAD FIXED
// ════════════════════════════════════════════════════════════════
// ✅ Fixed: Audio upload using FormData.fromMap
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

        debugPrint(
          '✅ Profile loaded - Images: ${profile.userMedia?.images.length}',
        );
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

  // ⭐⭐⭐ UPDATE PROFILE
  Future<Either<Failure, MarriageUserProfileModel>> updateMarriageProfile(
    MarriageUserProfileModel profile,
  ) async {
    try {
      debugPrint('💾 Updating profile...');

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

  Map<String, dynamic> _convertToServerFormat(
    MarriageUserProfileModel profile,
  ) {
    final List<Map<String, dynamic>> answers = [];

    String? _cleanValue(String? value) {
      if (value == null) return null;
      final cleaned = value.trim();
      return cleaned.isEmpty ? null : cleaned;
    }

    if (profile.aboutMe != null) {
      final aboutMe = profile.aboutMe!;

      if (aboutMe.weight != null) {
        final cleaned = _cleanValue(aboutMe.weight);
        if (cleaned != null)
          answers.add({'category': 'weight', 'answer': cleaned});
      }
      if (aboutMe.height != null) {
        final cleaned = _cleanValue(aboutMe.height);
        if (cleaned != null)
          answers.add({'category': 'height', 'answer': cleaned});
      }
      if (aboutMe.age != null) {
        final cleaned = _cleanValue(aboutMe.age);
        if (cleaned != null)
          answers.add({'category': 'age', 'answer': cleaned});
      }
      if (aboutMe.socialStatus != null) {
        final cleaned = _cleanValue(aboutMe.socialStatus);
        if (cleaned != null)
          answers.add({'category': 'socialStatus', 'answer': cleaned});
      }
      if (aboutMe.nationality != null) {
        final cleaned = _cleanValue(aboutMe.nationality);
        if (cleaned != null)
          answers.add({'category': 'nationality', 'answer': cleaned});
      }
      if (aboutMe.country != null) {
        final cleaned = _cleanValue(aboutMe.country);
        if (cleaned != null)
          answers.add({'category': 'country', 'answer': cleaned});
      }
      if (aboutMe.skinColor != null) {
        final cleaned = _cleanValue(aboutMe.skinColor);
        if (cleaned != null)
          answers.add({'category': 'skinColor', 'answer': cleaned});
      }
      if (aboutMe.healthStatus != null) {
        final cleaned = _cleanValue(aboutMe.healthStatus);
        if (cleaned != null)
          answers.add({'category': 'healthStatus', 'answer': cleaned});
      }
      if (aboutMe.smoker != null) {
        final cleaned = _cleanValue(aboutMe.smoker);
        if (cleaned != null)
          answers.add({'category': 'smoker', 'answer': cleaned});
      }
      if (aboutMe.religiousCommitment != null) {
        final cleaned = _cleanValue(aboutMe.religiousCommitment);
        if (cleaned != null)
          answers.add({'category': 'religiousCommitment', 'answer': cleaned});
      }
    }

    if (profile.professionalLife != null) {
      final pro = profile.professionalLife!;

      if (pro.job != null) {
        final cleaned = _cleanValue(pro.job);
        if (cleaned != null)
          answers.add({'category': 'job', 'answer': cleaned});
      }
      if (pro.educationLevel != null) {
        final cleaned = _cleanValue(pro.educationLevel);
        if (cleaned != null)
          answers.add({'category': 'educationLevel', 'answer': cleaned});
      }
      if (pro.chooseEmployer != null) {
        final cleaned = _cleanValue(pro.chooseEmployer);
        if (cleaned != null)
          answers.add({'category': 'chooseEmployer', 'answer': cleaned});
      }
    }

    if (profile.family != null) {
      final family = profile.family!;

      if (family.hasChildren != null) {
        final cleaned = _cleanValue(family.hasChildren);
        if (cleaned != null)
          answers.add({'category': 'hasChildren', 'answer': cleaned});
      }
      if (family.childrenNumber != null) {
        final cleaned = _cleanValue(family.childrenNumber);
        if (cleaned != null)
          answers.add({'category': 'childrenNumber', 'answer': cleaned});
      }
      if (family.childrenLivingStatus != null) {
        final cleaned = _cleanValue(family.childrenLivingStatus);
        if (cleaned != null)
          answers.add({'category': 'childrenLivingStatus', 'answer': cleaned});
      }
    }

    if (profile.hobbies.isNotEmpty) {
      final cleanedHobbies = profile.hobbies
          .map((h) => h.trim())
          .where((h) => h.isNotEmpty)
          .join(', ');
      if (cleanedHobbies.isNotEmpty) {
        answers.add({'category': 'hobbies', 'answer': cleanedHobbies});
      }
    }

    final Map<String, dynamic> requestBody = {'answers': answers};

    if (profile.myDescription != null) {
      final cleanedBio = _cleanValue(profile.myDescription);
      if (cleanedBio != null) {
        requestBody['mydescription'] = cleanedBio;
      }
    }

    if (profile.aboutMe?.age != null) {
      requestBody['age'] = int.tryParse(profile.aboutMe!.age!.trim()) ?? 25;
    }

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
        if (cleaned != null) goalsMap['engagment'] = cleaned;
      }

      if (goalsMap.isNotEmpty) {
        requestBody['yourGoals'] = goalsMap;
      }
    }

    debugPrint('✅ Converted to server format: ${answers.length} answers');
    return requestBody;
  }

  // ⭐ UPLOAD IMAGE - CORRECT ENDPOINT ✅
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
        endPoint: '/user/add-image',
        data: formData,
      );

      if (response['success'] == true) {
        debugPrint('✅ Image uploaded successfully');

        // ⭐⭐⭐ السيرفر مش بيرجع URL، بس بيضيف الصورة
        // لازم نعمل reload للبروفايل عشان نجيب الصور الجديدة
        final profileResult = await getMarriageProfile();

        return profileResult.fold(
          (failure) {
            debugPrint('⚠️ Could not reload profile after upload');
            // حتى لو فشل الـ reload، الصورة اتضافت بنجاح
            return const Right('uploaded');
          },
          (profile) {
            debugPrint('✅ Profile reloaded with new images');
            return const Right('uploaded');
          },
        );
      }

      return Left(ServerFailure(response['message'] ?? 'فشل رفع الصورة'));
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ⭐⭐⭐ DELETE IMAGE
  Future<Either<Failure, bool>> deleteMarriageImage(String imageUrl) async {
    try {
      debugPrint('🗑️ Deleting image: $imageUrl');

      final response = await _apiService.delete(
        endPoint: '/user/delete-media',
        data: {'link': imageUrl},
      );

      debugPrint('📥 Delete response: ${jsonEncode(response)}');

      if (response['success'] == true) {
        debugPrint('✅ Image deleted successfully');
        return const Right(true);
      }

      return Left(ServerFailure(response['message'] ?? 'فشل حذف الصورة'));
    } on DioException catch (e) {
      debugPrint('❌ Delete failed: ${e.response?.data}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      return Left(ServerFailure('خطأ: $e'));
    }
  }
Future<Either<Failure, Map<String, String>>> uploadVideoAndAudio({
  File? videoFile,
  File? audioFile,
}) async {
  try {
    final Map<String, dynamic> data = {};

    if (audioFile != null) {
      data['audio'] = await MultipartFile.fromFile(
        audioFile.path,
        filename:
            'audio_${DateTime.now().millisecondsSinceEpoch}.mp3',
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

    debugPrint('📤 Uploading audio/video: ${formData.files}');

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
    debugPrint('❌ Upload error: $e');
    return Left(ServerFailure('خطأ في الرفع: $e'));
  }
}

  // ⭐ DELETE VIDEO
  // ⭐⭐⭐ DELETE VIDEO (Same as Delete Image)
  Future<Either<Failure, bool>> deleteVideo(String videoUrl) async {
    try {
      debugPrint('🗑️ Deleting video: $videoUrl');

      // استخدام نفس الـ Endpoint والطريقة بتاعة حذف الصورة
      final response = await _apiService.delete(
        endPoint: '/user/delete-media',
        data: {'link': videoUrl},
      );

      if (response['success'] == true) {
        debugPrint('✅ Video deleted successfully');
        return const Right(true);
      }

      return Left(ServerFailure(response['message'] ?? 'فشل حذف الفيديو'));
    } on DioException catch (e) {
      debugPrint('❌ Delete video failed: ${e.response?.data}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      debugPrint('❌ Delete video error: $e');
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ⭐ DELETE AUDIO
  // ⭐⭐⭐ DELETE AUDIO (Same as Delete Image/Video)
  Future<Either<Failure, bool>> deleteAudio(String audioUrl) async {
    try {
      debugPrint('🗑️ Deleting audio: $audioUrl');

      // استخدام نفس الـ Endpoint والـ Body (link)
      final response = await _apiService.delete(
        endPoint: '/user/delete-media',
        data: {'link': audioUrl},
      );

      if (response['success'] == true) {
        debugPrint('✅ Audio deleted successfully');
        return const Right(true);
      }

      return Left(
        ServerFailure(response['message'] ?? 'فشل حذف التسجيل الصوتي'),
      );
    } on DioException catch (e) {
      debugPrint('❌ Delete audio failed: ${e.response?.data}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      debugPrint('❌ Delete audio error: $e');
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  Future<void> _saveProfileLocally(MarriageUserProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(profile.toJson()));
      debugPrint('💾 Saved locally');
    } catch (e) {
      debugPrint('⚠️ Local save failed: $e');
    }
  }

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
