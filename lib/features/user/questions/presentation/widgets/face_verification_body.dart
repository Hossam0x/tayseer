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
  @override
  void initState() {
    super.initState();
    context.read<QuestionsCubit>().resetFaceVerification();

    // ✅ افتح الـ SDK أول ما الشاشة تفتح
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startVerification();
    });
  }

  // ═══════════════════════════════════════
  // Actions
  // ═══════════════════════════════════════

  Future<void> _startVerification() async {
    await context.read<QuestionsCubit>().verifyFaceWithDidit();
  }

  void _goToNextScreen() {
    context.pushReplacementNamed(AppRouter.kAddedImagesView);
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
                      _buildCenterIcon(context, state),
                      SizedBox(height: context.height * 0.04),
                      _buildDescription(context, state),
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
      alignment: AlignmentDirectional.centerStart,
      child: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(isArabic ? Icons.arrow_forward : Icons.arrow_back, size: 20),
      ),
    );
  }

  // ═══════════════════════════════════════
  // Title
  // ═══════════════════════════════════════

  Widget _buildTitle(BuildContext context, QuestionsState state) {
    String titleKey;
    Color titleColor;

    if (state.isVerificationSuccess) {
      titleKey = 'verification_done';
      titleColor = Colors.green;
    } else if (state.isVerificationFailed) {
      titleKey = 'verification_failed_title';
      titleColor = Colors.red;
    } else {
      titleKey = 'verify_personal_photo';
      titleColor = AppColors.kscandryTextColor;
    }

    return Text(
      context.tr(titleKey),
      style: Styles.textStyle22Bold.copyWith(color: titleColor),
      textAlign: TextAlign.center,
    );
  }

  // ═══════════════════════════════════════
  // Center Icon
  // ═══════════════════════════════════════

  Widget _buildCenterIcon(BuildContext context, QuestionsState state) {
    if (state.isVerificationLoading || state.isVerificationInitial) {
      return SizedBox(
        width: context.width * 0.3,
        height: context.width * 0.3,
        child: const CustomloadingApp(),
      );
    }

    if (state.isVerificationSuccess) {
      return _buildSuccessIcon();
    }

    if (state.isVerificationFailed) {
      return _buildFailureIcon();
    }

    return const SizedBox.shrink();
  }

  // ═══════════════════════════════════════
  // Description
  // ═══════════════════════════════════════

  Widget _buildDescription(BuildContext context, QuestionsState state) {
    String descKey;

    if (state.isVerificationSuccess) {
      descKey = 'verification_success_subtitle';
    } else if (state.isVerificationFailed) {
      descKey = 'verification_failed_subtitle';
    } else {
      descKey = 'please_wait';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        context.tr(descKey),
        style: Styles.textStyle14.copyWith(
          color: Colors.grey.shade600,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
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
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
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
  // Bottom Section
  // ═══════════════════════════════════════

  Widget _buildBottomSection(BuildContext context, QuestionsState state) {
    // ✅ Loading أو Initial → الـ SDK بيفتح
    if (state.isVerificationLoading || state.isVerificationInitial) {
      return Text(
        context.tr('sdk_processing'),
        style: Styles.textStyle14.copyWith(color: Colors.grey),
        textAlign: TextAlign.center,
      );
    }

    // ✅ نجح
    if (state.isVerificationSuccess) {
      return Column(
        children: [
          Text(
            context.tr('redirecting'),
            style: Styles.textStyle14.copyWith(color: Colors.green),
          ),
          const SizedBox(height: 8),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.green,
            ),
          ),
        ],
      );
    }

    // ✅ فشل → زرار إعادة المحاولة (يفتح الـ SDK تاني)
    if (state.isVerificationFailed) {
      return Column(
        children: [
          CustomBotton(
            width: context.width * 0.9,
            onPressed: _startVerification,
            title: context.tr('retry_verification'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              context.tr('go_back'),
              style: Styles.textStyle14.copyWith(color: Colors.grey.shade600),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
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
