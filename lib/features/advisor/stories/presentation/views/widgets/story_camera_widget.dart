import 'dart:async';
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
  bool _isRecording = false;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _switchCamera() async {
    if (widget.cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;

    final newDescription = widget.cameras[_selectedCameraIndex];
    await widget.controller.setDescription(newDescription);
    if (mounted) setState(() {});
  }

  Future<void> _takePicture() async {
    if (!widget.controller.value.isInitialized || _isRecording) return;
    try {
      final XFile photo = await widget.controller.takePicture();

      // Fix: Don't manual flip. Most modern camera plugins handle front camera
      // rendering automatically. Manual flipping often causes mirrored text.
      File imageFile = File(photo.path);

      if (mounted) {
        final cubit = context.read<AddStoryCubit>();
        cubit.setPreviewFile(imageFile, context, isVideo: false);
      }
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  Future<void> _startVideoRecording() async {
    if (!widget.controller.value.isInitialized || _isRecording) return;
    try {
      await widget.controller.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingSeconds++;
            // Automatic stop at 60 seconds
            if (_recordingSeconds >= 60) {
              _stopVideoRecording();
            }
          });
        }
      });
    } catch (e) {
      debugPrint("Error starting video recording: $e");
    }
  }

  Future<void> _stopVideoRecording() async {
    if (!_isRecording) return;
    try {
      final XFile video = await widget.controller.stopVideoRecording();
      _recordingTimer?.cancel();

      setState(() {
        _isRecording = false;
        _recordingSeconds = 0;
      });

      if (mounted) {
        final cubit = context.read<AddStoryCubit>();
        cubit.setPreviewFile(
          File(video.path),
          context,
          isVideo: true,
          isFrontCamera: _isFrontCamera(),
        );
      }
    } catch (e) {
      debugPrint("Error stopping video recording: $e");
      setState(() {
        _isRecording = false;
        _recordingSeconds = 0;
      });
    }
  }

  bool _isFrontCamera() {
    return widget.cameras[_selectedCameraIndex].lensDirection ==
        CameraLensDirection.front;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // Calculate proper aspect ratio for the camera preview
    final cameraRatio = widget.controller.value.aspectRatio;

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Camera Preview with proper aspect ratio
          Positioned.fill(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1 / cameraRatio,
                child: CameraPreview(widget.controller),
              ),
            ),
          ),

          // Recording indicator
          if (_isRecording)
            Positioned(
              top: 60.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _formatDuration(_recordingSeconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Header
          Positioned(
            top: 40.h,
            left: 16.w,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: _isRecording ? null : widget.onBack,
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
                  onPressed: _isRecording ? null : _switchCamera,
                ),

                // Capture button (photo or video)
                GestureDetector(
                  onTap: _isRecording ? _stopVideoRecording : _takePicture,
                  onLongPress: _isRecording ? null : _startVideoRecording,
                  child: Container(
                    height: 80.w,
                    width: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isRecording ? Colors.red : Colors.white,
                        width: 5,
                      ),
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: _isRecording ? 30.w : 60.w,
                        width: _isRecording ? 30.w : 60.w,
                        decoration: BoxDecoration(
                          color: _isRecording ? Colors.red : Colors.white,
                          borderRadius: _isRecording
                              ? BorderRadius.circular(8.r)
                              : BorderRadius.circular(60.r),
                        ),
                      ),
                    ),
                  ),
                ),

                // Mode indicator
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isRecording ? Icons.videocam : Icons.camera_alt,
                      color: Colors.white,
                      size: 30,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
