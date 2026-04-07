import 'package:camera/camera.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/stories_gallery_grid.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/story_camera_widget.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/story_preview_view.dart';
import 'package:tayseer/my_import.dart';

class AddStoryBody extends StatefulWidget {
  const AddStoryBody({super.key});

  @override
  State<AddStoryBody> createState() => _AddStoryBodyState();
}

class _AddStoryBodyState extends State<AddStoryBody> {
  bool _isCameraActive = false;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    // Permissions are handled by Cubit. When granted, listener will trigger _initCamera.
    final state = context.read<AddStoryCubit>().state;
    if (state.isCameraGranted == true) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras[0],
          ResolutionPreset.high,
          enableAudio: true,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera in body: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddStoryCubit, AddStoryState>(
      listener: (context, state) {
        if (state.addStoryState == CubitStates.loading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const CustomloadingApp(),
          );
        } else if (state.addStoryState == CubitStates.success) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // 1. Dismiss loading dialog
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }

            // 2. Show success snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar(
                context,
                isSuccess: true,
                text: context.tr('story_published_success'),
              ),
            );

            // 3. Navigate back immediately
            final nav = Navigator.of(context);
            if (nav.canPop()) nav.pop();
          });
        } else if (state.addStoryState == CubitStates.failure) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context); // Dismiss loading dialog
            }
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar(
                context,
                isSuccess: false,
                text:
                    state.errorMessage ?? context.tr('failed_to_publish_story'),
              ),
            );
          });
        }

        // Trigger Camera initialization once permissions are granted
        if (state.isCameraGranted == true &&
            !_isCameraInitialized &&
            _cameraController == null) {
          _initCamera();
        }
      },
      builder: (context, state) {
        if (state.isLoadingAssets && state.galleryAssets.isEmpty) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CustomloadingApp()),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentMode(state),
        );
      },
    );
  }

  Widget _buildCurrentMode(AddStoryState state) {
    // 1. Preview Mode
    if (state.previewFile != null) {
      return StoryPreviewView(
        file: state.previewFile!,
        isVideo: state.isVideoPreview,
        isFrontCamera: state.isFrontCamera,
        onClose: () {
          context.read<AddStoryCubit>().resetSelection();
          setState(() {
            _isCameraActive = false;
          });
        },
      );
    }

    // 2. Camera Mode
    if (_isCameraActive && _isCameraInitialized && _cameraController != null) {
      return StoryCameraWidget(
        controller: _cameraController!,
        cameras: _cameras,
        onBack: () {
          setState(() {
            _isCameraActive = false;
          });
        },
      );
    }

    // 3. Grid Mode (Main)
    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.kWhiteColor,
        elevation: 0,
        centerTitle: true,
        title: state.albums.isEmpty
            ? Text(context.tr('new_story'), style: Styles.textStyle18SemiBold)
            : Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.kGreyB3.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AssetPathEntity>(
                    value: state.selectedAlbum,
                    borderRadius: BorderRadius.circular(16.r),
                    dropdownColor: Colors.white,
                    elevation: 3,
                    isDense: true,
                    icon: Padding(
                      padding: EdgeInsetsDirectional.only(start: 6.w),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.kprimaryColor,
                        size: 22.sp,
                      ),
                    ),
                    items: state.albums.map((album) {
                      return DropdownMenuItem(
                        value: album,
                        child: Text(
                          album.name,
                          style: Styles.textStyle16SemiBold.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (album) {
                      if (album != null) {
                        context.read<AddStoryCubit>().changeAlbum(album);
                      }
                    },
                  ),
                ),
              ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black, size: 25.h),
          onPressed: () => context.pop(),
        ),
      ),
      body: StoriesGalleryGrid(
        controller: _cameraController,
        isInitialized: _isCameraInitialized,
        onCameraTap: () async {
          final isGranted = await context
              .read<AddStoryCubit>()
              .checkAndRequestCamera();
          if (isGranted) {
            setState(() {
              _isCameraActive = true;
            });
          }
        },
      ),
    );
  }
}
