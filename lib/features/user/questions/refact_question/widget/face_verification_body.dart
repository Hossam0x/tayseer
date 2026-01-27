import 'dart:math' as math;

import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';

class FaceVerificationBody extends StatefulWidget {
  const FaceVerificationBody({super.key});

  @override
  State<FaceVerificationBody> createState() => _FaceVerificationBodyState();
}

class _FaceVerificationBodyState extends State<FaceVerificationBody>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    // Reset state when entering the screen
    context.read<QuestionsCubit>().resetFaceVerification();

    // إعداد الـ Animation للخط المتحرك
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null && mounted) {
        context.read<QuestionsCubit>().setCapturedFaceImage(image);
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            context,
            text: 'حدث خطأ أثناء التقاط الصورة',
            isError: true,
          ),
        );
      }
    }
  }

  Future<void> _verifyImage() async {
    final state = context.read<QuestionsCubit>().state;
    if (state.capturedFaceImage != null) {
      // بدء الـ animation
      _scanAnimationController.repeat();

      await context.read<QuestionsCubit>().verifyFaceImage(
        image: state.capturedFaceImage!,
      );

      // إيقاف الـ animation
      _scanAnimationController.stop();
      _scanAnimationController.reset();
    }
  }

  void _retryCapture() {
    context.read<QuestionsCubit>().resetFaceVerification();
    _captureImage();
  }

  void _goToNextScreen() {
    // // غيّر الـ route حسب التطبيق
    // context.pushReplacementNamed(AppRouter.kUserLayoutView);
  }

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: SafeArea(
        child: BlocConsumer<QuestionsCubit, QuestionsState>(
          listenWhen: (previous, current) {
            return previous.faceVerificationState !=
                current.faceVerificationState;
          },
          listener: (context, state) {
            if (state.isVerificationSuccess) {
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  _goToNextScreen();
                }
              });
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Header with back button
                  _buildHeader(context),

                  SizedBox(height: context.height * 0.02),

                  // Title
                  _buildTitle(context, state),

                  SizedBox(height: context.height * 0.02),

                  // Error message (if verification failed - 400)
                  if (state.isVerificationFailed &&
                      state.faceVerificationError != null)
                    _buildErrorMessage(context, state),

                  SizedBox(height: context.height * 0.08),

                  // Image Frame (constrained height to avoid overly large frame)
                  SizedBox(
                    height: context.height * 0.28,
                    width: context.width * 0.5,
                    child: Center(child: _buildImageFrame(context, state)),
                  ),

                  SizedBox(height: context.height * 0.1),

                  // Result Icon or Button
                  _buildBottomSection(context, state),

                  SizedBox(height: context.height * 0.04),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(Icons.arrow_back, size: 20),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, QuestionsState state) {
    String title;

    if (!state.hasImage || state.isInitial) {
      title = 'التحقق من الصورة الشخصية';
    } else {
      title = 'تم التحقق';
    }

    return Text(
      title,
      style: Styles.textStyle22Bold.copyWith(
        color: AppColors.kscandryTextColor,
      ),
      textAlign: TextAlign.center,
    );
  }

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
              state.faceVerificationError ??
                  'الرجاء التأكد من أن وجهك في الإطار وأن الإضاءة جيدة.',
              style: Styles.textStyle14.copyWith(color: Colors.red.shade700),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFrame(BuildContext context, QuestionsState state) {
    final frameSize = context.width * 0.65;

    // تحديد لون الإطار بناءً على الحالة
    Color borderColor;
    if (state.isVerificationSuccess) {
      // ✅ 200 = أخضر
      borderColor = Colors.green;
    } else if (state.isVerificationFailed) {
      // ✅ 400 = أحمر
      borderColor = Colors.red;
    } else if (state.isVerificationLoading) {
      borderColor = Colors.blue;
    } else {
      borderColor = Colors.grey.shade400;
    }

    return GestureDetector(
      onTap: !state.hasImage ? _captureImage : null,
      child: Container(
        width: frameSize,
        height: frameSize * 1.1,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 4),
          color: Colors.grey.shade100,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _buildFrameContent(context, state, frameSize),
        ),
      ),
    );
  }

  Widget _buildFrameContent(
    BuildContext context,
    QuestionsState state,
    double frameSize,
  ) {
    // حالة لم يتم التقاط صورة بعد
    if (!state.hasImage) {
      return _buildEmptyFrame(context, frameSize);
    }

    // حالة تم التقاط صورة
    return Stack(
      fit: StackFit.expand,
      children: [
        // الصورة
        Image.file(File(state.capturedFaceImage!.path), fit: BoxFit.cover),

        // خط المسح (Scanning line) أثناء التحميل
        if (state.isVerificationLoading)
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Positioned(
                top: _scanAnimation.value * (frameSize * 1.1 - 4),
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.blue.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

        // ✅ الخط الأخضر بعد التحقق الناجح (200)
        if (state.isVerificationSuccess) _buildVerificationLine(true),

        // ✅ الخط الأحمر بعد فشل التحقق (400)
        if (state.isVerificationFailed) _buildVerificationLine(false),
      ],
    );
  }

  Widget _buildEmptyFrame(BuildContext context, double frameSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Face placeholder icon
        CustomPaint(
          size: Size(frameSize * 0.5, frameSize * 0.5),
          painter: FacePlaceholderPainter(),
        ),
        const SizedBox(height: 20),
        Text(
          'اضغط لالتقاط صورة',
          style: Styles.textStyle14.copyWith(color: Colors.grey.shade600),
        ),
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

  Widget _buildBottomSection(BuildContext context, QuestionsState state) {
    if (!state.hasImage) {
      return _buildCaptureButton(context);
    }

    // حالة التحميل
    if (state.isVerificationLoading) {
      return SizedBox(width: 50, height: 50, child: CustomloadingApp());
    }

    // ✅ حالة النجاح (200) - أيقونة خضراء
    if (state.isVerificationSuccess) {
      return _buildSuccessIcon();
    }

    // ✅ حالة الفشل (400) - أيقونة حمراء للإعادة
    if (state.isVerificationFailed) {
      return _buildRetryButton(context);
    }

    // الحالة الافتراضية - زر التحقق (بعد التقاط الصورة)
    return _buildVerifyButton(context);
  }

  Widget _buildCaptureButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _captureImage,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kprimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'التقاط صورة',
          style: Styles.textStyle16.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    return CustomBotton(
      width: context.width * 0.9,
      onPressed: _verifyImage,
      title: context.tr('verify'),
    );
  }

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
          // الخلفية المسننة (Badge)
          CustomPaint(
            size: const Size(80, 80),
            painter: BadgePainter(color: Colors.green),
          ),
          // علامة الصح
          const Icon(Icons.check, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  Widget _buildRetryButton(BuildContext context) {
    return GestureDetector(
      onTap: _retryCapture,
      child: Container(
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
      ),
    );
  }
}

class BadgePainter extends CustomPainter {
  final Color color;

  BadgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const points = 12;

    for (var i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final r = i.isEven ? radius : radius * 0.85;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FacePlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;

    final cornerLength = width * 0.25;
    final radius = width * 0.15;

    // الزاوية العلوية اليسرى
    canvas.drawArc(
      Rect.fromLTWH(0, 0, radius * 2, radius * 2),
      math.pi,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawLine(Offset(0, radius), Offset(0, cornerLength), paint);
    canvas.drawLine(Offset(radius, 0), Offset(cornerLength, 0), paint);

    // الزاوية العلوية اليمنى
    canvas.drawArc(
      Rect.fromLTWH(width - radius * 2, 0, radius * 2, radius * 2),
      -math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawLine(Offset(width, radius), Offset(width, cornerLength), paint);
    canvas.drawLine(
      Offset(width - radius, 0),
      Offset(width - cornerLength, 0),
      paint,
    );

    // الزاوية السفلية اليسرى
    canvas.drawArc(
      Rect.fromLTWH(0, height - radius * 2, radius * 2, radius * 2),
      math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(0, height - radius),
      Offset(0, height - cornerLength),
      paint,
    );
    canvas.drawLine(
      Offset(radius, height),
      Offset(cornerLength, height),
      paint,
    );

    // الزاوية السفلية اليمنى
    canvas.drawArc(
      Rect.fromLTWH(
        width - radius * 2,
        height - radius * 2,
        radius * 2,
        radius * 2,
      ),
      0,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(width, height - radius),
      Offset(width, height - cornerLength),
      paint,
    );
    canvas.drawLine(
      Offset(width - radius, height),
      Offset(width - cornerLength, height),
      paint,
    );

    // خطين أفقيين في المنتصف
    final lineY1 = height * 0.4;
    final lineY2 = height * 0.6;
    final lineStartX = width * 0.3;
    final lineEndX = width * 0.7;

    canvas.drawLine(
      Offset(lineStartX, lineY1),
      Offset(lineEndX, lineY1),
      paint,
    );
    canvas.drawLine(
      Offset(lineStartX, lineY2),
      Offset(lineEndX, lineY2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
