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
  final bool isSaving;
  final String? videoPreviewUrl;
  final String? imagePreviewUrl;

  const EditPersonalDataState({
    this.state = CubitStates.initial,
    this.profile,
    required this.currentData,
    this.imageFile,
    this.videoFile,
    this.errorMessage,
    this.isSaving = false,
    this.videoPreviewUrl,
    this.imagePreviewUrl,
  });

  factory EditPersonalDataState.initial() {
    return EditPersonalDataState(
      currentData: UpdatePersonalDataRequest(),
      state: CubitStates.loading,
    );
  }

  EditPersonalDataState copyWith({
    CubitStates? state,
    AdvisorProfileModel? profile,
    UpdatePersonalDataRequest? currentData,
    File? imageFile,
    File? videoFile,
    String? errorMessage,
    bool? isSaving,
    String? videoPreviewUrl,
    String? imagePreviewUrl,
  }) {
    return EditPersonalDataState(
      state: state ?? this.state,
      profile: profile ?? this.profile,
      currentData: currentData ?? this.currentData,
      imageFile: imageFile ?? this.imageFile,
      videoFile: videoFile ?? this.videoFile,
      errorMessage: errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
      videoPreviewUrl: videoPreviewUrl ?? this.videoPreviewUrl,
      imagePreviewUrl: imagePreviewUrl ?? this.imagePreviewUrl,
    );
  }

  bool get hasChanges {
    if (profile == null) return false;

    // تحقق من التغييرات في الحقول النصية
    final currentTextChanged =
        (currentData.name != null && currentData.name != profile!.name) ||
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
    isSaving,
    videoPreviewUrl,
    imagePreviewUrl,
  ];
}
