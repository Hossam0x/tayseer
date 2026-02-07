// marriage_profile_page.dart - UNIFIED PAGE WITH SHIMMER LOADING
// ════════════════════════════════════════════════════════════════
// ✅ صفحة واحدة - Toggle بين العرض والتعديل
// ⭐⭐⭐ تم إضافة Shimmer Loading باستخدام MarriageProfileSkeleton
// ════════════════════════════════════════════════════════════════

import 'dart:developer';
import 'dart:ui';
import 'package:tayseer/core/widgets/custom_toggle_tab_bar.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/marriage/view/widget/additional_image.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/marriage_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/marriage_profile_edit_view.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/marriage_life_events_section.dart';
 // ⭐⭐⭐ Import skeleton
import 'package:tayseer/my_import.dart';

// ⭐⭐⭐ Import sections من صفحة العرض
import 'package:tayseer/features/user/marriage/view/widget/about_me.dart';
import 'package:tayseer/features/user/marriage/view/widget/bio_voice_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/education.dart';
import 'package:tayseer/features/user/marriage/view/widget/interests_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/religious.dart';

import 'widgets/MarriageProfileSkeleton .dart';

class MarriagefilePage extends StatefulWidget {
  final UserProfileModel? userProfile;
  final int initialTabIndex; // 0 = عرض, 1 = تعديل

  const MarriagefilePage({
    super.key,
    this.userProfile,
    this.initialTabIndex = 1, // Default to عرض
  });

  @override
  State<MarriagefilePage> createState() => _MarriagefilePageState();
}

class _MarriagefilePageState extends State<MarriagefilePage> {
  late int _selectedTabIndex;
  final ImagePicker _picker = ImagePicker();
  final int _maxImages = 5;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MarriageProfileCubit(
        getIt<MarriageProfileRepository>(),
        initialUserProfile: widget.userProfile,
      )..loadProfile(),
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<MarriageProfileCubit, MarriageProfileState>(
            listener: (context, state) {
              if (state.state == CubitStates.success &&
                  state.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  CustomSnackBar(
                    context,
                    text: state.successMessage!,
                    isSuccess: true,
                  ),
                );
              }
              if (state.state == CubitStates.failure &&
                  state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  CustomSnackBar(
                    context,
                    text: state.errorMessage!,
                    isError: true,
                  ),
                );
              }
            },
            builder: (context, state) {
              final cubit = context.read<MarriageProfileCubit>();

              // ════════════════════════════════════════════════════════════════
              // ⭐⭐⭐ UPDATED: Loading with Shimmer Skeleton
              // ════════════════════════════════════════════════════════════════
              if (state.isLoading && state.profile == null) {
                return Column(
                  children: [
                    // Fixed header remains visible during loading
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 10.h),
                      child: _buildFixedHeader(context),
                    ),
                    // Shimmer skeleton for content
                    const Expanded(child: MarriageProfileSkeleton()),
                  ],
                );
              }

              // ✅ Error
              if (state.state == CubitStates.failure && state.profile == null) {
                return _buildError(context, state.errorMessage);
              }

              final profile = state.profile;
              if (profile == null) {
                return const Center(child: Text('لا توجد بيانات'));
              }

              return Column(
                children: [
                  // ⭐⭐⭐ FIXED HEADER - AppBar + Toggle
                  Padding(
                  padding:  EdgeInsets.symmetric(horizontal:  24.h,vertical: 10.h),
                    child: _buildFixedHeader(context),
                  ),

                  // ⭐⭐⭐ DYNAMIC CONTENT - Changes based on tab
                  Expanded(
                    child: _selectedTabIndex == 1
                        ? _buildViewContent(profile)
                        : MarriageProfileEditView(
                            profile: profile,
                            state: state,
                            cubit: cubit,
                            maxImages: _maxImages,
                            selectedTabIndex: _selectedTabIndex,
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ FIXED HEADER - يبقى ثابت دايماً
  // ════════════════════════════════════════════════════════════════

  Widget _buildFixedHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // AppBar
          SimpleAppBar(title: "الملف الشخصى", isLargeTitle: true),
          SizedBox(height: 5.h),
          // Toggle Tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
            child: CustomToggleTabBar(
              firstTabText:"تعديل" ,
              secondTabText: "عرض",
              initialIndex: _selectedTabIndex,
              onTabChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ VIEW CONTENT - المحتوى في وضع العرض
  // ════════════════════════════════════════════════════════════════

  Widget _buildViewContent(MarriageUserProfileModel profile) {
    final images = profile.userMedia?.images ?? [];
    final displayImages = images.length > 5 ? images.sublist(0, 5) : images;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.0.w),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header with images
          _buildViewHeader(profile),

          // About Me
          _buildSliverPadding(
            child: AboutMeSection(items: _buildAboutMeItems(profile)),
          ),

          // Education
          _buildSliverPadding(
            child: EducationSection(items: _buildEducationItems(profile)),
          ),

          // Goals
          if (profile.yourGoals != null)
            _buildSliverPadding(
              child: MarriageLifeEventsSection(
                titleName: "أهدافي",
                events: _buildTimelineEvents(profile.yourGoals!),
              ),
            ),
          // ===== 6. Additional Image =====
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            sliver: SliverToBoxAdapter(
              child: displayImages.isNotEmpty
                  ? AdditionalImageSection(
                      imageUrl: displayImages.length > 1
                          ? displayImages[1]
                          : displayImages[0],
                    )
                  : const SizedBox.shrink(), // في حال كانت القائمة فارغة تماماً
            ),
          ),

          // Religious
          _buildSliverPadding(
            child: ReligiousSection(tags: _buildReligiousTags(profile)),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            sliver: SliverToBoxAdapter(
              child: VideoSection(
                videoUrl: profile.userMedia?.video,

              ),
            ),
          ),

          // Interests
          if (profile.hobbies.isNotEmpty)
            _buildSliverPadding(
              child: InterestsSection(interests: _buildInterestsItems(profile)),
            ),

          // Bio
          if (profile.myDescription != null &&
              profile.myDescription!.isNotEmpty)
            _buildSliverPadding(
              child: BioVoiceSection(
                bioText: profile.myDescription!,
                audioPath: profile.userMedia?.audio ?? "",
              ),
            ),
    SliverToBoxAdapter(child: SizedBox(height: 50.h)),

          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              height: 113.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.kWhiteColor.withOpacity(0.7),
                    AppColors.primary50,
                    AppColors.primary100,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary300,
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              "هل تزوجت بواسطة",
                              style: Styles.textStyle16.copyWith(
                                color: AppColors.primary600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Stack(
                              children: [
                                Text(
                                  "تيسير",
                                  style: Styles.textStyle26Bold.copyWith(
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 3.w
                                      ..color = Color(0xFFAC1A36),
                                  ),
                                ),
                                Text(
                                  "تيسير",
                                  style: Styles.textStyle26Bold.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "تواصل معنا واحصل علي مكافأة مالية",
                          style: Styles.textStyle12.copyWith(
                            color: AppColors.secondary700,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: () {
                      log("تواصل معنا button tapped");
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.white, width: 2.w),
                      ),
                      child: Container(
                        width: 125.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary300,
                              blurRadius: 11,
                              spreadRadius: 0,
                            ),
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary200,
                              AppColors.primary200,
                              AppColors.primary100,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "تواصل معنا",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),
    );
  }


  // ════════════════════════════════════════════════════════════════
  // VIEW CONTENT HELPERS
  // ════════════════════════════════════════════════════════════════
  Widget _buildViewHeader(MarriageUserProfileModel profile) {
    final images = profile.userMedia?.images ?? [];
    final displayImages = images.length > 5 ? images.sublist(0, 5) : images;

    return SliverToBoxAdapter(
      child: Column(
        children: [
          // Main image area with Stack for the progress card
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 650.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(33.r),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      displayImages.isNotEmpty
                          ? displayImages[0]
                          : 'https://via.placeholder.com/400',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // ✅ قسم إكمال البيانات المضاف (Progress Section)
              _buildCompletionCard(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 24.h),
      // استخدام ClipRRect لتطبيق تأثير الفلتر داخل الحدود فقط
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ), // تأثير التغبيش الزجاجي
          child: Container(
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
              // تدرج لوني أبيض شفاف ليعطي إحساس الزجاج
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. الخط الزمني المطور
                _buildEnhancedTimeline(progress: 0.2),

                SizedBox(height: 20.h),
                Row(
                  children: [
                    Column(
                      children: [
                        // 2. النص الرئيسي (العنوان)
                        Text(
                         context.tr('complete_profile_100_percent'), 
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary600, // وردي غامق احترافي
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // 3. النص الوصفي
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Text(
                            context.tr('complete_profile_description'),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.secondary700,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Spacer(),
                    // 4. زر الإكمال المطور بظلال متوهجة
                    _buildGradientButton(),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTimeline({required double progress}) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // 1. الخط الخلفي الباهت (Base Line)
            Container(
              height: 6.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            // 2. الخط الملون المتدرج (Progress Line)
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFFFFC107)],
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE91E63).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. النقاط (الدروع)
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

                      // Number badge on top
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
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: isReached
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        width: 26.r,
                        height: 26.r,
                        decoration: BoxDecoration(
                          color: isReached
                              ? const Color(0xFFFFD54F)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isReached
                                ? Colors.orange
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow: isReached
                              ? [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.4),
                                    blurRadius: 6,
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          Icons.shield,
                          size: 14.r,
                          color: isReached
                              ? Colors.white
                              : Colors.grey.shade400,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "${(4 - index) * 25}%",
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: isReached
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isReached ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradientButton() {
    return Container(
      child: GestureDetector(
        onTap: () {
          log("إكمال البيانات button tapped");
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.white, width: 2.w),
          ),
          child: Container(
            width: 125.w,
            height: 36.h,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary300,
                  blurRadius: 11,
                  spreadRadius: 0,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary200,
                  AppColors.primary200,
                  AppColors.primary100,
                ],
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: Text(
           context.tr('complete_your_profile_bott'), // بدلاً من "إكمال البيانات"
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverPadding({required Widget child}) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      sliver: SliverToBoxAdapter(child: child),
    );
  }

  List<Map<String, dynamic>> _buildAboutMeItems(profile) {
    return [
      if (profile.aboutMe?.socialStatus != null)
        {
          'icon': AssetsData.kdrawingIcon,
          'label': profile.aboutMe!.socialStatus,
        },
      if (profile.aboutMe?.weight != null)
        {'icon': AssetsData.kdrawingIcon, 'label': profile.aboutMe?.weight},
      if (profile.aboutMe?.skinColor != null)
        {
          'icon': AssetsData.kdrawingIcon,
          'label': "البشرة ${profile.aboutMe!.skinColor}",
        },

      if (profile.aboutMe?.healthStatus != null)
        {
          'icon': AssetsData.kwritingIcon,
          'label': profile.aboutMe!.healthStatus,
        },
    ];
  }

  List<Map<String, dynamic>> _buildEducationItems(profile) {
    return [
      if (profile.professionalLife?.educationLevel != null)
        {
          'icon': AssetsData.kwritingIcon,
          'label': profile.professionalLife!.educationLevel,
        },
      if (profile.professionalLife?.job != null)
        {
          'icon': AssetsData.kwritingIcon,
          'label': profile.professionalLife!.job,
        },
    ];
  }

  List<Map<String, dynamic>> _buildTimelineEvents(YourGoals goals) {
    final List<Map<String, dynamic>> events = [];

    if (goals.travel != null && goals.travel!.isNotEmpty) {
      events.add({
        'timeLabel': goals.travel,
        'goalType': 'travel',
      });
    }

    if (goals.children != null && goals.children!.isNotEmpty) {
      events.add({
        'timeLabel': goals.children,
        'goalType': 'المهر  ',
      });
    }

    if (goals.engagement != null && goals.engagement!.isNotEmpty) {
      events.add({
        'timeLabel': goals.engagement,
        'goalType': 'engagement',
      });
    }

    if (goals.marry != null && goals.marry!.isNotEmpty) {
      events.add({
        'timeLabel': goals.marry,
        'goalType': 'marry',
      });
    }

    return events;
  }

  List<Map<String, dynamic>> _buildReligiousTags(profile) {
    return [
      if (profile.aboutMe?.religiousCommitment != null)
        {
          'icon': AssetsData.kdrawingIcon,
          'label': profile.aboutMe!.religiousCommitment,
        },
      if (profile.aboutMe?.smoker != null)
        {
          'icon': AssetsData.kwritingIcon,
          'label': "${profile.aboutMe!.smoker} ادخن",
        },
    ];
  }

  List<Map<String, dynamic>> _buildInterestsItems(profile) {
    return profile.hobbies
        .map<Map<String, dynamic>>(
          (hobby) => {'icon': AssetsData.kmusicIcon, 'label': hobby},
        )
        .toList();
  }

  Widget _buildError(BuildContext context, String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.w, color: AppColors.errorColor),
          Gap(16.h),
          Text(
            message ?? 'حدث خطأ في تحميل البيانات',
            textAlign: TextAlign.center,
            style: Styles.textStyle16,
          ),
          Gap(24.h),
          CustomBotton(
            title: 'رجوع',
            onPressed: () => Navigator.pop(context),
            width: 120.w,
            height: 48.h,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Video Section Classes (same as before)
// ════════════════════════════════════════════════════════════════

class AppVideo extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final bool muted;
  final Function(VideoPlayerController)? onControllerReady;
  final Function(String)? onError;

  const AppVideo(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.autoPlay = false,
    this.looping = true,
    this.showControls = false,
    this.muted = false,
    this.onControllerReady,
    this.onError,
  });

  @override
  State<AppVideo> createState() => _AppVideoState();
}

class _AppVideoState extends State<AppVideo> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    if (widget.url.isEmpty || !widget.url.startsWith('http')) {
      setState(() {
        _hasError = true;
        _errorMessage = 'رابط الفيديو غير صالح';
      });
      if (widget.onError != null) {
        widget.onError!(_errorMessage!);
      }
      return;
    }

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize()
            .then((_) {
              if (mounted) {
                setState(() => _isInitialized = true);
                _controller!.setLooping(widget.looping);
                _controller!.setVolume(widget.muted ? 0 : 1);

                if (widget.autoPlay) {
                  _controller!.play();
                }

                if (widget.onControllerReady != null) {
                  widget.onControllerReady!(_controller!);
                }
              }
            })
            .catchError((error) {
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _errorMessage = 'فشل تحميل الفيديو: ${error.toString()}';
                });
                if (widget.onError != null) {
                  widget.onError!(_errorMessage!);
                }
              }
            });

      _controller?.addListener(() {
        if (_controller!.value.hasError && mounted) {
          setState(() {
            _hasError = true;
            _errorMessage =
                _controller!.value.errorDescription ??
                'حدث خطأ في تشغيل الفيديو';
          });
          if (widget.onError != null) {
            widget.onError!(_errorMessage!);
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'خطأ في إنشاء مشغل الفيديو: ${e.toString()}';
        });
        if (widget.onError != null) {
          widget.onError!(_errorMessage!);
        }
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _errorMessage ?? 'حدث خطأ',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade300, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
              const SizedBox(height: 12),
              Text(
                'جاري تحميل الفيديو...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: widget.fit,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}

class VideoSection extends StatefulWidget {
  final String? videoUrl;
  final VoidCallback? onDelete;
  final VoidCallback? onUpload;
  final bool showControls;

  const VideoSection({
    super.key,
    this.videoUrl,
    this.onDelete,
    this.onUpload,
    this.showControls = true,
  });

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  VideoPlayerController? _controller;
  bool isPlaying = false;
  bool showOverlay = true;
  bool hasError = false;
  bool isInitializing = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    if (hasValidVideo) {
      _initializeVideo();
    } else {
      isInitializing = false;
    }
  }

  @override
  void didUpdateWidget(VideoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      if (hasValidVideo) {
        setState(() {
          isInitializing = true;
          hasError = false;
          errorMessage = null;
        });
        _initializeVideo();
      }
    }
  }

  bool get hasValidVideo {
    return widget.videoUrl != null &&
        widget.videoUrl!.isNotEmpty &&
        (widget.videoUrl!.startsWith('http://') ||
            widget.videoUrl!.startsWith('https://'));
  }

  void _initializeVideo() async {
    if (!hasValidVideo) {
      setState(() {
        isInitializing = false;
        hasError = true;
        errorMessage = 'رابط الفيديو غير صالح';
      });
      return;
    }

    try {
      _disposeController();

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl!),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      _controller!.addListener(_videoListener);

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          isInitializing = false;
          hasError = false;
        });

        _controller!.setLooping(true);
        _controller!.setVolume(1.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isInitializing = false;
          hasError = true;
          errorMessage = 'فشل في تحميل الفيديو: ${e.toString()}';
        });
      }
      debugPrint('❌ Video initialization error: $e');
    }
  }

  void _videoListener() {
    if (!mounted) return;

    if (_controller!.value.hasError) {
      setState(() {
        hasError = true;
        errorMessage =
            _controller!.value.errorDescription ?? 'خطأ في تشغيل الفيديو';
      });
      debugPrint(
        '❌ Video playback error: ${_controller!.value.errorDescription}',
      );
    }

    if (isPlaying != _controller!.value.isPlaying) {
      setState(() {
        isPlaying = _controller!.value.isPlaying;
      });
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        showOverlay = true;
      } else {
        _controller!.play();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _controller!.value.isPlaying) {
            setState(() => showOverlay = false);
          }
        });
      }
    });
  }

  void _seek(Duration duration) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final currentPos = _controller!.value.position;
    final totalDuration = _controller!.value.duration;
    final newPos = currentPos + duration;

    _controller!.seekTo(
      newPos < Duration.zero
          ? Duration.zero
          : (newPos > totalDuration ? totalDuration : newPos),
    );
  }

  void _disposeController() {
    _controller?.removeListener(_videoListener);
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!hasValidVideo) {
      return _buildEmptyState();
    }

    if (hasError) {
      return _buildErrorState();
    }

    if (isInitializing) {
      return _buildLoadingState();
    }

    return _buildVideoPlayer();
  }

  Widget _buildEmptyState() {
    return Container(
      height: 250.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_off_outlined,
            size: 60.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 12.h),
          Text(
            'لم يتم رفع فيديو بعد',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.onUpload != null) ...[
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: widget.onUpload,
              icon: const Icon(Icons.upload),
              label: const Text('رفع فيديو'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 250.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60.sp, color: Colors.red.shade400),
          SizedBox(height: 12.h),
          Text(
            'فشل تحميل الفيديو',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (errorMessage != null) ...[
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp, color: Colors.red.shade600),
              ),
            ),
          ],
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                hasError = false;
                errorMessage = null;
                isInitializing = true;
              });
              _initializeVideo();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 250.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.black87,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 3.w),
            SizedBox(height: 12.h),
            Text(
              'جاري تحميل الفيديو...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return VisibilityDetector(
      key: Key(widget.videoUrl!),
      onVisibilityChanged: (info) {
        if (!mounted ||
            _controller == null ||
            !_controller!.value.isInitialized) {
          return;
        }

        if (info.visibleFraction > 0.6) {
          if (!_controller!.value.isPlaying) {
            _controller!.play();
          }
        } else {
          if (_controller!.value.isPlaying) {
            _controller!.pause();
            setState(() => showOverlay = true);
          }
        }
      },
      child: Container(
        height: 250.h,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_controller != null && _controller!.value.isInitialized)
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),

              if (widget.onDelete != null)
                Positioned(top: 10.h, right: 10.w, child: _buildDeleteButton()),

              GestureDetector(
                onTap: () {
                  setState(() => showOverlay = !showOverlay);
                },
                child: Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

              if (widget.showControls && (showOverlay || !isPlaying))
                _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: const Text('تأكيد الحذف'),
              content: const Text('هل تريد حذف هذا الفيديو؟'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('إلغاء'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('حذف', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );

          if (confirm == true && widget.onDelete != null) {
            widget.onDelete!();
          }
        },
        customBorder: const CircleBorder(),
        child: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.delete_outline, color: Colors.white, size: 20.sp),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCircleButton(
              icon: Icons.replay_10_rounded,
              onTap: () => _seek(const Duration(seconds: -10)),
            ),
            Gap(20.w),
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.black87,
                  size: 35.sp,
                ),
              ),
            ),
            Gap(20.w),
            _buildCircleButton(
              icon: Icons.forward_10_rounded,
              onTap: () => _seek(const Duration(seconds: 10)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 45.w,
          height: 45.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.black87, size: 24.sp),
        ),
      ),
    );
  }
}