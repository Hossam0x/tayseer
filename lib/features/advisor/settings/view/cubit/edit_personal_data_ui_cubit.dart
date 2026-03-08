import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditPersonalDataUiState extends Equatable {
  final String? nameError;
  final String? usernameError;
  final bool isVideoLoading;
  final double uploadProgress;

  final String? selectedPosition;
  final String? selectedSpecialization;
  final String? selectedExperienceDisplay;
  final String? selectedExperienceValue;

  const EditPersonalDataUiState({
    this.nameError,
    this.usernameError,
    this.isVideoLoading = false,
    this.uploadProgress = 0.0,
    this.selectedPosition,
    this.selectedSpecialization,
    this.selectedExperienceDisplay,
    this.selectedExperienceValue,
  });

  EditPersonalDataUiState copyWith({
    String? nameError,
    String? usernameError,
    bool? isVideoLoading,
    double? uploadProgress,
    bool clearNameError = false,
    bool clearUsernameError = false,
    String? selectedPosition,
    String? selectedSpecialization,
    String? selectedExperienceDisplay,
    String? selectedExperienceValue,
  }) {
    return EditPersonalDataUiState(
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      usernameError: clearUsernameError
          ? null
          : (usernameError ?? this.usernameError),
      isVideoLoading: isVideoLoading ?? this.isVideoLoading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      selectedPosition: selectedPosition ?? this.selectedPosition,
      selectedSpecialization:
          selectedSpecialization ?? this.selectedSpecialization,
      selectedExperienceDisplay:
          selectedExperienceDisplay ?? this.selectedExperienceDisplay,
      selectedExperienceValue:
          selectedExperienceValue ?? this.selectedExperienceValue,
    );
  }

  @override
  List<Object?> get props => [
    nameError,
    usernameError,
    isVideoLoading,
    uploadProgress,
    selectedPosition,
    selectedSpecialization,
    selectedExperienceDisplay,
    selectedExperienceValue,
  ];
}

class EditPersonalDataUiCubit extends Cubit<EditPersonalDataUiState> {
  EditPersonalDataUiCubit() : super(const EditPersonalDataUiState());

  void validateName(String value, String errorMessage) {
    if (value.trim().length < 4 || value.trim().length > 24) {
      emit(state.copyWith(nameError: errorMessage));
    } else {
      emit(state.copyWith(clearNameError: true));
    }
  }

  void validateUsername(String value, String errorMessage) {
    final cleaned = value.startsWith('@') ? value.substring(1) : value;
    final trimmed = cleaned.trim();
    if (trimmed.length < 4 || trimmed.length > 24) {
      emit(state.copyWith(usernameError: errorMessage));
    } else {
      emit(state.copyWith(clearUsernameError: true));
    }
  }

  void setVideoLoading(bool loading) {
    emit(state.copyWith(isVideoLoading: loading));
  }

  void updateProgress(double progress) {
    emit(state.copyWith(uploadProgress: progress));
  }

  void updateSelectedPosition(String? value) {
    emit(state.copyWith(selectedPosition: value));
  }

  void updateSelectedSpecialization(String? value) {
    emit(state.copyWith(selectedSpecialization: value));
  }

  void updateSelectedExperience(String? display, String? value) {
    emit(
      state.copyWith(
        selectedExperienceDisplay: display,
        selectedExperienceValue: value,
      ),
    );
  }

  // To allow initialization from existing profile
  void initializeFields({
    String? position,
    String? specialization,
    String? experienceDisplay,
    String? experienceValue,
  }) {
    emit(
      state.copyWith(
        selectedPosition: position,
        selectedSpecialization: specialization,
        selectedExperienceDisplay: experienceDisplay,
        selectedExperienceValue: experienceValue,
      ),
    );
  }
}
