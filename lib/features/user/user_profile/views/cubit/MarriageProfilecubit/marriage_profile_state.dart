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
  final bool hasUnsavedFields;

  // ── Pending uploads ──────────────────────────────────────────
  final File? pendingSingleImage;
  final List<File> pendingImages;
  final File? pendingVideo;
  final File? pendingAudio;

  // ── Pending deletes (UI يختفي فوراً، API call عند Save فقط) ──
  final bool pendingDeleteSingleImage;
  final String? deletedSingleImageUrl; // الـ URL الأصلي عشان نقدر نـ undo

  final List<String> deletedImageUrls; // secondary images محذوفة
  final Map<String, String>
  deletedImagesOriginalData; // url → original (للـ undo)

  final bool pendingDeleteVideo;
  final String? deletedVideoUrl; // للـ undo + للـ API call في Save

  final bool pendingDeleteAudio;
  final String? deletedAudioUrl; // للـ undo + للـ API call في Save

  const MarriageProfileState({
    this.state = CubitStates.initial,
    this.profile,
    this.errorMessage,
    this.successMessage,
    this.isLoading = false,
    this.isUpdating = false,
    this.savedFromButton = false,
    this.hasUnsavedFields = false,
    this.pendingSingleImage,
    this.pendingImages = const [],
    this.pendingVideo,
    this.pendingAudio,
    this.pendingDeleteSingleImage = false,
    this.deletedSingleImageUrl,
    this.deletedImageUrls = const [],
    this.deletedImagesOriginalData = const {},
    this.pendingDeleteVideo = false,
    this.deletedVideoUrl,
    this.pendingDeleteAudio = false,
    this.deletedAudioUrl,
  });

  // ── Getters ───────────────────────────────────────────────────
  bool get hasPendingSingleImage => pendingSingleImage != null;
  bool get hasPendingVideo => pendingVideo != null;
  bool get hasPendingAudio => pendingAudio != null;
  bool get hasAnyPendingMedia =>
      hasPendingSingleImage ||
      pendingImages.isNotEmpty ||
      hasPendingVideo ||
      hasPendingAudio ||
      pendingDeleteSingleImage ||
      deletedImageUrls.isNotEmpty ||
      pendingDeleteVideo ||
      pendingDeleteAudio;

  MarriageProfileState copyWith({
    CubitStates? state,
    MarriageUserProfileModel? profile,
    String? errorMessage,
    String? successMessage,
    bool? isLoading,
    bool? isUpdating,
    bool? savedFromButton,
    bool? hasUnsavedFields,
    File? pendingSingleImage,
    List<File>? pendingImages,
    File? pendingVideo,
    File? pendingAudio,
    bool? pendingDeleteSingleImage,
    String? deletedSingleImageUrl,
    List<String>? deletedImageUrls,
    Map<String, String>? deletedImagesOriginalData,
    bool? pendingDeleteVideo,
    String? deletedVideoUrl,
    bool? pendingDeleteAudio,
    String? deletedAudioUrl,
    // ── clear flags ──
    bool clearMessages = false,
    bool clearPendingSingleImage = false,
    bool clearPendingVideo = false,
    bool clearPendingAudio = false,
    bool clearAllPending = false,
    bool clearDeletedSingleImageUrl = false,
  }) {
    return MarriageProfileState(
      state: state ?? this.state,
      profile: profile ?? this.profile,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages
          ? null
          : (successMessage ?? this.successMessage),
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      savedFromButton: savedFromButton ?? this.savedFromButton,
      hasUnsavedFields: hasUnsavedFields ?? this.hasUnsavedFields,

      // uploads
      pendingSingleImage: clearAllPending || clearPendingSingleImage
          ? null
          : (pendingSingleImage ?? this.pendingSingleImage),
      pendingImages: clearAllPending
          ? []
          : (pendingImages ?? this.pendingImages),
      pendingVideo: clearAllPending || clearPendingVideo
          ? null
          : (pendingVideo ?? this.pendingVideo),
      pendingAudio: clearAllPending || clearPendingAudio
          ? null
          : (pendingAudio ?? this.pendingAudio),

      // single image delete
      pendingDeleteSingleImage: clearAllPending
          ? false
          : (pendingDeleteSingleImage ?? this.pendingDeleteSingleImage),
      deletedSingleImageUrl: (clearAllPending || clearDeletedSingleImageUrl)
          ? null
          : (deletedSingleImageUrl ?? this.deletedSingleImageUrl),

      // secondary images delete
      deletedImageUrls: clearAllPending
          ? []
          : (deletedImageUrls ?? this.deletedImageUrls),
      deletedImagesOriginalData: clearAllPending
          ? {}
          : (deletedImagesOriginalData ?? this.deletedImagesOriginalData),

      // video delete
      pendingDeleteVideo: clearAllPending
          ? false
          : (pendingDeleteVideo ?? this.pendingDeleteVideo),
      deletedVideoUrl: clearAllPending
          ? null
          : (deletedVideoUrl ?? this.deletedVideoUrl),

      // audio delete
      pendingDeleteAudio: clearAllPending
          ? false
          : (pendingDeleteAudio ?? this.pendingDeleteAudio),
      deletedAudioUrl: clearAllPending
          ? null
          : (deletedAudioUrl ?? this.deletedAudioUrl),
    );
  }

  MarriageProfileState clearDeletedImageUrls() =>
      copyWith(deletedImageUrls: [], deletedImagesOriginalData: {});

  @override
  List<Object?> get props => [
    state,
    profile,
    errorMessage,
    successMessage,
    isLoading,
    isUpdating,
    savedFromButton,
    hasUnsavedFields,
    pendingSingleImage,
    pendingImages,
    pendingVideo,
    pendingAudio,
    pendingDeleteSingleImage,
    deletedSingleImageUrl,
    deletedImageUrls,
    deletedImagesOriginalData,
    pendingDeleteVideo,
    deletedVideoUrl,
    pendingDeleteAudio,
    deletedAudioUrl,
  ];
}
