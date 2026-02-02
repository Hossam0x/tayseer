// marriage_profile_page.dart - UNIFIED PAGE
// ════════════════════════════════════════════════════════════════
// ✅ صفحة واحدة - Toggle بين العرض والتعديل
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
import 'package:tayseer/my_import.dart';

// ⭐⭐⭐ Import sections من صفحة العرض
import 'package:tayseer/features/user/marriage/view/widget/about_me.dart';
import 'package:tayseer/features/user/marriage/view/widget/bio_voice_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/education.dart';
import 'package:tayseer/features/user/marriage/view/widget/interests_section.dart';
// import 'package:tayseer/features/user/marriage/view/widget/life_event_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/religious.dart';

class MarriagefilePage extends StatefulWidget {
  final UserProfileModel? userProfile;
  final int initialTabIndex; // 0 = عرض, 1 = تعديل

  const MarriagefilePage({
    super.key,
    this.userProfile,
    this.initialTabIndex = 0, // Default to عرض
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

              // ✅ Loading
              if (state.isLoading && state.profile == null) {
                return const Center(child: CircularProgressIndicator());
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
                  _buildFixedHeader(context),

                  // ⭐⭐⭐ DYNAMIC CONTENT - Changes based on tab
                  Expanded(
                    child: _selectedTabIndex == 0
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
              firstTabText: "عرض",
              secondTabText: "تعديل",
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
                          "يجب إكمال البيانات بنسبة 100%.",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary600, // وردي غامق احترافي
                            // letterSpacing: -0.5,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // 3. النص الوصفي
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Text(
                            "ادخل البيانات الشخصية كاملة حتى تتمكن من \nإيجاد شريكك المناسب",
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

                // // 4. زر الإكمال المطور بظلال متوهجة
                // _buildGradientButton(),
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
            // نستخدم Alignment.centerLeft لضمان البداية من اليسار دائماً
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

            // 3. النقاط (الدروع) مرتبة من 0% (يسار) إلى 100% (يمين)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                int badgeNumber = index + 1;
                int totalSteps = 5;
                int reversedNumber = totalSteps - badgeNumber + 1;
                // حساب النسبة لكل نقطة (0, 0.25, 0.50, 0.75, 1.0)
                final reversedIndex = 4 - index;
                double pointProgress = reversedIndex / 4;
                bool isReached = pointProgress <= progress;
                return Align(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      SizedBox(height: 6.h),

                      // ⭐⭐⭐ Number badge on top
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isReached
                                ? const Color(0xFFFFC107) // ذهبي
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
                            reversedNumber.toString().padLeft(
                              2,
                              '0',
                            ), // 05, 04, 03...
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
                        "${(4 - index) * 25}%", // يطبع 0%, 25%, 50%, 75%, 100%
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
          log("تواصل معنا button tapped");
          // Handle button tap
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
                  color: AppColors
                      .primary300, // Light pink at bottom (primary50/secondary200)

                  blurRadius: 11,
                  spreadRadius: 0,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary200, // Your primary color
                  AppColors.primary200, // Your secondary color
                  AppColors.primary100, // Your secondary color
                ],
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: Text(
              "إكمال البيانات",
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

  // ✅ Helper function to build timeline events from YourGoals
  List<Map<String, dynamic>> _buildTimelineEvents(YourGoals goals) {
    final List<Map<String, dynamic>> events = [];

    // ترتيب الأهداف من اليمين لليسار (حسب الـ RTL)
    // الترتيب: توافق ← تواصل ← خطوبة ← زواج

    // 1. توافق (Compatibility) - usually happens first
    if (goals.travel != null && goals.travel!.isNotEmpty) {
      events.add({
        'timeLabel': goals.travel, // مثلاً: "خلال 3 أشهر"
        'goalType': 'travel',
      });
    }

    // 2. تواصل (Communication)
    if (goals.children != null && goals.children!.isNotEmpty) {
      events.add({
        'timeLabel': goals.children, // مثلاً: "خلال 6 أشهر"
        'goalType': 'المهر  ',
      });
    }

    // 3. خطوبة (Engagement)
    if (goals.engagement != null && goals.engagement!.isNotEmpty) {
      events.add({
        'timeLabel': goals.engagement, // مثلاً: "خلال سنة"
        'goalType': 'engagement',
      });
    }

    // 4. زواج (Marriage)
    if (goals.marry != null && goals.marry!.isNotEmpty) {
      events.add({
        'timeLabel': goals.marry, // مثلاً: "خلال سنتين"
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
// updated_app_video.dart
// ════════════════════════════════════════════════════════════════
// ✅ AppVideo محسّن مع معالجة الأخطاء وحالات التحميل
// ════════════════════════════════════════════════════════════════

class AppVideo extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final bool muted;
  final Function(VideoPlayerController)? onControllerReady;
  final Function(String)? onError; // ⭐⭐⭐ NEW: callback للأخطاء

  const AppVideo(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.autoPlay = false,
    this.looping = true,
    this.showControls = false,
    this.muted = false,
    this.onControllerReady,
    this.onError, // ⭐⭐⭐ NEW
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
    // ⭐⭐⭐ التحقق من صحة الـ URL
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

                // ⭐ إرسال الـ controller للـ parent
                if (widget.onControllerReady != null) {
                  widget.onControllerReady!(_controller!);
                }
              }
            })
            .catchError((error) {
              // ⭐⭐⭐ معالجة أخطاء التحميل
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

      // ⭐⭐⭐ الاستماع لأخطاء التشغيل
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
      // ⭐⭐⭐ معالجة أخطاء إنشاء الـ controller
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
    // ⭐⭐⭐ حالة الخطأ
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

    // ⭐⭐⭐ حالة التحميل
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

    // ⭐⭐⭐ عرض الفيديو
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
// fixed_video_section.dart
// ════════════════════════════════════════════════════════════════
// ✅ VideoSection محسّن مع معالجة حالات null والأخطاء
// fixed_video_section.dart
// ════════════════════════════════════════════════════════════════
// ✅ VideoSection محسّن مع معالجة شاملة للأخطاء
// ════════════════════════════════════════════════════════════════

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
      // تنظيف أي controller سابق
      _disposeController();

      // إنشاء controller جديد
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl!),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      // إضافة listener للأخطاء
      _controller!.addListener(_videoListener);

      // تهيئة الفيديو
      await _controller!.initialize();

      if (mounted) {
        setState(() {
          isInitializing = false;
          hasError = false;
        });

        // إعدادات الفيديو
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

    // تحديث حالة التشغيل
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
        // إخفاء الأزرار بعد ثانيتين
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
    // حالة: لا يوجد فيديو
    if (!hasValidVideo) {
      return _buildEmptyState();
    }

    // حالة: خطأ في التحميل
    if (hasError) {
      return _buildErrorState();
    }

    // حالة: جاري التحميل
    if (isInitializing) {
      return _buildLoadingState();
    }

    // حالة: عرض الفيديو
    return _buildVideoPlayer();
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ حالة عدم وجود فيديو
  // ════════════════════════════════════════════════════════════════
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

  // ════════════════════════════════════════════════════════════════
  // ⭐ حالة الخطأ
  // ════════════════════════════════════════════════════════════════
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

  // ════════════════════════════════════════════════════════════════
  // ⭐ حالة التحميل
  // ════════════════════════════════════════════════════════════════
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

  // ════════════════════════════════════════════════════════════════
  // ⭐ مشغل الفيديو
  // ════════════════════════════════════════════════════════════════
  Widget _buildVideoPlayer() {
    return VisibilityDetector(
      key: Key(widget.videoUrl!),
      onVisibilityChanged: (info) {
        if (!mounted ||
            _controller == null ||
            !_controller!.value.isInitialized) {
          return;
        }

        // تشغيل تلقائي عند الظهور
        if (info.visibleFraction > 0.6) {
          if (!_controller!.value.isPlaying) {
            _controller!.play();
          }
        } else {
          // إيقاف عند الاختفاء
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
              // الفيديو
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

              // زر الحذف
              if (widget.onDelete != null)
                Positioned(top: 10.h, right: 10.w, child: _buildDeleteButton()),

              // طبقة شفافة للتحكم
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

              // أزرار التحكم
              if (widget.showControls && (showOverlay || !isPlaying))
                _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐ زر الحذف
  // ════════════════════════════════════════════════════════════════
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

  // ════════════════════════════════════════════════════════════════
  // ⭐ أزرار التحكم
  // ════════════════════════════════════════════════════════════════
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
