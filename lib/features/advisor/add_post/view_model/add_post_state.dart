import 'dart:io';
import 'package:tayseer/features/advisor/add_post/model/category_model.dart';
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
  final List<AssetEntity> selectedVideos;
  final List<String> availableGifs;
  final List<String> selectedGifs;
  final bool loading;
  final String draftText;
  final String? selectedCategoryId;
  final String? errorMessage;

  const AddPostState({
    this.addPostState = CubitStates.initial,
    this.categoryState = CubitStates.initial,
    this.galleryImages = const [],
    this.galleryAlbums = const [],
    this.selectedImages = const [],
    this.capturedImages = const [], // 🔥
    this.availableGifs = const [],
    this.selectedGifs = const [],
    this.galleryVideos = const [],
    this.galleryVideoAlbums = const [],
    this.selectedVideos = const [],
    this.loading = false,
    this.draftText = '',
    this.errorMessage,
    this.selectedCategoryId,
    this.categories = const [],
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
    List<String>? availableGifs,
    List<String>? selectedGifs,
    List<AssetEntity>? galleryVideos,
    List<AssetEntity>? selectedVideos,
    bool? loading,
    String? draftText,
    String? errorMessage,
    String? selectedCategoryId,
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
      availableGifs: availableGifs ?? this.availableGifs,
      selectedGifs: selectedGifs ?? this.selectedGifs,
      galleryVideos: galleryVideos ?? this.galleryVideos,
      selectedVideos: selectedVideos ?? this.selectedVideos,
      loading: loading ?? this.loading,
      draftText: draftText ?? this.draftText,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }
}
