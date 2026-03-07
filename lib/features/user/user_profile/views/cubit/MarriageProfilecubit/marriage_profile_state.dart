import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';

class MarriageProfileState extends Equatable {
  final CubitStates state;
  final MarriageUserProfileModel? profile;
  final String? errorMessage;
  final String? successMessage;
  final bool isLoading;
  final bool isUpdating;
final bool savedFromButton;
  // ⭐ Pending Media (local files, not uploaded yet)
  final File? pendingSingleImage;
  final List<File> pendingImages;
  final File? pendingVideo;
  final File? pendingAudio;
  final bool hasUnsavedFields;

  // ⭐ Deleted Media (URLs to delete on save)
  final String? deletedSingleImageUrl;
  final List<String> deletedImageUrls;
  final bool pendingDeleteVideo;
  final bool pendingDeleteAudio;

  const MarriageProfileState({
    this.state = CubitStates.initial,
    this.hasUnsavedFields = false,
    this.profile,
    this.errorMessage,
    this.successMessage,
    this.isLoading = false,
    this.isUpdating = false,
    this.pendingSingleImage,
    this.pendingImages = const [],
    this.pendingVideo,
    this.pendingAudio,
    this.deletedSingleImageUrl,
    this.deletedImageUrls = const [],
    this.pendingDeleteVideo = false,
    this.pendingDeleteAudio = false,
    this.savedFromButton = false,
  });


  // ⭐ Helper getters
  bool get hasPendingSingleImage => pendingSingleImage != null;
  bool get hasPendingVideo => pendingVideo != null;
  bool get hasPendingAudio => pendingAudio != null;
  bool get hasAnyPendingMedia =>
      hasPendingSingleImage ||
      pendingImages.isNotEmpty ||
      hasPendingVideo ||
      hasPendingAudio ||
      deletedSingleImageUrl != null ||
      deletedImageUrls.isNotEmpty ||
      pendingDeleteVideo ||
      pendingDeleteAudio;

  MarriageProfileState copyWith({
    CubitStates? state,
    MarriageUserProfileModel? profile,
    String? errorMessage,
    bool? hasUnsavedFields,
    String? successMessage,
    bool? isLoading,
    bool? isUpdating,
    File? pendingSingleImage,
    List<File>? pendingImages,
    File? pendingVideo,
    File? pendingAudio,
    String? deletedSingleImageUrl,
    List<String>? deletedImageUrls,
    bool? pendingDeleteVideo,
    bool? pendingDeleteAudio,
    bool clearMessages = false,
    bool clearPendingSingleImage = false,
    bool clearPendingVideo = false,
    bool clearPendingAudio = false,
    bool clearAllPending = false,
    bool? savedFromButton,
  }) {
    return MarriageProfileState(
      state: state ?? this.state,
      profile: profile ?? this.profile,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      hasUnsavedFields: hasUnsavedFields ?? this.hasUnsavedFields,
      savedFromButton: savedFromButton ?? this.savedFromButton, 
      // ⭐ Pending Media
      pendingSingleImage: clearAllPending || clearPendingSingleImage
          ? null
          : (pendingSingleImage ?? this.pendingSingleImage),
      pendingImages: clearAllPending ? [] : (pendingImages ?? this.pendingImages),
      pendingVideo: clearAllPending || clearPendingVideo
          ? null
          : (pendingVideo ?? this.pendingVideo),
      pendingAudio: clearAllPending || clearPendingAudio
          ? null
          : (pendingAudio ?? this.pendingAudio),

      // ⭐ Deleted Media
      deletedSingleImageUrl: clearAllPending
          ? null
          : (deletedSingleImageUrl ?? this.deletedSingleImageUrl),
      deletedImageUrls:
          clearAllPending ? [] : (deletedImageUrls ?? this.deletedImageUrls),
      pendingDeleteVideo:
          clearAllPending ? false : (pendingDeleteVideo ?? this.pendingDeleteVideo),
      pendingDeleteAudio:
          clearAllPending ? false : (pendingDeleteAudio ?? this.pendingDeleteAudio),
    );
  }

  @override
  List<Object?> get props => [
        state,
        profile,
        errorMessage,
        successMessage,
        isLoading,
        isUpdating,
        pendingSingleImage,
        pendingImages,
        pendingVideo,
        pendingAudio,
        deletedSingleImageUrl,
        deletedImageUrls,
        pendingDeleteVideo,
        pendingDeleteAudio,
        savedFromButton,
      ];
}