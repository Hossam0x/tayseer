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
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, MarriageUserProfileModel>> updateMarriageProfile(
    MarriageUserProfileModel profile,
  ) async {
    try {
      final requestData = _convertToServerFormat(profile);
      final response = await _apiService.patch(
        endPoint: '/user/update-marry-profile',
        data: requestData,
      );

      if (response['success'] == true) {
        // ⭐⭐⭐ جيب البروفايل المحدث من السيرفر
        final fetchResult = await getMarriageProfile();

        return fetchResult.fold((failure) => Left(failure), (updatedProfile) {
          return Right(updatedProfile);
        });
      }

      return Left(ServerFailure(response['message'] ?? 'فشل التحديث'));
    } catch (e) {
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ CONVERT TO SERVER FORMAT - FIXED (SEND KEYS ONLY)
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
        if (cleaned != null) {
          answers.add({'category': 'weight', 'answer': cleaned});
        }
      }
      if (aboutMe.height != null) {
        final cleaned = _cleanValue(aboutMe.height);
        if (cleaned != null) {
          answers.add({'category': 'height', 'answer': cleaned});
        }
      }
      if (aboutMe.age != null) {
        final cleaned = _cleanValue(aboutMe.age);
        if (cleaned != null) {
          answers.add({'category': 'age', 'answer': cleaned});
        }
      }
      if (aboutMe.socialStatus != null) {
        final cleaned = _cleanValue(aboutMe.socialStatus);
        if (cleaned != null) {
          answers.add({'category': 'socialStatus', 'answer': cleaned});
        }
      }
      if (aboutMe.nationality != null) {
        final cleaned = _cleanValue(aboutMe.nationality);
        if (cleaned != null) {
          answers.add({'category': 'nationality', 'answer': cleaned});
        }
      }
      if (aboutMe.country != null) {
        final cleaned = _cleanValue(aboutMe.country);
        if (cleaned != null) {
          answers.add({'category': 'country', 'answer': cleaned});
        }
      }
      if (aboutMe.skinColor != null) {
        final cleaned = _cleanValue(aboutMe.skinColor);
        if (cleaned != null) {
          answers.add({'category': 'skinColor', 'answer': cleaned});
        }
      }
      if (aboutMe.healthStatus != null) {
        final cleaned = _cleanValue(aboutMe.healthStatus);
        if (cleaned != null) {
          answers.add({'category': 'healthStatus', 'answer': cleaned});
        }
      }
      if (aboutMe.smoker != null) {
        final cleaned = _cleanValue(aboutMe.smoker);
        if (cleaned != null) {
          answers.add({'category': 'smoker', 'answer': cleaned});
        }
      }
      if (aboutMe.drinkAlcohol != null) {
        final cleaned = _cleanValue(aboutMe.drinkAlcohol);
        if (cleaned != null) {
          answers.add({'category': 'drinkAlcohol', 'answer': cleaned});
        }
      }

      if (aboutMe.eatHalalOnly != null) {
        final cleaned = _cleanValue(aboutMe.eatHalalOnly);
        if (cleaned != null) {
          answers.add({'category': 'eatHalalOnly', 'answer': cleaned});
        }
      }
      if (aboutMe.religiousCommitment != null) {
        final cleaned = _cleanValue(aboutMe.religiousCommitment);
        if (cleaned != null) {
          answers.add({'category': 'religiousCommitment', 'answer': cleaned});
        }
      }
    }

    // ⭐ Professional Life
    if (profile.professionalLife != null) {
      final pro = profile.professionalLife!;

      if (pro.job != null) {
        final cleaned = _cleanValue(pro.job);
        if (cleaned != null) {
          answers.add({'category': 'job', 'answer': cleaned});
        }
      }
      if (pro.educationLevel != null) {
        final cleaned = _cleanValue(pro.educationLevel);
        if (cleaned != null) {
          answers.add({'category': 'educationLevel', 'answer': cleaned});
        }
      }
      if (pro.chooseEmployer != null) {
        final cleaned = _cleanValue(pro.chooseEmployer);
        if (cleaned != null) {
          answers.add({'category': 'chooseEmployer', 'answer': cleaned});
        }
      }
    }

    // ⭐ Family
    if (profile.family != null) {
      final family = profile.family!;

      if (family.hasChildren != null) {
        final cleaned = _cleanValue(family.hasChildren);
        if (cleaned != null) {
          answers.add({'category': 'hasChildren', 'answer': cleaned});
        }
      }
      if (family.childrenNumber != null) {
        final cleaned = _cleanValue(family.childrenNumber);
        if (cleaned != null) {
          answers.add({'category': 'childrenNumber', 'answer': cleaned});
        }
      }
      if (family.childrenLivingStatus != null) {
        final cleaned = _cleanValue(family.childrenLivingStatus);
        if (cleaned != null) {
          answers.add({'category': 'childrenLivingStatus', 'answer': cleaned});
        }
      }
    }

    // ⭐⭐⭐ HOBBIES (interests only)
    if (profile.hobbies.isNotEmpty) {
      final interestHobbies = profile.hobbies
          .where((h) => h.startsWith('interest_'))
          .map((h) => h.trim())
          .where((h) => h.isNotEmpty)
          .toList();

      if (interestHobbies.isNotEmpty) {
        final cleanedInterests = interestHobbies.join(', ');
        answers.add({'category': 'hobbies', 'answer': cleanedInterests});
      }
    }

    // ⭐⭐⭐ FAITH - ADD TO ANSWERS ARRAY
    if (profile.faith.isNotEmpty) {
      answers.add({
        'category': 'faith',
        'answer': profile.faith, // ✅ List مباشرة مش String
      });
    }

    // ⭐⭐⭐ GOALS - حطها هنا قبل requestBody!
    if (profile.yourGoals != null) {
      if (profile.yourGoals!.intendTravelAbroad != null) {
        final cleaned = _cleanValue(profile.yourGoals!.intendTravelAbroad);
        if (cleaned != null) {
          answers.add({'category': 'intendTravelAbroad', 'answer': cleaned});
        }
      }

      if (profile.yourGoals!.familyAcceptance != null) {
        final cleaned = _cleanValue(profile.yourGoals!.familyAcceptance);
        if (cleaned != null) {
          answers.add({'category': 'familyAcceptance', 'answer': cleaned});
        }
      }

      if (profile.yourGoals!.marry != null) {
        final cleaned = _cleanValue(profile.yourGoals!.marry);
        if (cleaned != null) {
          answers.add({'category': 'marriageIntentions', 'answer': cleaned});
        }
      }

      if (profile.yourGoals!.engagement != null) {
        final cleaned = _cleanValue(profile.yourGoals!.engagement);
        if (cleaned != null) {
          answers.add({'category': 'engagment', 'answer': cleaned});
        }
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

    // ⭐ Age
    if (profile.aboutMe?.age != null) {
      requestBody['age'] = int.tryParse(profile.aboutMe!.age!.trim()) ?? 25;
    }

    // ⭐ Progress percentage
    if (profile.answerCompletedPercentage != null) {
      requestBody['answerCompletedPercentage'] =
          profile.answerCompletedPercentage;
    }

    return requestBody;
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ UPLOAD IMAGE - WITH RELOAD
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
        // ⭐⭐⭐ نعمل reload عشان نجيب النسبة المحدثة

        final profileResult = await getMarriageProfile();

        return profileResult.fold(
          (failure) {
            return const Right('uploaded');
          },
          (profile) {
            return const Right('uploaded');
          },
        );
      }

      return Left(ServerFailure(response['message'] ?? 'فشل رفع الصورة'));
    } catch (e) {
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ DELETE IMAGE - WITH RELOAD
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, bool>> deleteMarriageImage(String imageUrl) async {
    try {
      final response = await _apiService.delete(
        endPoint: '/user/delete-media',
        data: {'link': imageUrl},
      );

      if (response['success'] == true) {
        // ⭐⭐⭐ نعمل reload عشان نجيب النسبة المحدثة

        await getMarriageProfile();

        return const Right(true);
      }

      return Left(ServerFailure(response['message'] ?? 'فشل حذف الصورة'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
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
        // ⭐⭐⭐ نعمل reload عشان نجيب النسبة المحدثة

        await getMarriageProfile();

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
  // ⭐⭐⭐ DELETE VIDEO - WITH RELOAD
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, bool>> deleteVideo(String videoUrl) async {
    try {
      final response = await _apiService.delete(
        endPoint: '/user/delete-media',
        data: {'link': videoUrl},
      );

      if (response['success'] == true) {
        await getMarriageProfile();

        return const Right(true);
      }

      return Left(ServerFailure(response['message'] ?? 'فشل حذف الفيديو'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ DELETE AUDIO - WITH RELOAD
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, bool>> deleteAudio(String audioUrl) async {
    try {
      final response = await _apiService.delete(
        endPoint: '/user/delete-media',
        data: {'link': audioUrl},
      );

      if (response['success'] == true) {
        // ⭐⭐⭐ نعمل reload عشان نجيب النسبة المحدثة

        await getMarriageProfile();

        return const Right(true);
      }

      return Left(
        ServerFailure(response['message'] ?? 'فشل حذف التسجيل الصوتي'),
      );
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ UPLOAD SINGLE IMAGE - WITH RELOAD
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
        // ⭐ Reload profile to get updated progress

        final profileResult = await getMarriageProfile();

        return profileResult.fold(
          (failure) {
            return const Right('uploaded');
          },
          (profile) {
            return const Right('uploaded');
          },
        );
      }

      return Left(ServerFailure(response['message'] ?? 'فشل رفع الصورة'));
    } catch (e) {
      return Left(ServerFailure('خطأ: $e'));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ DELETE SINGLE IMAGE - WITH RELOAD
  // ════════════════════════════════════════════════════════════════
  Future<Either<Failure, bool>> deleteSingleImage(String imageUrl) async {
    try {
      final response = await _apiService.delete(
        endPoint: '/user/delete-media',
        data: {'link': imageUrl},
      );

      if (response['success'] == true) {
        // ⭐ Reload profile to get updated progress

        final reloadResult = await getMarriageProfile();

        reloadResult.fold((failure) {}, (profile) {
          final newSingleImage = profile.userMedia?.singleImage;

          if (newSingleImage != null) {}
        });

        return const Right(true);
      }

      return Left(ServerFailure(response['message'] ?? 'فشل حذف الصورة'));
    } on DioException catch (e) {
      return Left(ServerFailure.fromDioError(e));
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
