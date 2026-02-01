// marriage_profile_cubit.dart - FIXED DELETE IMAGE
// ════════════════════════════════════════════════════════════════
// ✅ استخدام deleteMarriageImage بدلاً من saveProfile للحذف
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

  Future<void> loadProfile() async {
    emit(state.copyWith(
      state: CubitStates.loading,
      isLoading: true,
      clearMessages: true,
    ));

    debugPrint('🔄 Loading profile...');
    final result = await _repository.getMarriageProfile();

    result.fold(
      (failure) {
        debugPrint('❌ Failed to load profile: ${failure.message}');
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isLoading: false,
        ));
      },
      (marriageProfile) {
        debugPrint('✅ Profile loaded successfully');
        emit(state.copyWith(
          state: CubitStates.success,
          profile: marriageProfile,
          isLoading: false,
        ));
      },
    );
  }

  Future<void> saveProfile() async {
    if (state.profile == null) {
      debugPrint('⚠️ No profile to save');
      return;
    }

    emit(state.copyWith(
      state: CubitStates.loading,
      isUpdating: true,
      clearMessages: true,
    ));

    debugPrint('💾 Saving profile...');
    final result = await _repository.updateMarriageProfile(state.profile!);

    result.fold(
      (failure) {
        debugPrint('❌ Failed to save profile: ${failure.message}');
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isUpdating: false,
        ));
      },
      (updatedProfile) {
        debugPrint('✅ Profile saved and refreshed successfully');
        emit(state.copyWith(
          state: CubitStates.success,
          profile: updatedProfile,
          successMessage: 'تم حفظ البيانات بنجاح',
          isUpdating: false,
        ));
      },
    );
  }

  void updateField(String fieldKey, dynamic value) {
    if (state.profile == null) {
      debugPrint('⚠️ No profile to update');
      return;
    }

    debugPrint('🔄 Updating field: $fieldKey = $value');

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
          debugPrint('⚠️ Unknown field: $fieldKey');
          updatedProfile = profile;
      }
    }

    emit(state.copyWith(profile: updatedProfile));
    debugPrint('✅ Field updated successfully');
  }

  bool _isAboutMeField(String fieldKey) {
    return [
      'country', 'nationality', 'height', 'weight', 'skinColor',
      'ethnicity', 'healthStatus', 'religiousCommitment', 'religiosity',
      'smoker', 'smoking', 'maritalStatus', 'socialStatus',
      'previouslyMarried', 'age',
    ].contains(fieldKey);
  }

  bool _isProfessionalLifeField(String fieldKey) {
    return [
      'job', 'occupation', 'choose_job', 'jobTitle', 'professionalLevel',
      'educationLevel', 'education_level', 'employer', 'chooseEmployer',
      'choose_employer',
    ].contains(fieldKey);
  }

  bool _isFamilyField(String fieldKey) {
    return [
      'hasChildren', 'childrenNumber', 'childrenLiveWithYou',
      'childrenLivingStatus',
    ].contains(fieldKey);
  }

  bool _isYourGoalsField(String fieldKey) {
    return [
      'communicationTimeline', 'engagementTimeline', 'marriageTimeline',
      'dowry', 'travelPreference', 'travel', 'marry', 'engagement', 'children',
    ].contains(fieldKey);
  }


  Future<void> uploadImage(File imageFile) async {
    if (state.profile == null) return;

    emit(state.copyWith(isLoading: true, clearMessages: true));
    
    final result = await _repository.uploadMarriageImage(imageFile);

    result.fold(
      (failure) => emit(state.copyWith(
        state: CubitStates.failure,
        errorMessage: failure.message,
        isLoading: false,
      )),
      (_) async {
        // ⭐⭐⭐ السيرفر ضاف الصورة بنجاح، دلوقتي نعمل reload للبروفايل
        debugPrint('✅ Image uploaded, reloading profile...');
        await loadProfile();
      },
    );
  }





















  // ⭐⭐⭐ DELETE IMAGE - FIXED
  Future<void> deleteImage(String imageUrl) async {
    if (state.profile == null) return;

    emit(state.copyWith(isLoading: true, clearMessages: true));

    debugPrint('🗑️ Deleting image from profile: $imageUrl');

    // ⭐⭐⭐ استخدام الـ endpoint الصحيح
    final result = await _repository.deleteMarriageImage(imageUrl);

    result.fold(
      (failure) {
        debugPrint('❌ Delete failed: ${failure.message}');
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isLoading: false,
        ));
      },
      (_) {
        debugPrint('✅ Image deleted from server, updating local state');
        
        // Update local state
        final currentMedia = state.profile!.userMedia ?? UserMedia(images: []);
        final updatedImages = List<String>.from(currentMedia.images)..remove(imageUrl);

        final updatedProfile = state.profile!.copyWith(
          userMedia: currentMedia.copyWith(images: updatedImages),
        );

        emit(state.copyWith(
          profile: updatedProfile,
          isLoading: false,
          successMessage: 'تم حذف الصورة بنجاح',
        ));
      },
    );
  }

  Future<void> uploadVideo(File videoFile) async {
    if (state.profile == null) return;

    emit(state.copyWith(
      isLoading: true,
      clearMessages: true,
    ));

    debugPrint('📤 Uploading video...');
    
    final result = await _repository.uploadVideoAndAudio(
      videoFile: videoFile,
    );

    result.fold(
      (failure) {
        debugPrint('❌ Video upload failed: ${failure.message}');
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isLoading: false,
        ));
      },
      (urls) {
        debugPrint('✅ Video uploaded: ${urls['video']}');
        
        final currentMedia = state.profile!.userMedia ?? UserMedia(images: []);
        final updatedProfile = state.profile!.copyWith(
          userMedia: currentMedia.copyWith(
            video: urls['video'],
          ),
        );

        emit(state.copyWith(
          profile: updatedProfile,
          isLoading: false,
          successMessage: 'تم رفع الفيديو بنجاح',
        ));
      },
    );
  }

  Future<void> uploadAudio(File audioFile) async {
    if (state.profile == null) return;

    emit(state.copyWith(
      isLoading: true,
      clearMessages: true,
    ));

    debugPrint('📤 Uploading audio...');
    
    final result = await _repository.uploadVideoAndAudio(
      audioFile: audioFile,
    );

    result.fold(
      (failure) {
        debugPrint('❌ Audio upload failed: ${failure.message}');
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isLoading: false,
        ));
      },
      (urls) {
        debugPrint('✅ Audio uploaded: ${urls['audio']}');
        
        final currentMedia = state.profile!.userMedia ?? UserMedia(images: []);
        final updatedProfile = state.profile!.copyWith(
          userMedia: currentMedia.copyWith(
            audio: urls['audio'],
          ),
        );

        emit(state.copyWith(
          profile: updatedProfile,
          isLoading: false,
          successMessage: 'تم رفع التسجيل الصوتي بنجاح',
        ));
      },
    );
  }

  Future<void> deleteVideo() async {
    // التأكد إن فيه فيديو أصلاً عشان نحذفه
    final currentVideoUrl = state.profile?.userMedia?.video;
    if (currentVideoUrl == null) return;

    emit(state.copyWith(isLoading: true, clearMessages: true));

    debugPrint('🗑️ Deleting video from server...');
    
    // نمرر الـ URL للـ repository
    final result = await _repository.deleteVideo(currentVideoUrl);

    result.fold(
      (failure) {
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isLoading: false,
        ));
      },
      (_) {
        debugPrint('✅ Video deleted from server, updating local state');
        
        // تحديث الـ state المحلي لمسح الفيديو من الواجهة
        final currentMedia = state.profile!.userMedia ?? UserMedia(images: []);
        final updatedProfile = state.profile!.copyWith(
          userMedia: currentMedia.copyWith(video: null), // مسح رابط الفيديو
        );

        emit(state.copyWith(
          profile: updatedProfile,
          isLoading: false,
          successMessage: 'تم حذف الفيديو بنجاح',
        ));
      },
    );
  }
  Future<void> deleteAudio() async {
    // جلب رابط الصوت الحالي من الـ State
    final currentAudioUrl = state.profile?.userMedia?.audio;
    if (currentAudioUrl == null) return;

    emit(state.copyWith(isLoading: true, clearMessages: true));

    debugPrint('🗑️ Deleting audio from server...');

    final result = await _repository.deleteAudio(currentAudioUrl);

    result.fold(
      (failure) {
        emit(state.copyWith(
          state: CubitStates.failure,
          errorMessage: failure.message,
          isLoading: false,
        ));
      },
      (_) {
        debugPrint('✅ Audio deleted from server, updating local state');
        
        // تحديث الحالة المحلية لمسح الرابط
        final currentMedia = state.profile!.userMedia ?? UserMedia(images: []);
        final updatedProfile = state.profile!.copyWith(
          userMedia: currentMedia.copyWith(audio: null), // مسح الرابط من الـ Model
        );

        emit(state.copyWith(
          profile: updatedProfile,
          isLoading: false,
          successMessage: 'تم حذف التسجيل الصوتي بنجاح',
        ));
      },
    );
  }
  void resetState() => emit(state.copyWith(
        state: CubitStates.initial,
        clearMessages: true,
      ));

  Future<void> clearAllData() async {
    await _repository.clearLocalStorage();
    emit(const MarriageProfileState());
  }
}