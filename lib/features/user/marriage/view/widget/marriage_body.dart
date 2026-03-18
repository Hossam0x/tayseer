import 'dart:async';

import 'package:tayseer/core/services/deep_link_service.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/history_page.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_FilterChips.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_body.dart';
import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart';
import 'package:tayseer/features/user/marriage/view/widget/section_toggle.dart';
import 'package:tayseer/features/user/marriage/view/widget/animated_be_first_button.dart';
import 'package:tayseer/features/user/marriage/view/widget/swipe_action_pop_up.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_cubit.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/dash_border.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/user/marriage/view/widget/about_me.dart';
import 'package:tayseer/features/user/marriage/view/widget/additional_image.dart';
import 'package:tayseer/features/user/marriage/view/widget/bio_voice_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/bottom_actions_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/compatibility.dart';
import 'package:tayseer/features/user/marriage/view/widget/education.dart';
import 'package:tayseer/features/user/marriage/view/widget/interests_section.dart';
import 'package:tayseer/core/constant/marriage_constants.dart';
import 'package:tayseer/features/user/marriage/view/widget/message_input_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/religious.dart';
import 'package:tayseer/features/user/marriage/view/widget/sliver_profile_header.dart';
import 'package:tayseer/features/user/marriage/view/widget/video_section.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/marriage_life_events_section.dart';
import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart'
    as marriageModel;

class MarriageBody extends StatefulWidget {
  const MarriageBody({
    super.key,
    this.personId,
    this.fromInteractions = false,
    this.initialIsFavorite = false,
    this.onScroll,
  });

  final String? personId;
  final bool fromInteractions;
  final bool initialIsFavorite;
  final Function(bool isScrollingDown)? onScroll;

  @override
  State<MarriageBody> createState() => MarriageBodyState();
}

class MarriageBodyState extends State<MarriageBody>
    with SingleTickerProviderStateMixin {
  final ScrollController _mainScrollController = ScrollController();
  InteractionsCubit? _interactionsCubit;

  final GlobalKey<InteractionBodyState> _interactionBodyKey =
      GlobalKey<InteractionBodyState>();
  final GlobalKey<HistorypageState> _historyKey = GlobalKey<HistorypageState>();

  double _lastOffset = 0;
  double _scrollDelta = 0;
  static const double _scrollThreshold = 20.0;
  Timer? _scrollIdleTimer;
  static const Duration _scrollIdleDelay = Duration(milliseconds: 800);

  InteractionsCubit get interactionsCubit {
    if (_interactionsCubit == null) {
      _interactionsCubit = getIt<InteractionsCubit>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _interactionsCubit!.fetchHistorySilently();
      });
    }
    return _interactionsCubit!;
  }

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(_scrollListener);

    final cubit = context.read<MarriageCubit>();
    cubit.fetchMarriageProfile(
      seedFavoriteId: (cubit.seedPersonId != null && cubit.seedIsFavorite)
          ? cubit.seedPersonId
          : null,
    );
    cubit.initAnimation(this);
  }

  @override
  @override
  void dispose() {
    _scrollIdleTimer?.cancel(); // ✅ أضف دي
    _mainScrollController.removeListener(_scrollListener);
    _mainScrollController.dispose();
    _interactionsCubit?.close();
    super.dispose();
  }

  void _scrollListener() {
    final currentOffset = _mainScrollController.offset;
    final delta = currentOffset - _lastOffset;
    _scrollDelta += delta;

    if (_scrollDelta.abs() >= _scrollThreshold) {
      final isDown = _scrollDelta > 0;
      final cubit = context.read<MarriageCubit>();
      if (cubit.state.isScrollingDown != isDown) {
        cubit.setScrollingDown(isDown);
      }
      widget.onScroll?.call(isDown);
      _scrollDelta = 0;
    }

    if (currentOffset <= 0) {
      _scrollDelta = 0;
      final cubit = context.read<MarriageCubit>();
      if (cubit.state.isScrollingDown) {
        cubit.setScrollingDown(false);
        widget.onScroll?.call(false);
      }
    }

    _lastOffset = currentOffset;

    // ✅ الجديد — idle timer
    _scrollIdleTimer?.cancel();
    _scrollIdleTimer = Timer(_scrollIdleDelay, () {
      if (!mounted) return;
      final cubit = context.read<MarriageCubit>();
      if (cubit.state.isScrollingDown) {
        cubit.setScrollingDown(false);
        widget.onScroll?.call(false);
      }
    });
  }

  Future<void> _showSwipePopup(
    BuildContext context,
    SwipeActionType type,
  ) async {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(child: SwipeActionPopup(type: type)),
      ),
    );

    overlay.insert(entry);

    // ✅ بعد 900ms اشيل الـ popup
    await Future.delayed(const Duration(milliseconds: 900));
    entry.remove();
  }

  void scrollToTop() {
    if (_mainScrollController.hasClients) {
      _mainScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _resetScrollTracking() {
    _lastOffset = 0;
    _scrollDelta = 0;
    if (!mounted) return;
    context.read<MarriageCubit>().setScrollingDown(false);
  }

  String _tr(String? value) {
    if (value == null || value.trim().isEmpty) return '';
    return context.tr(value.trim());
  }

  List<Map<String, dynamic>> _buildTimelineEventsFromAnswers(
    marriageModel.YourGoals goals,
  ) {
    final List<Map<String, dynamic>> events = [];

    final marriageValue = goals.marriageIntentions ?? goals.marry;
    if (marriageValue != null && marriageValue.toString().trim().isNotEmpty) {
      events.add({
        'timeLabel': _tr(marriageValue.toString()),
        'goalType': 'marriage_intentions',
      });
    }

    if (goals.engagment != null &&
        goals.engagment.toString().trim().isNotEmpty) {
      events.add({
        'timeLabel': _tr(goals.engagment.toString()),
        'goalType': 'engagement',
      });
    }

    final familyValue = goals.familyAcceptance ?? goals.children;
    if (familyValue != null && familyValue.toString().trim().isNotEmpty) {
      events.add({
        'timeLabel': _tr(familyValue.toString()),
        'goalType': 'familyAcceptance',
      });
    }

    if (goals.travel != null && goals.travel.toString().trim().isNotEmpty) {
      events.add({
        'timeLabel': _tr(goals.travel.toString()),
        'goalType': 'intendTravelAbroad',
      });
    }

    return events;
  }

  Widget _buildToggle() {
    final cubit = context.read<MarriageCubit>();
    return SectionToggle(
      isMarriage: cubit.state.isMarriageTab,
      onChanged: (value) {
        if (!value && widget.fromInteractions) {
          context.pop();
          return;
        }
        cubit.setMarriageTab(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MarriageCubit, MarriageState>(
      // ✅ block مش موجود في listenWhen خالص
      listenWhen: (previous, current) =>
          previous.marriageProfileState != current.marriageProfileState ||
          (previous.sendRegardState != current.sendRegardState &&
              current.showActionSnackbar) ||
          (previous.sendRegardTextState != current.sendRegardTextState &&
              current.showActionSnackbar),

      buildWhen: (previous, current) =>
          previous.marriageProfileState != current.marriageProfileState ||
          previous.allUsers != current.allUsers ||
          previous.currentIndex != current.currentIndex ||
          previous.isMarriageTab != current.isMarriageTab ||
          previous.isScrollingDown != current.isScrollingDown ||
          previous.swipeDirection != current.swipeDirection ||
          previous.swipeProgress != current.swipeProgress ||
          previous.isAnimating != current.isAnimating ||
          previous.showHistory != current.showHistory ||
          previous.selectedHistoryFilter != current.selectedHistoryFilter ||
          previous.favoritedIds != current.favoritedIds ||
          previous.isLoadingMore != current.isLoadingMore,

      listener: (context, state) {
        // ✅ Regard failure
        if ((state.sendRegardState == CubitStates.failure ||
                state.sendRegardTextState == CubitStates.failure) &&
            state.showActionSnackbar) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.errorMessage ?? 'حدث خطأ ما',
              isError: true,
            ),
          );
          context.read<MarriageCubit>().resetState();
        }

        // ✅ Regard success
        if (state.sendRegardState == CubitStates.success &&
            state.showActionSnackbar) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              return AppImage(AssetsData.kSuccessMarriageAnimationsLottie);
            },
          );
          Future.delayed(const Duration(seconds: 4), () {
            if (context.mounted) context.pop();
          });
          context.read<MarriageCubit>().resetState();
        }

        // ✅ block مفيش listener له خالص —
        // الـ cubit بنفسه بيعمل كل حاجة ويعمل reset
      },

      builder: (context, state) {
        if (state.marriageProfileState == CubitStates.loading) {
          return _buildShimmerScreen();
        }

        if (state.marriageProfileState == CubitStates.failure) {
          return _buildWithAppBar(
            child: Center(
              child: Text(
                state.errorMessage ?? 'حدث خطأ ما',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        }

        // ✅ في الـ builder — غير الـ users filter
        final List<UserItem> allUsers = state.allUsers;
        final List<UserItem> users = widget.personId != null
            ? () {
                final filtered = allUsers
                    .where((p) => p.user?.id == widget.personId)
                    .toList();
                // ✅ لو مش موجود في النتايج، اطلب إضافته وارجع كل الـ users مؤقتاً
                if (filtered.isEmpty &&
                    state.marriageProfileState == CubitStates.success) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<MarriageCubit>().fetchSpecificProfile(
                      widget.personId!,
                    );
                  });
                }
                return filtered.isNotEmpty ? filtered : allUsers;
              }()
            : allUsers;

        if (users.isEmpty) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: state.isMarriageTab
                ? _buildWithAppBar(
                    key: const ValueKey('empty_marriage'),
                    child: _buildEmptyMarriage(context.read<MarriageCubit>()),
                  )
                : _buildInteractionsContent(
                    key: const ValueKey('interactions'),
                    state: state,
                  ),
          );
        }

        int profileIndex = state.currentIndex;
        if (profileIndex >= users.length) {
          profileIndex = users.length - 1;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<MarriageCubit>().clampCurrentIndex(
              usersLength: users.length,
            );
          });
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state.isMarriageTab
              ? _buildMarriageContent(
                  personId: widget.personId ?? "",
                  key: const ValueKey('marriage'),
                  state: state,
                  profileIndex: profileIndex,
                  users: users,
                )
              : _buildInteractionsContent(
                  key: const ValueKey('interactions'),
                  state: state,
                ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // APP BAR WRAPPER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildWithAppBar({Key? key, required Widget child}) {
    return Directionality(
      key: key,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: CustomBackground(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(child: _buildToggle()),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          context.pushNamed(AppRouter.kMarriageFilterView);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.black12,
                          child: AppImage(
                            AssetsData.kfilterIcon,
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      child: AnimatedBeFirstButton(
                        onTap: () {
                          context.pushNamed(AppRouter.kBoostAccountView);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEmptyMarriage(MarriageCubit cubit) {
    return RefreshIndicator.adaptive(
      onRefresh: () => cubit.refreshProfile(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppImage(
                      AssetsData.noPersonsBlocked,
                      width: 180.w,
                      height: 180.h,
                    ),
                    Gap(24.h),
                    Text(
                      context.tr('no_marriage_users'),
                      style: Styles.textStyle18Bold.copyWith(
                        color: AppColors.kprimaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Gap(12.h),
                    Text(
                      context.tr('share_app_to_find_users'),
                      style: Styles.textStyle14.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    Gap(24.h),
                  ],
                ),
              ),
            ),
          ),
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
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
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

  // ═══════════════════════════════════════════════════════════════
  // MARRIAGE TAB
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMarriageContent({
    Key? key,
    required String personId,
    required MarriageState state,
    required int profileIndex,
    required List<UserItem> users,
  }) {
    final profile = users[profileIndex];
    final user = profile.user;
    final answers = profile.answers;
    final images = answers?.userMedia?.image ?? [];

    final List<String> validImages = images
        .where((img) => img.isNotEmpty)
        .toList();

    final List<String> displayImages = validImages.isNotEmpty
        ? validImages
        : (user?.image != null && user!.image!.isNotEmpty ? [user.image!] : []);

    final cubit = context.read<MarriageCubit>();

    final bool shouldBlurImages = widget.fromInteractions
        ? (cubit.interactionUser?.isImageBlurred ?? user?.imageBlur ?? false)
        : (user?.imageBlur ?? false);
    final bool isVerifiedUser = widget.fromInteractions
        ? (cubit.interactionUser?.isverified ?? user?.isVerified ?? false)
        : (user?.isVerified ?? false);
    final bool hasNext =
        widget.personId == null && profileIndex + 1 < users.length;

    final nextProfile = hasNext ? users[profileIndex + 1] : null;
    final nextUser = nextProfile?.user;
    final nextAnswers = nextProfile?.answers;
    final List<String> nextImages = nextAnswers?.userMedia?.image ?? [];

    final timelineEvents = answers?.yourGoals != null
        ? _buildTimelineEventsFromAnswers(answers!.yourGoals!)
        : <Map<String, dynamic>>[];

    return Directionality(
      key: key,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: CustomBackground(
        child: Stack(
          children: [
            RefreshIndicator.adaptive(
              onRefresh: () => cubit.refreshProfile(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                key: ValueKey<int>(profileIndex),
                controller: _mainScrollController,
                slivers: [
                  SliverProfileHeader(
                    isVerified: isVerifiedUser,
                    nextIsVerified: hasNext
                        ? (nextUser?.isVerified ?? false)
                        : null,
                    reportId: user?.id,
                    images: displayImages,
                    name: user?.name ?? '',
                    age: "🎂 ${_tr(answers?.aboutMe?.age)}",
                    location: _tr(user?.country ?? answers?.aboutMe?.country),
                    tagsjob: "💼 ${_tr(user?.about?.job)}",
                    educationLevel: "🎓 ${_tr(user?.about?.educationLevel)}",
                    religiousCommitment:
                        "🕌 ${_tr(user?.about?.religiousCommitment)}",
                    nationality: "🌍 ${_tr(user?.about?.nationality)}",
                    height: "📏 ${user?.about?.height ?? ''}",
                    toggleWidget: _buildToggle(),
                    swipeDirection: state.swipeDirection,
                    swipeProgress: state.swipeProgress,
                    shouldBlur: shouldBlurImages,
                    nextImages: hasNext ? nextImages : null,
                    nextName: hasNext ? (nextUser?.name ?? '') : null,
                    nextAge: hasNext
                        ? "🎂 ${_tr(nextAnswers?.aboutMe?.age)}"
                        : null,
                    nextLocation: hasNext
                        ? _tr(
                            nextUser?.country ?? nextAnswers?.aboutMe?.country,
                          )
                        : null,
                    nextTagsjob: hasNext
                        ? "💼 ${_tr(nextUser?.about?.job)}"
                        : null,
                    nextEducationLevel: hasNext
                        ? "🎓 ${_tr(nextUser?.about?.educationLevel)}"
                        : null,
                    nextReligiousCommitment: hasNext
                        ? "🕌 ${_tr(nextUser?.about?.religiousCommitment)}"
                        : null,
                    nextNationality: hasNext
                        ? "🌍 ${_tr(nextUser?.about?.nationality)}"
                        : null,
                    nextHeight: hasNext
                        ? "📏 ${nextUser?.about?.height ?? ''}"
                        : null,
                    isFavorited: state.favoritedIds.contains(user?.id ?? ''),
                    // ✅ زرار الـ favorite في الـ SliverProfileHeader
                    onFavoriteTap: () async {
                      await _showSwipePopup(context, SwipeActionType.favorite);
                      cubit.toggleLocalFavorite(
                        user?.id ?? '',
                        removeFromList: widget.personId == null,
                      );
                    },
                  ),

                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: CompatibilitySection(
                        title: context.tr('compatibility_profile'),
                        subtitle: user?.similarity != null
                            ? '${user!.similarity}%'
                            : '',
                        tags:
                            user?.matchingTags
                                ?.where(
                                  (t) =>
                                      t.value != null &&
                                      t.value!.trim().isNotEmpty,
                                )
                                .map<String>((t) => _tr(t.value))
                                .toList() ??
                            [],
                      ),
                    ),
                  ),

                  if (displayImages.length > 1 && displayImages[1].isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: AdditionalImageSection(
                          personId: user?.id ?? '',
                          imageUrl: displayImages[1],
                          shouldBlur: shouldBlurImages,
                        ),
                      ),
                    ),

                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: AboutMeSection(
                        items: [
                          if (answers?.aboutMe?.socialStatus != null)
                            {
                              'label':
                                  "💍 ${_tr(answers!.aboutMe!.socialStatus)}",
                            },
                          if (answers?.family?.hasChildren != null)
                            {
                              'label':
                                  "👶 ${_tr(answers!.family!.hasChildren)}",
                            },
                          if (answers?.aboutMe?.weight != null)
                            {'label': "⚖️ ${answers?.aboutMe?.weight} "},
                          if (answers?.professionalLife?.job != null)
                            {
                              'label':
                                  "💼 ${_tr(answers!.professionalLife!.job)}",
                            },
                          if (answers?.aboutMe?.healthStatus != null)
                            {
                              'label':
                                  "🩺 ${_tr(answers!.aboutMe!.healthStatus)}",
                            },
                        ],
                      ),
                    ),
                  ),

                  if (displayImages.length > 2 && displayImages[2].isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: AdditionalImageSection(
                          personId: user?.id ?? '',
                          imageUrl: displayImages[2],
                          shouldBlur: shouldBlurImages,
                        ),
                      ),
                    ),

                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: EducationSection(
                        items: [
                          if (answers?.professionalLife?.educationLevel != null)
                            {
                              'label':
                                  "🎓 ${_tr(answers!.professionalLife!.educationLevel)}",
                            },
                          if (answers?.professionalLife?.job != null)
                            {
                              'label':
                                  "💼 ${_tr(answers!.professionalLife!.job)}",
                            },
                        ],
                      ),
                    ),
                  ),

                  if (displayImages.length > 3 && displayImages[3].isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: AdditionalImageSection(
                          personId: user?.id ?? '',
                          imageUrl: displayImages[3],
                          shouldBlur: shouldBlurImages,
                        ),
                      ),
                    ),

                  if (timelineEvents.isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: MarriageLifeEventsSection(
                          titleName:
                              "${user?.name ?? ''} ${context.tr('goals')}",
                          events: timelineEvents,
                        ),
                      ),
                    ),

                  if (displayImages.isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: AdditionalImageSection(
                          personId: user?.id ?? '',
                          imageUrl: displayImages.first,
                          isHastar: true,
                          shouldBlur: shouldBlurImages,
                        ),
                      ),
                    ),

                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: ReligiousSection(
                        tags: [
                          if (answers?.aboutMe?.religiousCommitment != null)
                            {
                              'label':
                                  "🕌 ${_tr(answers!.aboutMe!.religiousCommitment)}",
                            },
                          if (answers?.aboutMe?.smoker != null)
                            {'label': "🚬 ${_tr(answers!.aboutMe!.smoker)}"},
                        ],
                      ),
                    ),
                  ),

                  if (answers?.userMedia?.video != null)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: VideoSection(
                          videoUrl: answers!.userMedia!.video!,
                        ),
                      ),
                    ),

                  if (displayImages.length > 4 && displayImages[4].isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: AdditionalImageSection(
                          personId: user?.id ?? '',
                          imageUrl: displayImages[4],
                          shouldBlur: shouldBlurImages,
                        ),
                      ),
                    ),

                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: InterestsSection(
                        interests:
                            MarriageConstants.parseKeysFromRaw(
                              answers?.hobbies,
                            ).map((h) {
                              final emoji = MarriageConstants.getEmoji(h);
                              final translated = _tr(h);
                              return {'label': '$emoji $translated'};
                            }).toList(),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: BioVoiceSection(
                        bioText: answers?.myDescription ?? '',
                        audioPath: answers?.userMedia?.audio ?? '',
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: MessageInputSection(
                        name: user?.name ?? '',
                        personId: user?.id ?? '',
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: BottomActionsSection(
                        onShare: () {
                          DeepLinkService.shareProfile(
                            personId: user?.id ?? '',
                            userName: user?.name ?? '',
                          );
                        },

                        onBlock: () {
                          CustomshowDialogWithImage(
                            context,
                            title: context.tr(AppStrings.blockUser),
                            supTitle: context.tr(
                              AppStrings.blockUserConfirmation,
                            ),
                            icon: Icons.block,
                            bottonText: context.tr(AppStrings.yes),
                            onPressed: () async {
                              cubit.blockUser(personId: user?.id ?? '');

                              if (!mounted) return;
                              if (widget.personId == null) {
                                _resetScrollTracking();
                                scrollToTop();
                              }
                            },
                            showCancelButton: true,
                            cancelText: context.tr(AppStrings.no),
                            onCancel: () => Navigator.pop(context),
                          );
                        },
                        onReport: () {
                          context.pushNamed(
                            AppRouter.kReportsView,
                            arguments: {
                              'type': ReportType.user,
                              'id': user?.id ?? '',
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    sliver: SliverToBoxAdapter(child: _buildVerifiedCard()),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 150.h)),
                ],
              ),
            ),

            // ✅ أزرار Like / Star / Dislike
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              bottom: state.isScrollingDown ? 30.h : 130.h,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: state.isAnimating,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ✅ Like
                    buildCircleButton(
                      onTap: () async {
                        await _showSwipePopup(context, SwipeActionType.like);
                        await cubit.swipeLike(
                          personId: profile.user?.id ?? '',
                          usersLength: users.length,
                          hasSinglePerson: widget.personId != null,
                        );
                        if (widget.personId == null && mounted) {
                          _resetScrollTracking();
                          scrollToTop();
                        }
                      },
                      Icons.check,
                      AppColors.kprimaryTextColor,
                      HexColor('f8d3da'),
                    ),

                    // ✅ Star (regard)
                    buildCircleButton(
                      onTap: () async {
                      
                        cubit.sendRegard(personId: profile.user?.id ?? '');
                      },
                      Icons.star,
                      Colors.white,
                      HexColor('cccab3'),
                    ),

                    // ✅ Dislike
                    buildCircleButton(
                      onTap: () async {
                        await _showSwipePopup(context, SwipeActionType.dislike);
                        await cubit.swipeDislike(
                          personId: profile.user?.id ?? '',
                          usersLength: users.length,
                          hasSinglePerson: widget.personId != null,
                        );
                        if (widget.personId == null && mounted) {
                          _resetScrollTracking();
                          scrollToTop();
                        }
                      },
                      Icons.close,
                      Colors.white,
                      HexColor('e44e6c'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // INTERACTIONS TAB
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInteractionsContent({Key? key, required MarriageState state}) {
    final cubit = context.read<MarriageCubit>();

    return Directionality(
      key: key,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: CustomBackground(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: state.showHistory
                    ? SimpleAppBar(
                        title: context.tr('history'),
                        isLargeTitle: true,
                        onBack: () => cubit.hideHistoryView(),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(child: _buildToggle()),
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                context.pushNamed(
                                  AppRouter.kMarriageFilterView,
                                );
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.black12,
                                child: AppImage(
                                  AssetsData.kfilterIcon,
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            child: GestureDetector(
                              onTap: () {
                                cubit.showHistoryView();
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  Future.delayed(
                                    const Duration(milliseconds: 150),
                                    () =>
                                        _historyKey.currentState?.scrollToTop(),
                                  );
                                });
                              },
                              child: AppImage(
                                AssetsData.archiveIcon,
                                width: 50.w,
                                height: 50.h,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: state.showHistory
                    ? _buildEmbeddedHistory(state)
                    : BlocProvider.value(
                        key: const ValueKey('interaction_body'),
                        value: interactionsCubit,
                        child: InteractionBody(key: _interactionBodyKey),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // EMBEDDED HISTORY
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEmbeddedHistory(MarriageState state) {
    final cubit = context.read<MarriageCubit>();

    return BlocProvider.value(
      key: const ValueKey('history_content'),
      value: interactionsCubit,
      child: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilterChips(
              onFilterChanged: (filterKey) {
                cubit.setHistoryFilter(filterKey);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Future.delayed(
                    const Duration(milliseconds: 100),
                    () => _historyKey.currentState?.scrollToTop(),
                  );
                });
              },
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: Historypage(
                key: _historyKey,
                selectedFilter: state.selectedHistoryFilter,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CIRCLE BUTTON
  // ═══════════════════════════════════════════════════════════════
  Widget buildCircleButton(
    IconData icon,
    Color iconColor,
    Color bgColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28.r,
        backgroundColor: bgColor,
        child: Icon(icon, color: iconColor, size: 30),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SHIMMER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildShimmerScreen() {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: CustomBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _shimmer(height: context.height * 0.9)),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: _shimmer(height: 100)),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: _shimmer(height: 100)),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: _shimmer(height: 150)),
            const SliverToBoxAdapter(child: SizedBox(height: 150)),
          ],
        ),
      ),
    );
  }

  Widget _shimmer({double? height, double? width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height ?? 100,
        width: width ?? double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
