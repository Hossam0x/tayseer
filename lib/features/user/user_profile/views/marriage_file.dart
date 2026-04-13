import 'dart:ui';
import 'package:tayseer/core/constant/marriage_constants.dart';
import 'package:tayseer/core/widgets/custom_toggle_tab_bar.dart';
import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/core/widgets/gif_overlay.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/marriage/view/widget/video_section.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/marriage_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/marriage_profile_edit_view.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/complete_marriage_file.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/marriage_life_events_section.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/marriage_reward_card.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/user/marriage/view/widget/about_me.dart';
import 'package:tayseer/features/user/marriage/view/widget/bio_voice_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/education.dart';
import 'package:tayseer/features/user/marriage/view/widget/interests_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/religious.dart';
import 'widgets/profile_statistics_cards.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/regards_purchase_sheet.dart';

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

class _MarriagefilePageState extends State<MarriagefilePage>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late int _selectedTabIndex;
  final int _maxImages = 5;
  String? _scrollToSection;

  bool _hasShownLoadGif = false;
  bool _hasStartedLoadingGif = false;

  static const String _defaultImageUrl =
      "https://cdn-icons-png.flaticon.com/512/149/149071.png";

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  // // ارتفاع الـ AppBar (SimpleAppBar + Toggle) بدون statusBar
  // double _appBarHeight() {
  //   return 10.h + 56.h + 5.h + 46.h + 10.h;
  // }

  // double _appBarOffset(BuildContext context) {
  //   final statusBar = MediaQuery.of(context).padding.top;
  //   return statusBar + _appBarHeight();
  // }

  String _translateValue(String? value) {
    if (value == null || value.isEmpty) return '';
    final translated = context.tr(value);
    if (translated == value && !value.contains(' ')) return value;
    return translated;
  }

  double _calculateTotalProgress(MarriageUserProfileModel profile) {
    double questionProgress = (profile.answerCompletedPercentage ?? 0)
        .toDouble();
    questionProgress = questionProgress.clamp(0, 25);

    int imageBonus = 0;
    final images = profile.userMedia?.images ?? [];
    if (images.isNotEmpty) {
      final imageCount = images.length > 4 ? 4 : images.length;
      imageBonus = imageCount * 5;
    }

    int videoBonus = 0;
    bool hasVideo =
        profile.userMedia?.video != null &&
        profile.userMedia!.video!.isNotEmpty;
    if (hasVideo) videoBonus = 25;

    int audioBonus = 0;
    bool hasAudio =
        profile.userMedia?.audio != null &&
        profile.userMedia!.audio!.isNotEmpty;
    if (hasAudio) audioBonus = 25;

    int verificationBonus = true ? 5 : 0;

    double totalProgress =
        questionProgress +
        imageBonus +
        videoBonus +
        audioBonus +
        verificationBonus;

    return totalProgress.clamp(0, 100);
  }

  String _getMainDisplayImage(MarriageUserProfileModel profile) {
    if (profile.userMedia?.singleImage != null &&
        profile.userMedia!.singleImage!.isNotEmpty) {
      return profile.userMedia!.singleImage!;
    }
    return _defaultImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MarriageProfileCubit(
        getIt<MarriageProfileRepository>(),
        initialUserProfile: widget.userProfile,
      )..loadProfile(),
      child: Builder(
        builder: (context) => WillPopScope(
          onWillPop: () async {
            final cubit = context.read<MarriageProfileCubit>();
            final state = cubit.state;

            final hasSingleImage =
                (state.profile?.userMedia?.singleImage != null &&
                    state.profile!.userMedia!.singleImage!.isNotEmpty) ||
                state.pendingSingleImage != null;
            if (!hasSingleImage) {
              _showMustAddImageDialog(context, cubit, state.profile!);
              return false;
            }

            final hasUnsavedChanges =
                state.pendingSingleImage != null ||
                state.deletedSingleImageUrl != null ||
                state.pendingImages.isNotEmpty ||
                state.deletedImageUrls.isNotEmpty ||
                state.pendingVideo != null ||
                state.pendingDeleteVideo ||
                state.pendingAudio != null ||
                state.hasUnsavedFields ||
                state.pendingDeleteAudio;

            if (hasUnsavedChanges) {
              _showUnsavedChangesDialog(context, cubit, state);
              return false;
            }

            final progress = _calculateTotalProgress(state.profile!);
            Navigator.pop(context, progress);
            return false;
          },
          child: Scaffold(
            body: Stack(
              children: [
                // 1️⃣ Background
                Positioned.fill(
                  child: Image.asset(AssetsData.userBGImage, fit: BoxFit.cover),
                ),

                // 2️⃣ Content — بيبدأ من أعلى لكن بيترك مساحة للـ AppBar
                SafeArea(
                  child: BlocConsumer<MarriageProfileCubit, MarriageProfileState>(
                    listener: (context, state) {
                      if (state.isLoading &&
                          state.profile == null &&
                          !_hasStartedLoadingGif) {
                        _hasStartedLoadingGif = true;
                        showGifOverlay(
                          context,
                          repeatCount: 99,
                          gifDuration: const Duration(milliseconds: 900),
                          topOffset: _appBarOffset(context),
                        );
                      }

                      if (state.state == CubitStates.success &&
                          state.profile != null &&
                          !state.isLoading &&
                          !_hasShownLoadGif) {
                        _hasShownLoadGif = true;
                        showGifOverlay(
                          context,
                          repeatCount: 1,
                          gifDuration: const Duration(milliseconds: 900),
                          topOffset: _appBarOffset(context),
                        );
                      }

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
                        // ✅ مساحة فاضية بحجم الـ AppBar بس — الـ AppBar هيظهر فوق
                        return SizedBox(height: _appBarHeight());
                      }

                      if (state.state == CubitStates.failure &&
                          state.profile == null) {
                        return _buildError(context, state.errorMessage);
                      }

                      final profile = state.profile;
                      if (profile == null) {
                        return Center(
                          child: Text(context.tr("data_load_error")),
                        );
                      }

                      return Column(
                        children: [
                          // ✅ مساحة فاضية بحجم الـ AppBar عشان الـ content ميتغطيش
                          SizedBox(height: _appBarHeight()),

                          // ✅ Content
                          Expanded(
                            child: _selectedTabIndex == 1
                                ? _buildViewContent(profile)
                                : MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    removeBottom: false,
                                    child: MarriageProfileEditView(
                                      profile: profile,
                                      state: state,
                                      cubit: cubit,
                                      maxImages: _maxImages,
                                      selectedTabIndex: _selectedTabIndex,
                                      scrollToSection: _scrollToSection,
                                      onTabChanged: (index) {
                                        setState(() {
                                          _selectedTabIndex = index;
                                        });
                                      },
                                      onSaveSuccess: () {
                                        if (mounted) {
                                          showGifOverlay(
                                            context,
                                            repeatCount: 1,
                                            gifDuration: const Duration(
                                              milliseconds: 900,
                                            ),
                                            topOffset: _appBarOffset(context),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // 3️⃣ ✅ AppBar فوق كل حاجة — فوق الـ GIF overlay دايمًا
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.h,
                        vertical: 10.h,
                      ),
                      child: _buildFixedHeader(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ ارتفاع الـ AppBar بدون statusBar
  double _appBarHeight() {
    return 10.h + 56.h + 5.h + 46.h + 10.h;
  }

  // ✅ الـ topOffset للـ GIF (بيشمل statusBar)
  double _appBarOffset(BuildContext context) {
    final statusBar = MediaQuery.of(context).padding.top;
    return statusBar + _appBarHeight();
  }

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
        setState(() {
          _selectedTabIndex = 0;
          _scrollToSection = 'images';
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _scrollToSection = null;
            });
          }
        });
      },
    );
  }

  void _showUnsavedChangesDialog(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageProfileState state,
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

                final updatedState = cubit.state;
                final hasSingleAfterDiscard =
                    updatedState.profile?.userMedia?.singleImage != null &&
                    updatedState.profile!.userMedia!.singleImage!.isNotEmpty;

                if (!hasSingleAfterDiscard) {
                  _showMustAddImageDialog(
                    context,
                    cubit,
                    updatedState.profile!,
                  );
                  return;
                }

                final progress = updatedState.profile != null
                    ? _calculateTotalProgress(cubit.state.profile!)
                    : 0.0;
                Navigator.pop(context, progress);
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
            child: BlocBuilder<MarriageProfileCubit, MarriageProfileState>(
              bloc: cubit,
              builder: (context, currentState) {
                return ElevatedButton(
                  onPressed: currentState.isUpdating
                      ? null
                      : () async {
                          await cubit.saveProfile();
                          Navigator.pop(dialogContext);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentState.isUpdating
                        ? AppColors.primary300.withOpacity(0.7)
                        : AppColors.primary300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: currentState.isUpdating
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          context.tr('save_and_exit'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
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
      color: Colors.transparent,
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
    final images = profile.userMedia?.images ?? [];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.0.w),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
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

          _buildSliverPadding(
            child: ProfileStatisticsCards(
              upgradesCount: profile.likesLeft ?? 0,
              resultsCount: profile.regardsLeft ?? 0,
              onUpgradesTap: () => showLimitReachedDialog(
                context,
                title: context.tr('reached_free_likes_limit'),
                subtitle: context.tr('subscribe_to_like_more'),
                subscribeText: context.tr('subscribe'),
                laterText: context.tr('later'),
                onSubscribe: () {
                  context.pushNamed(AppRouter.kUserPackagesView);
                },
              ),
              onResultsTap: () =>
                  showRegardsPurchaseSheet(context), // ✅ regards
            ),
          ),

          _buildSliverPadding(
            child: AboutMeSection(items: _buildAboutMeItems(profile)),
          ),

          if (images.isNotEmpty)
            _buildImageSection(images[0], 'profile_image_0'),

          _buildSliverPadding(
            child: EducationSection(items: _buildEducationItems(profile)),
          ),

          if (profile.yourGoals != null)
            _buildSliverPadding(
              child: MarriageLifeEventsSection(
                titleName: context.tr("my_goals"),
                events: _buildTimelineEvents(profile.yourGoals!),
              ),
            ),

          if (images.length > 1)
            _buildImageSection(images[1], 'profile_image_1'),

          _buildSliverPadding(
            child: ReligiousSection(tags: _buildReligiousTags(profile)),
          ),

          if (profile.userMedia?.video != null &&
              profile.userMedia!.video!.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              sliver: SliverToBoxAdapter(
                child: VideoSection(videoUrl: profile.userMedia?.video),
              ),
            ),

          if (profile.hobbies.isNotEmpty)
            _buildSliverPadding(
              child: InterestsSection(
                title: 'my_interests',
                interests: _buildInterestsItems(profile),
              ),
            ),

          if (profile.faith.isNotEmpty)
            _buildSliverPadding(
              child: InterestsSection(
                title: 'choose_faith',
                interests: _buildFaithItems(profile),
              ),
            ),

          if (images.length > 2)
            _buildImageSection(images[2], 'profile_image_2'),

          if (profile.myDescription != null &&
              profile.myDescription!.isNotEmpty)
            _buildSliverPadding(
              child: BioVoiceSection(
                bioText: profile.myDescription!,
                audioPath: profile.userMedia?.audio ?? "",
              ),
            ),

          if (images.length > 3)
            _buildImageSection(images[3], 'profile_image_3'),

          SliverToBoxAdapter(child: SizedBox(height: 30.h)),
          SliverToBoxAdapter(child: MarriageRewardCard()),
          SliverToBoxAdapter(child: SizedBox(height: 140.h)),
        ],
      ),
    );
  }

  Widget _buildImageSection(String imageUrl, String heroTag) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      sliver: SliverToBoxAdapter(
        child: GestureDetector(
          onTap: () => FullScreenImageView.show(
            context,
            imageUrl: imageUrl,
            heroTag: heroTag,
            userName: context.tr("my_profile"),
          ),
          child: Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: AppImage(
                imageUrl,
                height: 400.h,
                width: double.infinity,
                fit: BoxFit.cover,
                radius: 16.r,
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
                ? () => FullScreenImageView.show(
                    context,
                    imageUrl: mainImage,
                    heroTag: 'profile_main_image',
                    userName: context.tr("my_profile"),
                  )
                : null,
            child: Hero(
              tag: 'profile_main_image',
              child: Container(
                height: 650.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(33.r),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(33.r),
                  ),
                  child: AppImage(
                    mainImage,
                    height: 650.h,
                    width: double.infinity,
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
    final int realPercent = (progress * 100).toInt();

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_floatAnimation.value),
          child: child,
        );
      },
      child: Container(
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
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                      const Spacer(),
                      _buildGradientButton(profile, progress: progress),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
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
              onProfileRefresh: () async {
                final cubit = context.read<MarriageProfileCubit>();

                await cubit.loadProfile();

                final profile = cubit.state.profile;

                if (profile == null) {
                  throw Exception("Profile is null after refresh");
                }

                return profile;
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
          'label': "💍 ${_translateValue(profile.aboutMe!.socialStatus)}",
        },
      if (profile.aboutMe?.age != null)
        {
          'icon': AssetsData.kdrawingIcon,
          'label': "🎂\u200F ${profile.aboutMe?.age} ${context.tr('age')}",
        },
      if (profile.aboutMe?.skinColor != null)
        {
          'icon': AssetsData.kdrawingIcon,
          'label':
              "🎨 ${context.tr('Skin')} ${_translateValue(profile.aboutMe!.skinColor)}",
        },
      if (profile.aboutMe?.healthStatus != null)
        {
          'icon': AssetsData.kwritingIcon,
          'label': "🩺 ${_translateValue(profile.aboutMe!.healthStatus)}",
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
          'label':
              "🎓 ${_translateValue(profile.professionalLife!.educationLevel)}",
        },
      if (profile.professionalLife?.job != null)
        {
          'icon': AssetsData.kwritingIcon,
          'label': "💼 ${_translateValue(profile.professionalLife!.job)}",
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
          'label':
              "🕌 ${_translateValue(profile.aboutMe!.religiousCommitment)}",
        },
      if (profile.aboutMe?.smoker != null)
        {
          'icon': AssetsData.kwritingIcon,
          'label': "🚬 ${_translateValue(profile.aboutMe!.smoker)}",
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

  Widget buildCachedImage({
    required String url,
    double? height,
    BorderRadius? radius,
    BoxFit fit = BoxFit.cover,
    Widget? errorWidget,
  }) {
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(16.r),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        width: double.infinity,
        height: height,
        placeholder: (context, _) =>
            shimmerImagePlaceholder(height: height, radius: radius),
        errorWidget: (context, _, __) =>
            errorWidget ??
            Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.grey,
                size: 48.w,
              ),
            ),
      ),
    );
  }

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

Widget shimmerImagePlaceholder({double? height, BorderRadius? radius}) {
  return Container(
    height: height ?? double.infinity,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: radius ?? BorderRadius.circular(16.r),
    ),
  );
}
