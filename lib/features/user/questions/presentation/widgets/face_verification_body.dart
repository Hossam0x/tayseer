// lib/features/user/questions/view/widget/face_verification_body.dart

import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/user/questions/presentation/widgets/face_verification_painters.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_cubit.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_state.dart';

class FaceVerificationBody extends StatefulWidget {
  const FaceVerificationBody({super.key});

  @override
  State<FaceVerificationBody> createState() => _FaceVerificationBodyState();
}

class _FaceVerificationBodyState extends State<FaceVerificationBody> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isVerifying = false; // ✅ هل ضغط تحقق ولا لسه

  @override
  void initState() {
    super.initState();
    context.read<QuestionsCubit>().resetFaceVerification();
    _initCamera();
  }

  // ═══════════════════════════════════════
  // Camera Setup
  // ═══════════════════════════════════════

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  // ═══════════════════════════════════════
  // Actions
  // ═══════════════════════════════════════

  Future<void> _startVerification() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    // ✅ شيل الـ Blur وابدأ التحقق
    setState(() {
      _isVerifying = true;
    });

    // // ✅ تأخير بسيط عشان المستخدم يشوف نفسه قبل الالتقاط
    // await Future.delayed(const Duration(seconds: 2));

    try {
      final XFile photo = await _cameraController!.takePicture();
      final Uint8List imageBytes = await photo.readAsBytes();

      if (mounted) {
        await context.read<QuestionsCubit>().verifyFaceLocally(
          capturedImageBytes: imageBytes,
        );
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            context,
            text: context.tr('capture_error'),
            isError: true,
          ),
        );
      }
    }
  }

  void _retryVerification() {
    setState(() {
      _isVerifying = false; // ✅ رجّع الـ Blur
    });
    context.read<QuestionsCubit>().resetFaceVerification();
  }

  void _goToNextScreen() {
    context.pushReplacementNamed(AppRouter.kAddedImagesView);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════
  // Build
  // ═══════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<QuestionsCubit>().resetFaceVerification();
        }
      },
      child: CustomBackground(
        child: SafeArea(
          child: BlocConsumer<QuestionsCubit, QuestionsState>(
            listenWhen: (previous, current) =>
                previous.faceVerificationState != current.faceVerificationState,
            listener: (context, state) {
              if (state.isVerificationSuccess) {
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) _goToNextScreen();
                });
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(context),
                      SizedBox(height: context.height * 0.02),
                      _buildTitle(context, state),
                      SizedBox(height: context.height * 0.02),
                      if (state.isVerificationFailed &&
                          state.faceVerificationError != null)
                        _buildErrorMessage(context, state),
                      SizedBox(height: context.height * 0.08),
                      SizedBox(
                        height: context.height * 0.35,
                        width: context.width * 0.6,
                        child: Center(child: _buildCameraFrame(context, state)),
                      ),
                      SizedBox(height: context.height * 0.08),
                      _buildBottomSection(context, state),
                      SizedBox(height: context.height * 0.04),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // Header
  // ═══════════════════════════════════════

  Widget _buildHeader(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back, size: 20),
      ),
    );
  }

  // ═══════════════════════════════════════
  // Title
  // ═══════════════════════════════════════

  Widget _buildTitle(BuildContext context, QuestionsState state) {
    final String titleKey = state.isVerificationSuccess
        ? 'verification_done'
        : 'verify_personal_photo';

    return Text(
      context.tr(titleKey),
      style: Styles.textStyle22Bold.copyWith(
        color: AppColors.kscandryTextColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  // ═══════════════════════════════════════
  // Error Message
  // ═══════════════════════════════════════

  Widget _buildErrorMessage(BuildContext context, QuestionsState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.close, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.tr(state.faceVerificationError ?? 'verification_error'),
              style: Styles.textStyle14.copyWith(color: Colors.red.shade700),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // Camera Frame
  // ═══════════════════════════════════════

  Widget _buildCameraFrame(BuildContext context, QuestionsState state) {
    final frameSize = context.width * 0.6;

    Color borderColor;
    if (state.isVerificationSuccess) {
      borderColor = Colors.green;
    } else if (state.isVerificationFailed) {
      borderColor = Colors.red;
    } else {
      borderColor = Colors.grey.shade400;
    }

    return Container(
      width: frameSize,
      height: frameSize * 1.2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 4),
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildCameraContent(context, state),
      ),
    );
  }

  Widget _buildCameraContent(BuildContext context, QuestionsState state) {
    if (!_isCameraReady ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // ✅ Live Camera Preview
        CameraPreview(_cameraController!),

        // ✅ Blur Layer - قبل ما يضغط تحقق
        if (!_isVerifying && state.isVerificationInitial)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.visibility_off_outlined,
                      color: Colors.white.withOpacity(0.8),
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('press_verify_to_start'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ✅ خط أخضر بعد النجاح
        if (state.isVerificationSuccess) _buildVerificationLine(true),

        // ✅ خط أحمر بعد الفشل
        if (state.isVerificationFailed) _buildVerificationLine(false),
      ],
    );
  }

  Widget _buildVerificationLine(bool isSuccess) {
    return Center(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        color: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  // ═══════════════════════════════════════
  // Bottom Section
  // ═══════════════════════════════════════

  Widget _buildBottomSection(BuildContext context, QuestionsState state) {
    if (state.isVerificationLoading) {
      return const SizedBox(width: 50, height: 50, child: CustomloadingApp());
    }

    if (state.isVerificationSuccess) {
      return _buildSuccessIcon();
    }

    if (state.isVerificationFailed) {
      return Column(
        children: [
          _buildFailureIcon(),
          const SizedBox(height: 20),
          CustomBotton(
            width: context.width * 0.9,
            onPressed: _retryVerification,
            title: context.tr('retry_verification'),
          ),
        ],
      );
    }

    return CustomBotton(
      width: context.width * 0.9,
      onPressed: _isCameraReady ? _startVerification : null,
      title: context.tr('verify'),
    );
  }

  // ═══════════════════════════════════════
  // Success Icon
  // ═══════════════════════════════════════

  Widget _buildSuccessIcon() {
    return Container(
      width: context.width * 0.2,
      height: context.width * 0.2,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(80, 80),
            painter: BadgePainter(color: Colors.green),
          ),
          const Icon(Icons.check, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // Failure Icon
  // ═══════════════════════════════════════

  Widget _buildFailureIcon() {
    return Container(
      width: context.width * 0.15,
      height: context.width * 0.15,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(Icons.close, color: Colors.white, size: 40),
    );
  }
}
