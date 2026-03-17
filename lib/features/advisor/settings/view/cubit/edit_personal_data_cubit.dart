import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/core/utils/profile_event_bus.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/edit_personal_data_repository.dart';
import 'package:tayseer/features/advisor/settings/data/models/edit_personal_data_models.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data_state.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
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

      result.fold(
        (failure) {
          emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        },
        (response) {
          if (response.success) {
            final newImageUrl =
                response.data?['image'] as String? ?? state.profile?.image;
            final oldImageUrl = state.profile?.image;

            // Build final new URL with versioning if needed to force update without blinking
            String finalImageUrl = newImageUrl ?? '';
            if (finalImageUrl == oldImageUrl && finalImageUrl.isNotEmpty) {
              finalImageUrl =
                  "$finalImageUrl${finalImageUrl.contains('?') ? '&' : '?'}v=${DateTime.now().millisecondsSinceEpoch}";
            }

            // تحديث البروفايل بعد الحفظ الناجح
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
              image: finalImageUrl,
              video: response.data?['videoLink'] ?? state.profile!.video,
            );

            if (updatedProfile != null) {
              // تحديث الـ Singleton العالمي
              kCurrentUserData = kCurrentUserData?.copyWith(
                name: updatedProfile.name,
                image: updatedProfile.image,
                username: updatedProfile.userName,
              );

              // حفظ في SharedPreferences
              CachNetwork.setData(
                key: kuserData,
                value: jsonEncode(kCurrentUserData?.toJson()),
              );

              // تحديث الكاش المحلي للحقول الفردية (للتوافق)
              CachNetwork.setData(
                key: kMyProfileImage,
                value: updatedProfile.image ?? '',
              );
              CachNetwork.setData(
                key: kMyProfileName,
                value: updatedProfile.name,
              );

              // تحديث الـ HomeCubit فوراً
              getIt<HomeCubit>().refreshUserInfoFromCache();

              // إطلاق حدث التحديث للمزامنة العالمية
              ProfileEventBus.instance.fire(
                ProfileUpdateEvent(
                  name: updatedProfile.name,
                  image: updatedProfile.image ?? '',
                  username: updatedProfile.userName,
                ),
              );
            }

            // ⭐ إطلاق حدث التحديث للمزامنة الفورية في التطبيق
            if (updatedProfile != null) {
              ProfileEventBus.instance.fire(
                ProfileUpdateEvent(
                  name: updatedProfile.name,
                  image: updatedProfile.image ?? '',
                  username: updatedProfile.userName,
                ),
              );
            }

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
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'error_during_save: ${e.toString()}',
        ),
      );
    }
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
    const apiKey = 'AIzaSyAzkpmYLG58vfNtxPGvfh8Ynix02VNWnUg';

    try {
      final model = GenerativeModel(model: 'gemma-3-4b-it', apiKey: apiKey);
      final prompt =
          '''
أنت كاتب محتوى متخصص في كتابة السِّيَر الذاتية (Bio) للمستشارين والمرشدين الأسريين.
المطلوب: بايو احترافي لمستشار/مرشد في العلاقات الأسرية.
النص المُدخل: "$currentText"
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        controller.text = response.text!;
        updateBio(response.text!);
        emit(state.copyWith(isAiState: CubitStates.success));
        emit(state.copyWith(isAiState: CubitStates.initial));
      }
    } catch (e) {
      debugPrint('Gemini AI error: $e');
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
