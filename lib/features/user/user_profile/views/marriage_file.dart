import 'dart:developer';
import 'dart:ui';
import 'package:tayseer/core/widgets/custom_toggle_tab_bar.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/marriage/view/widget/additional_image.dart';
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

// ⭐⭐⭐ Import sections
import 'package:tayseer/features/user/marriage/view/widget/about_me.dart';
import 'package:tayseer/features/user/marriage/view/widget/bio_voice_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/education.dart';
import 'package:tayseer/features/user/marriage/view/widget/interests_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/religious.dart';

import 'widgets/MarriageProfileSkeleton .dart';
import 'widgets/profile_statistics_cards.dart'; // ⭐⭐⭐ NEW IMPORT

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
  final ImagePicker _picker = ImagePicker();
  final int _maxImages = 5;
  String? _scrollToSection;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
  }

  // ════════════════════════════════════════════════════════════════
  // ⭐⭐⭐ CALCULATE TOTAL PROGRESS (Server + Media)
  // ════════════════════════════════════════════════════════════════
  double _calculateTotalProgress(MarriageUserProfileModel profile) {
    // Questions contribute 20% max
    double questionProgress = (profile.answerCompletedPercentage ?? 0)
        .toDouble();
    questionProgress = questionProgress > 20 ? 20 : questionProgress;

    // Media contributes 80% max
    int mediaBonus = 0;

    final images = profile.userMedia?.images ?? [];
    if (images.isNotEmpty) {
      final imageCount = images.length > 5 ? 5 : images.length;
      mediaBonus += imageCount * 5; // Max 25%
    }

    bool hasVideo =
        profile.userMedia?.video != null &&
        profile.userMedia!.video!.isNotEmpty;
    if (hasVideo) mediaBonus += 30; // 30%

    bool hasAudio =
        profile.userMedia?.audio != null &&
        profile.userMedia!.audio!.isNotEmpty;
    if (hasAudio) mediaBonus += 30; // 25%

    // Cap media at 80%
    mediaBonus = mediaBonus > 80 ? 80 : mediaBonus;

    double totalProgress = questionProgress + mediaBonus;

    debugPrint('📊 Question Progress: $questionProgress%');
    debugPrint('📊 Media Bonus: $mediaBonus%');
    debugPrint('📊 Total: $totalProgress%');

    return totalProgress;
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

              if (state.state == CubitStates.failure && state.profile == null) {
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
    final images = profile.userMedia?.images ?? [];
    final displayImages = images.length > 5 ? images.sublist(0, 5) : images;
    final totalProgress = _calculateTotalProgress(profile);
    final progressFraction = totalProgress / 100;

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.0.w),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildViewHeader(profile),
              
              // ⭐⭐⭐ NEW: Statistics Cards Section (Before AboutMe)
              _buildSliverPadding(
                child: ProfileStatisticsCards(
                  upgradesCount: 34, 
                  resultsCount: 1,   
                  onUpgradesTap: () {
                    debugPrint('⭐ Upgrades button tapped');
                  
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ترقية الاعجابات المتبقية'),
                        backgroundColor: AppColors.primary600,
                      ),
                    );
                  },
                  onResultsTap: () {
                    debugPrint('⭐ Results button tapped');
                    // TODO: Navigate to results/rewards screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('عرض النتائج والمكافآت'),
                        backgroundColor: AppColors.primary600,
                      ),
                    );
                  },
                ),
              ),
              
              _buildSliverPadding(
                child: AboutMeSection(items: _buildAboutMeItems(profile)),
              ),
              _buildSliverPadding(
                child: EducationSection(items: _buildEducationItems(profile)),
              ),
              if (profile.yourGoals != null)
                _buildSliverPadding(
                  child: MarriageLifeEventsSection(
                    titleName:context.tr("my_goals"),
                    events: _buildTimelineEvents(profile.yourGoals!),
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                sliver: SliverToBoxAdapter(
                  child: displayImages.isNotEmpty
                      ? AdditionalImageSection(
                        isHastar: false,
                          imageUrl: displayImages.length > 1
                              ? displayImages[1]
                              : displayImages[0],
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              _buildSliverPadding(
                child: ReligiousSection(tags: _buildReligiousTags(profile)),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                sliver: SliverToBoxAdapter(
                  child: VideoSection(videoUrl: profile.userMedia?.video),
                ),
              ),
              if (profile.hobbies.isNotEmpty)
                _buildSliverPadding(
                  child: InterestsSection(
                    interests: _buildInterestsItems(profile),
                  ),
                ),
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
                child:
              MarriageRewardCard()),
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),
        ),
        // 2. الكارد الثابت (يظهر فقط إذا لم تكن النسبة 100%)
        if (totalProgress < 100)
          Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              ignoring: false,
              child: _buildCompletionCard(progressFraction, profile: profile),
            ),
          ),
      ],
    );
  }

  Widget _buildViewHeader(MarriageUserProfileModel profile) {
    final images = profile.userMedia?.images ?? [];
    final displayImages = images.length > 5 ? images.sublist(0, 5) : images;

    final totalProgress = _calculateTotalProgress(profile);
    final progressFraction = totalProgress / 100;

    return SliverToBoxAdapter(
      child: Column(
        children: [
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard(
    double progress, {
    required MarriageUserProfileModel profile,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 24.h),
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
                  color: Colors.black.withOpacity(0.1),
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
                    Column(
                      children: [
                        Text(
                          context.tr('complete_profile_100_percent'),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary600,
                          ),
                        ),
                        SizedBox(height: 8.h),
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
          'label': "${context.tr('Skin')} ${profile.aboutMe!.skinColor}",
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
      events.add({'timeLabel': goals.travel, 'goalType': 'travel'});
    }

    if (goals.children != null && goals.children!.isNotEmpty) {
      events.add({
        'timeLabel': goals.children,
        'goalType': context.tr("select_dowry_title"),
      });
    }

    if (goals.engagement != null && goals.engagement!.isNotEmpty) {
      events.add({'timeLabel': goals.engagement, 'goalType': 'engagement'});
    }

    if (goals.marry != null && goals.marry!.isNotEmpty) {
      events.add({'timeLabel': goals.marry, 'goalType': 'marry'});
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
          'label': "${profile.aboutMe!.smoker} ",
        },
    ];
  }

// UPDATED: _buildInterestsItems method in MarriagefilePage
// Replace the existing _buildInterestsItems method with this:

List<Map<String, dynamic>> _buildInterestsItems(profile) {
  // ⭐⭐⭐ Map to get emoji from key
  final Map<String, String> _keyToEmojiMap = {};
  
  // Build emoji map from all categories
  final categories = {
  'category_sports': {
        'interest_baseball': '⚾',
        'interest_running': '🏃',
        'interest_weightlifting': '🏋️',
        'interest_gymnastics': '🤸',
        'interest_golf': '⛳',
        'interest_tennis': '🎾',
        'interest_swimming': '🏊',
        'interest_dancing': '💃',
        'interest_skating': '⛸️',
        'interest_yoga': '🧘',
        'interest_flying_disc': '🥏',
        'interest_badminton': '🏸',
        'interest_skiing': '⛷️',
        'interest_cycling': '🚴',
        'interest_basketball': '🏀',
        'interest_football': '⚽',
        'interest_karate': '🥋',
        'interest_boxing': '🥊',
        'interest_archery': '🏹',
        'interest_horse_riding': '🏇',
      },
      'category_arts_culture': {
        'interest_theater': '🎭',
        'interest_magic': '🪄',
        'interest_music': '🎵',
        'interest_painting': '🎨',
        'interest_photography': '📷',
        'interest_cinema': '🎬',
        'interest_reading': '📚',
        'interest_writing': '✍️',
        'interest_poetry': '📝',
        'interest_history': '🏛️',
        'interest_languages': '🗣️',
        'interest_museums': '🖼️',
        'interest_calligraphy': '🖋️',
        'interest_sculpture': '🗿',
        'interest_design': '🎯',
        'interest_fashion': '👗',
      },
      'category_community': {
        'interest_volunteering': '🤝',
        'interest_charity': '💝',
        'interest_teaching': '👨‍🏫',
        'interest_mentoring': '🧑‍🤝‍🧑',
        'interest_elderly_care': '👴',
        'interest_children_care': '👶',
        'interest_environment': '🌱',
        'interest_animal_care': '🐾',
        'interest_blood_donation': '🩸',
        'interest_community_events': '🎉',
        'interest_social_work': '💼',
        'interest_human_rights': '⚖️',
      },
      'category_technology': {
        'interest_programming': '💻',
        'interest_gaming': '🎮',
        'interest_ai': '🤖',
        'interest_web_dev': '🌐',
        'interest_mobile_apps': '📱',
        'interest_cybersecurity': '🔒',
        'interest_data_science': '📊',
        'interest_electronics': '🔌',
        'interest_robotics': '🦾',
        'interest_vr_ar': '🥽',
        'interest_3d_printing': '🖨️',
        'interest_drones': '🚁',
        'interest_smart_home': '🏠',
        'interest_blockchain': '⛓️',
      },
      'category_outdoors': {
        'interest_hiking': '🥾',
        'interest_camping': '🏕️',
        'interest_fishing': '🎣',
        'interest_beach': '🏖️',
        'interest_mountain_climbing': '🏔️',
        'interest_gardening': '🌻',
        'interest_picnic': '🧺',
        'interest_bird_watching': '🦅',
        'interest_stargazing': '🌟',
        'interest_road_trips': '🚗',
        'interest_sailing': '⛵',
        'interest_diving': '🤿',
        'interest_surfing': '🏄',
        'interest_kayaking': '🛶',
        'interest_rock_climbing': '🧗',
        'interest_paragliding': '🪂',
      },
      'category_food_drinks': {
        'interest_cooking': '👨‍🍳',
        'interest_baking': '🧁',
        'interest_grilling': '🍖',
        'interest_coffee': '☕',
        'interest_tea': '🍵',
        'interest_smoothies': '🥤',
        'interest_sushi': '🍣',
        'interest_pizza': '🍕',
        'interest_desserts': '🍰',
        'interest_healthy_food': '🥗',
        'interest_street_food': '🌮',
        'interest_fine_dining': '🍽️',
        'interest_food_photography': '📸',
        'interest_chocolate': '🍫',
        'interest_ice_cream': '🍦',
      },
  };

  // Build key-to-emoji map
  categories.forEach((categoryKey, items) {
    items.forEach((key, emoji) {
      _keyToEmojiMap[key] = emoji;
    });
  });

  // ⭐⭐⭐ Now profile.hobbies contains KEYS like ["interest_running", "interest_golf"]
  return profile.hobbies.map<Map<String, dynamic>>((hobbyKey) {
    // Get emoji for this key
    final emoji = _keyToEmojiMap[hobbyKey] ?? '🎵'; // default fallback
    
    // Translate the key to display text
    final displayText = context.tr(hobbyKey);

    debugPrint('🎯 Interest: key="$hobbyKey", emoji="$emoji", display="$displayText"');

    return {
      'icon': AssetsData.kmusicIcon,
      'label': '$emoji $displayText', // ⭐ Show emoji + translated text
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