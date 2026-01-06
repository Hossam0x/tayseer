import 'dart:io';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_state.dart';
import 'package:tayseer/features/advisor/add_post/repo/posts_repository.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart' as di;
import 'package:tayseer/my_import.dart';

class AddPostCubit extends Cubit<AddPostState> {
  AddPostCubit({PostsRepository? repository})
    : _repo = repository ?? di.getIt<PostsRepository>(),
      super(const AddPostState());

  final PostsRepository _repo;
  final contentController = TextEditingController();

  /// Create post using repository (uses current state for content/media)
  Future<void> createPost({
    required String categoryId,
    required String postType,
  }) async {
    emit(state.copyWith(addPostState: CubitStates.loading));

    final images = state.selectedImages;
    final videos = state.selectedVideos.isNotEmpty
        ? state.selectedVideos.first
        : null;

    final response = await _repo.createPost(
      content: contentController.text,
      categoryId: categoryId,
      postType: postType,
      images: images.isEmpty ? null : images,
      videos: videos,
    );

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            addPostState: CubitStates.failure,
            errorMessage: failure.message,
            loading: false,
          ),
        );
      },
      (_) {
        // success - clear draft and selections
        emit(
          state.copyWith(
            addPostState: CubitStates.success,
            loading: false,
            selectedImages: [],
            selectedVideos: [],
            capturedImages: [],
            selectedGifs: [],
            draftText: '',
          ),
        );
        contentController.clear();
      },
    );
  }

  /// Get All category

  Future<void> getALLCategory() async {
    emit(state.copyWith(categoryState: CubitStates.loading));

    final response = await _repo.getALLCategory();

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            categoryState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (categories) {
        emit(
          state.copyWith(
            categoryState: CubitStates.success,
            categories: categories,
          ),
        );
      },
    );
  }

  /// Load a list of GIFs (sample URLs). In a real app this could call Giphy API.
  Future<void> loadGifs() async {
    // sample GIF URLs
    final gifs = <String>[
      'https://media.giphy.com/media/3oEjI6SIIHBdRxXI40/giphy.gif',
      'https://media.giphy.com/media/l0HlQ7LRal9b0v2pu/giphy.gif',
      'https://media.giphy.com/media/1xVf3Yy8z2n0Q/giphy.gif',
      'https://media.giphy.com/media/xT0xeJpnrWC4XWblEk/giphy.gif',
      'https://media.giphy.com/media/5xaOcLGvzHxDKjufnLW/giphy.gif',
    ];

    emit(state.copyWith(availableGifs: gifs));
  }

  /// تحميل صور الجهاز (مرة واحدة)
  Future<void> loadGallery() async {
    emit(state.copyWith(loading: true));

    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) {
      debugPrint('❌ Permission denied!');
      emit(state.copyWith(loading: false));
      return;
    }
    debugPrint('✅ Permission granted');

    // provide ordering to avoid malformed SQL (empty ORDER BY)
    final filter = FilterOptionGroup(
      imageOption: FilterOption(),
      orders: [OrderOption(type: OrderOptionType.createDate, asc: false)],
    );

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: false,
      filterOption: filter,
    );
    debugPrint('📁 Found ${albums.length} albums');

    if (albums.isEmpty) {
      debugPrint('⚠️ No albums found!');
      emit(
        state.copyWith(galleryImages: [], galleryAlbums: [], loading: false),
      );
      return;
    }

    // find the "All" album if present, otherwise use the first album
    final allAlbum = albums.firstWhere(
      (a) => a.isAll, // AssetPathEntity.isAll indicates combined album
      orElse: () => albums.first,
    );

    List<AssetEntity> images = [];
    try {
      images = await allAlbum.getAssetListPaged(page: 0, size: 200);
      debugPrint('📸 Loaded ${images.length} images from ${allAlbum.name}');
    } catch (e) {
      debugPrint('getAssetListPaged failed for images: $e');
      try {
        images = await allAlbum.getAssetListRange(start: 0, end: 200);
        debugPrint('📸 Fallback: Loaded ${images.length} images');
      } catch (e2) {
        debugPrint('getAssetListRange fallback failed for images: $e2');
        images = [];
      }
    }

    // also load videos
    final videoAlbums = await PhotoManager.getAssetPathList(
      type: RequestType.video,
      onlyAll: false,
      filterOption: filter,
    );

    List<AssetEntity> videos = [];
    if (videoAlbums.isNotEmpty) {
      final allVideoAlbum = videoAlbums.firstWhere(
        (a) => a.isAll,
        orElse: () => videoAlbums.first,
      );
      try {
        videos = await allVideoAlbum.getAssetListPaged(page: 0, size: 200);
      } catch (e) {
        debugPrint('getAssetListPaged failed for videos: $e');
        try {
          videos = await allVideoAlbum.getAssetListRange(start: 0, end: 200);
        } catch (e2) {
          debugPrint('getAssetListRange fallback failed for videos: $e2');
          videos = [];
        }
      }
    }

    emit(
      state.copyWith(
        galleryImages: images,
        galleryAlbums: albums,
        galleryVideos: videos,
        galleryVideoAlbums: videoAlbums,
        loading: false,
      ),
    );
    debugPrint(
      '✅ Gallery loaded: ${images.length} images, ${videos.length} videos',
    );
  }

  /// اختيار / إلغاء اختيار صورة من الـ BottomSheet
  void toggleImage(AssetEntity image) {
    final selected = List<AssetEntity>.from(state.selectedImages);

    if (selected.contains(image)) {
      selected.remove(image);
    } else {
      selected.add(image);
    }

    emit(state.copyWith(selectedImages: selected));
  }

  /// حذف صورة من اللي تحت الـ TextField
  void removeSelected(AssetEntity image) {
    final selected = List<AssetEntity>.from(state.selectedImages);
    selected.remove(image);
    emit(state.copyWith(selectedImages: selected));
  }

  /// 🔥 حذف صورة ملتقطة من الكاميرا
  void removeCapturedImage(File file) {
    final captured = List<File>.from(state.capturedImages);
    captured.remove(file);
    emit(state.copyWith(capturedImages: captured));
  }

  /// Update the draft text from the UI
  void updateText(String text) {
    emit(state.copyWith(draftText: text));
  }

  /// Commit a list of images selected in the bottom sheet into the main selected images
  void commitSelectedImages(List<AssetEntity> images) {
    final selected = List<AssetEntity>.from(state.selectedImages);
    for (final img in images) {
      if (!selected.contains(img)) selected.add(img);
    }
    emit(state.copyWith(selectedImages: selected));
  }

  /// Commit selected GIF URLs from the bottom sheet into state
  void commitSelectedGifs(List<String> gifs) {
    final selected = List<String>.from(state.selectedGifs);
    for (final g in gifs) {
      if (!selected.contains(g)) selected.add(g);
    }
    emit(state.copyWith(selectedGifs: selected));
  }

  /// Commit a list of video AssetEntity selected in bottom sheet
  void commitSelectedVideos(List<AssetEntity> videos) {
    final selected = List<AssetEntity>.from(state.selectedVideos);
    for (final v in videos) {
      if (!selected.contains(v)) selected.add(v);
    }
    emit(state.copyWith(selectedVideos: selected));
  }

  /// Remove a selected video from draft
  void removeSelectedVideo(AssetEntity video) {
    final selected = List<AssetEntity>.from(state.selectedVideos);
    selected.remove(video);
    emit(state.copyWith(selectedVideos: selected));
  }

  /// Remove a selected GIF from the draft
  void removeSelectedGif(String gifUrl) {
    final selected = List<String>.from(state.selectedGifs);
    selected.remove(gifUrl);
    emit(state.copyWith(selectedGifs: selected));
  }

  /// Set the selected category id from UI
  void setSelectedCategoryId(String id) {
    emit(state.copyWith(selectedCategoryId: id));
  }

  /// 🔥 إضافة صورة ملتقطة من الكاميرا مباشرة بدون حفظها في الجاليري
  Future<void> addCapturedImage(File file) async {
    try {
      final captured = List<File>.from(state.capturedImages);
      captured.add(file);
      emit(state.copyWith(capturedImages: captured));
    } catch (e) {
      debugPrint('addCapturedImage error: $e');
    }
  }
}
