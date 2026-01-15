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
  final bool shouldRemoveVideo; // إضافة flag
  final bool shouldRemoveImage; // إضافة flag

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
    this.shouldRemoveVideo = false,
    this.shouldRemoveImage = false,
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
    bool? shouldRemoveVideo,
    bool? shouldRemoveImage,
    bool clearImageFile = false,
    bool clearVideoFile = false,
    bool clearVideoPreviewUrl = false,
    bool clearImagePreviewUrl = false,
  }) {
    return EditPersonalDataState(
      state: state ?? this.state,
      profile: profile ?? this.profile,
      currentData: currentData ?? this.currentData,
      imageFile: clearImageFile ? null : (imageFile ?? this.imageFile),
      videoFile: clearVideoFile ? null : (videoFile ?? this.videoFile),
      errorMessage: errorMessage ?? this.errorMessage,
      isSaving: isSaving ?? this.isSaving,
      videoPreviewUrl: clearVideoPreviewUrl
          ? null
          : (videoPreviewUrl ?? this.videoPreviewUrl),
      imagePreviewUrl: clearImagePreviewUrl
          ? null
          : (imagePreviewUrl ?? this.imagePreviewUrl),
      shouldRemoveVideo: shouldRemoveVideo ?? this.shouldRemoveVideo,
      shouldRemoveImage: shouldRemoveImage ?? this.shouldRemoveImage,
    );
  }

  bool get hasChanges {
    if (profile == null) return false;

    final request = profile!.toRequest();

    // تحقق من وجود تغييرات في الحقول النصية
    bool textChanged =
        (request.name ?? '') != (currentData.name ?? '') ||
        (request.dateOfBirth ?? '') != (currentData.dateOfBirth ?? '') ||
        (request.gender ?? '') != (currentData.gender ?? '') ||
        (request.professionalSpecialization ?? '') !=
            (currentData.professionalSpecialization ?? '') ||
        (request.jobGrade ?? '') != (currentData.jobGrade ?? '') ||
        (request.yearsOfExperience ?? '') !=
            (currentData.yearsOfExperience ?? '') ||
        (request.aboutYou ?? '') != (currentData.aboutYou ?? '');

    // تحقق من وجود ملفات جديدة
    bool filesChanged = imageFile != null || videoFile != null;

    // تحقق من حذف الفيديو أو الصورة
    bool mediaRemoved = shouldRemoveVideo || shouldRemoveImage;

    return textChanged || filesChanged || mediaRemoved;
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
    shouldRemoveVideo,
    shouldRemoveImage,
  ];
}
