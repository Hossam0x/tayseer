import 'dart:io';
import 'package:camera/camera.dart';
import 'package:tayseer/core/utils/helper/image_picker_helper.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_cubit.dart';

class CameraBody extends StatefulWidget {
  const CameraBody({super.key, required this.cubit});
  final AddPostCubit cubit;
  @override
  State<CameraBody> createState() => _CameraBodyState();
}

class _CameraBodyState extends State<CameraBody> with WidgetsBindingObserver {
  File? _image;
  final ImagePickerHelper _pickerHelper = ImagePickerHelper();

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIdx = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _selectedCameraIdx = 0;
        await _initController(_cameras[_selectedCameraIdx]);
      }
    } catch (e) {
      // ignore errors for now
    }
  }

  Future<void> _initController(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await _controller!.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // initialization error
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initController(_cameras[_selectedCameraIdx]);
    }
  }

  void _pickFromGallery() async {
    final XFile? file = await _pickerHelper.pickFromGallery();
    if (file != null) {
      final f = File(file.path);
      setState(() {
        _image = f;
      });
      // show preview and let user press Next to confirm/send to post
    }
  }

  void _switchCamera() async {
    if (_cameras.isEmpty) return;
    _selectedCameraIdx = (_selectedCameraIdx + 1) % _cameras.length;
    await _controller?.dispose();
    await _initController(_cameras[_selectedCameraIdx]);
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;
    try {
      final XFile file = await _controller!.takePicture();
      setState(() {
        _image = File(file.path);
      });
    } catch (e) {
      debugPrint('takePicture error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        centerTitle: true,
        title: Text('Camera', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          if (_image != null)
            Image.file(
              _image!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            )
          else if (_isInitialized && _controller != null)
            LayoutBuilder(
              builder: (context, constraints) {
                final size = MediaQuery.of(context).size;
                final deviceRatio = size.width / size.height;
                final previewRatio = _controller!.value.aspectRatio;
                return Transform.scale(
                  scale: previewRatio / deviceRatio,
                  child: Center(child: CameraPreview(_controller!)),
                );
              },
            )
          else
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Camera',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // زر اختيار من المعرض
                GestureDetector(
                  onTap: _pickFromGallery,
                  child: AppImage(
                    AssetsData.kopenGalFromCameraIcon,
                    width: 40,
                    height: 40,
                  ),
                ),
                // زر التقاط صورة بالكاميرا
                _image != null
                    ? CustomBotton(
                        height: context.responsiveHeight(60),
                        width: context.responsiveWidth(150),
                        useGradient: true,
                        title: context.tr('next'),
                        onPressed: () async {
                          // send captured/selected image to cubit then return
                          try {
                            await widget.cubit.addCapturedImage(_image!);
                          } catch (e) {
                            debugPrint('addCapturedImage error: $e');
                          }
                          if (!mounted) return;
                          context.pop();
                        },
                      )
                    : GestureDetector(
                        onTap: _takePicture,
                        child: AppImage(AssetsData.konkollCameraIcon),
                      ),
                // زر تبديل الكاميرا
                GestureDetector(
                  onTap: _switchCamera,
                  child: AppImage(
                    AssetsData.krottionIcon,
                    width: 40,
                    height: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
