import 'package:tayseer/core/models/category_model.dart';
import 'package:tayseer/my_import.dart';

class AddPostState {
  final CubitStates addPostState;
  final CubitStates categoryState;
  final List<CategoryModel> categories;
  final List<AssetEntity> galleryImages;
  final List<AssetPathEntity> galleryAlbums;
  final List<AssetPathEntity> galleryVideoAlbums;
  final List<AssetEntity> galleryVideos;
  final List<AssetEntity> selectedImages;
  final List<File> capturedImages;
  final XFile? capturedVideo;
  final List<AssetEntity> selectedVideos;
  final List<String> availableGifs;
  final bool loading;
  final String draftText;
  final String? selectedCategoryId;
  final String? errorMessage;
  final bool isAiLoading;

  const AddPostState({
    this.addPostState = CubitStates.initial,
    this.categoryState = CubitStates.initial,
    this.galleryImages = const [],
    this.galleryAlbums = const [],
    this.selectedImages = const [],
    this.capturedImages = const [], // 🔥
    this.capturedVideo,
    this.availableGifs = const [],
    this.galleryVideos = const [],
    this.galleryVideoAlbums = const [],
    this.selectedVideos = const [],
    this.loading = false,
    this.draftText = '',
    this.errorMessage,
    this.selectedCategoryId,
    this.categories = const [],
    this.isAiLoading = false,
  });

  AddPostState copyWith({
    CubitStates? addPostState,
    CubitStates? categoryState,
    List<CategoryModel>? categories,
    List<AssetEntity>? galleryImages,
    List<AssetPathEntity>? galleryAlbums,
    List<AssetPathEntity>? galleryVideoAlbums,
    List<AssetEntity>? selectedImages,
    List<File>? capturedImages, // 🔥
    Object? capturedVideo = _capturedVideoSentinel,

    bool? loading,
    String? draftText,
    String? errorMessage,
    String? selectedCategoryId,
    bool? isAiLoading,
  }) {
    return AddPostState(
      addPostState: addPostState ?? this.addPostState,
      categoryState: categoryState ?? this.categoryState,
      categories: categories ?? this.categories,
      galleryImages: galleryImages ?? this.galleryImages,
      galleryAlbums: galleryAlbums ?? this.galleryAlbums,
      galleryVideoAlbums: galleryVideoAlbums ?? this.galleryVideoAlbums,
      selectedImages: selectedImages ?? this.selectedImages,
      capturedImages: capturedImages ?? this.capturedImages, // 🔥
      capturedVideo: identical(capturedVideo, _capturedVideoSentinel)
          ? this.capturedVideo
          : (capturedVideo as XFile?),

      loading: loading ?? this.loading,
      draftText: draftText ?? this.draftText,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      errorMessage: errorMessage,
    );
  }
}

const _capturedVideoSentinel = Object();
