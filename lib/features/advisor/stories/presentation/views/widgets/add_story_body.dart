import 'package:camera/camera.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
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
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
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
          context.pop(); // Dismiss loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              isSuccess: true,
              text: 'تم نشر القصة بنجاح',
            ),
          );
          getIt<StoriesCubit>().fetchStories();
          context.pop(); // Go back to profile
        } else if (state.addStoryState == CubitStates.failure) {
          context.pop(); // Dismiss loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              isSuccess: false,
              text: state.errorMessage ?? 'فشل نشر القصة',
            ),
          );
        }
      },
      builder: (context, state) {
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
        onClose: () {
          context.read<AddStoryCubit>().resetSelection();
          setState(() {
            _isCameraActive = false; // Ensure we go back to grid
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
            : DropdownButtonHideUnderline(
                child: DropdownButton<AssetPathEntity>(
                  value: state.selectedAlbum,
                  items: state.albums.map((album) {
                    return DropdownMenuItem(
                      value: album,
                      child: Text(
                        album.name,
                        style: Styles.textStyle18SemiBold,
                      ),
                    );
                  }).toList(),
                  onChanged: (album) {
                    if (album != null) {
                      context.read<AddStoryCubit>().changeAlbum(album);
                    }
                  },
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black,
                  ),
                ),
              ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: StoriesGalleryGrid(
        controller: _cameraController,
        isInitialized: _isCameraInitialized,
        onCameraTap: () {
          setState(() {
            _isCameraActive = true;
          });
        },
      ),
    );
  }
}
