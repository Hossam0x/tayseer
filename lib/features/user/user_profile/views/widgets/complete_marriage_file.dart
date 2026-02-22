import 'package:tayseer/core/widgets/custom_outline_button.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/verification_page.dart';
import 'package:tayseer/my_import.dart';

class CompleteMarriageFile extends StatelessWidget {
  const CompleteMarriageFile({
    super.key,
    required this.progress,
    required this.profile,
    required this.onNavigateToEdit,
  });

  final double progress;
  final MarriageUserProfileModel profile;
  final Function(String section) onNavigateToEdit;

  @override
  Widget build(BuildContext context) {
    // Calculate verification percentage
    final List<Map<String, dynamic>> verificationItems = [
      {
        'title': context.tr('photo_verification'),
        'description': context.tr('photo_verification_desc'),
        'isVerified': false, // Adjust based on your model
      },
      {
        'title': context.tr('age_verification'),
        'description': context.tr('age_verification_desc'),
        'isVerified': true, // Adjust based on your model
      },
      {
        'title': context.tr('identity_verification'),
        'description': context.tr('identity_verification_desc'),
        'isVerified': true, // Adjust based on your model
      },
    ];

    int totalItems = verificationItems.length;
    int completedItems = verificationItems
        .where((item) => item['isVerified'] as bool)
        .length;
    int verificationPercentage = totalItems > 0
        ? ((completedItems / totalItems) * 100).round()
        : 0;

    final imageCount = profile.userMedia?.images.length ?? 0;
    final hasVideo =
        profile.userMedia?.video != null &&
        profile.userMedia!.video!.isNotEmpty;
    final hasAudio =
        profile.userMedia?.audio != null &&
        profile.userMedia!.audio!.isNotEmpty;

    // Check if user is verified (you may need to adjust this based on your model)
    final isVerified = false;

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
                    _buildEnhancedTimeline(progress: progress),
                    SizedBox(height: 20.h),

                    // Verification Section
                    if (!isVerified)
                      _buildVerificationCard(
                        context,
                        verificationPercentage,
                        verificationItems,
                      ),

                    if (!isVerified) SizedBox(height: 12.h),

                    // Images Section (show if less than 5 images)
                    if (imageCount < 4)
                      _buildTaskCard(
                        context,
                        title: context.tr('add_minimum_images'),
                        subtitle: context.tr('add_more_images_description'),
                        buttonText: context.tr('add'),
                        currentCount: imageCount,
                        requiredCount: 4,
                        onTap: () {
                          onNavigateToEdit('images');
                        },
                      ),

                    SizedBox(height: 12.h),

                    // Video Section (show if no video)
                    if (!hasVideo)
                      _buildTaskCard(
                        context,
                        title: context.tr('add_intro_video'),
                        subtitle: context.tr('add_video_description'),
                        buttonText: context.tr('add'),
                        onTap: () {
                          onNavigateToEdit('video');
                        },
                      ),

                    SizedBox(height: 12.h),

                    // Audio Section (show if no audio)
                    if (!hasAudio)
                      _buildTaskCard(
                        context,
                        title: context.tr('add_audio_clip'),
                        subtitle: context.tr('add_audio_description'),
                        buttonText: context.tr('add'),
                        onTap: () {
                          onNavigateToEdit('audio');
                        },
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

  Widget _buildVerificationCard(
    BuildContext context,
    int percentage,
    List<Map<String, dynamic>> items,
  ) {
    return Container(
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
          // Icon with dynamic percentage
          Container(
            padding: EdgeInsets.all(8.w),
            height: 88.h,
            decoration: BoxDecoration(
              color: AppColors.primary200.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Stack(
              children: [
                Positioned(
                  child: Icon(
                    Icons.verified_user,
                    color: AppColors.primary200,
                    size: 44.sp,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 4.h,
                      horizontal: 8.w,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12.r)),
                    ),
                    child: Text(
                      "$percentage%",
                      style: Styles.textStyle14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary200,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('get_verified'),
                  style: Styles.textStyle16Bold.copyWith(),
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
          // Arrow icon
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      VerificationScreen(verificationItems: items),
                ),
              );
            },
            icon: Icon(
              Icons.arrow_forward_ios,
              color: Colors.black.withOpacity(0.5),
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

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
                        style: Styles.textStyle16Bold.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (currentCount != null && requiredCount != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
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
          Column(
            children: [
              // Fixed RTL/LTR direction issue
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: isReached
                                    ? const Color(0xFFFFC107)
                                    : Colors.grey.shade300,
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
                                  color: isReached
                                      ? Colors.white
                                      : Colors.grey.shade600,
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
              // Background bar
              Container(
                height: 4.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),

              // Progress bar - wrapped in Directionality
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

              // Percentage capsule
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
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
