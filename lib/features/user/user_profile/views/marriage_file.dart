import 'dart:ui';
import 'package:tayseer/core/constant/marriage_constants.dart';
import 'package:tayseer/core/widgets/custom_toggle_tab_bar.dart';
import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/marriage/view/widget/video_section.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/marriage_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/marriage_profile_edit_view.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/complete_marriage_file.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/dash_border.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/marriage_life_events_section.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/marriage_reward_card.dart';
import 'package:tayseer/my_import.dart';
// ⭐⭐⭐ Import sections
import 'package:tayseer/features/user/marriage/view/widget/about_me.dart';
import 'package:tayseer/features/user/marriage/view/widget/bio_voice_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/education.dart';
import 'package:tayseer/features/user/marriage/view/widget/interests_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/religious.dart';
import 'widgets/MarriageProfileSkeleton .dart';
import 'widgets/profile_statistics_cards.dart';

class MarriagefilePage extends StatefulWidget {
  final UserProfileModel? userProfile;
  final int initialTabIndex;

  const MarriagefilePage({
    super.key,
    this.userProfile,
    this.initialTabIndex = 1,
  });

  @override
  State<MarriagefilePage> createState() => _MarriagefilePageState();
}

class _MarriagefilePageState extends State<MarriagefilePage> {
  late int _selectedTabIndex;
  final int _maxImages = 5;
  String? _scrollToSection;

  // ⭐⭐⭐ DEFAULT IMAGE URL
  static const String _defaultImageUrl =
      "https://cdn-icons-png.flaticon.com/512/149/149071.png";

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ NEW: دالة ترجمة عامة
  // ════════════════════════════════════════════════════════════════
  String _translateValue(String? value) {
    if (value == null || value.isEmpty) return '';

    final translated = context.tr(value);

    if (translated == value && !value.contains(' ')) {
      return value;
    }

    return translated;
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ CALCULATE TOTAL PROGRESS (Server + Media)
  // ════════════════════════════════════════════════════════════════
 double _calculateTotalProgress(MarriageUserProfileModel profile) {
    // Questions: max 25%
    double questionProgress = (profile.answerCompletedPercentage ?? 0).toDouble();
    questionProgress = questionProgress.clamp(0, 25);

    // Images: كل صورة 5%, max 20% (4 صور)
    int imageBonus = 0;
    final images = profile.userMedia?.images ?? [];
    if (images.isNotEmpty) {
      final imageCount = images.length > 4 ? 4 : images.length;
      imageBonus = imageCount * 5;
    }

    // Video: 25%
    int videoBonus = 0;
    bool hasVideo =
        profile.userMedia?.video != null &&
        profile.userMedia!.video!.isNotEmpty;
    if (hasVideo) videoBonus = 25;

    // Audio: 25%
    int audioBonus = 0;
    bool hasAudio =
        profile.userMedia?.audio != null &&
        profile.userMedia!.audio!.isNotEmpty;
    if (hasAudio) audioBonus = 25;

    // Verification: 5%
    int verificationBonus = (profile.isVerified == true) ? 5 : 0;

    double totalProgress =
        questionProgress + imageBonus + videoBonus + audioBonus + verificationBonus;

    // لا تتعدى 100
    return totalProgress.clamp(0, 100);
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ NEW: Get Main Display Image
  // ════════════════════════════════════════════════════════════════
  String _getMainDisplayImage(MarriageUserProfileModel profile) {
    // Priority 1: singleImage
    if (profile.userMedia?.singleImage != null &&
        profile.userMedia!.singleImage!.isNotEmpty) {
      debugPrint('📸 [MAIN_IMAGE] Using singleImage');
      return profile.userMedia!.singleImage!;
    }

    // // Priority 2: First image from images list
    // final images = profile.userMedia?.images ?? [];
    // if (images.isNotEmpty) {
    //   debugPrint('📸 [MAIN_IMAGE] Using first image from list');
    //   return images[0];
    // }

    // Priority 3: Default placeholder
    debugPrint('📸 [MAIN_IMAGE] Using default placeholder');
    return _defaultImageUrl;
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ NEW: Get Secondary Display Image
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MarriageProfileCubit(
        getIt<MarriageProfileRepository>(),
        initialUserProfile: widget.userProfile,
      )..loadProfile(),
      // ✅ استخدم builder عشان تاخد context جديد يشوف الـ provider
      child: Builder(
        // ✅ Builder عادي بدل builder parameter
        builder: (context) => WillPopScope(
          onWillPop: () async {
            // ✅ اشتغل لو المستخدم زار Edit tab في أي وقت (مش لازم يكون فيه دلوقتي)
            final cubit = context.read<MarriageProfileCubit>();
            final state = cubit.state;

            final hasSingleImage =
                (state.profile?.userMedia?.singleImage != null &&
                    state.profile!.userMedia!.singleImage!.isNotEmpty) ||
                state.pendingSingleImage != null;

            final hasUnsavedChanges =
                state.pendingSingleImage != null ||
                state.deletedSingleImageUrl != null ||
                state.pendingImages.isNotEmpty ||
                state.deletedImageUrls.isNotEmpty ||
                state.pendingVideo != null ||
                state.pendingDeleteVideo ||
                state.pendingAudio != null ||
                  state.hasUnsavedFields||
                state.pendingDeleteAudio;


            // ✅ شيل الشرط _selectedTabIndex == 0
            // لو فيه تغييرات، اتحقق منها بغض النظر عن الـ tab الحالي
            if (hasUnsavedChanges || !hasSingleImage) {
              if (state.profile == null) return true;

              if (!hasSingleImage) {
                _showMustAddImageDialog(context, cubit, state.profile!);
                return false;
              }
              if (hasUnsavedChanges) {
                _showUnsavedChangesDialog(context, cubit);
                return false;
              }
            }

            return true;
          },
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

                  if (state.isLoading && state.profile == null) {
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.h,
                            vertical: 10.h,
                          ),
                          child: _buildFixedHeader(context),
                        ),
                        const Expanded(child: MarriageProfileSkeleton()),
                      ],
                    );
                  }

                  if (state.state == CubitStates.failure &&
                      state.profile == null) {
                    return _buildError(context, state.errorMessage);
                  }

                  final profile = state.profile;
                  if (profile == null) {
                    return Center(child: Text(context.tr("data_load_error")));
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.h,
                          vertical: 10.h,
                        ),
                        child: _buildFixedHeader(context),
                      ),
                      Expanded(
                        child: _selectedTabIndex == 1
                            ? _buildViewContent(profile)
                            : MarriageProfileEditView(
                                profile: profile,
                                state: state,
                                cubit: cubit,
                                maxImages: _maxImages,
                                selectedTabIndex: _selectedTabIndex,
                                scrollToSection: _scrollToSection,
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // في MarriagefilePage
  void _showMustAddImageDialog(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile,
  ) {
    CustomshowDialogWithImage(
      context,
      title: context.tr('add_main_image_required'),
      supTitle: context.tr('must_add_main_image_before_exit'),
      icon: Icons.image_outlined,
      iconColor: Colors.orange,
      iconBackgroundColor: Colors.orange.withOpacity(0.1),
      bottonText: context.tr('add_image'),
      showCancelButton: false,
      onPressed: () async {
        // ✅ اضطر تعمل setState لو الـ tab مش على edit
        setState(() => _selectedTabIndex = 0);
      },
    );
  }

  void _showUnsavedChangesDialog(
    BuildContext context,
    MarriageProfileCubit cubit,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 36.w,
              ),
            ),
            Gap(12.h),
            Text(
              context.tr('unsaved_changes'),
              textAlign: TextAlign.center,
              style: Styles.textStyle18Meduim,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('unsaved_changes_message'),
              textAlign: TextAlign.center,
              style: Styles.textStyle16.copyWith(
                color: AppColors.kscandryTextColor,
                height: 1.5,
              ),
            ),
            Gap(12.h),
            // _buildPendingChangesSummary(context),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        actions: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                cubit.discardAllPending();
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text(
                context.tr('discard_and_exit'),
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                cubit.saveProfile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              child: Text(
                context.tr('save_and_exit'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                context.tr('cancel'),
                style: TextStyle(
                  color: AppColors.kscandryTextColor,
                  fontSize: 15.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SimpleAppBar(title: context.tr('my_profile'), isLargeTitle: true),
          SizedBox(height: 5.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
            child: CustomToggleTabBar(
              firstTabText: context.tr("edit"),
              secondTabText: context.tr("show"),
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

Widget _buildViewContent(MarriageUserProfileModel profile) {
    final totalProgress = _calculateTotalProgress(profile);
    final progressFraction = totalProgress / 100;

    // ⭐ Extract images list once
    final images = profile.userMedia?.images ?? [];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.0.w),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Completion card at the very top
          if (totalProgress < 100)
            SliverToBoxAdapter(
              child: _buildCompletionCard(progressFraction, profile: profile),
            ),

          _buildViewHeader(profile),

          _buildSliverPadding(
            child: (profile.inReview == true)
                ? Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, 0.55),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.all(5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppImage(AssetsData.underreviewIcon, width: 24.w),
                          Gap(5.w),
                          Text(
                            context.tr("under_review"),
                            style: Styles.textStyle18SemiBold,
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),

          // Statistics Cards
          _buildSliverPadding(
            child: ProfileStatisticsCards(
              upgradesCount: profile.interactionCount ?? 0,
              resultsCount: profile.regredsCount ?? 0,
              onUpgradesTap: () =>
                  context.pushNamed(AppRouter.kinteractionSubscriptionView),
              onResultsTap: () =>
                  context.pushNamed(AppRouter.kinteractionSubscriptionView),
            ),
          ),

          // About Me
          _buildSliverPadding(
            child: AboutMeSection(items: _buildAboutMeItems(profile)),
          ),

          // ⭐ IMAGE 0 — بعد نبذة عني
          if (images.isNotEmpty)
            _buildImageSection(images[0], 'profile_image_0'),

          // Education
          _buildSliverPadding(
            child: EducationSection(items: _buildEducationItems(profile)),
          ),

          // Goals
          if (profile.yourGoals != null)
            _buildSliverPadding(
              child: MarriageLifeEventsSection(
                titleName: context.tr("my_goals"),
                events: _buildTimelineEvents(profile.yourGoals!),
              ),
            ),

          // ⭐ IMAGE 1 — بعد الأهداف (مكان الصورة الثانوية القديمة)
          if (images.length > 1)
            _buildImageSection(images[1], 'profile_image_1'),

          // Religious
          _buildSliverPadding(
            child: ReligiousSection(tags: _buildReligiousTags(profile)),
          ),

          // Video
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            sliver: SliverToBoxAdapter(
              child: VideoSection(videoUrl: profile.userMedia?.video),
            ),
          ),

          // Hobbies / Interests
          if (profile.hobbies.isNotEmpty)
            _buildSliverPadding(
              child: InterestsSection(
                title: 'my_interests',
                interests: _buildInterestsItems(profile),
              ),
            ),

          // Faith
          if (profile.faith.isNotEmpty)
            _buildSliverPadding(
              child: InterestsSection(
                title: 'choose_faith',
                interests: _buildFaithItems(profile),
              ),
            ),

          // ⭐ IMAGE 2 — بعد الإيمان
          if (images.length > 2)
            _buildImageSection(images[2], 'profile_image_2'),

          // Bio + Voice
          if (profile.myDescription != null &&
              profile.myDescription!.isNotEmpty)
            _buildSliverPadding(
              child: BioVoiceSection(
                bioText: profile.myDescription!,
                audioPath: profile.userMedia?.audio ?? "",
              ),
            ),

          // ⭐ IMAGE 3 — بعد البايو والتسجيل الصوتي
          if (images.length > 3)
            _buildImageSection(images[3], 'profile_image_3'),

          SliverToBoxAdapter(child: SizedBox(height: 30.h)),
          SliverToBoxAdapter(child: MarriageRewardCard()),
          SliverToBoxAdapter(child: SizedBox(height: 140.h)),
        ],
      ),
    );
  }
  Widget _buildVerifiedCard() {
    return CustomPaint(
      painter: DashedBorderPainter(
        color: Color(0xFFE91E63).withOpacity(0.4),
        strokeWidth: 1.5,
        dashWidth: 6,
        dashSpace: 4,
        borderRadius: 12.r,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Color(0xFFFFF0F3),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(AssetsData.verIcon, height: 80.h),
            // SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('verified_profile_title'), // "هذا الملف موثق"
                    style: Styles.textStyle16Bold.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary400,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    context.tr(
                      'verified_profile_desc',
                    ), // "تم التأكد من صحة جميع البيانات الشخصية من قبل التطبيق"
                    textAlign: TextAlign.right,
                    style: Styles.textStyle16Bold.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondary400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ NEW: Secondary Image Section with proper logic
  // ════════════════════════════════════════════════════════════════

   Widget _buildImageSection(String imageUrl, String heroTag) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      sliver: SliverToBoxAdapter(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImageView(
                  imageUrl: imageUrl,
                  heroTag: heroTag,
                  userName: context.tr("my_profile"),
                ),
              ),
            );
          },
          child: Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                height: 400.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewHeader(MarriageUserProfileModel profile) {
    final mainImage = _getMainDisplayImage(profile);

    return SliverToBoxAdapter(
      child: Column(
        children: [
          GestureDetector(
            onTap: mainImage != _defaultImageUrl
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageView(
                          imageUrl: mainImage,
                          heroTag: 'profile_main_image',
                          userName: context.tr("my_profile"),
                        ),
                      ),
                    );
                  }
                : null,
            child: Hero(
              tag: 'profile_main_image',
              child: Container(
                height: 650.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(33.r),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(mainImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard(
    double progress, {
    required MarriageUserProfileModel profile,
  }) {
    // ⭐ Real percentage as integer (e.g. 65%)
    final int realPercent = (progress * 100).toInt();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 12.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(5.r),
            decoration: BoxDecoration(
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
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal:  8.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ⭐ Show real percentage dynamically
                          Text(
                            "${context.tr('complete_profile_100_percent')}$realPercent%",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            context.tr('complete_profile_description'),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.secondary700,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    _buildGradientButton(profile, progress: progress),
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

  Widget _buildGradientButton(
    MarriageUserProfileModel profile, {
    required double progress,
  }) {
    return GestureDetector(
      onTap: () async {
        String? selectedSection;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteMarriageFile(
              profile: profile,
              progress: progress,
              onNavigateToEdit: (section) {
                selectedSection = section;
                Navigator.pop(context);
              },
            ),
          ),
        );

        if (mounted && selectedSection != null) {
          setState(() {
            _selectedTabIndex = 0;
            _scrollToSection = selectedSection;
          });

          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _scrollToSection = null;
              });
            }
          });
        }
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
            context.tr('complete_your_profile_bott'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
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

  List<Map<String, dynamic>> _buildAboutMeItems(
    MarriageUserProfileModel profile,
  ) {
    return [
      if (profile.aboutMe?.socialStatus != null)
        {
          'icon': AssetsData.kdrawingIcon,
          'label': _translateValue(profile.aboutMe!.socialStatus),
        },
      if (profile.aboutMe?.age != null)
        {
          'icon': AssetsData.kdrawingIcon,
          'label': "${context.tr('age')} ${profile.aboutMe?.age}",
        },
      if (profile.aboutMe?.skinColor != null)
        {
          'icon': AssetsData.kdrawingIcon,
          'label':
              "${context.tr('Skin')} ${_translateValue(profile.aboutMe!.skinColor)}",
        },
      if (profile.aboutMe?.healthStatus != null)
        {
          'icon': AssetsData.kwritingIcon,
          'label': _translateValue(profile.aboutMe!.healthStatus),
        },
    ];
  }

  List<Map<String, dynamic>> _buildEducationItems(
    MarriageUserProfileModel profile,
  ) {
    return [
      if (profile.professionalLife?.educationLevel != null)
        {
          'icon': AssetsData.kwritingIcon,
          'label': _translateValue(profile.professionalLife!.educationLevel),
        },
      if (profile.professionalLife?.job != null)
        {
          'icon': AssetsData.kwritingIcon,
          'label': _translateValue(profile.professionalLife!.job),
        },
    ];
  }

  List<Map<String, dynamic>> _buildTimelineEvents(YourGoals goals) {
    final List<Map<String, dynamic>> events = [];

    if (goals.intendTravelAbroad != null &&
        goals.intendTravelAbroad!.isNotEmpty) {
      events.add({
        'timeLabel': _translateValue(goals.intendTravelAbroad),
        'goalType': 'intendTravelAbroad',
      });
    }
    if (goals.familyAcceptance != null && goals.familyAcceptance!.isNotEmpty) {
      events.add({
        'timeLabel': _translateValue(goals.familyAcceptance),
        'goalType': 'familyAcceptance',
      });
    }

    if (goals.engagement != null && goals.engagement!.isNotEmpty) {
      events.add({
        'timeLabel': _translateValue(goals.engagement),
        'goalType': 'engagement',
      });
    }

    if (goals.marry != null && goals.marry!.isNotEmpty) {
      events.add({
        'timeLabel': _translateValue(goals.marry),
        'goalType': 'marriage_intentions',
      });
    }

    return events;
  }

  List<Map<String, dynamic>> _buildReligiousTags(
    MarriageUserProfileModel profile,
  ) {
    return [
      if (profile.aboutMe?.religiousCommitment != null)
        {
          'icon': AssetsData.kdrawingIcon,
          'label': _translateValue(profile.aboutMe!.religiousCommitment),
        },
      if (profile.aboutMe?.smoker != null)
        {
          'icon': AssetsData.kwritingIcon,
          'label': _translateValue(profile.aboutMe!.smoker),
        },
    ];
  }

  List<Map<String, dynamic>> _buildFaithItems(
    MarriageUserProfileModel profile,
  ) {
    final faithList = MarriageConstants.parseKeysFromRaw(
      profile.faith,
    ).where((s) => s.startsWith('faith_')).toList();

    if (faithList.isEmpty) return [];

    return faithList.map<Map<String, dynamic>>((key) {
      final emoji = MarriageConstants.getEmoji(key);
      return {
        'icon': AssetsData.kmusicIcon,
        'label': '$emoji ${_translateValue(key)}',
      };
    }).toList();
  }
  // ⭐⭐⭐ FIX: دالة _buildInterestsItems مع الترجمة الكاملة

  List<Map<String, dynamic>> _buildInterestsItems(
    MarriageUserProfileModel profile,
  ) {
    final hobbiesList = MarriageConstants.parseKeysFromRaw(profile.hobbies);
    if (hobbiesList.isEmpty) return [];

    return hobbiesList.map<Map<String, dynamic>>((key) {
      final emoji = MarriageConstants.getEmoji(key);
      return {
        'icon': AssetsData.kmusicIcon,
        'label': '$emoji ${_translateValue(key)}',
      };
    }).toList();
  }

  Widget _buildError(BuildContext context, String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.w, color: AppColors.errorColor),
          Gap(16.h),
          Text(
            message ?? context.tr("data_load_error"),
            textAlign: TextAlign.center,
            style: Styles.textStyle16,
          ),
          Gap(24.h),
          CustomBotton(
            title: context.tr("back"),
            onPressed: () => Navigator.pop(context),
            width: 120.w,
            height: 48.h,
          ),
        ],
      ),
    );
  }
}
