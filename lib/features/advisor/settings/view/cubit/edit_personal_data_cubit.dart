import 'package:tayseer/features/advisor/settings/data/models/edit_personal_data_models.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/edit_personal_data_repository.dart';
import 'package:tayseer/my_import.dart';
import 'edit_personal_data_state.dart';

class EditPersonalDataCubit extends Cubit<EditPersonalDataState> {
  final EditPersonalDataRepository _repository;

  EditPersonalDataCubit(this._repository)
    : super(EditPersonalDataState.initial()) {
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    try {
      emit(state.copyWith(state: CubitStates.loading, errorMessage: null));

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
          final yearsExp = profile.yearsOfExperience;
          String? yearsExpString;

          if (yearsExp != null) {
            if (int.tryParse(yearsExp) != null) {
              final intValue = int.parse(yearsExp);
              if (intValue == 2) {
                yearsExpString = "سنتين";
              } else if (intValue == 3) {
                yearsExpString = "3 سنوات";
              } else if (intValue == 5) {
                yearsExpString = "5 سنوات";
              } else if (intValue == 10) {
                yearsExpString = "10 سنوات";
              } else if (intValue > 10) {
                yearsExpString = "أكثر من 10 سنوات";
              } else {
                yearsExpString = yearsExp.toString();
              }
            } else {
              yearsExpString = yearsExp;
            }
          }

          final initialRequest = UpdatePersonalDataRequest(
            name: profile.name,
            dateOfBirth: profile.dateOfBirth,
            gender: profile.gender,
            professionalSpecialization: profile.professionalSpecialization,
            jobGrade: profile.jobGrade,
            yearsOfExperience: yearsExpString,
            aboutYou: profile.aboutYou,
            image: profile.image,
            video: profile.video,
          );

          emit(
            state.copyWith(
              state: CubitStates.success,
              profile: profile,
              currentData: initialRequest,
              imagePreviewUrl: profile.image,
              videoPreviewUrl: profile.video,
              errorMessage: null,
              shouldRemoveVideo: false,
              shouldRemoveImage: false,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          state: CubitStates.failure,
          errorMessage: 'حدث خطأ غير متوقع: ${e.toString()}',
        ),
      );
    }
  }

  void updateName(String name) {
    if (name != state.currentData.name) {
      emit(state.copyWith(currentData: state.currentData.copyWith(name: name)));
    }
  }

  void updateSpecialization(String specialization) {
    if (specialization != state.currentData.professionalSpecialization) {
      emit(
        state.copyWith(
          currentData: state.currentData.copyWith(
            professionalSpecialization: specialization,
          ),
        ),
      );
    }
  }

  void updatePosition(String position) {
    if (position != state.currentData.jobGrade) {
      emit(
        state.copyWith(
          currentData: state.currentData.copyWith(jobGrade: position),
        ),
      );
    }
  }

  void updateExperience(String experience) {
    if (experience != state.currentData.yearsOfExperience) {
      emit(
        state.copyWith(
          currentData: state.currentData.copyWith(
            yearsOfExperience: experience,
          ),
        ),
      );
    }
  }

  void updateBio(String bio) {
    if (bio != state.currentData.aboutYou) {
      emit(
        state.copyWith(currentData: state.currentData.copyWith(aboutYou: bio)),
      );
    }
  }

  void updateImageFile(File? file) {
    if (file != null) {
      emit(
        state.copyWith(
          imageFile: file,
          shouldRemoveImage: false,
          imagePreviewUrl: file.path,
        ),
      );
    }
  }

  void updateVideoFile(File? file, {String? previewUrl}) {
    if (file != null) {
      emit(
        state.copyWith(
          videoFile: file,
          videoPreviewUrl: previewUrl,
          shouldRemoveVideo: false,
        ),
      );
    }
  }

  // دالة لحذف الصورة
  void removeImage() {
    emit(
      state.copyWith(
        clearImageFile: true,
        clearImagePreviewUrl: true,
        shouldRemoveImage: true,
        currentData: state.currentData.copyWith(clearImage: true),
      ),
    );
  }

  // دالة لحذف الفيديو
  void removeVideo() {
    emit(
      state.copyWith(
        clearVideoFile: true,
        clearVideoPreviewUrl: true,
        shouldRemoveVideo: true,
        currentData: state.currentData.copyWith(clearVideo: true),
      ),
    );
  }

  Future<void> saveChanges() async {
    if (state.isSaving || !state.hasChanges) return;

    emit(state.copyWith(isSaving: true, errorMessage: null));

    try {
      String? imageUrl = state.imagePreviewUrl;
      String? videoUrl = state.videoPreviewUrl;

      // رفع الصورة الجديدة إذا كانت موجودة
      if (state.imageFile != null) {
        final uploadedImageUrl = await _repository.uploadFile(
          state.imageFile!,
          'image',
        );
        if (uploadedImageUrl != null) {
          imageUrl = uploadedImageUrl;
        }
      } else if (state.shouldRemoveImage) {
        imageUrl = null;
      }

      // رفع الفيديو الجديد إذا كان موجوداً
      if (state.videoFile != null) {
        final uploadedVideoUrl = await _repository.uploadFile(
          state.videoFile!,
          'video',
        );
        if (uploadedVideoUrl != null) {
          videoUrl = uploadedVideoUrl;
        }
      } else if (state.shouldRemoveVideo) {
        videoUrl = null;
      }

      // تحديث الـ request
      final updatedRequest = state.currentData.copyWith(
        image: imageUrl,
        video: videoUrl,
        clearImage: state.shouldRemoveImage,
        clearVideo: state.shouldRemoveVideo,
      );

      print('📤 Updated request - Image: $imageUrl, Video: $videoUrl');
      print(
        '📤 Should remove - Image: ${state.shouldRemoveImage}, Video: ${state.shouldRemoveVideo}',
      );

      // إرسال الطلب
      final result = await _repository.updatePersonalData(
        request: updatedRequest,
        imageFile: state.imageFile,
        videoFile: state.videoFile,
        removeVideo: state.shouldRemoveVideo && state.videoFile == null,
      );

      result.fold(
        (failure) {
          emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        },
        (response) {
          emit(
            state.copyWith(
              isSaving: false,
              errorMessage: null,
              imagePreviewUrl: imageUrl,
              videoPreviewUrl: videoUrl,
              shouldRemoveVideo: false,
              shouldRemoveImage: false,
              clearImageFile: true,
              clearVideoFile: true,
              profile: state.profile?.copyWith(
                name: updatedRequest.name ?? state.profile!.name,
                aboutYou: updatedRequest.aboutYou ?? state.profile!.aboutYou,
                jobGrade: updatedRequest.jobGrade ?? state.profile!.jobGrade,
                yearsOfExperience:
                    updatedRequest.yearsOfExperience ??
                    state.profile!.yearsOfExperience,
                professionalSpecialization:
                    updatedRequest.professionalSpecialization ??
                    state.profile!.professionalSpecialization,
                image: imageUrl,
                video: videoUrl,
              ),
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'حدث خطأ أثناء الحفظ: ${e.toString()}',
        ),
      );
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(errorMessage: null));
    }
  }
}
