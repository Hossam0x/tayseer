import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:tayseer/features/advisor/stories/data/repository/stories_repository.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_state.dart';
import 'package:tayseer/my_import.dart';

class AddStoryCubit extends Cubit<AddStoryState> {
  final StoriesRepository storiesRepository;
  final contentController = TextEditingController();

  AddStoryCubit(this.storiesRepository) : super(const AddStoryState()) {
    _initPermissions();
  }

  Future<void> _initPermissions() async {
    await requestGalleryPermission();
    await checkAndRequestCamera();
  }

  Future<bool> checkAndRequestCamera() async {
    final Map<Permission, PermissionStatus> camMicResults = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final bool isCamGranted =
        camMicResults[Permission.camera]?.isGranted ?? false;
    final bool isMicGranted =
        camMicResults[Permission.microphone]?.isGranted ?? false;

    final cameraGranted = isCamGranted && isMicGranted;
    if (!isClosed) emit(state.copyWith(isCameraGranted: cameraGranted));
    return cameraGranted;
  }

  Future<void> requestGalleryPermission() async {
    if (isClosed) return;
    emit(state.copyWith(isLoadingAssets: true));
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (isClosed) return;
      final bool isGalleryGranted = ps.isAuth || ps.hasAccess;
      emit(state.copyWith(isGalleryGranted: isGalleryGranted));

      if (isGalleryGranted) {
        await loadGalleryAssets(refresh: true);
      } else {
        if (!isClosed) emit(state.copyWith(isLoadingAssets: false));
      }
    } catch (e) {
      debugPrint("Error in gallery permission request: $e");
      if (!isClosed) {
        emit(state.copyWith(isLoadingAssets: false, isGalleryGranted: false));
      }
    }
  }

  final int _pageSize = 60;

  Future<void> loadGalleryAssets({bool refresh = false}) async {
    if (isClosed) return;
    if (state.isLoadingAssets && !refresh) return;
    if (!refresh && !state.hasMoreAssets) return;

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
      // Request permissions using PhotoManager natively (fallback check)
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (isClosed) return;
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

        if (isClosed) return;

        if (albums.isEmpty) {
          albums = await PhotoManager.getAssetPathList(
            type: RequestType.image,
            filterOption: filterOption,
          );
        }

        if (isClosed) return;

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

        if (isClosed) return;

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
      if (!isClosed) emit(state.copyWith(isLoadingAssets: false));
    }
  }

  void changeAlbum(AssetPathEntity album) {
    emit(state.copyWith(selectedAlbum: album));
    loadGalleryAssets(refresh: true);
  }

  void selectAsset(AssetEntity asset, BuildContext context) async {
    final file = await asset.file;
    if (file != null) {
      final isVideo = asset.type == AssetType.video;

      if (isVideo) {
        // Limit: 60 seconds
        if (asset.duration > 60) {
          if (!context.mounted) return;
          AppToast.error(context, context.tr('video_duration_limit_60s'));
          return;
        }

        // Limit: 50MB
        final size = await file.length();
        if (size > 50 * 1024 * 1024) {
          if (!context.mounted) return;
          AppToast.error(context, context.tr('video_size_limit_50mb'));
          return;
        }
      }

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
    emit(state.clearSelection());
  }

  void setPreviewFile(
    File file,
    BuildContext context, {
    bool isVideo = false,
    bool isFrontCamera = false,
  }) async {
    if (isVideo) {
      // Check file size limit (50MB)
      final size = await file.length();
      if (size > 50 * 1024 * 1024) {
        if (context.mounted) {
          AppToast.error(context, context.tr('video_size_limit_50mb'));
        }
        return;
      }

      // Check duration limit (60 seconds)
      try {
        final videoController = VideoPlayerController.file(file);
        await videoController.initialize();
        final durationSeconds = videoController.value.duration.inSeconds;
        await videoController.dispose();
        if (durationSeconds > 60) {
          if (context.mounted) {
            AppToast.error(context, context.tr('video_duration_limit_60s'));
          }
          return;
        }
      } catch (e) {
        debugPrint('Error checking video duration: $e');
        // Allow it through if we can't check duration
      }
    }

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

    double? videoDuration;
    if (videoFiles.isNotEmpty) {
      try {
        final controller = VideoPlayerController.file(
          File(videoFiles.first.path),
        );
        await controller.initialize();
        videoDuration = controller.value.duration.inMilliseconds / 1000.0;
        await controller.dispose();
      } catch (e) {
        debugPrint("Error getting video duration: $e");
      }
    }

    final result = await storiesRepository.createStories(
      content: contentController.text,
      images: imageFiles,
      videos: videoFiles,
      videoDuration: videoDuration,
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

    if (!isClosed) emit(state.copyWith(isAiLoading: true));
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

      if (isClosed) return;

      if (response.text != null) {
        contentController.text = response.text!;
        emit(state.copyWith(draftText: response.text!, isAiLoading: false));
      }
    } catch (e) {
      if (!isClosed) emit(state.copyWith(isAiLoading: false));
    }
  }
}
