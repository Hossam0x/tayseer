import 'package:flutter/widgets.dart';
import 'package:tayseer/core/widgets/custom_outline_button.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
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
    final imageCount = profile.userMedia?.images.length ?? 0;
    final hasVideo = profile.userMedia?.video != null && 
                      profile.userMedia!.video!.isNotEmpty;
    final hasAudio = profile.userMedia?.audio != null && 
                      profile.userMedia!.audio!.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 10.h),
              child: SimpleAppBar(
                title: "استكمال البيانات",
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

                    // Images Section (show if less than 5 images)
                    if (imageCount < 5)
                      _buildTaskCard(
                        context,
                        title: context.tr('add_minimum_images'),
                        subtitle: context.tr('add_more_images_description'),
                        buttonText: context.tr('add'),
                        currentCount: imageCount,
                        requiredCount: 5,
                        onTap: () {
                          onNavigateToEdit('images');
                          // Navigator.pop(context);
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
                          // Navigator.pop(context);
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
                          // Navigator.pop(context);
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

            // Colors.white.withOpacity(0.7),
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
              Row(
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
                                fontSize: 10.sp,
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
              SizedBox(height: 16.h),
              _buildTimeline(progress: progress),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline({required double progress}) {
    // التأكد من أن القيمة بين 0 و 1
    final double safeProgress = progress.clamp(0.0, 1.0);
    final String percentageText = "${(safeProgress * 100).toInt()}%";

    return Column(
      children: [
        SizedBox(
          height: 30.h, // ارتفاع مناسب لاستيعاب الكبسولة والشريط
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. الشريط الخلفي (الرمادي)
              Container(
                height: 4.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(
                    0.2,
                  ), // أو لون رمادي داكن حسب الخلفية
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),

              // 2. شريط التقدم الملون
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: safeProgress,
                  child: Container(
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFFD375F,
                      ), // اللون الوردي المحمر من الصورة
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),

              // 3. الكبسولة (النسبة المئوية) التي تتحرك مع التقدم
              LayoutBuilder(
                builder: (context, constraints) {
                  // حساب الإزاحة لجعل الكبسولة تتمركز عند نهاية شريط التقدم
                  double position = safeProgress * constraints.maxWidth;

                  return Stack(
                    children: [
                      Positioned(
                        left:
                            position -
                            20.w, // طرح نصف عرض الكبسولة لتتوسط النهاية
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
                                fontSize: 10.sp,
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
            ],
          ),
        ),
      ],
    );
  }

}




  // Widget _buildEnhancedTimeline({required double progress}) {
  //   return Container(
  //     padding: EdgeInsets.all(10),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.topCenter,
  //         end: Alignment.bottomCenter,
  //         colors: [
  //           Colors.white,
  //           Colors.white.withOpacity(0.8),
  //           Colors.white.withOpacity(0.6),
  //           Colors.white.withOpacity(0.5),
  //           AppColors.primary200.withOpacity(0.5),

  //           // Colors.white.withOpacity(0.7),
  //         ],
  //       ),
  //       borderRadius: BorderRadius.circular(24.r),
  //       border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Color.fromRGBO(235, 122, 145, 0.46),
  //           blurRadius: 20,
  //           offset: const Offset(0, 10),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         Column(
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: List.generate(5, (index) {
  //                 int badgeNumber = index + 1;
  //                 int totalSteps = 5;
  //                 int reversedNumber = totalSteps - badgeNumber + 1;
  //                 final reversedIndex = 4 - index;
  //                 double pointProgress = reversedIndex / 4;
  //                 bool isReached = pointProgress <= progress;

  //                 return Align(
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       SizedBox(height: 6.h),
  //                       Center(
  //                         child: Container(
  //                           padding: EdgeInsets.symmetric(
  //                             horizontal: 7.w,
  //                             vertical: 4.h,
  //                           ),
  //                           decoration: BoxDecoration(
  //                             color: isReached
  //                                 ? const Color(0xFFFFC107)
  //                                 : Colors.grey.shade300,
  //                             borderRadius: BorderRadius.circular(8.r),
  //                             boxShadow: isReached
  //                                 ? [
  //                                     BoxShadow(
  //                                       color: Colors.black.withOpacity(0.1),
  //                                       blurRadius: 3,
  //                                       offset: Offset(0, 1),
  //                                     ),
  //                                   ]
  //                                 : [],
  //                           ),
  //                           child: Text(
  //                             reversedNumber.toString().padLeft(2, '0'),
  //                             style: TextStyle(
  //                               fontSize: 10.sp,
  //                               fontWeight: FontWeight.bold,
  //                               color: isReached
  //                                   ? Colors.white
  //                                   : Colors.grey.shade600,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 );
  //               }),
  //             ),
  //             SizedBox(height: 16.h),
  //             _buildTimeline(progress: progress),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildTimeline({required double progress}) {
  //   // التأكد من أن القيمة بين 0 و 1
  //   final double safeProgress = progress.clamp(0.0, 1.0);
  //   final String percentageText = "${(safeProgress * 100).toInt()}%";

  //   return Column(
  //     children: [
  //       SizedBox(
  //         height: 30.h, // ارتفاع مناسب لاستيعاب الكبسولة والشريط
  //         child: Stack(
  //           alignment: Alignment.center,
  //           children: [
  //             // 1. الشريط الخلفي (الرمادي)
  //             Container(
  //               height: 4.h,
  //               width: double.infinity,
  //               decoration: BoxDecoration(
  //                 color: Colors.grey.withOpacity(
  //                   0.2,
  //                 ), // أو لون رمادي داكن حسب الخلفية
  //                 borderRadius: BorderRadius.circular(10.r),
  //               ),
  //             ),

  //             // 2. شريط التقدم الملون
  //             Align(
  //               alignment: Alignment.centerLeft,
  //               child: FractionallySizedBox(
  //                 widthFactor: safeProgress,
  //                 child: Container(
  //                   height: 4.h,
  //                   decoration: BoxDecoration(
  //                     color: const Color(
  //                       0xFFFD375F,
  //                     ), // اللون الوردي المحمر من الصورة
  //                     borderRadius: BorderRadius.circular(10.r),
  //                   ),
  //                 ),
  //               ),
  //             ),

  //             // 3. الكبسولة (النسبة المئوية) التي تتحرك مع التقدم
  //             LayoutBuilder(
  //               builder: (context, constraints) {
  //                 // حساب الإزاحة لجعل الكبسولة تتمركز عند نهاية شريط التقدم
  //                 double position = safeProgress * constraints.maxWidth;

  //                 return Stack(
  //                   children: [
  //                     Positioned(
  //                       left:
  //                           position -
  //                           20.w, // طرح نصف عرض الكبسولة لتتوسط النهاية
  //                       top: 0,
  //                       bottom: 0,
  //                       child: Center(
  //                         child: Container(
  //                           padding: EdgeInsets.symmetric(
  //                             horizontal: 8.w,
  //                             vertical: 2.h,
  //                           ),
  //                           decoration: BoxDecoration(
  //                             color: const Color(0xFFFD375F),
  //                             borderRadius: BorderRadius.circular(20.r),
  //                           ),
  //                           child: Text(
  //                             percentageText,
  //                             style: TextStyle(
  //                               color: Colors.white,
  //                               fontSize: 10.sp,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 );
  //               },
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

