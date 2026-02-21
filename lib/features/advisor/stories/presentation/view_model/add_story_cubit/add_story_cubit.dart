import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:tayseer/features/advisor/stories/data/repository/stories_repository.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_state.dart';
import 'package:tayseer/my_import.dart';

class AddStoryCubit extends Cubit<AddStoryState> {
  final StoriesRepository storiesRepository;
  final contentController = TextEditingController();

  AddStoryCubit(this.storiesRepository) : super(const AddStoryState()) {
    loadGalleryAssets();
  }

  final int _pageSize = 60;

  Future<void> loadGalleryAssets({bool refresh = false}) async {
    if (state.isLoadingAssets || (!refresh && !state.hasMoreAssets)) return;

    if (refresh) {
      emit(
        state.copyWith(
          isLoadingAssets: true,
          galleryAssets: [],
          currentAssetsPage: 0,
          hasMoreAssets: true,
        ),
      );
    } else {
      emit(state.copyWith(isLoadingAssets: true));
    }

    try {
      // Request permissions using PhotoManager natively
      await PhotoManager.clearFileCache();
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth && !ps.hasAccess) {
        emit(state.copyWith(isLoadingAssets: false, hasMoreAssets: false));
        return;
      }

      // 2. Load albums if not already loaded
      if (state.albums.isEmpty) {
        final FilterOptionGroup filterOption = FilterOptionGroup(
          orders: [
            const OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        );

        // Try common first, then fallback to image if empty
        List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
          type: RequestType.common,
          filterOption: filterOption,
        );

        if (albums.isEmpty) {
          albums = await PhotoManager.getAssetPathList(
            type: RequestType.image,
            filterOption: filterOption,
          );
        }

        if (albums.isNotEmpty) {
          emit(state.copyWith(albums: albums, selectedAlbum: albums[0]));
        } else {
          emit(state.copyWith(isLoadingAssets: false, hasMoreAssets: false));
          return;
        }
      }

      // 3. Load assets from selected album
      final album = state.selectedAlbum;
      if (album != null) {
        final newItems = await album.getAssetListPaged(
          page: state.currentAssetsPage,
          size: _pageSize,
        );

        if (newItems.isEmpty) {
          emit(state.copyWith(isLoadingAssets: false, hasMoreAssets: false));
        } else {
          final updatedAssets = List<AssetEntity>.from(state.galleryAssets)
            ..addAll(newItems);
          emit(
            state.copyWith(
              galleryAssets: updatedAssets,
              currentAssetsPage: state.currentAssetsPage + 1,
              isLoadingAssets: false,
            ),
          );
        }
      } else {
        emit(state.copyWith(isLoadingAssets: false, hasMoreAssets: false));
      }
    } catch (e) {
      debugPrint("Error loading gallery: $e");
      emit(state.copyWith(isLoadingAssets: false));
    }
  }

  void changeAlbum(AssetPathEntity album) {
    emit(state.copyWith(selectedAlbum: album));
    loadGalleryAssets(refresh: true);
  }

  void selectAsset(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null) {
      // Check if it's a video
      final isVideo = asset.type == AssetType.video;
      emit(
        state.copyWith(
          selectedAsset: asset,
          previewFile: file,
          isVideoPreview: isVideo,
        ),
      );
    }
  }

  void resetSelection() {
    emit(
      state.copyWith(
        selectedAsset: null,
        previewFile: null,
        isVideoPreview: false,
        isFrontCamera: false,
      ),
    );
  }

  void setPreviewFile(
    File file, {
    bool isVideo = false,
    bool isFrontCamera = false,
  }) {
    emit(
      state.copyWith(
        previewFile: file,
        isVideoPreview: isVideo,
        isFrontCamera: isFrontCamera,
      ),
    );
  }

  Future<({List<File> images, List<XFile> videos})> getMediaToUpload() async {
    final List<File> imageFiles = [];
    final List<XFile> videoFiles = [];

    // Use previewFile if available (this covers both selected from gallery and captured)
    if (state.previewFile != null) {
      if (state.isVideoPreview) {
        // It's a video from camera or gallery
        videoFiles.add(XFile(state.previewFile!.path));
      } else {
        // It's an image
        imageFiles.add(state.previewFile!);
      }
    } else {
      // Fallback to old behavior if needed, but we aim for the new flow
      for (var asset in state.selectedImages) {
        final file = await asset.file;
        if (file != null) imageFiles.add(file);
      }
      imageFiles.addAll(state.capturedImages);

      if (state.capturedVideo != null) {
        videoFiles.add(state.capturedVideo!);
      }
      for (var video in state.selectedVideos) {
        videoFiles.add(video);
      }
    }

    return (images: imageFiles, videos: videoFiles);
  }

  Future<void> createStory() async {
    if (isClosed) return;
    emit(state.copyWith(addStoryState: CubitStates.loading));

    final List<File> imageFiles = [];
    final List<XFile> videoFiles = [];

    // Use previewFile if available (this covers both selected from gallery and captured)
    if (state.previewFile != null) {
      if (state.isVideoPreview) {
        // It's a video from camera or gallery
        videoFiles.add(XFile(state.previewFile!.path));
      } else {
        // It's an image
        imageFiles.add(state.previewFile!);
      }
    } else {
      // Fallback to old behavior if needed, but we aim for the new flow
      for (var asset in state.selectedImages) {
        final file = await asset.file;
        if (file != null) imageFiles.add(file);
      }
      imageFiles.addAll(state.capturedImages);

      if (state.capturedVideo != null) {
        videoFiles.add(state.capturedVideo!);
      }
      for (var video in state.selectedVideos) {
        videoFiles.add(video);
      }
    }

    final result = await storiesRepository.createStories(
      content: contentController.text,
      images: imageFiles,
      videos: videoFiles,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        if (!isClosed) {
          emit(
            state.copyWith(
              addStoryState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (_) {
        if (!isClosed) {
          emit(state.copyWith(addStoryState: CubitStates.success));
          contentController.clear();
          resetSelection();
        }
      },
    );
  }

  void updateText(String text) {
    emit(state.copyWith(draftText: text));
  }

  void addCapturedImage(File file) {
    final captured = List<File>.from(state.capturedImages)..add(file);
    emit(state.copyWith(capturedImages: captured));
  }

  void removeCapturedImage(File file) {
    final captured = List<File>.from(state.capturedImages)..remove(file);
    emit(state.copyWith(capturedImages: captured));
  }

  void addCapturedVideo(XFile file) {
    emit(state.copyWith(capturedVideo: file));
  }

  void removeCapturedVideo() {
    emit(state.copyWith(capturedVideo: null));
  }

  void removeSelectedImage(AssetEntity asset) {
    final selected = List<AssetEntity>.from(state.selectedImages)
      ..remove(asset);
    emit(state.copyWith(selectedImages: selected));
  }

  void addSelectedImages(List<AssetEntity> assets) {
    final selected = List<AssetEntity>.from(state.selectedImages)
      ..addAll(assets);
    emit(state.copyWith(selectedImages: selected));
  }

  void addSelectedVideos(List<XFile> videos) {
    final selected = List<XFile>.from(state.selectedVideos)..addAll(videos);
    emit(state.copyWith(selectedVideos: selected));
  }

  Future<void> enhanceTextWithGemini(BuildContext context) async {
    final currentText = contentController.text;
    if (currentText.trim().isEmpty) return;

    emit(state.copyWith(isAiLoading: true));
    const apiKey =
        'AIzaSyAzkpmYLG58vfNtxPGvfh8Ynix02VNWnUg'; // Keep it for now as per AddPostCubit

    try {
      final model = GenerativeModel(model: 'gemma-3-4b-it', apiKey: apiKey);
      final prompt =
          '''
You are a professional social media content creator.
Rewrite the text to be engaging and professional with emojis.
Return ONLY the rewritten text.
Input text: "$currentText"
''';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        contentController.text = response.text!;
        emit(state.copyWith(draftText: response.text!, isAiLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isAiLoading: false));
    }
  }
}
