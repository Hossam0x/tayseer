import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/marriage_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_state.dart';
import 'package:tayseer/my_import.dart';

class MarriageProfileCubit extends Cubit<MarriageProfileState> {
  final MarriageProfileRepository _repository;
  final UserProfileModel? initialUserProfile;

  MarriageProfileCubit(this._repository, {this.initialUserProfile})
    : super(const MarriageProfileState());

  // ════════════════════════════════════════════════════════════════
  // LOAD PROFILE
  // ════════════════════════════════════════════════════════════════
  Future<void> loadProfile() async {
    emit(
      state.copyWith(
        state: CubitStates.loading,
        isLoading: true,
        clearMessages: true,
      ),
    );

    final result = await _repository.getMarriageProfile();
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            state: CubitStates.failure,
            errorMessage: failure.message,
            isLoading: false,
          ),
        );
      },
      (marriageProfile) {
        final profileWithProgress = _calculateProgressWithMedia(
          marriageProfile,
        );

        emit(
          state.copyWith(
            state: CubitStates.success,
            profile: profileWithProgress,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future<void> autoSaveFields() async {
    if (state.profile == null) return;

    try {
      await _repository.updateMarriageProfile(state.profile!);
      debugPrint('✅ [AUTO-SAVE] Fields saved');
    } catch (e) {
      debugPrint('⚠️ [AUTO-SAVE] Error: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ✅ PENDING MEDIA - Single Image
  // ════════════════════════════════════════════════════════════════
  void addPendingSingleImage(File file) {
    final existingUrl = state.profile?.userMedia?.singleImage;
    emit(
      state.copyWith(
        pendingSingleImage: file,
        // لو فيه صورة قديمة، احتفظ بـ URL للحذف وقت الحفظ
        deletedSingleImageUrl: existingUrl ?? state.deletedSingleImageUrl,
      ),
    );
  }

  void markDeleteSingleImage() {
    final url = state.profile?.userMedia?.singleImage;

    // حدّث الـ profile محلياً عشان يختفي من الشاشة فوراً
    MarriageUserProfileModel? updatedProfile;
    if (state.profile != null) {
      updatedProfile = state.profile!.copyWith(
        userMedia: state.profile!.userMedia?.copyWith(singleImage: null),
      );
    }

    emit(
      state.copyWith(
        profile: updatedProfile ?? state.profile,
        deletedSingleImageUrl: url,
        clearPendingSingleImage: true,
      ),
    );
  }

  void discardAllPending() {
    // ✅ نرجع الـ profile لحالته الأصلية (reload من السيرفر)
    // الأسهل: نعمل emit بـ clearAllPending: true
    emit(state.copyWith(clearAllPending: true));
  }

  // ════════════════════════════════════════════════════════════════
  // ✅ PENDING MEDIA - Images (Secondary)
  // ════════════════════════════════════════════════════════════════
  void addPendingImage(File file) {
    final serverCount =
        (state.profile?.userMedia?.images.length ?? 0) -
        state.deletedImageUrls.length;
    final total = serverCount + state.pendingImages.length;

    if (total >= 4) {
      return;
    }

    final updated = [...state.pendingImages, file];

    emit(state.copyWith(pendingImages: updated));
  }

  void markDeleteImage(String imageUrl) {
    final updatedDeleted = [...state.deletedImageUrls, imageUrl];

    // حدّث الـ profile محلياً عشان الصورة تختفي من الشاشة فوراً
    if (state.profile != null) {
      final currentImages = List<String>.from(
        state.profile!.userMedia?.images ?? [],
      );
      currentImages.remove(imageUrl);
      final updatedProfile = state.profile!.copyWith(
        userMedia: state.profile!.userMedia?.copyWith(images: currentImages),
      );
      emit(
        state.copyWith(
          profile: updatedProfile,
          deletedImageUrls: updatedDeleted,
        ),
      );
    } else {
      emit(state.copyWith(deletedImageUrls: updatedDeleted));
    }
  }

  void removePendingImage(int index) {
    final updated = List<File>.from(state.pendingImages);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);

      emit(state.copyWith(pendingImages: updated));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // ✅ PENDING MEDIA - Video
  // ════════════════════════════════════════════════════════════════
  void addPendingVideo(File file) {
    final existingVideo = state.profile?.userMedia?.video;
    emit(
      state.copyWith(
        pendingVideo: file,
        // لو فيه فيديو قديم، اعمل mark للحذف
        pendingDeleteVideo: existingVideo != null && existingVideo.isNotEmpty,
      ),
    );
  }

  void markDeleteVideo() {
    MarriageUserProfileModel? updatedProfile;
    if (state.profile != null) {
      updatedProfile = state.profile!.copyWith(
        userMedia: state.profile!.userMedia?.copyWith(video: null),
      );
    }

    emit(
      state.copyWith(
        profile: updatedProfile ?? state.profile,
        pendingDeleteVideo: true,
        clearPendingVideo: true,
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ✅ PENDING MEDIA - Audio
  // ════════════════════════════════════════════════════════════════
  void addPendingAudio(File file) {
    final existingAudio = state.profile?.userMedia?.audio;
    emit(
      state.copyWith(
        pendingAudio: file,
        // لو فيه صوت قديم، اعمل mark للحذف
        pendingDeleteAudio: existingAudio != null && existingAudio.isNotEmpty,
      ),
    );
  }

  void markDeleteAudio() {
    MarriageUserProfileModel? updatedProfile;
    if (state.profile != null) {
      updatedProfile = state.profile!.copyWith(
        userMedia: state.profile!.userMedia?.copyWith(audio: null),
      );
    }

    emit(
      state.copyWith(
        profile: updatedProfile ?? state.profile,
        pendingDeleteAudio: true,
        clearPendingAudio: true,
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ✅ REORDER - محلي فقط، هيتحفظ مع saveProfile
  // ════════════════════════════════════════════════════════════════
  void reorderImageLocally(int currentIndex, List<String> allImages) {
    if (currentIndex == 0 || state.profile == null) return;

    final reordered = List<String>.from(allImages);
    final selected = reordered.removeAt(currentIndex);
    reordered.insert(0, selected);

    final updatedProfile = state.profile!.copyWith(
      userMedia: state.profile!.userMedia?.copyWith(images: reordered),
    );

    emit(state.copyWith(profile: updatedProfile));
  }

  // ════════════════════════════════════════════════════════════════
  // ✅✅✅ SAVE PROFILE - يرفع كل الـ pending media عند الحفظ
  // ════════════════════════════════════════════════════════════════
  Future<void> saveProfile() async {
    if (state.profile == null) return;

    emit(
      state.copyWith(
        state: CubitStates.loading,
        isUpdating: true,
        clearMessages: true,
      ),
    );
    try {
      // ════════════════════
      // Step 1: Deletions
      // ════════════════════
      if (state.deletedSingleImageUrl != null) {
        await _repository.deleteSingleImage(state.deletedSingleImageUrl!);
      }

      for (final url in state.deletedImageUrls) {
        await _repository.deleteMarriageImage(url);
      }

      if (state.pendingDeleteVideo) {
        final videoUrl = state.profile?.userMedia?.video;
        if (videoUrl != null && videoUrl.isNotEmpty) {
          await _repository.deleteVideo(videoUrl);
        }
      }

      if (state.pendingDeleteAudio) {
        final audioUrl = state.profile?.userMedia?.audio;
        if (audioUrl != null && audioUrl.isNotEmpty) {
          await _repository.deleteAudio(audioUrl);
        }
      }

      // ════════════════════
      // Step 2: Uploads
      // ════════════════════
      if (state.pendingSingleImage != null) {
        await _repository.uploadSingleImage(state.pendingSingleImage!);
      }

      for (int i = 0; i < state.pendingImages.length; i++) {
        await _repository.uploadMarriageImage(state.pendingImages[i]);
      }

      if (state.pendingVideo != null) {
        await _repository.uploadVideoAndAudio(videoFile: state.pendingVideo!);
      }

      if (state.pendingAudio != null) {
        await _repository.uploadVideoAndAudio(audioFile: state.pendingAudio!);
      }

      // ════════════════════
      // Step 3: Save Profile
      // ════════════════════

      final result = await _repository.updateMarriageProfile(state.profile!);

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              state: CubitStates.failure,
              errorMessage: failure.message,
              isUpdating: false,
            ),
          );
        },
        (_) async {
          // ✅ Clear all pending
          emit(state.copyWith(clearAllPending: true, isUpdating: false));
          // ✅ Reload لجيب الـ URLs الجديدة من السيرفر
          await loadProfile();
          emit(state.copyWith(state: CubitStates.success, isUpdating: false));
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          state: CubitStates.failure,
          errorMessage: e.toString(),
          isUpdating: false,
        ),
      );
    }
  }

  // ════════════════════════════════════════════════════════════════
  // CALCULATE PROGRESS
  // ════════════════════════════════════════════════════════════════
  MarriageUserProfileModel _calculateProgressWithMedia(
    MarriageUserProfileModel profile,
  ) {
    int totalProgress = 50;

    final singleImage = profile.userMedia?.singleImage;
    final images = profile.userMedia?.images ?? [];
    final totalImages =
        (singleImage != null && singleImage.isNotEmpty ? 1 : 0) + images.length;

    if (totalImages > 0) {
      final imageCount = totalImages > 5 ? 5 : totalImages;
      totalProgress += imageCount * 5;
    }

    if (profile.userMedia?.video != null &&
        profile.userMedia!.video!.isNotEmpty) {
      totalProgress += 10;
    }
    if (profile.userMedia?.audio != null &&
        profile.userMedia!.audio!.isNotEmpty) {
      totalProgress += 10;
    }
    if (profile.isVerified ?? false) totalProgress += 5;

    final finalProgress = totalProgress > 100 ? 100 : totalProgress;

    return profile.copyWith(answerCompletedPercentage: finalProgress);
  }

  // ════════════════════════════════════════════════════════════════
  // UPDATE FIELD
  // ════════════════════════════════════════════════════════════════
  void updateField(String fieldKey, dynamic value) {
    if (state.profile == null) return;

    // ✅ عند تغيير الدولة، حدّث الجنسية تلقائياً
    if (fieldKey == 'country') {
      final nationalityValue = _convertCountryToNationality(value);
      _updateFieldInternal('nationality', nationalityValue);
    }
    _updateFieldInternal(fieldKey, value);
  }

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
        case 'drinkAlcohol':
          updatedAbout = currentAbout.copyWith(drinkAlcohol: value);
          break;
        case 'eatHalalOnly':
          updatedAbout = currentAbout.copyWith(eatHalalOnly: value);
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
      final current = profile.professionalLife ?? ProfessionalLife();
      ProfessionalLife updated;
      switch (fieldKey) {
        case 'education_level':
        case 'educationLevel':
          updated = current.copyWith(educationLevel: value);
          break;
        case 'choose_job':
        case 'job':
        case 'occupation':
          updated = current.copyWith(job: value);
          break;
        case 'choose_employer':
        case 'employer':
        case 'chooseEmployer':
          updated = current.copyWith(chooseEmployer: value);
          break;
        default:
          updated = current;
      }
      updatedProfile = profile.copyWith(professionalLife: updated);
    } else if (_isFamilyField(fieldKey)) {
      final current = profile.family ?? Family();
      Family updated;
      switch (fieldKey) {
        case 'hasChildren':
          updated = current.copyWith(hasChildren: value);
          break;
        case 'childrenNumber':
          updated = current.copyWith(childrenNumber: value);
          break;
        case 'childrenLiveWithYou':
        case 'childrenLivingStatus':
          updated = current.copyWith(childrenLivingStatus: value);
          break;
        default:
          updated = current;
      }
      updatedProfile = profile.copyWith(family: updated);
    } else if (_isGoalsField(fieldKey)) {
      final current = profile.yourGoals ?? YourGoals();
      YourGoals updated;
      switch (fieldKey) {
        case 'engagement':
        case 'engagementTimeline':
          updated = current.copyWith(engagement: value);
          break;
        case 'marry':
        case 'marriage_intentions':
        case 'communicationTimeline':
          updated = current.copyWith(marry: value);
          break;
        case 'familyAcceptance':
          updated = current.copyWith(familyAcceptance: value);
          break;
        case 'intendTravelAbroad':
          updated = current.copyWith(intendTravelAbroad: value);
          break;
        default:
          updated = current;
      }
      updatedProfile = profile.copyWith(yourGoals: updated);
    } else if (fieldKey == 'bio' || fieldKey == 'myDescription') {
      updatedProfile = profile.copyWith(myDescription: value);
    } else if (fieldKey == 'hobbies' || fieldKey == 'interests') {
      final validKeys = (value as String)
          .split(', ')
          .where((h) => h.startsWith('interest_') || h.startsWith('faith_'))
          .toList();
      updatedProfile = profile.copyWith(hobbies: validKeys);
    } else if (fieldKey == 'faith') {
      final newFaith = (value as String)
          .split(', ')
          .where((h) => h.startsWith('faith_'))
          .toList();
      emit(state.copyWith(profile: state.profile!.copyWith(faith: newFaith)));
      return;
    } else {
      updatedProfile = profile;
    }

    emit(state.copyWith(profile: updatedProfile));
  }

  // ════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════
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

  static const Map<String, String> _countryValueToNationalityKeyMap = {
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

  String _convertCountryToNationality(String country) {
    if (_countryToNationalityKeyMap.containsKey(country)) {
      return _countryToNationalityKeyMap[country]!;
    }
    if (_countryValueToNationalityKeyMap.containsKey(country)) {
      return _countryValueToNationalityKeyMap[country]!;
    }
    return country;
  }

  bool _isAboutMeField(String f) => [
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
    'age',
    'drinkAlcohol',
    'eatHalalOnly',
  ].contains(f);

  bool _isProfessionalLifeField(String f) => [
    'education_level',
    'educationLevel',
    'choose_job',
    'job',
    'occupation',
    'choose_employer',
    'employer',
    'chooseEmployer',
  ].contains(f);

  bool _isFamilyField(String f) => [
    'hasChildren',
    'childrenNumber',
    'childrenLiveWithYou',
    'childrenLivingStatus',
  ].contains(f);

  bool _isGoalsField(String f) => [
    'engagement',
    'engagementTimeline',
    'marry',
    'marriage_intentions',
    'communicationTimeline',
    'familyAcceptance',
    'intendTravelAbroad',
  ].contains(f);

  Future<void> clearAllData() async {
    await _repository.clearLocalStorage();
    emit(const MarriageProfileState());
  }
}
