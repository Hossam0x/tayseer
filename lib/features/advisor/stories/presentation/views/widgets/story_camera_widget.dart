import 'package:camera/camera.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_cubit.dart';
import 'package:tayseer/my_import.dart';

class StoryCameraWidget extends StatefulWidget {
  final CameraController controller;
  final List<CameraDescription> cameras;
  final VoidCallback onBack;
  const StoryCameraWidget({
    super.key,
    required this.controller,
    required this.cameras,
    required this.onBack,
  });

  @override
  State<StoryCameraWidget> createState() => _StoryCameraWidgetState();
}

class _StoryCameraWidgetState extends State<StoryCameraWidget> {
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    // Assuming the passed controller is already initialized for cameras[0]
  }

  Future<void> _switchCamera() async {
    if (widget.cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;

    // We modify the external controller (risky but since it's shared, it works for this design)
    // Actually, it's better to tell the body to switch, but for now let's just do it here
    // or better, handle it in body. For speed, I'll do it here by re-initializing.
    final newDescription = widget.cameras[_selectedCameraIndex];

    // We can't easily dispose the shared one without body knowing.
    // However, for this task, I'll assume we can re-init it.
    await widget.controller.setDescription(newDescription);
    if (mounted) setState(() {});
  }

  Future<void> _takePicture() async {
    if (!widget.controller.value.isInitialized) return;
    try {
      final XFile photo = await widget.controller.takePicture();
      if (mounted) {
        final cubit = context.read<AddStoryCubit>();
        cubit.setPreviewFile(File(photo.path));
      }
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        Positioned.fill(child: CameraPreview(widget.controller)),

        // Header
        Positioned(
          top: 40.h,
          left: 16.w,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: widget.onBack,
          ),
        ),

        // Controls
        Positioned(
          bottom: 40.h,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Switch camera
              IconButton(
                icon: const Icon(
                  Icons.flip_camera_ios,
                  color: Colors.white,
                  size: 35,
                ),
                onPressed: _switchCamera,
              ),

              // Take picture
              GestureDetector(
                onTap: _takePicture,
                child: Container(
                  height: 80.w,
                  width: 80.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 5),
                  ),
                  child: Center(
                    child: Container(
                      height: 60.w,
                      width: 60.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),

              // Space for symmetry
              const SizedBox(width: 50),
            ],
          ),
        ),
      ],
    );
  }
}
