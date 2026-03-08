import 'package:equatable/equatable.dart';
import 'package:tayseer/my_import.dart';

class AddStoryState extends Equatable {
  final CubitStates addStoryState;
  final String? errorMessage;
  final List<AssetPathEntity> albums;
  final AssetPathEntity? selectedAlbum;
  final List<AssetEntity> galleryAssets;
  final bool isLoadingAssets;
  final bool hasMoreAssets;
  final int currentAssetsPage;
  final AssetEntity? selectedAsset;
  final File? previewFile;
  final bool isVideoPreview;
  final bool isFrontCamera;

  final List<AssetEntity> selectedImages;
  final List<File> capturedImages;
  final List<XFile> selectedVideos;
  final XFile? capturedVideo;
  final String draftText;
  final bool isAiLoading;
  final bool? permissionsGranted;

  const AddStoryState({
    this.albums = const [],
    this.selectedAlbum,
    this.galleryAssets = const [],
    this.isLoadingAssets = false,
    this.hasMoreAssets = true,
    this.currentAssetsPage = 0,
    this.selectedAsset,
    this.previewFile,
    this.isVideoPreview = false,
    this.isFrontCamera = false,
    this.addStoryState = CubitStates.initial,
    this.errorMessage,
    this.selectedImages = const [],
    this.capturedImages = const [],
    this.selectedVideos = const [],
    this.capturedVideo,
    this.draftText = '',
    this.isAiLoading = false,
    this.permissionsGranted,
  });

  AddStoryState copyWith({
    List<AssetPathEntity>? albums,
    AssetPathEntity? selectedAlbum,
    List<AssetEntity>? galleryAssets,
    bool? isLoadingAssets,
    bool? hasMoreAssets,
    int? currentAssetsPage,
    AssetEntity? selectedAsset,
    File? previewFile,
    bool? isVideoPreview,
    bool? isFrontCamera,
    CubitStates? addStoryState,
    String? errorMessage,
    List<AssetEntity>? selectedImages,
    List<File>? capturedImages,
    List<XFile>? selectedVideos,
    XFile? capturedVideo,
    String? draftText,
    bool? isAiLoading,
    bool? permissionsGranted,
  }) {
    return AddStoryState(
      albums: albums ?? this.albums,
      selectedAlbum: selectedAlbum ?? this.selectedAlbum,
      galleryAssets: galleryAssets ?? this.galleryAssets,
      isLoadingAssets: isLoadingAssets ?? this.isLoadingAssets,
      hasMoreAssets: hasMoreAssets ?? this.hasMoreAssets,
      currentAssetsPage: currentAssetsPage ?? this.currentAssetsPage,
      selectedAsset: selectedAsset ?? this.selectedAsset,
      previewFile: previewFile ?? this.previewFile,
      isVideoPreview: isVideoPreview ?? this.isVideoPreview,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      addStoryState: addStoryState ?? this.addStoryState,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedImages: selectedImages ?? this.selectedImages,
      capturedImages: capturedImages ?? this.capturedImages,
      selectedVideos: selectedVideos ?? this.selectedVideos,
      capturedVideo: capturedVideo ?? this.capturedVideo,
      draftText: draftText ?? this.draftText,
      isAiLoading: isAiLoading ?? this.isAiLoading,
      permissionsGranted: permissionsGranted ?? this.permissionsGranted,
    );
  }

  @override
  List<Object?> get props => [
    albums,
    selectedAlbum,
    galleryAssets,
    isLoadingAssets,
    hasMoreAssets,
    currentAssetsPage,
    selectedAsset,
    previewFile,
    isVideoPreview,
    isFrontCamera,
    addStoryState,
    errorMessage,
    selectedImages,
    capturedImages,
    selectedVideos,
    capturedVideo,
    draftText,
    isAiLoading,
    permissionsGranted,
  ];

  AddStoryState clearSelection() {
    return AddStoryState(
      albums: albums,
      selectedAlbum: selectedAlbum,
      galleryAssets: galleryAssets,
      isLoadingAssets: isLoadingAssets,
      hasMoreAssets: hasMoreAssets,
      currentAssetsPage: currentAssetsPage,
      addStoryState: addStoryState,
      errorMessage: errorMessage,
      selectedImages: selectedImages,
      capturedImages: capturedImages,
      selectedVideos: selectedVideos,
      capturedVideo: capturedVideo,
      draftText: draftText,
      isAiLoading: isAiLoading,
      selectedAsset: null,
      previewFile: null,
      isVideoPreview: false,
      isFrontCamera: false,
    );
  }
}
