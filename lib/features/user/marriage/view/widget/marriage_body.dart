import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/history_page.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_FilterChips.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_body.dart';
import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart';
import 'package:tayseer/features/user/marriage/view/widget/section_toggle.dart';
import 'package:tayseer/features/user/marriage/view/widget/animated_be_first_button.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_cubit.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/user/marriage/view/widget/about_me.dart';
import 'package:tayseer/features/user/marriage/view/widget/additional_image.dart';
import 'package:tayseer/features/user/marriage/view/widget/bio_voice_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/bottom_actions_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/compatibility.dart';
import 'package:tayseer/features/user/marriage/view/widget/education.dart';
import 'package:tayseer/features/user/marriage/view/widget/interests_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/message_input_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/religious.dart';
import 'package:tayseer/features/user/marriage/view/widget/sliver_profile_header.dart';
import 'package:tayseer/features/user/marriage/view/widget/life_event_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/video_section.dart';

class MarriageBody extends StatefulWidget {
  const MarriageBody({
    super.key,
    this.personId,
    this.fromInteractions = false,
    this.onScroll,
  });
  final String? personId;
  final bool fromInteractions;
  final Function(bool isScrollingDown)? onScroll;

  @override
  State<MarriageBody> createState() => MarriageBodyState();
}

class MarriageBodyState extends State<MarriageBody> {
  final ScrollController _mainScrollController = ScrollController();
  InteractionsCubit? _interactionsCubit;

  final GlobalKey<InteractionBodyState> _interactionBodyKey =
      GlobalKey<InteractionBodyState>();

  // ════════════════════════════════════════════════════
  // ✅ متغيرات الـ Scroll
  // ════════════════════════════════════════════════════
  double _lastOffset = 0;
  double _scrollDelta = 0;
  static const double _scrollThreshold = 20.0;

  // ════════════════════════════════════════════════════
  // ✅ متغيرات الـ History (embedded بدل Navigator.push)
  // ════════════════════════════════════════════════════
  bool _showHistory = false;
  String _selectedHistoryFilter = "liked_you";
  final GlobalKey<HistorypageState> _historyKey = GlobalKey<HistorypageState>();

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
    context.read<MarriageCubit>().fetchMarriageProfile();
  }

  @override
  void dispose() {
    _mainScrollController.removeListener(_scrollListener);
    _mainScrollController.dispose();
    _interactionsCubit?.close();
    super.dispose();
  }

  // ════════════════════════════════════════════════════
  // ✅ Scroll Listener
  // ════════════════════════════════════════════════════
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

      // ✅ إبلاغ الـ Layout بالسكرول (لإخفاء NavBar)
      widget.onScroll?.call(isDown);
      _scrollDelta = 0;
    }

    _lastOffset = currentOffset;
  }

  // ✅ Scroll to Top
  void scrollToTop() {
    if (_mainScrollController.hasClients) {
      _mainScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ✅ Reset scroll tracking
  void _resetScrollTracking() {
    _lastOffset = 0;
    _scrollDelta = 0;
    context.read<MarriageCubit>().setScrollingDown(false);
  }

  Widget _buildToggle() {
    final cubit = context.read<MarriageCubit>();
    return SectionToggle(
      isMarriage: cubit.state.isMarriageTab,
      onChanged: (value) {
        // ✅ لو جاي من التفاعلات وضغط على تاب التفاعلات = ارجع للخلف
        if (!value && widget.fromInteractions) {
          context.pop();
          return;
        }
        // ✅ لو بيرجع من الـ history، ارجع للـ interactions أولاً
        if (_showHistory) {
          setState(() => _showHistory = false);
        }
        cubit.setMarriageTab(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MarriageCubit, MarriageState>(
      listenWhen: (previous, current) =>
          previous.marriageProfileState != current.marriageProfileState ||
          previous.userInteractionState != current.userInteractionState ||
          previous.sendRegardState != current.sendRegardState,
      listener: (context, state) {
        if (state.userInteractionState == CubitStates.failure ||
            state.sendRegardState == CubitStates.failure ||
            state.sendRegardTextState == CubitStates.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.errorMessage ?? 'حدث خطأ ما',
              isError: true,
            ),
          );
          context.read<MarriageCubit>().resetState();
        }

        if (state.sendRegardState == CubitStates.success) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              return AppImage(AssetsData.kSuccessMarriageAnimationsLottie);
            },
          );
          Future.delayed(const Duration(seconds: 4), () {
            context.pop();
          });
          context.read<MarriageCubit>().resetState();
        }
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

        final List<UserItem> allUsers = state.profile?.data?.users ?? [];
        final List<UserItem> users = widget.personId != null
            ? allUsers.where((p) => p.user?.id == widget.personId).toList()
            : allUsers;

        if (users.isEmpty) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: state.isMarriageTab
                ? _buildWithAppBar(
                    key: const ValueKey('empty_marriage'),
                    child: _buildEmptyMarriage(),
                  )
                : _buildInteractionsContent(
                    key: const ValueKey('interactions'),
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
              : _buildInteractionsContent(key: const ValueKey('interactions')),
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
      textDirection: TextDirection.rtl,
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
  // EMPTY MARRIAGE STATE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEmptyMarriage() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(AssetsData.noPersonsBlocked, width: 180.w, height: 180.h),
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

    return Directionality(
      key: key,
      textDirection: TextDirection.rtl,
      child: CustomBackground(
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(position: offsetAnimation, child: child);
              },
              child: CustomScrollView(
                key: ValueKey<int>(profileIndex),
                controller: _mainScrollController,
                slivers: [
                  SliverProfileHeader(
                    reportId: user?.id,
                    images: images,
                    name: user?.name ?? '',
                    age: "🎂 ${answers?.aboutMe?.age ?? ''}",
                    location: user?.country ?? answers?.aboutMe?.country ?? '',
                    tagsjob: "💼 ${user?.about?.job ?? ''}",
                    educationLevel: "🎓 ${user?.about?.educationLevel ?? ''}",
                    religiousCommitment:
                        "🕌 ${user?.about?.religiousCommitment ?? ''}",
                    nationality: "🌍 ${user?.about?.nationality ?? ''}",
                    height: "📏 ${user?.about?.height ?? ''}",
                    toggleWidget: _buildToggle(),
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
                                .map<String>((t) => t.value!)
                                .toList() ??
                            [],
                      ),
                    ),
                  ),
                  if (images.length > 1 && images[1].isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: AdditionalImageSection(
                          personId: user?.id ?? '',
                          imageUrl: images[1],
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
                            {'label': "💍 ${answers!.aboutMe!.socialStatus}"},

                          if (answers?.family?.hasChildren != null)
                            {'label': "👶 ${answers!.family!.hasChildren}"},

                          if (answers?.aboutMe?.weight != null)
                            {'label': "⚖️ ${answers?.aboutMe?.weight} gm"},

                          if (answers?.professionalLife?.job != null)
                            {'label': "💼 ${answers!.professionalLife!.job}"},

                          if (answers?.aboutMe?.healthStatus != null)
                            {'label': "🩺 ${answers!.aboutMe!.healthStatus}"},
                        ],
                      ),
                    ),
                  ),
                  if (images.length > 2 && images[2].isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: AdditionalImageSection(
                          personId: user?.id ?? '',
                          imageUrl: images[2],
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
                                  "🎓 ${answers!.professionalLife!.educationLevel}",
                            },

                          if (answers?.professionalLife?.job != null)
                            {'label': "💼 ${answers!.professionalLife!.job}"},
                        ],
                      ),
                    ),
                  ),
                  if (images.length > 3 && images[3].isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: AdditionalImageSection(
                          personId: user?.id ?? '',
                          imageUrl: images[3],
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: LifeEventsSection(
                        titleName: user?.name ?? '',
                        events: [
                          {
                            'timeLabel': answers?.yourGoals?.marry,
                            'goalLabel': context.tr('marriage_profile'),
                            'isActive': true,
                          },
                          {
                            'timeLabel': answers?.yourGoals?.engagment ?? '',
                            'goalLabel': context.tr('engagement_profile'),
                            'isActive': true,
                          },
                          {
                            'timeLabel': answers?.yourGoals?.children ?? '',
                            'goalLabel': context.tr('children_profile'),
                            'isActive': true,
                          },
                          {
                            'timeLabel': answers?.yourGoals?.travel,
                            'goalLabel': context.tr('travel_profile'),
                            'isActive': true,
                          },
                        ],
                      ),
                    ),
                  ),
                  if (images.isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: AdditionalImageSection(
                          personId: user?.id ?? '',
                          imageUrl: images.first,
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
                                  "🕌 ${answers!.aboutMe!.religiousCommitment}",
                            },

                          if (answers?.aboutMe?.smoker != null)
                            {'label': "🚬 ${answers!.aboutMe!.smoker}"},
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
                  if (images.length > 4 && images[4].isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: AdditionalImageSection(
                          personId: user?.id ?? '',
                          imageUrl: images[4],
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
                        interests: (answers?.hobbies ?? [])
                            .map((h) => {'label': h})
                            .toList(),
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
                        onBlock: () {
                          CustomshowDialogWithImage(
                            context,
                            bottonText: context.tr("send_report"),
                            imageUrl: AssetsData.kWoriningImage,
                            title: context.tr("confirm_report"),
                            supTitle: context.tr("sup_confirm_report"),
                            onPressed: () {},
                            showCancelButton: true,
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
                  SliverToBoxAdapter(child: SizedBox(height: 150.h)),
                ],
              ),
            ),

            // ════════════════════════════════════════════════════
            // ✅ Animated Floating Buttons
            // ════════════════════════════════════════════════════
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              bottom: state.isScrollingDown ? 50.h : 130.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildCircleButton(
                    onTap: () {
                      context.read<MarriageCubit>().userInteraction(
                        personId: profile.user?.id ?? '',
                        interactionType: 'like',
                      );
                      if (widget.personId == null && users.length > 1) {
                        context.read<MarriageCubit>().advanceProfile(
                          usersLength: users.length,
                        );
                        _resetScrollTracking();
                        scrollToTop();
                      }
                    },
                    Icons.favorite_outline,
                    AppColors.kprimaryTextColor,
                    HexColor('f8d3da'),
                  ),
                  buildCircleButton(
                    onTap: () {
                      context.read<MarriageCubit>().sendRegard(
                        personId: profile.user?.id ?? '',
                      );
                    },
                    Icons.star,
                    Colors.white,
                    HexColor('cccab3'),
                  ),
                  buildCircleButton(
                    onTap: () {
                      context.read<MarriageCubit>().userInteraction(
                        personId: profile.user?.id ?? '',
                        interactionType: 'dislike',
                      );
                      if (widget.personId == null && users.length > 1) {
                        context.read<MarriageCubit>().advanceProfile(
                          usersLength: users.length,
                        );
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
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ✅ INTERACTIONS TAB — مع embedded history (بدون Navigator.push)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildInteractionsContent({Key? key}) {
    return Directionality(
      key: key,
      textDirection: TextDirection.rtl,
      child: CustomBackground(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: _showHistory
                    // ══════════════════════════════════════
                    // ✅ AppBar السجل: SimpleAppBar
                    // ══════════════════════════════════════
                    ? SimpleAppBar(
                        title: context.tr('history'),
                        isLargeTitle: true,
                        onBack: () => setState(() => _showHistory = false),
                      )
                    // ══════════════════════════════════════
                    // ✅ AppBar التفاعلات: الأصلي
                    // ══════════════════════════════════════
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
                                setState(() {
                                  _showHistory = true;
                                  _selectedHistoryFilter = "liked_you";
                                });
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

            // ✅ AnimatedSwitcher بين الـ InteractionBody والـ History
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _showHistory
                    ? _buildEmbeddedHistory()
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
  // ✅ EMBEDDED HISTORY — بدون Scaffold أو Navigator
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEmbeddedHistory() {
    return BlocProvider.value(
      key: const ValueKey('history_content'),
      value: interactionsCubit,
      child: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Filter Chips
            FilterChips(
              onFilterChanged: (filterKey) {
                setState(() => _selectedHistoryFilter = filterKey);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Future.delayed(
                    const Duration(milliseconds: 100),
                    () => _historyKey.currentState?.scrollToTop(),
                  );
                });
              },
            ),
            SizedBox(height: 8.h),

            // ✅ History Page — الـ BlocProvider.value فوق بيوصله للـ Historypage
            Expanded(
              child: Historypage(
                key: _historyKey,
                selectedFilter: _selectedHistoryFilter,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
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

  Widget _buildShimmerScreen() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _shimmer(height: context.height * 0.9)),
            SliverToBoxAdapter(child: const SizedBox(height: 20)),
            SliverToBoxAdapter(child: _shimmer(height: 100)),
            SliverToBoxAdapter(child: const SizedBox(height: 20)),
            SliverToBoxAdapter(child: _shimmer(height: 100)),
            SliverToBoxAdapter(child: const SizedBox(height: 20)),
            SliverToBoxAdapter(child: _shimmer(height: 150)),
            SliverToBoxAdapter(child: const SizedBox(height: 150)),
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
