// marriage_profile_cubit.dart - COMPLETE UPDATED VERSION
// ════════════════════════════════════════════════════════════════
// ✅ FIX: تحديث النسبة محليًا بعد كل عملية رفع/حذف
// ✅ الاعتماد على النسبة من السيرفر + إضافة نسبة الميديا محليًا
// ════════════════════════════════════════════════════════════════

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/marriage_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_state.dart';
import 'package:tayseer/my_import.dart';

class MarriageProfileCubit extends Cubit<MarriageProfileState> {
  final MarriageProfileRepository _repository;
  final UserProfileModel? initialUserProfile;

  MarriageProfileCubit(
    this._repository, {
    this.initialUserProfile,
  }) : super(const MarriageProfileState());

// ════════════════════════════════════════════════════════════════
// ⭐⭐⭐ SIMPLIFIED: استخدم النسبة من السيرفر مباشرة
// ════════════════════════════════════════════════════════════════
Future<void> loadProfile() async {
  emit(state.copyWith(
    state: CubitStates.loading,
    isLoading: true,
    clearMessages: true,
  ));

  debugPrint('🔄 [CUBIT] Loading profile...');
  final result = await _repository.getMarriageProfile();

  result.fold(
    (failure) {
      debugPrint('❌ [CUBIT] Load failed: ${failure.message}');
      emit(state.copyWith(
        state: CubitStates.failure,
        errorMessage: failure.message,
        isLoading: false,
      ));
    },
    (marriageProfile) {
      // ⭐⭐⭐ احسب النسبة مع الميديا
      final profileWithMedia = _calculateProgressWithMedia(marriageProfile);
      
      debugPrint('✅ [CUBIT] Profile loaded');
      debugPrint('📊 Server Progress: ${marriageProfile.answerCompletedPercentage}%');
      debugPrint('📊 Final Progress (with media): ${profileWithMedia.answerCompletedPercentage}%');
      
      emit(state.copyWith(
        state: CubitStates.success,
        profile: profileWithMedia,
        isLoading: false,
      ));
    },
  );
}
  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ CALCULATE PROGRESS WITH MEDIA
  // ════════════════════════════════════════════════════════════════
  MarriageUserProfileModel _calculateProgressWithMedia(MarriageUserProfileModel profile) {
    final serverProgress = profile.answerCompletedPercentage ?? 0;
    int mediaBonus = 0;

    // حساب عدد الصور (كل صورة = 5%)
    final images = profile.userMedia?.images ?? [];
    if (images.isNotEmpty) {
      final imageCount = images.length > 5 ? 5 : images.length; // max 5 images
      mediaBonus += imageCount * 5; // 5% لكل صورة
      debugPrint('📸 [CUBIT] Images: $imageCount × 5% = ${imageCount * 5}%');
    }

    // فيديو = 25%
    final hasVideo = profile.userMedia?.video != null && 
                     profile.userMedia!.video!.isNotEmpty;
    if (hasVideo) {
      mediaBonus += 30;
      debugPrint('🎥 [CUBIT] Video: +25%');
    }

    // صوت = 25%
    final hasAudio = profile.userMedia?.audio != null && 
                     profile.userMedia!.audio!.isNotEmpty;
    if (hasAudio) {
      mediaBonus += 30;
      debugPrint('🎤 [CUBIT] Audio: +25%');
    }

    final totalProgress = serverProgress + mediaBonus;
    final finalProgress = totalProgress > 100 ? 100 : totalProgress;

    debugPrint('📊 [CUBIT] Server: $serverProgress% + Media: $mediaBonus% = $finalProgress%');

    return profile.copyWith(answerCompletedPercentage: finalProgress);
  }

Future<void> saveProfile() async {
  if (state.profile == null) return;

  emit(state.copyWith(
    state: CubitStates.loading,
    isUpdating: true,
    clearMessages: true,
  ));

  final result = await _repository.updateMarriageProfile(state.profile!);

  result.fold(
    (failure) {
      emit(state.copyWith(
        state: CubitStates.failure,
        errorMessage: failure.message,
        isUpdating: false,
      ));
    },
    (updatedProfile) {
      // ⭐⭐⭐ استخدم الـ profile اللي جاي من السيرفر مباشرة
      debugPrint('✅ Saved - New progress: ${updatedProfile.answerCompletedPercentage}%');
      
      emit(state.copyWith(
        state: CubitStates.success,
        profile: updatedProfile, // ⭐ هنا البروفايل الجديد بالنسبة المحدثة
        successMessage: 'تم حفظ البيانات بنجاح',
        isUpdating: false,
      ));
    },
  );
}  // ════════════════════════════════════════════════════════════════
 // ⭐⭐⭐ أضف الـ function دي هنا
 static const Map<String, String> _countryToNationalityKeyMap = {
    'country_saudi': 'nationality_saudi',
    'country_egypt': 'nationality_egyptian',
    'country_emirati': 'nationality_emirati',
    'country_kuwait': 'nationality_kuwaiti',
    'country_qatar': 'nationality_qatari',
    'country_bahrain': 'nationality_bahraini',
    'country_jordan': 'nationality_jordanian',
    'country_palestine': 'nationality_palestinian',
    'country_morocco': 'nationality_moroccan',
    'country_tunisia': 'nationality_tunisian',
  };

  /// خريطة عكسية لتحويل القيم المترجمة → Nationality Keys
  static const Map<String, String> _countryValueToNationalityKeyMap = {
    // Arabic
    'السعودية': 'nationality_saudi',
    'مصر': 'nationality_egyptian',
    'الإمارات': 'nationality_emirati',
    'الكويت': 'nationality_kuwaiti',
    'قطر': 'nationality_qatari',
    'البحرين': 'nationality_bahraini',
    'الأردن': 'nationality_jordanian',
    'فلسطين': 'nationality_palestinian',
    'المغرب': 'nationality_moroccan',
    'تونس': 'nationality_tunisian',

    // English
    'Saudi Arabia': 'nationality_saudi',
    'Egypt': 'nationality_egyptian',
    'United Arab Emirates': 'nationality_emirati',
    'Kuwait': 'nationality_kuwaiti',
    'Qatar': 'nationality_qatari',
    'Bahrain': 'nationality_bahraini',
    'Jordan': 'nationality_jordanian',
    'Palestine': 'nationality_palestinian',
    'Morocco': 'nationality_moroccan',
    'Tunisia': 'nationality_tunisian',
  };
   /// ⭐ دالة التحويل من Country → Nationality
  String _convertCountryToNationality(String country) {
    // أولوية 1: Key-to-Key
    if (_countryToNationalityKeyMap.containsKey(country)) {
      return _countryToNationalityKeyMap[country]!;
    }

    // أولوية 2: Value-to-Key
    if (_countryValueToNationalityKeyMap.containsKey(country)) {
      return _countryValueToNationalityKeyMap[country]!;
    }

    // إذا لم يتم العثور، أرجع القيمة كما هي
    return country;
  }
  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ UPDATE FIELD WITH AUTO-SYNC
  // ════════════════════════════════════════════════════════════════

  void updateField(String fieldKey, dynamic value) {
    if (state.profile == null) {
      debugPrint('⚠️ [CUBIT] No profile to update');
      return;
    }

    debugPrint('🔄 [CUBIT] Updating field: $fieldKey = $value');

    // ⭐⭐⭐ AUTO-SYNC: إذا كان الحقل "country"، احسب nationality تلقائياً
    if (fieldKey == 'country') {
      final nationalityValue = _convertCountryToNationality(value);
      debugPrint('🔄 [AUTO-SYNC] Country: $value → Nationality: $nationalityValue');

      // تحديث الـ nationality أولاً
      _updateFieldInternal('nationality', nationalityValue);
    }

    // تحديث الحقل الأصلي
    _updateFieldInternal(fieldKey, value);
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ INTERNAL UPDATE (بدون auto-sync)
  // ════════════════════════════════════════════════════════════════

  void _updateFieldInternal(String fieldKey, dynamic value) {
    final profile = state.profile!;
    MarriageUserProfileModel updatedProfile;

    if (_isAboutMeField(fieldKey)) {
      final currentAbout = profile.aboutMe ?? AboutMe();
      AboutMe updatedAbout;

      switch (fieldKey) {
        case 'country':
          updatedAbout = currentAbout.copyWith(country: value);
          break;

        case 'nationality':
          updatedAbout = currentAbout.copyWith(nationality: value);
          break;

        case 'height':
          updatedAbout = currentAbout.copyWith(height: value);
          break;

        case 'weight':
          updatedAbout = currentAbout.copyWith(weight: value);
          break;

        case 'skinColor':
        case 'ethnicity':
          updatedAbout = currentAbout.copyWith(skinColor: value);
          break;

        case 'healthStatus':
          updatedAbout = currentAbout.copyWith(healthStatus: value);
          break;

        case 'religiousCommitment':
        case 'religiosity':
          updatedAbout = currentAbout.copyWith(religiousCommitment: value);
          break;

        case 'smoker':
        case 'smoking':
          updatedAbout = currentAbout.copyWith(smoker: value);
          break;

        case 'socialStatus':
        case 'maritalStatus':
          updatedAbout = currentAbout.copyWith(socialStatus: value);
          break;

        case 'age':
          updatedAbout = currentAbout.copyWith(age: value);
          break;

        default:
          updatedAbout = currentAbout;
      }

      updatedProfile = profile.copyWith(aboutMe: updatedAbout);
    } else if (_isProfessionalLifeField(fieldKey)) {
      final currentProfessional = profile.professionalLife ?? ProfessionalLife();
      ProfessionalLife updatedProfessional;

      switch (fieldKey) {
        case 'education_level':
        case 'educationLevel':
          updatedProfessional =
              currentProfessional.copyWith(educationLevel: value);
          break;

        case 'choose_job':
        case 'job':
        case 'occupation':
          updatedProfessional = currentProfessional.copyWith(job: value);
          break;

        case 'choose_employer':
        case 'employer':
        case 'chooseEmployer':
          updatedProfessional =
              currentProfessional.copyWith(chooseEmployer: value);
          break;

        default:
          updatedProfessional = currentProfessional;
      }

      updatedProfile = profile.copyWith(professionalLife: updatedProfessional);
    } else if (_isFamilyField(fieldKey)) {
      final currentFamily = profile.family ?? Family();
      Family updatedFamily;

      switch (fieldKey) {
        case 'hasChildren':
          updatedFamily = currentFamily.copyWith(hasChildren: value);
          break;

        case 'childrenNumber':
          updatedFamily = currentFamily.copyWith(childrenNumber: value);
          break;

        case 'childrenLiveWithYou':
        case 'childrenLivingStatus':
          updatedFamily = currentFamily.copyWith(childrenLivingStatus: value);
          break;

        default:
          updatedFamily = currentFamily;
      }

      updatedProfile = profile.copyWith(family: updatedFamily);
    } else if (_isGoalsField(fieldKey)) {
      final currentGoals = profile.yourGoals ?? YourGoals();
      YourGoals updatedGoals;

      switch (fieldKey) {
        case 'engagement':
        case 'engagementTimeline':
          updatedGoals = currentGoals.copyWith(engagement: value);
          break;

        case 'marry':
        case 'communicationTimeline':
          updatedGoals = currentGoals.copyWith(marry: value);
          break;

        case 'familyAcceptance':
        case 'dowry':
          updatedGoals = currentGoals.copyWith(children: value);
          break;

        case 'travel':
        case 'travelPreference':
          updatedGoals = currentGoals.copyWith(travel: value);
          break;

        default:
          updatedGoals = currentGoals;
      }

      updatedProfile = profile.copyWith(yourGoals: updatedGoals);
    } else if (fieldKey == 'bio' || fieldKey == 'myDescription') {
      updatedProfile = profile.copyWith(myDescription: value);
    } else if (fieldKey == 'hobbies' || fieldKey == 'interests') {
      final hobbiesList = (value as String).split(', ');
      updatedProfile = profile.copyWith(hobbies: hobbiesList);
    } else {
      updatedProfile = profile;
    }

    emit(state.copyWith(profile: updatedProfile));
    debugPrint('✅ [CUBIT] Field $fieldKey updated successfully');
  }

  // ════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ════════════════════════════════════════════════════════════════

  bool _isAboutMeField(String fieldKey) {
    return [
      'country',
      'nationality',
      'height',
      'weight',
      'skinColor',
      'ethnicity',
      'healthStatus',
      'religiousCommitment',
      'religiosity',
      'smoker',
      'smoking',
      'socialStatus',
      'maritalStatus',
      'age'
    ].contains(fieldKey);
  }

  bool _isProfessionalLifeField(String fieldKey) {
    return [
      'education_level',
      'educationLevel',
      'choose_job',
      'job',
      'occupation',
      'choose_employer',
      'employer',
      'chooseEmployer'
    ].contains(fieldKey);
  }

  bool _isFamilyField(String fieldKey) {
    return [
      'hasChildren',
      'childrenNumber',
      'childrenLiveWithYou',
      'childrenLivingStatus'
    ].contains(fieldKey);
  }

  bool _isGoalsField(String fieldKey) {
    return [
      'engagement',
      'engagementTimeline',
      'marry',
      'communicationTimeline',
      'familyAcceptance',
      'dowry',
      'travel',
      'travelPreference'
    ].contains(fieldKey);
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ UPLOAD IMAGE - WITH LOCAL PROGRESS UPDATE
  // ════════════════════════════════════════════════════════════════
  Future<void> uploadImage(File imageFile) async {
    if (state.profile == null) {
      debugPrint('⚠️ [CUBIT] No profile for image upload');
      return;
    }

    emit(state.copyWith(isLoading: true, clearMessages: true));

    debugPrint('📤 [CUBIT] Uploading image...');

    final result = await _repository.uploadMarriageImage(imageFile);

    result.fold(
      (failure) {
        debugPrint('❌ [CUBIT] Image upload failed: ${failure.message}');
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isLoading: false,
        ));
      },
      (_) async {
        debugPrint('✅ [CUBIT] Image uploaded, reloading profile...');
        await loadProfile(); // هيحسب النسبة تلقائيًا
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ DELETE IMAGE - WITH LOCAL PROGRESS UPDATE
  // ════════════════════════════════════════════════════════════════
  Future<void> deleteImage(String imageUrl) async {
    if (state.profile == null) {
      debugPrint('⚠️ [CUBIT] No profile for image deletion');
      return;
    }

    emit(state.copyWith(isLoading: true, clearMessages: true));

    debugPrint('🗑️ [CUBIT] Deleting image: $imageUrl');

    final result = await _repository.deleteMarriageImage(imageUrl);

    result.fold(
      (failure) {
        debugPrint('❌ [CUBIT] Delete failed: ${failure.message}');
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isLoading: false,
        ));
      },
      (_) async {
        debugPrint('✅ [CUBIT] Image deleted, reloading profile...');
        await loadProfile(); // هيحسب النسبة تلقائيًا
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ UPLOAD VIDEO - WITH LOCAL PROGRESS UPDATE
  // ════════════════════════════════════════════════════════════════
  Future<void> uploadVideo(File videoFile) async {
    if (state.profile == null) {
      debugPrint('⚠️ [CUBIT] No profile for video upload');
      return;
    }

    emit(state.copyWith(isLoading: true, clearMessages: true));

    debugPrint('📤 [CUBIT] Uploading video...');

    final result = await _repository.uploadVideoAndAudio(videoFile: videoFile);

    result.fold(
      (failure) {
        debugPrint('❌ [CUBIT] Video upload failed: ${failure.message}');
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isLoading: false,
        ));
      },
      (_) async {
        debugPrint('✅ [CUBIT] Video uploaded, reloading profile...');
        await loadProfile(); // هيحسب النسبة تلقائيًا
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ UPLOAD AUDIO - WITH LOCAL PROGRESS UPDATE
  // ════════════════════════════════════════════════════════════════
  Future<void> uploadAudio(File audioFile) async {
    if (state.profile == null) {
      debugPrint('⚠️ [CUBIT] No profile for audio upload');
      return;
    }

    emit(state.copyWith(isLoading: true, clearMessages: true));

    debugPrint('📤 [CUBIT] Uploading audio...');

    final result = await _repository.uploadVideoAndAudio(audioFile: audioFile);

    result.fold(
      (failure) {
        debugPrint('❌ [CUBIT] Audio upload failed: ${failure.message}');
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isLoading: false,
        ));
      },
      (_) async {
        debugPrint('✅ [CUBIT] Audio uploaded, reloading profile...');
        await loadProfile(); // هيحسب النسبة تلقائيًا
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ DELETE VIDEO - WITH LOCAL PROGRESS UPDATE
  // ════════════════════════════════════════════════════════════════
  Future<void> deleteVideo() async {
    final currentVideoUrl = state.profile?.userMedia?.video;
    if (currentVideoUrl == null) {
      debugPrint('⚠️ [CUBIT] No video to delete');
      return;
    }

    emit(state.copyWith(isLoading: true, clearMessages: true));

    debugPrint('🗑️ [CUBIT] Deleting video...');

    final result = await _repository.deleteVideo(currentVideoUrl);

    result.fold(
      (failure) {
        debugPrint('❌ [CUBIT] Delete video failed: ${failure.message}');
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isLoading: false,
        ));
      },
      (_) async {
        debugPrint('✅ [CUBIT] Video deleted, reloading profile...');
        await loadProfile(); // هيحسب النسبة تلقائيًا
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ DELETE AUDIO - WITH LOCAL PROGRESS UPDATE
  // ════════════════════════════════════════════════════════════════
  Future<void> deleteAudio() async {
    final currentAudioUrl = state.profile?.userMedia?.audio;
    if (currentAudioUrl == null) {
      debugPrint('⚠️ [CUBIT] No audio to delete');
      return;
    }

    emit(state.copyWith(isLoading: true, clearMessages: true));

    debugPrint('🗑️ [CUBIT] Deleting audio...');

    final result = await _repository.deleteAudio(currentAudioUrl);

    result.fold(
      (failure) {
        debugPrint('❌ [CUBIT] Delete audio failed: ${failure.message}');
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isLoading: false,
        ));
      },
      (_) async {
        debugPrint('✅ [CUBIT] Audio deleted, reloading profile...');
        await loadProfile(); // هيحسب النسبة تلقائيًا
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ DUMMY PROFILE (FOR TESTING)
  // ════════════════════════════════════════════════════════════════
  void loadDummyProfile() {
    emit(state.copyWith(state: CubitStates.loading));

    try {
      final dummyProfile = MarriageUserProfileModel(
        aboutMe: AboutMe(
          socialStatus: 'أعزب',
          weight: '75 كجم',
          skinColor: 'سمراء',
          healthStatus: 'جيدة',
          religiousCommitment: 'ملتزم',
          smoker: 'لا',
        ),
        professionalLife: ProfessionalLife(
          educationLevel: 'بكالوريوس',
          job: 'مهندس برمجيات',
        ),
        yourGoals: YourGoals(
          travel: 'خلال 3 أشهر',
          children: '50,000 ريال',
          engagement: 'خلال سنة',
          marry: 'خلال سنتين',
        ),
        hobbies: ['القراءة', 'السفر', 'الرياضة', 'الموسيقى'],
        myDescription: 'شخص طموح يحب التطوير والتعلم المستمر',
        userMedia: UserMedia(
          images: [
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
          ],
          video:
              'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          audio: '',
        ),
        answerCompletedPercentage: 40, // النسبة من السيرفر
      );

      // ⭐⭐⭐ حساب النسبة مع الميديا
      final profileWithMedia = _calculateProgressWithMedia(dummyProfile);

      emit(state.copyWith(
        profile: profileWithMedia,
        state: CubitStates.success,
      ));

      debugPrint('✅ [CUBIT] Dummy profile loaded with progress: ${profileWithMedia.answerCompletedPercentage}%');
    } catch (e) {
      debugPrint('❌ [CUBIT] Dummy profile failed: $e');
      emit(state.copyWith(
        state: CubitStates.failure,
        errorMessage: 'فشل في تحميل البيانات الوهمية',
      ));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ CLEAR ALL DATA
  // ════════════════════════════════════════════════════════════════
  Future<void> clearAllData() async {
    debugPrint('🗑️ [CUBIT] Clearing all data...');
    await _repository.clearLocalStorage();
    emit(const MarriageProfileState());
    debugPrint('✅ [CUBIT] All data cleared');
  }
}
