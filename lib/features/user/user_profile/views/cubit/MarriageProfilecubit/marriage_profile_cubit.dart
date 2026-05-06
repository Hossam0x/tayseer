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

  Future<void> _silentReload() async {
    final result = await _repository.getMarriageProfile();
    result.fold((_) {}, (profile) {
      final withProgress = _calculateProgressWithMedia(profile);
      emit(
        state.copyWith(
          profile: withProgress,
          state: CubitStates.success,
          savedFromButton: false,
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════
  // SINGLE IMAGE
  // ════════════════════════════════════════════════════════════════

  void addPendingSingleImage(File file) {
    emit(
      state.copyWith(
        pendingSingleImage: file,
        pendingDeleteSingleImage: false,
        clearDeletedSingleImageUrl: true,
        hasUnsavedFields: true,
      ),
    );
  }

  void markDeleteSingleImage() {
    final url = state.profile?.userMedia?.singleImage;

    // ✅ لا نعدل الـ profile — نحط flag بس
    emit(
      state.copyWith(
        clearPendingSingleImage: true,
        pendingDeleteSingleImage: url != null && url.startsWith('http'),
        deletedSingleImageUrl: url,
        hasUnsavedFields: true,
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // SECONDARY IMAGES
  // ════════════════════════════════════════════════════════════════

  void addPendingImage(File file) {
    final serverCount = state.profile?.userMedia?.images.length ?? 0;
    final deletedCount = state.deletedImageUrls.length;
    final total = (serverCount - deletedCount) + state.pendingImages.length;
    if (total >= 4) return;

    emit(
      state.copyWith(
        pendingImages: [...state.pendingImages, file],
        hasUnsavedFields: true,
      ),
    );
  }

  void removePendingImage(int index) {
    final updated = List<File>.from(state.pendingImages);
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      emit(state.copyWith(pendingImages: updated));
    }
  }

  void markDeleteImage(String imageUrl) {
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) return;

    // ✅ لا نعدل الـ profile — نضيف الـ URL للقائمة بس
    final updatedDeletedUrls = List<String>.from(state.deletedImageUrls);
    if (!updatedDeletedUrls.contains(imageUrl)) {
      updatedDeletedUrls.add(imageUrl);
    }

    emit(
      state.copyWith(
        deletedImageUrls: updatedDeletedUrls,
        hasUnsavedFields: true,
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // VIDEO
  // ════════════════════════════════════════════════════════════════

  void addPendingVideo(File file) {
    emit(
      state.copyWith(
        pendingVideo: file,
        pendingDeleteVideo: false,
        deletedVideoUrl: null,
        hasUnsavedFields: true,
      ),
    );
  }

  void markDeleteVideo() {
    final url = state.profile?.userMedia?.video;

    final updatedProfile = state.profile!.copyWith(
      userMedia: state.profile!.userMedia?.copyWith(video: null),
    );

    emit(
      state.copyWith(
        profile: updatedProfile,
        clearPendingVideo: true,
        pendingDeleteVideo: url != null && url.isNotEmpty,
        deletedVideoUrl: url,
        hasUnsavedFields: true,
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // AUDIO
  // ════════════════════════════════════════════════════════════════

  void addPendingAudio(File file) {
    emit(
      state.copyWith(
        pendingAudio: file,
        pendingDeleteAudio: false,
        deletedAudioUrl: null,
        hasUnsavedFields: true,
      ),
    );
  }

  void markDeleteAudio() {
    final url = state.profile?.userMedia?.audio;

    final updatedProfile = state.profile!.copyWith(
      userMedia: state.profile!.userMedia?.copyWith(audio: null),
    );

    emit(
      state.copyWith(
        profile: updatedProfile,
        clearPendingAudio: true,
        pendingDeleteAudio: url != null && url.isNotEmpty,
        deletedAudioUrl: url,
        hasUnsavedFields: true,
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // REORDER
  // ════════════════════════════════════════════════════════════════

  void reorderImageLocally(int currentIndex, List<String> allImages) {
    if (currentIndex == 0 || state.profile == null) return;

    final reordered = List<String>.from(allImages);
    final selected = reordered.removeAt(currentIndex);
    reordered.insert(0, selected);

    final updatedProfile = state.profile!.copyWith(
      userMedia: state.profile!.userMedia?.copyWith(images: reordered),
    );

    emit(state.copyWith(profile: updatedProfile, savedFromButton: false));
  }

  void reorderSecondaryImages(
    List<String> reorderedImages,
    List<String> filteredServerImages,
  ) {
    final imagesIndex = {
      for (int i = 0; i < reorderedImages.length; i++)
        i.toString(): reorderedImages[i],
    };

    final updatedMedia = state.profile?.userMedia?.copyWith(
      images: reorderedImages,
      imagesIndex: imagesIndex,
    );
    final updatedProfile = state.profile?.copyWith(userMedia: updatedMedia);

    if (updatedProfile != null) {
      emit(
        state.copyWith(
          profile: updatedProfile,
          hasUnsavedFields: true,
          savedFromButton: false,
        ),
      );
    }
  }

  // ════════════════════════════════════════════════════════════════
  // DISCARD
  // ════════════════════════════════════════════════════════════════

  void discardAllPending() {
    emit(
      state.copyWith(
        clearAllPending: true,
        deletedImageUrls: [],
        hasUnsavedFields: false,
      ),
    );
    _silentReload();
  }

  // ════════════════════════════════════════════════════════════════
  // SAVE PROFILE
  // ════════════════════════════════════════════════════════════════

  Future<void> saveProfile() async {
    if (state.profile == null) return;

    // ✅ احفظ كل القيم المهمة قبل أي emit
    final singleImageUrlToDelete = state.pendingDeleteSingleImage
        ? state.deletedSingleImageUrl
        : null;
    final videoUrlToDelete = state.pendingDeleteVideo
        ? state.deletedVideoUrl
        : null;
    final audioUrlToDelete = state.pendingDeleteAudio
        ? state.deletedAudioUrl
        : null;
    final imageUrlsToDelete = List<String>.from(state.deletedImageUrls);
    final savedProfile = state.profile!;
    final savedImagesIndex = Map<String, String>.from(
      state.profile?.userMedia?.imagesIndex ?? {},
    );
    final savedPendingImages = List<File>.from(state.pendingImages);
    final savedPendingSingleImage = state.pendingSingleImage;
    final savedPendingVideo = state.pendingVideo;
    final savedPendingAudio = state.pendingAudio;

    emit(
      state.copyWith(
        state: CubitStates.loading,
        isUpdating: true,
        clearMessages: true,
        savedFromButton: true,
      ),
    );

    try {
      if (singleImageUrlToDelete != null && singleImageUrlToDelete.isNotEmpty) {
        await _repository.deleteSingleImage(singleImageUrlToDelete);
      }

      for (final url in imageUrlsToDelete) {
        await _repository.deleteMarriageImage(url);
      }

      if (videoUrlToDelete != null && videoUrlToDelete.isNotEmpty) {
        await _repository.deleteVideo(videoUrlToDelete);
      }

      if (audioUrlToDelete != null && audioUrlToDelete.isNotEmpty) {
        await _repository.deleteAudio(audioUrlToDelete);
      }

      if (savedPendingSingleImage != null) {
        await _repository.uploadSingleImage(savedPendingSingleImage);
      }

      for (final file in savedPendingImages) {
        await _repository.uploadMarriageImage(file);
      }

      if (savedPendingVideo != null) {
        await _repository.uploadVideoAndAudio(videoFile: savedPendingVideo);
      }
      if (savedPendingAudio != null) {
        await _repository.uploadVideoAndAudio(audioFile: savedPendingAudio);
      }

      // ════════════════════════════
      // Step 4: Reorder
      // ════════════════════════════
      final hasNewImages = savedPendingImages.isNotEmpty;

      if (hasNewImages) {
        final reloadResult = await _repository.getMarriageProfile();
        await reloadResult.fold((_) async {}, (freshProfile) async {
          final serverImages = freshProfile.userMedia?.images ?? [];
          if (serverImages.isEmpty) return;

          List<String> finalOrder;

          if (savedImagesIndex.isNotEmpty) {
            final sorted =
                savedImagesIndex.entries
                    .where((e) => e.value.startsWith('http'))
                    .toList()
                  ..sort(
                    (a, b) => (int.tryParse(a.key) ?? 0).compareTo(
                      int.tryParse(b.key) ?? 0,
                    ),
                  );

            final orderedExisting = sorted
                .map((e) => e.value)
                .where((url) => serverImages.contains(url))
                .toList();

            final newlyUploaded = serverImages
                .where((url) => !orderedExisting.contains(url))
                .toList();
            finalOrder = [...orderedExisting, ...newlyUploaded];
          } else {
            finalOrder = serverImages;
          }

          if (finalOrder.length > 1) {
            final finalIndex = {
              for (int i = 0; i < finalOrder.length; i++)
                i.toString(): finalOrder[i],
            };
            await _repository.reorderImages(finalIndex);
          }
        });
      } else if (savedImagesIndex.isNotEmpty && imageUrlsToDelete.isEmpty) {
        final sorted =
            savedImagesIndex.entries
                .where((e) => e.value.startsWith('http'))
                .toList()
              ..sort(
                (a, b) => (int.tryParse(a.key) ?? 0).compareTo(
                  int.tryParse(b.key) ?? 0,
                ),
              );

        final finalOrder = sorted.map((e) => e.value).toList();

        if (finalOrder.length > 1) {
          final finalIndex = {
            for (int i = 0; i < finalOrder.length; i++)
              i.toString(): finalOrder[i],
          };
          await _repository.reorderImages(finalIndex);
        }
      }

      // ════════════════════════════
      // Step 5: Update profile fields
      // ════════════════════════════
      final result = await _repository.updateMarriageProfile(savedProfile);

      result.fold(
        (failure) => emit(
          state.copyWith(
            state: CubitStates.failure,
            errorMessage: failure.message,
            isUpdating: false,
          ),
        ),
        (_) async {
          emit(
            state.copyWith(
              clearAllPending: true,
              isUpdating: false,
              hasUnsavedFields: false,
              savedFromButton: true,
            ),
          );

          await loadProfile();

          emit(
            state.clearDeletedImageUrls().copyWith(
              state: CubitStates.success,
              isUpdating: false,
              savedFromButton: true,
            ),
          );
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
      emit(
        state.copyWith(
          profile: state.profile!.copyWith(faith: newFaith),
          hasUnsavedFields: true,
        ),
      );
      return;
    } else {
      updatedProfile = profile;
    }

    emit(
      state.copyWith(
        profile: updatedProfile,
        hasUnsavedFields: true,
        savedFromButton: false,
      ),
    );
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
    'country_algeria': 'nationality_algerian',
    'country_usa': 'nationality_american',
    'country_uk': 'nationality_british',
    'country_canada': 'nationality_canadian',
    'country_australia': 'nationality_australian',
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
    'الجزائر': 'nationality_algerian',
    'أمريكا': 'nationality_american',
    'بريطانيا': 'nationality_british',
    'كندا': 'nationality_canadian',
    'أستراليا': 'nationality_australian',
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
    'Algeria': 'nationality_algerian',
    'USA': 'nationality_american',
    'United States': 'nationality_american',
    'UK': 'nationality_british',
    'United Kingdom': 'nationality_british',
    'Canada': 'nationality_canadian',
    'Australia': 'nationality_australian',
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
