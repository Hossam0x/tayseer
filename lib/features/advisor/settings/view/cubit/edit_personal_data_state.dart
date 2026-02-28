import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/advisor/settings/data/models/edit_personal_data_models.dart';

class EditPersonalDataState extends Equatable {
  final CubitStates state;
  final AdvisorProfileModel? profile;
  final UpdatePersonalDataRequest currentData;
  final File? imageFile;
  final File? videoFile;
  final String? errorMessage;
  final String? successMessage;
  final bool isSaving;
  final String? videoPreviewUrl;
  final String? imagePreviewUrl;
  final CubitStates isAiState;

  const EditPersonalDataState({
    this.state = CubitStates.initial,
    this.profile,
    required this.currentData,
    this.imageFile,
    this.videoFile,
    this.errorMessage,
    this.successMessage,
    this.isSaving = false,
    this.videoPreviewUrl,
    this.imagePreviewUrl,
    this.isAiState = CubitStates.initial,
  });

  factory EditPersonalDataState.initial() {
    return EditPersonalDataState(
      currentData: UpdatePersonalDataRequest(),
      state: CubitStates.loading,
      isAiState: CubitStates.initial,
    );
  }

  EditPersonalDataState copyWith({
    CubitStates? state,
    AdvisorProfileModel? profile,
    UpdatePersonalDataRequest? currentData,
    File? imageFile,
    File? videoFile,
    String? errorMessage,
    String? successMessage,
    bool? isSaving,
    String? videoPreviewUrl,
    String? imagePreviewUrl,
    bool clearVideo = false,
    bool clearImage = false,
    CubitStates? isAiState,
  }) {
    return EditPersonalDataState(
      state: state ?? this.state,
      profile: profile ?? this.profile,
      currentData: currentData ?? this.currentData,
      imageFile: clearImage ? null : (imageFile ?? this.imageFile),
      videoFile: clearVideo ? null : (videoFile ?? this.videoFile),
      errorMessage: errorMessage, // Intentionally not keeping previous
      successMessage: successMessage, // Intentionally not keeping previous
      isSaving: isSaving ?? this.isSaving,
      videoPreviewUrl: clearVideo
          ? null
          : (videoPreviewUrl ?? this.videoPreviewUrl),
      imagePreviewUrl: clearImage
          ? null
          : (imagePreviewUrl ?? this.imagePreviewUrl),
      isAiState: isAiState ?? this.isAiState,
    );
  }

  bool get hasChanges {
    if (profile == null) return false;

    // تحقق من التغييرات في الحقول النصية
    final currentTextChanged =
        (currentData.name != null && currentData.name != profile!.name) ||
        (currentData.username != null &&
            currentData.username != profile!.userName) || // ⭐ أضف هذا
        (currentData.professionalSpecialization != null &&
            currentData.professionalSpecialization !=
                profile!.professionalSpecialization) ||
        (currentData.jobGrade != null &&
            currentData.jobGrade != profile!.jobGrade) ||
        (currentData.yearsOfExperience != null &&
            currentData.yearsOfExperience != profile!.yearsOfExperience) ||
        (currentData.aboutYou != null &&
            currentData.aboutYou != profile!.aboutYou);

    // تحقق من وجود ملفات جديدة
    final hasNewFiles = imageFile != null || videoFile != null;

    return currentTextChanged || hasNewFiles;
  }

  @override
  List<Object?> get props => [
    state,
    profile,
    currentData,
    imageFile,
    videoFile,
    errorMessage,
    successMessage,
    isSaving,
    videoPreviewUrl,
    imagePreviewUrl,
    isAiState,
  ];
}
