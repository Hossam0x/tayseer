// marriage_profile_cubit.dart - COMPLETE FIXED VERSION
// ════════════════════════════════════════════════════════════════
// ✅ FIX: إزالة حساب النسبة من الـ Cubit
// ✅ الاعتماد على النسبة اللي بيرجعها السيرفر
// ✅ استخدام البروفايل المحدث بعد كل عملية
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
  // ⭐ LOAD PROFILE
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
        debugPrint('✅ [CUBIT] Profile loaded - Progress: ${marriageProfile.answerCompletedPercentage}%');
        emit(state.copyWith(
          state: CubitStates.success,
          profile: marriageProfile,
          isLoading: false,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ SAVE PROFILE - USES UPDATED PROFILE FROM SERVER
  // ════════════════════════════════════════════════════════════════
  Future<void> saveProfile() async {
    if (state.profile == null) {
      debugPrint('⚠️ [CUBIT] No profile to save');
      return;
    }

    emit(state.copyWith(
      state: CubitStates.loading,
      isUpdating: true,
      clearMessages: true,
    ));

    debugPrint('💾 [CUBIT] Saving profile...');

    // ⭐⭐⭐ FIX: Repository هيرجع البروفايل المحدث من السيرفر
    final result = await _repository.updateMarriageProfile(state.profile!);

    result.fold(
      (failure) {
        debugPrint('❌ [CUBIT] Save failed: ${failure.message}');
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isUpdating: false,
        ));
      },
      (updatedProfile) {
        // ⭐⭐⭐ FIX: البروفايل المحدث فيه النسبة الصحيحة من السيرفر
        debugPrint('✅ [CUBIT] Saved - New progress: ${updatedProfile.answerCompletedPercentage}%');
        emit(state.copyWith(
          state: CubitStates.success,
          profile: updatedProfile,
          successMessage: 'تم حفظ البيانات بنجاح',
          isUpdating: false,
        ));
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ UPDATE FIELD (LOCAL STATE)
  // ════════════════════════════════════════════════════════════════
  void updateField(String fieldKey, dynamic value) {
    if (state.profile == null) {
      debugPrint('⚠️ [CUBIT] No profile to update');
      return;
    }

    debugPrint('🔄 [CUBIT] Updating field: $fieldKey = $value');

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
        case 'maritalStatus':
        case 'socialStatus':
        case 'previouslyMarried':
          updatedAbout = currentAbout.copyWith(socialStatus: value);
          break;
        case 'age':
          updatedAbout = currentAbout.copyWith(age: value.toString());
          break;
        default:
          updatedAbout = currentAbout;
      }

      updatedProfile = profile.copyWith(aboutMe: updatedAbout);
    } else if (_isProfessionalLifeField(fieldKey)) {
      final currentPro = profile.professionalLife ?? ProfessionalLife();
      ProfessionalLife updatedPro;

      switch (fieldKey) {
        case 'job':
        case 'occupation':
        case 'choose_job':
          updatedPro = currentPro.copyWith(job: value);
          break;
        case 'jobTitle':
        case 'professionalLevel':
        case 'educationLevel':
        case 'education_level':
          updatedPro = currentPro.copyWith(educationLevel: value);
          break;
        case 'employer':
        case 'chooseEmployer':
        case 'choose_employer':
          updatedPro = currentPro.copyWith(chooseEmployer: value);
          break;
        default:
          updatedPro = currentPro;
      }

      updatedProfile = profile.copyWith(professionalLife: updatedPro);
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
    } else if (_isYourGoalsField(fieldKey)) {
      final currentGoals = profile.yourGoals ?? YourGoals();
      YourGoals updatedGoals;

      switch (fieldKey) {
        case 'communicationTimeline':
        case 'marry':
          updatedGoals = currentGoals.copyWith(marry: value);
          break;
        case 'engagementTimeline':
        case 'engagement':
          updatedGoals = currentGoals.copyWith(engagement: value);
          break;
        case 'marriageTimeline':
          updatedGoals = currentGoals.copyWith(marry: value);
          break;
        case 'travelPreference':
        case 'travel':
          updatedGoals = currentGoals.copyWith(travel: value);
          break;
        case 'dowry':
        case 'children':
          updatedGoals = currentGoals.copyWith(children: value);
          break;
        default:
          updatedGoals = currentGoals;
      }

      updatedProfile = profile.copyWith(yourGoals: updatedGoals);
    } else {
      switch (fieldKey) {
        case 'bio':
        case 'myDescription':
          updatedProfile = profile.copyWith(myDescription: value);
          break;
        case 'interests':
        case 'hobbies':
          final hobbiesList = value is String
              ? value.split(', ').where((s) => s.isNotEmpty).toList()
              : (value as List<String>);
          updatedProfile = profile.copyWith(hobbies: hobbiesList);
          break;
        default:
          debugPrint('⚠️ [CUBIT] Unknown field: $fieldKey');
          updatedProfile = profile;
      }
    }

    emit(state.copyWith(profile: updatedProfile));
    debugPrint('✅ [CUBIT] Field updated successfully');
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ FIELD TYPE CHECKERS
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
      'maritalStatus',
      'socialStatus',
      'previouslyMarried',
      'age',
    ].contains(fieldKey);
  }

  bool _isProfessionalLifeField(String fieldKey) {
    return [
      'job',
      'occupation',
      'choose_job',
      'jobTitle',
      'professionalLevel',
      'educationLevel',
      'education_level',
      'employer',
      'chooseEmployer',
      'choose_employer',
    ].contains(fieldKey);
  }

  bool _isFamilyField(String fieldKey) {
    return [
      'hasChildren',
      'childrenNumber',
      'childrenLiveWithYou',
      'childrenLivingStatus',
    ].contains(fieldKey);
  }

  bool _isYourGoalsField(String fieldKey) {
    return [
      'communicationTimeline',
      'engagementTimeline',
      'marriageTimeline',
      'dowry',
      'travelPreference',
      'travel',
      'marry',
      'engagement',
      'children',
    ].contains(fieldKey);
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ UPLOAD IMAGE - RELOADS PROFILE AUTOMATICALLY
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
        // ⭐⭐⭐ Repository already reloaded, just refresh state
        await loadProfile();
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ DELETE IMAGE - RELOADS PROFILE AUTOMATICALLY
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
        // ⭐⭐⭐ Repository already reloaded, just refresh state
        await loadProfile();
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ UPLOAD VIDEO - RELOADS PROFILE AUTOMATICALLY
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
        // ⭐⭐⭐ Repository already reloaded, just refresh state
        await loadProfile();
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ UPLOAD AUDIO - RELOADS PROFILE AUTOMATICALLY
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
        // ⭐⭐⭐ Repository already reloaded, just refresh state
        await loadProfile();
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ DELETE VIDEO - RELOADS PROFILE AUTOMATICALLY
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
        // ⭐⭐⭐ Repository already reloaded, just refresh state
        await loadProfile();
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ DELETE AUDIO - RELOADS PROFILE AUTOMATICALLY
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
        // ⭐⭐⭐ Repository already reloaded, just refresh state
        await loadProfile();
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
        answerCompletedPercentage: 75,
      );

      emit(state.copyWith(
        profile: dummyProfile,
        state: CubitStates.success,
      ));

      debugPrint('✅ [CUBIT] Dummy profile loaded');
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