import 'package:tayseer/features/settings/data/models/edit_personal_data_models.dart';
import 'package:tayseer/features/settings/data/repositories/edit_personal_data_repository.dart';
import 'package:tayseer/my_import.dart';
import 'edit_personal_data_state.dart';

class EditPersonalDataCubit extends Cubit<EditPersonalDataState> {
  final EditPersonalDataRepository _repository;

  EditPersonalDataCubit(this._repository)
    : super(EditPersonalDataState.initial()) {
    loadProfileData();
  }

  Future<void> loadProfileData() async {
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
            state: CubitStates.success,
            profile: profile,
            currentData: profile.toRequest(),
            imagePreviewUrl: profile.image,
            videoPreviewUrl: profile.video,
          ),
        );
      },
    );
  }

  void updateName(String name) {
    emit(
      state.copyWith(
        currentData: UpdatePersonalDataRequest(
          name: name,
          dateOfBirth: state.currentData.dateOfBirth,
          gender: state.currentData.gender,
          professionalSpecialization:
              state.currentData.professionalSpecialization,
          jobGrade: state.currentData.jobGrade,
          yearsOfExperience: state.currentData.yearsOfExperience,
          aboutYou: state.currentData.aboutYou,
        ),
      ),
    );
  }

  void updateUserName(String userName) {
    // Note: username might not be editable in this endpoint
  }

  void updateSpecialization(String specialization) {
    emit(
      state.copyWith(
        currentData: UpdatePersonalDataRequest(
          name: state.currentData.name,
          dateOfBirth: state.currentData.dateOfBirth,
          gender: state.currentData.gender,
          professionalSpecialization: specialization,
          jobGrade: state.currentData.jobGrade,
          yearsOfExperience: state.currentData.yearsOfExperience,
          aboutYou: state.currentData.aboutYou,
        ),
      ),
    );
  }

  void updatePosition(String position) {
    emit(
      state.copyWith(
        currentData: UpdatePersonalDataRequest(
          name: state.currentData.name,
          dateOfBirth: state.currentData.dateOfBirth,
          gender: state.currentData.gender,
          professionalSpecialization:
              state.currentData.professionalSpecialization,
          jobGrade: position,
          yearsOfExperience: state.currentData.yearsOfExperience,
          aboutYou: state.currentData.aboutYou,
        ),
      ),
    );
  }

  void updateExperience(String experience) {
    emit(
      state.copyWith(
        currentData: UpdatePersonalDataRequest(
          name: state.currentData.name,
          dateOfBirth: state.currentData.dateOfBirth,
          gender: state.currentData.gender,
          professionalSpecialization:
              state.currentData.professionalSpecialization,
          jobGrade: state.currentData.jobGrade,
          yearsOfExperience: experience,
          aboutYou: state.currentData.aboutYou,
        ),
      ),
    );
  }

  void updateBio(String bio) {
    emit(
      state.copyWith(
        currentData: UpdatePersonalDataRequest(
          name: state.currentData.name,
          dateOfBirth: state.currentData.dateOfBirth,
          gender: state.currentData.gender,
          professionalSpecialization:
              state.currentData.professionalSpecialization,
          jobGrade: state.currentData.jobGrade,
          yearsOfExperience: state.currentData.yearsOfExperience,
          aboutYou: bio,
        ),
      ),
    );
  }

  void updateImageFile(File? file) {
    emit(state.copyWith(imageFile: file));
  }

  void updateVideoFile(File? file, {String? previewUrl}) {
    emit(state.copyWith(videoFile: file, videoPreviewUrl: previewUrl));
  }

  Future<void> saveChanges() async {
    if (state.isSaving || !state.hasChanges) return;

    emit(state.copyWith(isSaving: true));

    // رفع الملفات أولاً إذا كانت موجودة
    String? imageUrl = state.imagePreviewUrl;
    String? videoUrl = state.videoPreviewUrl;

    if (state.imageFile != null) {
      final uploadedImageUrl = await _repository.uploadFile(
        state.imageFile!,
        'image',
      );
      if (uploadedImageUrl != null) {
        imageUrl = uploadedImageUrl;
      }
    }

    if (state.videoFile != null) {
      final uploadedVideoUrl = await _repository.uploadFile(
        state.videoFile!,
        'video',
      );
      if (uploadedVideoUrl != null) {
        videoUrl = uploadedVideoUrl;
      }
    }

    // تحديث الـ request بالـ URLs الجديدة
    final updatedRequest = UpdatePersonalDataRequest(
      name: state.currentData.name,
      dateOfBirth: state.currentData.dateOfBirth,
      gender: state.currentData.gender,
      professionalSpecialization: state.currentData.professionalSpecialization,
      jobGrade: state.currentData.jobGrade,
      yearsOfExperience: state.currentData.yearsOfExperience,
      aboutYou: state.currentData.aboutYou,
      image: imageUrl,
      video: videoUrl,
    );

    // إرسال الطلب النهائي
    final result = await _repository.updatePersonalData(
      request: updatedRequest,
      imageFile: state.imageFile,
      videoFile: state.videoFile,
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
          ),
        );
      },
    );
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  void reset() {
    if (state.profile != null) {
      emit(
        state.copyWith(
          currentData: state.profile!.toRequest(),
          imageFile: null,
          videoFile: null,
          imagePreviewUrl: state.profile!.image,
          videoPreviewUrl: state.profile!.video,
        ),
      );
    }
  }
}
