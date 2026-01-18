import 'package:tayseer/core/widgets/snack_bar_service.dart';
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

          final initialRequest = UpdatePersonalDataRequest(
            name: profile.name,
            dateOfBirth: profile.dateOfBirth,
            gender: profile.gender,
            professionalSpecialization: profile.professionalSpecialization,
            jobGrade: profile.jobGrade,
            yearsOfExperience: yearsExp,
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

  void updateUsername(String username) {
    if (username != state.currentData.username) {
      emit(
        state.copyWith(
          currentData: state.currentData.copyWith(username: username),
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
          imagePreviewUrl: file.path, // عرض معاينة محلية
        ),
      );
    }
  }

  void updateVideoFile(File? file, {String? previewUrl}) {
    if (file != null) {
      emit(
        state.copyWith(
          videoFile: file,
          videoPreviewUrl: previewUrl ?? file.path,
        ),
      );
    }
  }

  // في الكوبيت
  void removeImage() {
    emit(
      state.copyWith(
        imageFile: null,
        imagePreviewUrl: null,
        // ⭐ إضافة flag للحذف
        currentData: state.currentData.copyWith(image: ""),
      ),
    );
  }

  void removeVideo() {
    emit(
      state.copyWith(
        videoFile: null,
        videoPreviewUrl: null,
        // ⭐ إضافة flag للحذف
        currentData: state.currentData.copyWith(video: ""),
      ),
    );
  }

  Future<void> saveChanges(BuildContext context) async {
    if (state.isSaving || !state.hasChanges) return;

    emit(state.copyWith(isSaving: true, errorMessage: null));

    try {
      // ⭐ إرسال البيانات كما هي بدون تنظيف
      final requestToSend = state.currentData;

      final result = await _repository.updatePersonalData(
        request: requestToSend,
        imageFile: state.imageFile,
        videoFile: state.videoFile,
      );

      result.fold(
        (failure) {
          emit(state.copyWith(isSaving: false, errorMessage: failure.message));
        },
        (response) {
          // تحديث البروفايل بعد الحفظ الناجح
          final updatedProfile = state.profile?.copyWith(
            name: state.currentData.name ?? state.profile!.name,
            professionalSpecialization:
                state.currentData.professionalSpecialization ??
                state.profile!.professionalSpecialization,
            jobGrade: state.currentData.jobGrade ?? state.profile!.jobGrade,
            yearsOfExperience:
                state.currentData.yearsOfExperience ?? // ⭐ String
                state.profile!.yearsOfExperience,
            aboutYou: state.currentData.aboutYou ?? state.profile!.aboutYou,
            image: response.data?['image'] ?? state.profile!.image,
            video: response.data?['videoLink'] ?? state.profile!.video,
          );

          emit(
            state.copyWith(
              isSaving: false,
              errorMessage: null,
              profile: updatedProfile,
              // مسح الملفات المؤقتة بعد الحفظ
              imageFile: null,
              videoFile: null,
            ),
          );

          // إظهار رسالة النجاح
          if (response.success) {
            showSafeSnackBar(
              context: context,
              text: 'تم تحديث البيانات بنجاح',
              isSuccess: true,
            );
            Navigator.pop(context);
          }
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
