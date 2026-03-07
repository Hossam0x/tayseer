import 'package:tayseer/core/enum/add_post_enum.dart';
import 'package:tayseer/core/models/category_model.dart';
import 'package:tayseer/my_import.dart';

class AddPostState {
  final CubitStates addPostState;
  final CubitStates categoryState;

  final List<CategoryModel> categories;

  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;

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
  final AddPostEnum resolvedPostType;

  const AddPostState({
    this.addPostState = CubitStates.initial,
    this.categoryState = CubitStates.initial,
    this.categories = const [],

    this.currentPage = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,

    this.galleryImages = const [],
    this.galleryAlbums = const [],
    this.selectedImages = const [],
    this.capturedImages = const [],
    this.capturedVideo,
    this.availableGifs = const [],
    this.galleryVideos = const [],
    this.galleryVideoAlbums = const [],
    this.selectedVideos = const [],
    this.loading = false,
    this.draftText = '',
    this.errorMessage,
    this.selectedCategoryId,
    this.isAiLoading = false,
    this.resolvedPostType = AddPostEnum.post,
  });

  AddPostState copyWith({
    CubitStates? addPostState,
    CubitStates? categoryState,
    List<CategoryModel>? categories,

    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,

    List<AssetEntity>? galleryImages,
    List<AssetPathEntity>? galleryAlbums,
    List<AssetPathEntity>? galleryVideoAlbums,
    List<AssetEntity>? selectedImages,
    List<File>? capturedImages,
    Object? capturedVideo = _capturedVideoSentinel,
    bool? loading,
    String? draftText,
    String? errorMessage,
    String? selectedCategoryId,
    bool? isAiLoading,
    AddPostEnum? resolvedPostType,
  }) {
    return AddPostState(
      addPostState: addPostState ?? this.addPostState,
      categoryState: categoryState ?? this.categoryState,
      categories: categories ?? this.categories,

      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,

      galleryImages: galleryImages ?? this.galleryImages,
      galleryAlbums: galleryAlbums ?? this.galleryAlbums,
      galleryVideoAlbums: galleryVideoAlbums ?? this.galleryVideoAlbums,
      selectedImages: selectedImages ?? this.selectedImages,
      capturedImages: capturedImages ?? this.capturedImages,
      capturedVideo: identical(capturedVideo, _capturedVideoSentinel)
          ? this.capturedVideo
          : (capturedVideo as XFile?),
      loading: loading ?? this.loading,
      draftText: draftText ?? this.draftText,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      errorMessage: errorMessage,
      isAiLoading: isAiLoading ?? this.isAiLoading,
      resolvedPostType: resolvedPostType ?? this.resolvedPostType,
    );
  }
}

const _capturedVideoSentinel = Object();
