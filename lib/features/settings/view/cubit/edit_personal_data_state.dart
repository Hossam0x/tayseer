import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/settings/data/models/edit_personal_data_models.dart';

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
    return EditPersonalDataState(currentData: UpdatePersonalDataRequest());
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

    final request = profile!.toRequest();
    return request.name != currentData.name ||
        request.dateOfBirth != currentData.dateOfBirth ||
        request.gender != currentData.gender ||
        request.professionalSpecialization !=
            currentData.professionalSpecialization ||
        request.jobGrade != currentData.jobGrade ||
        request.yearsOfExperience != currentData.yearsOfExperience ||
        request.aboutYou != currentData.aboutYou ||
        imageFile != null ||
        videoFile != null;
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
