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
  // ⭐⭐⭐ دالة تحويل القيم المترجمة → Keys (خارج _convertToServerFormat)
  // ════════════════════════════════════════════════════════════════
  String? _translateValueToKey(String translatedValue) {
    // خريطة عكسية كاملة: القيمة المترجمة → الـ key
    final valueToKeyMap = {
      // =============== الرياضة ===============
      'البيسبول': 'interest_baseball',
      'الجري': 'interest_running',
      'رفع الأثقال': 'interest_weightlifting',
      'الجمباز': 'interest_gymnastics',
      'الجولف': 'interest_golf',
      'التنس': 'interest_tennis',
      'السباحة': 'interest_swimming',
      'الرقص': 'interest_dancing',
      'التزلج': 'interest_skating',
      'اليوغا': 'interest_yoga',
      'الطبق الطائر': 'interest_flying_disc',
      'الريشة': 'interest_badminton',
      'ركوب الدراجة': 'interest_cycling',
      'كرة السلة': 'interest_basketball',
      'كرة القدم': 'interest_football',
      'الكاراتيه': 'interest_karate',
      'الملاكمة': 'interest_boxing',
      'الرماية': 'interest_archery',
      'ركوب الخيل': 'interest_horse_riding',

      // =============== فنون وثقافة ===============
      'المسرح': 'interest_theater',
      'السحر': 'interest_magic',
      'الموسيقى': 'interest_music',
      'الرسم': 'interest_painting',
      'التصوير': 'interest_photography',
      'السينما': 'interest_cinema',
      'القراءة': 'interest_reading',
      'الكتابة': 'interest_writing',
      'الشعر': 'interest_poetry',
      'التاريخ': 'interest_history',
      'اللغات': 'interest_languages',
      'المتاحف': 'interest_museums',
      'الخط العربي': 'interest_calligraphy',
      'النحت': 'interest_sculpture',
      'التصميم': 'interest_design',
      'الأزياء': 'interest_fashion',

      // =============== المجتمع ===============
      'التطوع': 'interest_volunteering',
      'الأعمال الخيرية': 'interest_charity',
      'التعليم': 'interest_teaching',
      'الإرشاد': 'interest_mentoring',
      'رعاية كبار السن': 'interest_elderly_care',
      'رعاية الأطفال': 'interest_children_care',
      'البيئة': 'interest_environment',
      'رعاية الحيوانات': 'interest_animal_care',
      'التبرع بالدم': 'interest_blood_donation',
      'الفعاليات المجتمعية': 'interest_community_events',
      'العمل الاجتماعي': 'interest_social_work',
      'حقوق الإنسان': 'interest_human_rights',

      // =============== التكنولوجيا ===============
      'البرمجة': 'interest_programming',
      'الألعاب': 'interest_gaming',
      'الذكاء الاصطناعي': 'interest_ai',
      'تطوير الويب': 'interest_web_dev',
      'تطبيقات الجوال': 'interest_mobile_apps',
      'الأمن السيبراني': 'interest_cybersecurity',
      'علم البيانات': 'interest_data_science',
      'الإلكترونيات': 'interest_electronics',
      'الروبوتات': 'interest_robotics',
      'الواقع الافتراضي': 'interest_vr_ar',
      'الطباعة ثلاثية الأبعاد': 'interest_3d_printing',
      'الطائرات بدون طيار': 'interest_drones',
      'المنزل الذكي': 'interest_smart_home',
      'البلوكتشين': 'interest_blockchain',

      // =============== النزهات ===============
      'المشي لمسافات': 'interest_hiking',
      'التخييم': 'interest_camping',
      'الصيد': 'interest_fishing',
      'الشاطئ': 'interest_beach',
      'تسلق الجبال': 'interest_mountain_climbing',
      'البستنة': 'interest_gardening',
      'النزهات': 'interest_picnic',
      'مراقبة الطيور': 'interest_bird_watching',
      'مراقبة النجوم': 'interest_stargazing',
      'رحلات الطريق': 'interest_road_trips',
      'الإبحار': 'interest_sailing',
      'الغوص': 'interest_diving',
      'ركوب الأمواج': 'interest_surfing',
      'التجديف': 'interest_kayaking',
      'تسلق الصخور': 'interest_rock_climbing',
      'الطيران الشراعي': 'interest_paragliding',

      // =============== الطعام والمشروبات ===============
      'الطبخ': 'interest_cooking',
      'الخبز': 'interest_baking',
      'الشواء': 'interest_grilling',
      'القهوة': 'interest_coffee',
      'الشاي': 'interest_tea',
      'العصائر': 'interest_smoothies',
      'السوشي': 'interest_sushi',
      'البيتزا': 'interest_pizza',
      'الحلويات': 'interest_desserts',
      'الطعام الصحي': 'interest_healthy_food',
      'طعام الشارع': 'interest_street_food',
      'المطاعم الفاخرة': 'interest_fine_dining',
      'تصوير الطعام': 'interest_food_photography',
      'الشوكولاتة': 'interest_chocolate',
      'الآيس كريم': 'interest_ice_cream',

      // =============== الإيمان ===============
      'الدعاء': 'faith_dua',
      'أداء العمرة': 'faith_umrah',
      'العمل الخيري': 'faith_charity_work',
      'الدعوة': 'faith_dawah',
      'الصدقة': 'faith_sadaqah',
      'تعلم الحديث': 'faith_hadith',
      'التهجد': 'faith_tahajjud',
      'الذكر': 'faith_dhikr',
      'الصلاة عدة مرات في اليوم': 'faith_multiple_prayers',
      'صلاة السنة': 'faith_sunnah_prayer',
      'صلاة النافلة': 'faith_nafila_prayer',
      'أداء الحج': 'faith_hajj',
      'الصلاة 5 مرات يوميًا': 'faith_five_prayers',
      'الفقه': 'faith_fiqh',
      'الصيام': 'faith_fasting',
      'التصوف': 'faith_tasawwuf',
      'حسن الأخلاق': 'faith_good_manners',
      'صلاة الجمعة': 'faith_friday_prayer',
    };

    return valueToKeyMap[translatedValue];
  }
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
Future<Either<Failure, MarriageUserProfileModel>> updateMarriageProfile(
  MarriageUserProfileModel profile,
) async {
  try {
    debugPrint('💾 [UPDATE] Updating profile...');

    final requestData = _convertToServerFormat(profile);
    final response = await _apiService.patch(
      endPoint: '/user/update-marry-profile',
      data: requestData,
    );

    if (response['success'] == true) {
      debugPrint('✅ [UPDATE] Profile updated successfully');

      // ⭐⭐⭐ جيب البروفايل المحدث من السيرفر
      final fetchResult = await getMarriageProfile();

      return fetchResult.fold(
        (failure) => Left(failure),
        (updatedProfile) {
          debugPrint('✅ [UPDATE] New Progress: ${updatedProfile.answerCompletedPercentage}%');
          return Right(updatedProfile);
        },
      );
    }

    return Left(ServerFailure(response['message'] ?? 'فشل التحديث'));
  } catch (e) {
    return Left(ServerFailure('خطأ: $e'));
  }
}  // ════════════════════════════════════════════════════════════════
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

    // ... باقي الكود (About Me, Professional Life, Family)

    // ⭐⭐⭐ Hobbies - إرسال KEYS فقط
    if (profile.hobbies.isNotEmpty) {
      final cleanedHobbies = profile.hobbies
          .map((h) => h.trim())
          .where((h) => h.isNotEmpty)
          .map((h) {
            // ⭐ لو key (interest_ أو faith_)، أرسله كما هو
            if (h.startsWith('interest_') || h.startsWith('faith_')) {
              return h;
            }
            // ⭐ لو قيمة مترجمة، حوّلها لـ key
            return _translateValueToKey(h) ?? h;
          })
          .join(', ');

      if (cleanedHobbies.isNotEmpty) {
        answers.add({'category': 'hobbies', 'answer': cleanedHobbies});
      }
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
      if (cleaned != null) goalsMap['engagment'] = cleaned;
    }
    
    if (goalsMap.isNotEmpty) {
      requestBody['yourGoals'] = goalsMap;
    }
  }

  // ⭐⭐⭐ CRITICAL: إرسال النسبة للسيرفر

//   if (profile.answerCompletedPercentage != null) {
//   requestBody['answerCompletedPercentage'] = profile.answerCompletedPercentage;
//   debugPrint('📊 [CONVERT] Sending progress: ${profile.answerCompletedPercentage}%');
// }
 if (profile.answerCompletedPercentage != null) {
    requestBody['answerCompletedPercentage'] = profile.answerCompletedPercentage;
    debugPrint('📊 [CONVERT] Sending progress: ${profile.answerCompletedPercentage}%');
  }
  debugPrint('✅ [CONVERT] Prepared ${answers.length} answers');
  debugPrint('📤 [CONVERT] Full request body keys: ${requestBody.keys.toList()}');
  
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

// ⭐⭐⭐ UPLOAD SINGLE IMAGE - WITH RELOAD
Future<Either<Failure, String>> uploadSingleImage(File imageFile) async {
  try {
    debugPrint('📤 [UPLOAD_SINGLE_IMAGE] Uploading single cover image...');

    final formData = FormData.fromMap({
      'singleImage': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'single_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    });

  
      final response = await _apiService.post(
        endPoint: '/user/add-image',
        data: formData,
      );
    if (response['success'] == true) {
      debugPrint('✅ [UPLOAD_SINGLE_IMAGE] Single image uploaded successfully');

      // ⭐ Reload profile to get updated progress
      debugPrint('🔄 [UPLOAD_SINGLE_IMAGE] Reloading profile...');
      final profileResult = await getMarriageProfile();

      return profileResult.fold(
        (failure) {
          debugPrint('⚠️ [UPLOAD_SINGLE_IMAGE] Could not reload profile');
          return const Right('uploaded');
        },
        (profile) {
          debugPrint('✅ [UPLOAD_SINGLE_IMAGE] Profile reloaded - Progress: ${profile.answerCompletedPercentage}%');
          return const Right('uploaded');
        },
      );
    }

    return Left(ServerFailure(response['message'] ?? 'فشل رفع الصورة'));
  } catch (e) {
    debugPrint('❌ [UPLOAD_SINGLE_IMAGE] Error: $e');
    return Left(ServerFailure('خطأ: $e'));
  }
}

Future<Either<Failure, bool>> deleteSingleImage(String imageUrl) async {
  try {
    debugPrint('🗑️ [DELETE_SINGLE_IMAGE] Deleting: $imageUrl');
    
    final response = await _apiService.delete(
      endPoint: '/user/delete-media',
      data: {'link': imageUrl},
    );

    if (response['success'] == true) {
      debugPrint('✅ [DELETE_SINGLE_IMAGE] Single image deleted successfully');

      // ⭐ Reload profile to get updated progress
      debugPrint('🔄 [DELETE_SINGLE_IMAGE] Reloading profile...');
      final reloadResult = await getMarriageProfile();
      
      // ⭐ DEBUG: طبع الصورة بعد الحذف
      reloadResult.fold(
        (failure) {
          debugPrint('⚠️ [DELETE_SINGLE_IMAGE] Failed to reload: ${failure.message}');
        },
        (profile) {
          final newSingleImage = profile.userMedia?.singleImage;
          debugPrint('📸 [DELETE_SINGLE_IMAGE] After reload - singleImage: $newSingleImage');
          
          if (newSingleImage != null) {
            debugPrint('⚠️ [DELETE_SINGLE_IMAGE] WARNING: singleImage should be null!');
          }
        },
      );

      return const Right(true);
    }

    return Left(ServerFailure(response['message'] ?? 'فشل حذف الصورة'));
  } on DioException catch (e) {
    debugPrint('❌ [DELETE_SINGLE_IMAGE] DioException: ${e.response?.data}');
    return Left(ServerFailure.fromDioError(e));
  } catch (e) {
    debugPrint('❌ [DELETE_SINGLE_IMAGE] Error: $e');
    return Left(ServerFailure('خطأ: $e'));
  }
}  Future<void> clearLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      debugPrint('🗑️ [STORAGE] Cleared');
    } catch (e) {
      debugPrint('⚠️ [STORAGE] Clear failed: $e');
    }
  }
}