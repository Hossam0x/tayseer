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
      // ⭐⭐⭐ تحقق من وجود الرابط
      final videoUrl = urls['video'];
      
      if (videoUrl == null || videoUrl.isEmpty) {
        debugPrint('⚠️ Video uploaded but no URL returned, reloading profile...');
        // ⭐ اعمل reload للبروفايل كامل
        loadProfile();
        return;
      }
      
      debugPrint('✅ Video uploaded: $videoUrl');
      
      final currentImages = state.profile!.userMedia?.images ?? [];
      final currentAudio = state.profile!.userMedia?.audio;
      
      final updatedMedia = UserMedia(
        images: currentImages,
        video: videoUrl, // ⭐ استخدم الرابط الصحيح
        audio: currentAudio,
      );

      final updatedProfile = state.profile!.copyWith(
        userMedia: updatedMedia,
      );

      emit(MarriageProfileState(
        state: CubitStates.success,
        profile: updatedProfile,
        isLoading: false,
        successMessage: 'تم رفع الفيديو بنجاح',
      ));
    },
  );
}
Future<void> uploadAudio(File audioFile) async {
  if (state.profile == null) return;

  emit(state.copyWith(isLoading: true, clearMessages: true));

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
    (_) async {
      // ⭐⭐⭐ السيرفر ضاف الصوت بنجاح، اعمل reload
      debugPrint('✅ Audio uploaded, reloading profile...');
      await loadProfile();
    },
  );
}
void loadDummyProfile() {
  emit(state.copyWith(
    state: CubitStates.loading,
  ));

  try {
    // Create dummy profile based on InteractionUserModel structure
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
      myDescription: 'شخص طموح يحب التطوير والتعلم المستمر، أبحث عن شريكة حياة تشاركني نفس القيم والاهتمامات.',
      userMedia: UserMedia(
        images: [
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
        ],
        video: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        audio: '',
      ),
    );

    emit(state.copyWith(
      profile: dummyProfile,
      state: CubitStates.success,
    ));
  } catch (e) {
    emit(state.copyWith(
      state: CubitStates.failure,
      errorMessage: 'فشل في تحميل البيانات الوهمية',
    ));
  }
}
Future<void> deleteVideo() async {
  final currentVideoUrl = state.profile?.userMedia?.video;
  if (currentVideoUrl == null) return;

  emit(state.copyWith(isLoading: true, clearMessages: true));

  debugPrint('🗑️ Deleting video from server...');
  
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
      
      // ⭐ أعمل نسخة جديدة تماماً
      final currentImages = state.profile!.userMedia?.images ?? [];
      final currentAudio = state.profile!.userMedia?.audio;
      
      final updatedMedia = UserMedia(
        images: currentImages,
        video: null, // ⭐ الفيديو = null
        audio: currentAudio,
      );

      final updatedProfile = state.profile!.copyWith(
        userMedia: updatedMedia,
      );

      // ⭐ أعمل emit للـ state كامل جديد
      emit(MarriageProfileState(
        state: CubitStates.success,
        profile: updatedProfile,
        isLoading: false,
        successMessage: 'تم حذف الفيديو بنجاح',
      ));
    },
  );
}
  Future<void> deleteAudio() async {
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
      
      // ⭐ أعمل نسخة جديدة تماماً
      final currentImages = state.profile!.userMedia?.images ?? [];
      final currentVideo = state.profile!.userMedia?.video;
      
      final updatedMedia = UserMedia(
        images: currentImages,
        video: currentVideo,
        audio: null, // ⭐ الصوت = null
      );

      final updatedProfile = state.profile!.copyWith(
        userMedia: updatedMedia,
      );

      // ⭐ أعمل emit للـ state كامل جديد
      emit(MarriageProfileState(
        state: CubitStates.success,
        profile: updatedProfile,
        isLoading: false,
        successMessage: 'تم حذف التسجيل الصوتي بنجاح',
      ));
    },
  );
}
  Future<void> clearAllData() async {
    await _repository.clearLocalStorage();
    emit(const MarriageProfileState());
  }
}