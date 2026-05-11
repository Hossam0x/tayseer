import 'dart:async';
import 'dart:convert';
import 'package:tayseer/core/services/groq_service.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart' as di;
import 'package:tayseer/core/utils/profile_event_bus.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/edit_personal_data_repository.dart';
import 'package:tayseer/features/advisor/settings/data/models/edit_personal_data_models.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_state.dart';
import 'package:tayseer/my_import.dart';

class EditPersonalDataCubit extends Cubit<EditPersonalDataState> {
  final EditPersonalDataRepository _repository;

  EditPersonalDataCubit(this._repository)
    : super(EditPersonalDataState.initial());

  // Changed to optional parameter for backward compatibility and to support UI retry calls
  Future<void> loadProfileData([AdvisorProfileModel? profile]) async {
    if (profile != null) {
      emit(
        state.copyWith(
          profile: profile,
          currentData: profile.toRequest(),
          state: CubitStates.success,
          imagePreviewUrl: profile.image,
          videoPreviewUrl: profile.video,
        ),
      );
    } else {
      await fetchProfileData();
    }
  }

  Future<void> fetchProfileData() async {
    emit(state.copyWith(state: CubitStates.loading));
    final result = await _repository.getAdvisorProfile();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            state: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (profile) {
        emit(
          state.copyWith(
            profile: profile,
            currentData: profile.toRequest(),
            state: CubitStates.success,
            imagePreviewUrl: profile.image,
            videoPreviewUrl: profile.video,
          ),
        );
      },
    );
  }

  void updateName(String name) {
    emit(state.copyWith(currentData: state.currentData.copyWith(name: name)));
  }

  void updateUsername(String username) {
    emit(
      state.copyWith(
        currentData: state.currentData.copyWith(username: username),
      ),
    );
  }

  void updateBio(String bio) {
    emit(
      state.copyWith(currentData: state.currentData.copyWith(aboutYou: bio)),
    );
  }

  void updateSpecialization(String specialization) {
    emit(
      state.copyWith(
        currentData: state.currentData.copyWith(
          professionalSpecialization: specialization,
        ),
      ),
    );
  }

  void updateJobGrade(String jobGrade) {
    emit(
      state.copyWith(
        currentData: state.currentData.copyWith(jobGrade: jobGrade),
      ),
    );
  }

  void updateExperience(String experience) {
    emit(
      state.copyWith(
        currentData: state.currentData.copyWith(yearsOfExperience: experience),
      ),
    );
  }

  void updatePosition(String position) {
    // Usually mapped to specialization or job grade depending on app logic
    updateJobGrade(position);
  }

  void updateImageFile(File file) {
    emit(
      state.copyWith(
        imageFile: file,
        clearImage: false,
        imagePreviewUrl: file.path,
      ),
    );
  }

  void updateVideoFile(File file, {String? previewUrl}) {
    emit(
      state.copyWith(
        videoFile: file,
        clearVideo: false,
        videoPreviewUrl: previewUrl ?? file.path,
      ),
    );
  }

  void removeImage() {
    emit(
      state.copyWith(
        clearImage: true,
        imageFile: null,
        currentData: state.currentData.copyWith(clearImage: true),
      ),
    );
  }

  void removeVideo() {
    emit(
      state.copyWith(
        clearVideo: true,
        videoFile: null,
        currentData: state.currentData.copyWith(clearVideo: true),
      ),
    );
  }

  Future<void> saveChanges() async {
    if (state.isSaving || !state.hasChanges) return;

    emit(
      state.copyWith(isSaving: true, errorMessage: null, uploadProgress: 0.0),
    );

    try {
      // Build a diff request — only include fields that actually changed
      final profile = state.profile;
      final current = state.currentData;
      final requestToSend = UpdatePersonalDataRequest(
        name: (current.name != null && current.name != profile?.name)
            ? current.name
            : null,
        username:
            (current.username != null && current.username != profile?.userName)
            ? current.username
            : null,
        professionalSpecialization:
            (current.professionalSpecialization != null &&
                current.professionalSpecialization !=
                    profile?.professionalSpecialization)
            ? current.professionalSpecialization
            : null,
        jobGrade:
            (current.jobGrade != null && current.jobGrade != profile?.jobGrade)
            ? current.jobGrade
            : null,
        yearsOfExperience:
            (current.yearsOfExperience != null &&
                current.yearsOfExperience != profile?.yearsOfExperience)
            ? current.yearsOfExperience
            : null,
        aboutYou:
            (current.aboutYou != null && current.aboutYou != profile?.aboutYou)
            ? current.aboutYou
            : null,
        image: current.image,
        video: current.video,
      );

      final result = await _repository.updatePersonalData(
        request: requestToSend,
        imageFile: state.imageFile,
        videoFile: state.videoFile,
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            if ((progress - state.uploadProgress).abs() > 0.01 ||
                progress == 1.0) {
              emit(state.copyWith(uploadProgress: progress));
            }
          }
        },
      );

      debugPrint('📤 EditPersonalDataCubit → request sent:');
      debugPrint('   name: ${requestToSend.name}');
      debugPrint('   username: ${requestToSend.username}');
      debugPrint(
        '   specialization: ${requestToSend.professionalSpecialization}',
      );
      debugPrint('   jobGrade: ${requestToSend.jobGrade}');
      debugPrint('   yearsOfExperience: ${requestToSend.yearsOfExperience}');
      debugPrint('   aboutYou: ${requestToSend.aboutYou}');
      debugPrint('   imageFile: ${state.imageFile?.path ?? 'none'}');
      debugPrint('   videoFile: ${state.videoFile?.path ?? 'none'}');

      // استخدام fold للتحقق من النتيجة بدون await داخل callback
      final failure = result.fold((f) => f, (_) => null);
      final response = result.fold((_) => null, (r) => r);

      if (failure != null) {
        debugPrint('❌ EditPersonalDataCubit → save failed: ${failure.message}');
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
      } else if (response != null) {
        debugPrint('✅ EditPersonalDataCubit → save response:');
        debugPrint('   success: ${response.success}');
        debugPrint('   data: ${response.data}');

        if (response.success) {
          final oldImageUrl = state.profile?.image;

          final updatedProfile = state.profile?.copyWith(
            name: state.currentData.name ?? state.profile!.name,
            userName: state.currentData.username ?? state.profile!.userName,
            professionalSpecialization:
                state.currentData.professionalSpecialization ??
                state.profile!.professionalSpecialization,
            jobGrade: state.currentData.jobGrade ?? state.profile!.jobGrade,
            yearsOfExperience:
                state.currentData.yearsOfExperience ??
                state.profile!.yearsOfExperience,
            aboutYou: state.currentData.aboutYou ?? state.profile!.aboutYou,
            image: state.profile!.image,
            video: response.data?['videoLink'] ?? state.profile!.video,
          );

          final profileName =
              updatedProfile?.name ?? kCurrentUserData?.name ?? '';
          final profileUsername =
              updatedProfile?.userName ?? kCurrentUserData?.username ?? '';

          kCurrentUserData = kCurrentUserData?.copyWith(
            name: profileName,
            username: profileUsername,
          );
          CachNetwork.setData(
            key: kuserData,
            value: jsonEncode(kCurrentUserData?.toJson()),
          );
          CachNetwork.setData(key: kMyProfileName, value: profileName);

          // ⭐ أولاً: جلب الصورة الجديدة وإطلاق الـ event قبل إغلاق الصفحة
          await _fetchAndFireFreshImage(
            oldImageUrl: oldImageUrl,
            profileName: profileName,
            profileUsername: profileUsername,
          );

          if (isClosed) return;

          // ⭐ ثانياً: بعد ما الـ event اتبعت، نبعت successMessage فيتعمل pop
          emit(
            state.copyWith(
              isSaving: false,
              errorMessage: null,
              profile: updatedProfile,
              state: CubitStates.success,
              successMessage: 'data_updated_successfully',
              imagePreviewUrl: updatedProfile?.image,
              videoPreviewUrl: updatedProfile?.video,
              imageFile: null,
              videoFile: null,
              clearImage: false,
              clearVideo: false,
            ),
          );
        } else {
          emit(state.copyWith(isSaving: false, errorMessage: 'save_failed'));
        }
      }
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'error_during_save: ${e.toString()}',
        ),
      );
    }
  }

  /// يجيب الـ URL الصح من getNameAndImage ويحدث الكاش ويبعت الـ event
  /// يُستدعى قبل emit(successMessage) عشان الـ Cubit ما يتغلقش قبل ما الـ event يتبعت
  Future<void> _fetchAndFireFreshImage({
    required String? oldImageUrl,
    required String profileName,
    required String profileUsername,
  }) async {
    if (isClosed) return;

    final result = await _repository.fetchNameAndImage();

    result.fold(
      (_) {
        // فشل الـ fetch — نبعت event بالبيانات المتاحة من الكاش
        final currentImage = CachNetwork.getStringData(key: kMyProfileImage);
        ProfileEventBus.instance.fire(
          ProfileUpdateEvent(
            name: profileName,
            image: currentImage,
            username: profileUsername,
            userId: kCurrentUserData?.id,
            userType: ProfileEventUserType.advisor,
          ),
        );
      },
      (data) {
        if (isClosed) return;
        final freshImage = data['image'] ?? '';
        final freshName = data['name'] ?? profileName;

        if (freshImage.isEmpty) return;

        // مسح الـ URL القديم من disk cache و memory cache
        if (oldImageUrl != null &&
            oldImageUrl.isNotEmpty &&
            oldImageUrl != freshImage) {
          try {
            CachedNetworkImage.evictFromCache(oldImageUrl);
            imageCache.evict(NetworkImage(oldImageUrl));
          } catch (_) {}
        }

        // حفظ الـ URL الجديد في الكاش
        kCurrentUserData = kCurrentUserData?.copyWith(
          image: freshImage,
          name: freshName,
        );
        CachNetwork.setData(
          key: kuserData,
          value: jsonEncode(kCurrentUserData?.toJson()),
        );
        CachNetwork.setData(key: kMyProfileImage, value: freshImage);
        CachNetwork.setData(key: kMyProfileName, value: freshName);

        debugPrint('🔄 fresh image from getNameAndImage: $freshImage');

        // إطلاق الـ event بالـ URL الجديد
        ProfileEventBus.instance.fire(
          ProfileUpdateEvent(
            name: freshName,
            image: freshImage,
            username: profileUsername,
            userId: kCurrentUserData?.id,
            userType: ProfileEventUserType.advisor,
          ),
        );
      },
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(errorMessage: null));
    }
  }

  void clearSuccess() {
    if (state.successMessage != null) {
      emit(state.copyWith(successMessage: null));
    }
  }

  Future<void> enhanceTextWithGemini(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final currentText = controller.text;

    if (currentText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: context.tr('please_write_text_first'),
          isError: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isAiState: CubitStates.loading));

    try {
      final groq = di.getIt<GroqService>();
      final prompt =
          'أنت كاتب محتوى متخصص في كتابة السِّيَر الذاتية (Bio) للمستشارين والمرشدين الأسريين.\n'
          'المطلوب: بايو احترافي لمستشار/مرشد في العلاقات الأسرية.\n'
          'النص المُدخل: "$currentText"\n'
          'أرجع النص المحسّن فقط بدون أي شرح إضافي.';

      final result = await groq.generateText(prompt);
      controller.text = result;
      updateBio(result);
      emit(state.copyWith(isAiState: CubitStates.success));
      emit(state.copyWith(isAiState: CubitStates.initial));
    } catch (e) {
      debugPrint('Groq AI error: $e');
      emit(state.copyWith(isAiState: CubitStates.failure));
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: 'AI Error: ${e.toString()}',
          isError: true,
        ),
      );
      emit(state.copyWith(isAiState: CubitStates.initial));
    }
  }
}
