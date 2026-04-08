import 'package:tayseer/core/widgets/custom_outline_button.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/features/user/verification/data/models/Verification_result_model.dart';
import 'package:tayseer/features/user/verification/data/verification_service.dart';
import 'package:tayseer/features/user/verification/presentation/view/verification_screen.dart';
import 'package:tayseer/features/user/verification/presentation/view/verification_webview_screen.dart';
import 'package:tayseer/my_import.dart';

class CompleteMarriageFile extends StatefulWidget {
  const CompleteMarriageFile({
    super.key,
    required this.progress,
    required this.profile,
    required this.onNavigateToEdit,
    required this.onProfileRefresh,
  });

  final double progress;
  final MarriageUserProfileModel profile;
  final Function(String section) onNavigateToEdit;
  final Future<MarriageUserProfileModel> Function() onProfileRefresh;

  @override
  State<CompleteMarriageFile> createState() => _CompleteMarriageFileState();
}

class _CompleteMarriageFileState extends State<CompleteMarriageFile>
    with SingleTickerProviderStateMixin {

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('📋 [CompleteMarriageFile] build() called');
    debugPrint('📋 [CompleteMarriageFile] progress: ${widget.progress}');
    debugPrint(
      '📋 [CompleteMarriageFile] profile.isVerified: ${widget.profile.isVerified}',
    );

    final List<Map<String, dynamic>> verificationItems = [
      {
        'title': context.tr('photo_verification'),
        'description': context.tr('photo_verification_desc'),
        'isVerified': widget.profile.isVerified == true,
      },
      {
        'title': context.tr('age_verification'),
        'description': context.tr('age_verification_desc'),
        'isVerified': widget.profile.isVerified == true,
      },
      {
        'title': context.tr('identity_verification'),
        'description': context.tr('identity_verification_desc'),
        'isVerified': widget.profile.isVerified == true,
      },
    ];

    int totalItems = verificationItems.length;
    int completedItems =
        verificationItems.where((item) => item['isVerified'] as bool).length;
    int verificationPercentage =
        totalItems > 0 ? ((completedItems / totalItems) * 100).round() : 0;

    final imageCount = widget.profile.userMedia?.images.length ?? 0;
    final hasVideo =
        widget.profile.userMedia?.video != null &&
        widget.profile.userMedia!.video!.isNotEmpty;
    final hasAudio =
        widget.profile.userMedia?.audio != null &&
        widget.profile.userMedia!.audio!.isNotEmpty;
    final isVerified = widget.profile.isVerified == true;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 10.h),
              child: SimpleAppBar(
                title: context.tr("complete_data"),
                isLargeTitle: true,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0.w),
                child: Column(
                  children: [
                    SizedBox(height: 11.h),
                    _buildEnhancedTimeline(progress: widget.progress),
                    SizedBox(height: 20.h),

                    widget.profile.isVerified == true
                        ? const SizedBox.shrink()
                        : _buildVerificationCard(
                            context,
                            verificationPercentage,
                            verificationItems,
                          ),

                    if (!isVerified) SizedBox(height: 12.h),

                    if (imageCount < 4)
                      _buildTaskCard(
                        context,
                        title: context.tr('add_minimum_images'),
                        subtitle: context.tr('add_more_images_description'),
                        buttonText: context.tr('add'),
                        currentCount: imageCount,
                        requiredCount: 4,
                        onTap: () => widget.onNavigateToEdit('images'),
                      ),

                    SizedBox(height: 12.h),

                    if (!hasVideo)
                      _buildTaskCard(
                        context,
                        title: context.tr('add_intro_video'),
                        subtitle: context.tr('add_video_description'),
                        buttonText: context.tr('add'),
                        onTap: () => widget.onNavigateToEdit('video'),
                      ),

                    SizedBox(height: 12.h),

                    if (!hasAudio)
                      _buildTaskCard(
                        context,
                        title: context.tr('add_audio_clip'),
                        subtitle: context.tr('add_audio_description'),
                        buttonText: context.tr('add'),
                        onTap: () => widget.onNavigateToEdit('audio'),
                      ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Full Verification Flow
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _startVerificationFlow(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final currentStatus = await VerificationService.getUserVerificationStatus();

    if (!context.mounted) return;
    Navigator.pop(context);

    if (currentStatus?.isVerified == true) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationScreen(result: currentStatus!),
        ),
      );
      return;
    }

    final url = await VerificationService.getVerificationUrl();

    if (!context.mounted) return;

    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(context, text: context.tr('error_occurred'), isError: true),
      );
      return;
    }

    final result = await Navigator.push<VerificationStatus>(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationWebViewScreen(webviewUrl: url),
      ),
    );

    if (!context.mounted) return;

    switch (result) {
      case VerificationStatus.approved:
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        final updatedStatus = await VerificationService.getUserVerificationStatus();

        if (!context.mounted) return;
        Navigator.pop(context);

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationScreen(
              result: updatedStatus ?? VerificationResult(isVerified: true, rejectReasons: []),
            ),
          ),
        );

        await widget.onProfileRefresh();
        break;

      case VerificationStatus.rejected:
        await _showRejectionScreen(context);
        break;

      default:
        break;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Show VerificationScreen with rejection reasons + handle retry
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _showRejectionScreen(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final currentStatus = await VerificationService.getUserVerificationStatus();

    if (!context.mounted) return;
    Navigator.pop(context);

    final shouldRetry = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationScreen(
          result: currentStatus ?? VerificationResult(isVerified: false, rejectReasons: []),
        ),
      ),
    );

    if (!context.mounted) return;

    if (shouldRetry == true) {
      final url = await VerificationService.getVerificationUrl();

      if (!context.mounted) return;

      if (url == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(context, text: context.tr('error_occurred'), isError: true),
        );
        return;
      }

      final retryResult = await Navigator.push<VerificationStatus>(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationWebViewScreen(webviewUrl: url),
        ),
      );

      if (!context.mounted) return;

      if (retryResult == VerificationStatus.approved) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        final updatedStatus = await VerificationService.getUserVerificationStatus();

        if (!context.mounted) return;
        Navigator.pop(context);

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationScreen(
              result: updatedStatus ?? VerificationResult(isVerified: true, rejectReasons: []),
            ),
          ),
        );

        await widget.onProfileRefresh();
      } else if (retryResult == VerificationStatus.rejected) {
        await _showRejectionScreen(context); // recursive retry
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Verification Card with Float Animation
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildVerificationCard(
    BuildContext context,
    int percentage,
    List<Map<String, dynamic>> items,
  ) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_floatAnimation.value),
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primary100, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary100.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.h),
              decoration: BoxDecoration(
                color: AppColors.primary200.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user,
                    color: AppColors.primary200,
                    size: MediaQuery.of(context).size.width >= 600 ? 56 : 44,
                  ),
                  SizedBox(height: 3.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      "$percentage%",
                      style: Styles.textStyle12.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary200,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('get_verified'),
                    style: Styles.textStyle16Bold,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    context.tr('verify_profile_description'),
                    style: Styles.textStyle12.copyWith(
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            IconButton(
              onPressed: () => _startVerificationFlow(context),
              icon: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black.withOpacity(0.5),
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Task Card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTaskCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
    int? currentCount,
    int? requiredCount,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary100, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary100.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Styles.textStyle16Bold.copyWith(color: Colors.black),
                      ),
                    ),
                    if (currentCount != null && requiredCount != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary50,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '$currentCount/$requiredCount',
                          style: Styles.textStyle12.copyWith(
                            color: AppColors.primary200,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: Styles.textStyle12.copyWith(
                    color: Color.fromRGBO(60, 60, 67, 0.6),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          CustomOutlineButton(
            height: 50.h,
            text: buttonText,
            textColor: AppColors.primary200,
            onTap: onTap,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Timeline
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEnhancedTimeline({required double progress}) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.8),
            Colors.white.withOpacity(0.6),
            Colors.white.withOpacity(0.5),
            AppColors.primary200.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(235, 122, 145, 0.46),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                int badgeNumber = index + 1;
                int totalSteps = 5;
                int reversedNumber = totalSteps - badgeNumber + 1;
                final reversedIndex = 4 - index;
                double pointProgress = reversedIndex / 4;
                bool isReached = pointProgress <= progress;

                return Align(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 6.h),
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isReached ? const Color(0xFFFFC107) : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: isReached
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 3,
                                      offset: Offset(0, 1),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            reversedNumber.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: isReached ? Colors.white : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 16.h),
          _buildTimeline(progress: progress),
        ],
      ),
    );
  }

  Widget _buildTimeline({required double progress}) {
    final double safeProgress = progress.clamp(0.0, 1.0);
    final String percentageText = "${(safeProgress * 100).toInt()}%";

    return Column(
      children: [
        SizedBox(
          height: 30.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 4.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: safeProgress,
                    child: Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFD375F),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double position = safeProgress * constraints.maxWidth;
                    return Stack(
                      children: [
                        Positioned(
                          left: position - 20.w,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFD375F),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                percentageText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}