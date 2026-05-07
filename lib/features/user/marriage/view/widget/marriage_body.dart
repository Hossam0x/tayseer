import 'dart:async';
import 'dart:developer';
import 'package:tayseer/core/enum/male_female.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/services/deep_link_service.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/features/shared/view_model/layout_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_state.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/animated_history_button.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/history_page.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_FilterChips.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_body.dart';
import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart';
import 'package:tayseer/features/user/marriage/view/widget/animated_be_first_button.dart';
import 'package:tayseer/features/user/marriage/view/widget/section_toggle.dart';
import 'package:tayseer/features/user/marriage/view/widget/swipe_action_pop_up.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_cubit.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/dash_border.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/regards_purchase_sheet.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/user/marriage/view/widget/about_me.dart';
import 'package:tayseer/features/user/marriage/view/widget/additional_image.dart';
import 'package:tayseer/features/user/marriage/view/widget/bio_voice_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/bottom_actions_section.dart';
import 'package:tayseer/features/user/marriage/view/widget/compatibility.dart';
import 'package:tayseer/features/user/marriage/view/widget/education.dart';
import 'package:tayseer/features/user/marriage/view/widget/interests_section.dart';
import 'package:tayseer/core/constant/marriage_constants.dart';
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
  bool _isActionInProgress = false;
  bool _navHiddenByMarriage = false;
  StreamSubscription? _layoutSubscription;
  bool _isInLayout = false;
  bool _isShowingGoldSheet = false; // ✅ true لو الـ widget جوه الـ UserLayout
  StreamSubscription?
  _subscriptionSubscription; // ✅ للاستماع للتغييرات في الاشتراك

  bool get _isConsultantViewingProfile =>
      widget.personId != null && selectedUserType == UserTypeEnum.asConsultant;

  InteractionsCubit get interactionsCubit {
    if (_interactionsCubit == null) {
      _interactionsCubit = getIt<InteractionsCubit>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _interactionsCubit!.fetchHistorySilently().then((_) {
          if (mounted) setState(() {});
        });
      });
    }
    return _interactionsCubit!;
  }

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(_scrollListener);

    // ✅ جيب الـ notification count فوراً عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      interactionsCubit.fetchAndSyncNotificationCount();
    });

    if (widget.fromInteractions) {
      _interactionsCubit = getIt<InteractionsCubit>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _interactionsCubit!.fetchHistorySilently().then((_) {
          if (mounted) setState(() {});
        });
      });
    }

    final cubit = context.read<MarriageCubit>();

    if (widget.personId != null) {
      cubit.fetchOnlySpecificProfile(widget.personId!);
    } else {
      cubit.fetchMarriageProfile(
        seedFavoriteId: (cubit.seedPersonId != null && cubit.seedIsFavorite)
            ? cubit.seedPersonId
            : null,
      );
    }

    cubit.initAnimation(this);

    // ✅ استمع للتغييرات في الاشتراك
    _subscriptionSubscription = SubscriptionEventBus
        .instance
        .onSubscriptionChanged
        .listen((_) {
          if (!mounted) return;
          cubit.refreshProfile();
        });

    // ✅ لما المستخدم يغير الـ tab ويرجع للـ marriage، reset الـ flag
    // بس لو الـ widget جوه الـ UserLayout (مش route مستقل من التفاعلات)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // تحقق إن LayoutCubit موجود في الـ context
      try {
        final layoutCubit = context.read<LayoutCubit>();
        _isInLayout = true;
        _layoutSubscription = layoutCubit.stream.listen((s) {
          if (!mounted) return;
          if (s.currentIndex != 1) {
            _navHiddenByMarriage = false;
          } else if (s.currentIndex == 1 && !_navHiddenByMarriage) {
            _hideNavOnce();
          }
        });
      } catch (_) {
        // LayoutCubit مش موجود — الـ widget مفتوح كـ route مستقل
        _isInLayout = false;
      }
    });

    if (_isConsultantViewingProfile) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          _showConsultantBlockedDialog();
        });
      });
    }
  }

  String _translateYesNo(
    String value, {
    required String yesKey,
    required String noKey,
  }) {
    final v = value.trim().toLowerCase();
    if (v == 'yes' || v == 'true' || v == '1') {
      return context.tr(yesKey);
    } else if (v == 'no' || v == 'false' || v == '0') {
      return context.tr(noKey);
    }
    return _tr(value);
  }

  void _showConsultantBlockedDialog() {
    CustomshowDialogWithImage(
      context,
      title: context.tr('cannot_do_this_action'),
      supTitle: context.tr('consultant_blocked_msg'),
      imageUrl: AssetsData.kWoriningImage,
      bottonText: context.tr('okay_understood'),
      showCancelButton: false,
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  String _translateCompatibilityValue(String value, String? category) {
    final v = value.trim().toLowerCase();
    final cat = category?.toLowerCase();

    if (v == 'yes' || v == 'true' || v == '1') {
      return switch (cat) {
        'smoker' => context.tr('smoking_yes'),
        'alcohol' ||
        'drinkalcohol' ||
        'drinks_alcohol' => context.tr('drinks_alcohol_yes'),
        'children' ||
        'has_children' ||
        'haschildren' => context.tr('has_childrens'),
        _ => context.tr('yes'),
      };
    }
    if (v == 'no' || v == 'false' || v == '0') {
      return switch (cat) {
        'smoker' => context.tr('smoking_no'),
        'alcohol' ||
        'drinkalcohol' ||
        'drinks_alcohol' => context.tr('drinks_alcohol_no'),
        'children' ||
        'has_children' ||
        'haschildren' => context.tr('has_no_children'),
        _ => context.tr('no'),
      };
    }

    return _tr(value);
  }

  @override
  void dispose() {
    _scrollIdleTimer?.cancel();
    _layoutSubscription?.cancel();
    _subscriptionSubscription?.cancel(); // ✅ إلغاء الاستماع
    _mainScrollController.removeListener(_scrollListener);
    _mainScrollController.dispose();
    super.dispose();
  }

  void _hideNavOnce() {
    if (!_isInLayout) return;
    if (_navHiddenByMarriage) return;
    final layoutCubit = context.read<LayoutCubit>();
    if (layoutCubit.state.currentIndex != 1) return;
    final marriageState = context.read<MarriageCubit>().state;
    final hasUsers =
        marriageState.allUsers.isNotEmpty &&
        marriageState.isMarriageTab &&
        marriageState.marriageProfileState != CubitStates.loading;
    if (!hasUsers) return;
    _navHiddenByMarriage = true;
    layoutCubit.setNavVisibility(false);
  }

  void _showNav() {
    if (!_isInLayout) return;
    if (!_navHiddenByMarriage) return;
    _navHiddenByMarriage = false;
    if (mounted) context.read<LayoutCubit>().setNavVisibility(true);
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

    _scrollIdleTimer?.cancel();
    _scrollIdleTimer = Timer(_scrollIdleDelay, () {
      if (!mounted) return;
      final cubit = context.read<MarriageCubit>();
      if (cubit.state.isScrollingDown) {
        cubit.setScrollingDown(false);
        widget.onScroll?.call(false);
      }
      // ✅ لما يوقف الـ scroll، ظهّر الـ nav
      _showNav();
    });
  }

  Future<void> _syncNotificationAfterInteraction() async {
    await interactionsCubit.fetchAndSyncNotificationCount();

    if (!mounted) return;

    final interactionsState = interactionsCubit.state;
    context.read<MarriageCubit>().syncNotificationCountFromInteractions(
      interactionsState.totalNotificationCount,
      interactionsState.likesNotificationCount,
      interactionsState.favoritesNotificationCount,
      interactionsState.regardsNotificationCount,
    );
  }

  Widget _buildHistoryButton({bool forMarriageTab = false}) {
    return BlocBuilder<InteractionsCubit, InteractionsState>(
      bloc: interactionsCubit,
      buildWhen: (prev, curr) =>
          prev.totalNotificationCount != curr.totalNotificationCount,
      builder: (context, interactionsState) {
        final marriageCubit = context.read<MarriageCubit>();
        return AnimatedHistoryButton(
          notificationCount: interactionsState.totalNotificationCount,
          onTap: forMarriageTab
              ? () => marriageCubit.setMarriageTab(false)
              : () {
                  marriageCubit.showHistoryView();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Future.delayed(
                      const Duration(milliseconds: 150),
                      () => _historyKey.currentState?.scrollToTop(),
                    );
                  });
                },
        );
      },
    );
  }

  List<Map<String, dynamic>> _buildFaithItems(Answers? answers) {
    final faithValue = answers?.faith;
    if (faithValue == null || faithValue.trim().isEmpty) return [];

    final emoji = MarriageConstants.getEmoji(faithValue);
    final translated = _tr(faithValue);
    return [
      {'label': '$emoji $translated'},
    ];
  }

  Future<void> _showSwipePopup(
    BuildContext context,
    SwipeActionType type,
  ) async {
    final overlay = Overlay.of(context);

    final String labelOverride = switch (type) {
      SwipeActionType.like => context.tr('like_action'),
      SwipeActionType.dislike => context.tr('dislike_action'),
      SwipeActionType.favorite => context.tr('favorite_action'),
      SwipeActionType.regard => context.tr('regard_action'),
      SwipeActionType.back => 'رجوع',
    };

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: IgnorePointer(
          child: SwipeActionPopup(type: type, labelOverride: labelOverride),
        ),
      ),
    );

    overlay.insert(entry);
    await Future.delayed(const Duration(milliseconds: 1100));
    entry.remove();
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_isActionInProgress) return;
    _isActionInProgress = true;
    try {
      await action();
    } finally {
      if (mounted) _isActionInProgress = false;
    }
  }

  void _showRegardInputSheet(
    BuildContext context, {
    required MarriageCubit cubit,
    required String personId,
    required String personName,
    bool countView = false,
  }) {
    final controller = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    // ✅ محتوى الـ sheet مشترك بين الـ dialog والـ bottom sheet
    Widget buildContent(BuildContext sheetContext) {
      return Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Directionality.of(context) == TextDirection.rtl
                    ? '${context.tr('messge_profil_title')} $personName'
                    : '$personName ${context.tr('messge_profil_title')}',
                style: Styles.textStyle14Bold,
              ),
              Gap(10.h),
              TextField(
                controller: controller,
                maxLines: 4,
                autofocus: true,
                decoration: InputDecoration(
                  fillColor: HexColor('f9f8ec'),
                  filled: true,
                  hintText: context.tr('type_your_message'),
                  hintStyle: Styles.textStyle12.copyWith(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              Gap(16.h),
              Center(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, value, __) {
                    final enabled = value.text.trim().isNotEmpty;
                    return CustomBotton(
                      backGroundcolor: enabled ? null : AppColors.kgreyColor,

                      useGradient: enabled,
                      title: context.tr('send_reply'),
                      onPressed: enabled
                          ? () {
                              Navigator.pop(sheetContext);
                              cubit.sendRegardText(
                                personId: personId,
                                text: value.text.trim(),
                                countView: countView,
                              );
                            }
                          : null,
                    );
                  },
                ),
              ),
              Gap(20.h),
            ],
          ),
        ),
      );
    }

    if (isTablet) {
      // ✅ iPad: dialog في المنتصف مع background معتم
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            insetPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.2,
              vertical: 40.h,
            ),
            child: SingleChildScrollView(child: buildContent(dialogContext)),
          );
        },
      );
    } else {
      // ✅ موبايل: bottom sheet عادي
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        builder: (sheetContext) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: buildContent(sheetContext),
          );
        },
      );
    }
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
        if (value && _mainScrollController.hasClients) {
          _mainScrollController.jumpTo(0);
          _resetScrollTracking();
        }
        cubit.setMarriageTab(value);
      },
    );
  }

  Widget _buildToggleAppBar(BuildContext context) {
    final bool showBackButton =
        widget.personId != null || _isConsultantViewingProfile;

    return Container(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SizedBox(
            height: 72.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(child: _buildToggle()),
                Positioned(
                  right: 0,
                  child: showBackButton
                      ? GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: CircleAvatar(
                            backgroundColor: Colors.black12,
                            child: AppImage(AssetsData.backArrow, width: 19.w),
                          ),
                        )
                      : GestureDetector(
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
                  child: showBackButton
                      ? const SizedBox.shrink()
                      : AnimatedBeFirstButton(
                          onTap: () {
                            context.pushNamed(AppRouter.kUserPackagesView);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isCurrentProfilePartial(MarriageState state, List<UserItem> users) {
    if (users.isEmpty) return false;
    final idx = state.currentIndex.clamp(0, users.length - 1);
    return users[idx].isPartialData;
  }

  Widget _buildEmptyMarriage(
    MarriageCubit cubit,
    MarriageState state, {
    bool forceShowFilter = false,
  }) {
    final hasActiveFilters = state.activeFilters.isNotEmpty || forceShowFilter;

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        if (hasActiveFilters) {
          await cubit.clearFiltersAndRefresh();
        } else {
          await cubit.refreshProfile();
        }
      },
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
                      hasActiveFilters
                          ? AssetsData.emptyFilter
                          : AssetsData.noPersonsBlocked,
                      width: 180.w,
                      height: 180.h,
                    ),
                    Gap(24.h),
                    if (hasActiveFilters) ...[
                      Text(
                        context.tr('seen_all_recommendations'),
                        style: Styles.textStyle18Bold.copyWith(
                          color: AppColors.kprimaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Gap(12.h),
                      Text(
                        context.tr('try_expanding_filter'),
                        style: Styles.textStyle14.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      Gap(24.h),
                      CustomBotton(
                        title: context.tr('expand_filter'),
                        width: context.width * 0.7,
                        onPressed: () =>
                            context.pushNamed(AppRouter.kMarriageFilterView),
                      ),
                    ] else ...[
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MarriageCubit, MarriageState>(
      listenWhen: (previous, current) =>
          previous.marriageProfileState != current.marriageProfileState ||
          (previous.sendRegardState != current.sendRegardState &&
              current.showActionSnackbar) ||
          (previous.blockActionState != current.blockActionState &&
              current.showActionSnackbar) ||
          (previous.sendRegardTextState != current.sendRegardTextState &&
              current.showActionSnackbar) ||
          (previous.userInteractionState != current.userInteractionState &&
              current.userInteractionState == CubitStates.failure) ||
          (previous.likesLeft != current.likesLeft && current.likesLeft == 0) ||
          (previous.regardsLeft != current.regardsLeft &&
              current.regardsLeft == 0) ||
          (previous.sendRegardTextState != current.sendRegardTextState &&
              current.sendRegardTextState == CubitStates.failure &&
              current.regardsLeft == 0),

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
          previous.isLoadingMore != current.isLoadingMore ||
          previous.userHistory != current.userHistory ||
          previous.activeFilters != current.activeFilters ||
          previous.interactionsNotificationCount !=
              current.interactionsNotificationCount ||
          previous.likesNotificationCount != current.likesNotificationCount ||
          previous.regardsLeft != current.regardsLeft ||
          previous.likesLeft != current.likesLeft,

      listener: (context, state) {
        // ✅ لو regardsLeft وصل 0 — من regard failure فقط
        if (state.regardsLeft == 0) {
          if (state.sendRegardState == CubitStates.failure ||
              state.sendRegardTextState == CubitStates.failure) {
            showRegardsPurchaseSheet(context);
            context.read<MarriageCubit>().resetState();
            return;
          }
        }

        if (state.likesLeft == 0 &&
            state.userInteractionState == CubitStates.failure) {
          final regardsLeft = state.regardsLeft;
          if (!_isShowingGoldSheet) {
            _isShowingGoldSheet = true;
            showGoldPurchaseSheet(
              context,
              onDismiss: () {
                _isShowingGoldSheet = false;
              },
            );
            context.read<MarriageCubit>().resetState();
            if (regardsLeft == 0) {
              context.read<MarriageCubit>().updateLimits(regardsLeft: 0);
            }
          }
          return;
        }

        if ((state.sendRegardState == CubitStates.failure ||
                state.sendRegardTextState == CubitStates.failure) &&
            state.showActionSnackbar &&
            (state.regardsLeft == null || state.regardsLeft != 0)) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.errorMessage ?? context.tr('error_occurred'),
              isError: true,
            ),
          );
          context.read<MarriageCubit>().resetState();
        }

        if ((state.sendRegardState == CubitStates.success ||
                state.sendRegardTextState == CubitStates.success) &&
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

        if (state.blockActionState == CubitStates.success &&
            state.showActionSnackbar) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('user_blocked_successfully'),
              isError: false,
            ),
          );
          context.read<MarriageCubit>().resetState();
        }

        if (state.blockActionState == CubitStates.failure &&
            state.showActionSnackbar) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.blockMessage ?? context.tr('error_occurred'),
              isError: true,
            ),
          );
          context.read<MarriageCubit>().resetState();
        }
      },
      builder: (context, state) {
        if (state.marriageProfileState == CubitStates.loading) {
          // ✅ خلفية فاضية — الـ GIF overlay بيتعرض فوقها من initState
          return _buildLoadingBackground();
        } else if (state.marriageProfileState == CubitStates.failure) {
          return _isConsultantViewingProfile
              ? _buildConsultantErrorScreen(state.errorMessage)
              : _buildWithAppBar(
                  child: CustomErrorView(
                    message: state.errorMessage ?? context.tr('error_occurred'),
                    onRetry: () =>
                        context.read<MarriageCubit>().refreshProfile(),
                  ),
                );
        }

        final List<UserItem> allUsers = state.allUsers;

        if (_isCurrentProfilePartial(state, allUsers)) {
          return _buildLoadingBackground();
        }

        final List<UserItem> users = widget.personId != null
            ? () {
                final filtered = allUsers
                    .where((p) => p.user?.id == widget.personId)
                    .toList();

                if (filtered.isNotEmpty && filtered.first.isPartialData) {
                  return <UserItem>[];
                }

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

        if (widget.personId != null) {
          final targetUser = allUsers
              .where((u) => u.user?.id == widget.personId)
              .firstOrNull;
          if (targetUser != null && targetUser.isPartialData) {
            return _buildLoadingBackground();
          }
        }

        if (users.isEmpty) {
          if (state.isMarriageTab) {
            final subscriptionType =
                (_interactionsCubit ?? getIt<InteractionsCubit>())
                    .state
                    .subscriptionType;
            final isFree =
                subscriptionType == 'free' || subscriptionType.isEmpty;

            return _buildWithAppBar(
              key: const ValueKey('empty_marriage'),
              child: isFree
                  ? _buildEmptyMarriage(
                      context.read<MarriageCubit>(),
                      state,
                      forceShowFilter: true,
                    )
                  : _buildEmptyMarriage(context.read<MarriageCubit>(), state),
            );
          }

          return _buildInteractionsContent(
            key: const ValueKey('interactions'),
            state: state,
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

        if (users[profileIndex].isPartialData) {
          return _buildLoadingBackground();
        }

        if (state.isMarriageTab) {
          // ✅ اخبي الـ nav مرة واحدة بس لما يدخل الـ marriage tab ويلاقي users
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _hideNavOnce();
          });
          return _buildMarriageContent(
            personId: widget.personId ?? "",
            key: const ValueKey('marriage'),
            state: state,
            profileIndex: profileIndex,
            users: users,
          );
        }

        return _buildInteractionsContent(
          key: const ValueKey('interactions'),
          state: state,
        );
      },
    );
  }

  Widget _buildConsultantErrorScreen(String? errorMessage) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: CustomBackground(
        child: SafeArea(
          child: Center(
            child: Text(
              errorMessage ?? context.tr('error_occurred'),
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWithAppBar({Key? key, required Widget child}) {
    final bool showBackButton =
        widget.personId != null || _isConsultantViewingProfile;

    return Directionality(
      key: key,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: CustomBackground(
        child: Column(
          children: [
            SizedBox(
              height: 72.h + MediaQuery.of(context).padding.top,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: 16.w,
                  right: 16.w,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(child: _buildToggle()),
                    Positioned(
                      right: 0,
                      child: showBackButton
                          ? GestureDetector(
                              onTap: () => Navigator.maybePop(context),
                              child: CircleAvatar(
                                backgroundColor: Colors.black12,
                                child: AppImage(
                                  AssetsData.backArrow,
                                  width: 19.w,
                                ),
                              ),
                            )
                          : GestureDetector(
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
                      child: showBackButton
                          ? const SizedBox.shrink()
                          : AnimatedBeFirstButton(
                              onTap: () {
                                context.pushNamed(AppRouter.kUserPackagesView);
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

  Widget _buildVerifiedCard(String? subscriptionType, bool isVerified) {
    final bool isGold = subscriptionType == 'gold';
    final bool isUltra = subscriptionType == 'ultra';
    final bool isPremium = isGold || isUltra;

    // ✅ الكارت الـ free (verified_profile) يظهر بس لو المستخدم verified
    if (!isPremium && !isVerified) return const SizedBox.shrink();

    final Color borderColor = isUltra
        ? const Color(0xFF6284FF).withOpacity(0.5)
        : isGold
        ? const Color(0xFFF4AE00).withOpacity(0.5)
        : const Color(0xFFE91E63).withOpacity(0.4);

    final Color bgColor = isUltra
        ? const Color(0xFFF0F3FF)
        : isGold
        ? const Color(0xFFFFF8E1)
        : const Color(0xFFFFF0F3);

    final String titleKey = isPremium
        ? (isUltra ? 'ultra_profile_title' : 'gold_profile_title')
        : 'verified_profile_title';

    final String descKey = isPremium
        ? (isUltra ? 'ultra_profile_desc' : 'gold_profile_desc')
        : 'verified_profile_desc';

    return CustomPaint(
      painter: DashedBorderPainter(
        color: borderColor,
        strokeWidth: 1.5,
        dashWidth: 6,
        dashSpace: 4,
        borderRadius: 12.r,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              isUltra
                  ? AssetsData.eliteVerIcon
                  : isGold
                  ? AssetsData.goldVerIcon
                  : AssetsData.verIcon,
              height: 80.h,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.tr(titleKey),
                          style: Styles.textStyle16Bold.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isUltra
                                ? const Color(0xFF6284FF)
                                : isGold
                                ? const Color(0xFFF4AE00)
                                : AppColors.primary400,
                          ),
                        ),
                      ),
                      if (isPremium) ...[
                        Gap(6.w),
                        isUltra
                            ? ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        Color(0xFF6284FF),
                                        Color(0xFF9FAEFF),
                                        Color(0xFFF4AE00),
                                      ],
                                    ).createShader(bounds),
                                child: AppImage(
                                  AssetsData.goldIcon,
                                  width: 24.w,
                                  color: Colors.white,
                                ),
                              )
                            : AppImage(AssetsData.goldIcon, width: 24.w),
                      ],
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    context.tr(descKey),
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

  String _getTagEmoji(String? category, String? value) {
    if (category == null) return '✨';

    if (category.toLowerCase() == 'country' ||
        category.toLowerCase() == 'nationality') {
      return CountryFlagUtils.getFlag(value ?? '');
    }

    switch (category.toLowerCase()) {
      case 'religion':
      case 'religious_commitment':
        return '🕌';
      case 'education':
      case 'education_level':
        return '🎓';
      case 'job':
      case 'professional_life':
        return '💼';
      case 'age':
        return '🎂';
      case 'hobby':
      case 'hobbies':
        return '🎯';
      case 'social_status':
      case 'marital_status':
        return '💍';
      case 'children':
      case 'has_children':
      case 'haschildren':
        return '👶';
      case 'height':
        return '📏';
      case 'weight':
        return '⚖️';
      case 'smoker':
        return '🚬';
      case 'travel':
        return '✈️';
      case 'goals':
      case 'marriage_intentions':
        return '💫';
      case 'alcohol':
      case 'drinks_alcohol':
      case 'drinkAlcohol':
        return '🍷';
      default:
        return '✨';
    }
  }

  List<String> _buildCompatibilityTags(List<MatchingTag>? matchingTags) {
    if (matchingTags == null) return [];

    const excludedCategories = {
      'social_status',
      'socialstatus',
      'health_status',
      'healthstatus',
      // ✅ شيل smoker — بيظهر في ReligiousSection
      'smoker',
      // ✅ شيل hasChildren/children — بيظهر في AboutMeSection
      'children',
      'has_children',
      'haschildren',
    };

    final List<String> result = [];

    for (final tag in matchingTags) {
      if (tag.value == null || tag.value!.trim().isEmpty) continue;

      final cat = tag.category?.toLowerCase().replaceAll('_', '') ?? '';
      if (excludedCategories.any((e) => e.replaceAll('_', '') == cat)) continue;

      // ✅ شيل faith من هنا — بيظهر في InterestsSection (choose_faith)
      final values = tag.value!
          .split(',')
          .map((v) => v.trim())
          .where((v) => v.isNotEmpty)
          .toList();

      for (final value in values) {
        if (value.startsWith('faith_')) continue; // ✅ faith في InterestsSection
        if (value.startsWith('interest_')) {
          final emoji = MarriageConstants.getEmoji(value);
          result.add('$emoji ${_tr(value)}');
        } else {
          final translated = _translateCompatibilityValue(value, tag.category);
          result.add('${_getTagEmoji(tag.category, value)} $translated');
        }
      }
    }

    return result;
  }

  Widget _buildMarriageContent({
    Key? key,
    required String personId,
    required MarriageState state,
    required int profileIndex,
    required List<UserItem> users,
  }) {
    final profile = users[profileIndex];
    if (profile.isPartialData) return _buildShimmerScreen();

    final user = profile.user;
    final answers = profile.answers;

    final List<String> validImages = (answers?.userMedia?.image ?? [])
        .where((img) => img.isNotEmpty)
        .toList();

    final String? mainImage = user?.image;
    final bool mainImageAlreadyIncluded =
        mainImage != null && validImages.any((img) => img == mainImage);

    final List<String> displayImages = validImages.isNotEmpty
        ? (mainImageAlreadyIncluded
              ? validImages
              : [if (mainImage != null) mainImage, ...validImages])
        : (mainImage != null ? [mainImage] : []);

    final cubit = context.read<MarriageCubit>();

    final bool isVerifiedUser = widget.fromInteractions
        ? (cubit.interactionUser?.isverified ?? user?.isVerified ?? false)
        : (user?.isVerified ?? false);

    final bool hasNext =
        widget.personId == null && profileIndex + 1 < users.length;

    final nextProfile = hasNext ? users[profileIndex + 1] : null;
    final nextUser = nextProfile?.user;
    final nextAnswers = nextProfile?.answers;

    final List<String> nextValidImages = (nextAnswers?.userMedia?.image ?? [])
        .where((img) => img.isNotEmpty)
        .toList();

    final String? nextMainImage = nextUser?.image;
    final bool nextMainIncluded =
        nextMainImage != null &&
        nextValidImages.any((img) => img == nextMainImage);

    final List<String> nextImages = nextValidImages.isNotEmpty
        ? (nextMainIncluded
              ? nextValidImages
              : [if (nextMainImage != null) nextMainImage, ...nextValidImages])
        : (nextMainImage != null ? [nextMainImage] : []);

    if (nextImages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = screenWidth * 1.5;
        final pixelRatio = MediaQuery.of(context).devicePixelRatio;
        final cacheW = (screenWidth * pixelRatio).toInt();
        final cacheH = (screenHeight * pixelRatio).toInt();
        for (final url in nextImages) {
          precacheImage(
            CachedNetworkImageProvider(
              url,
              maxWidth: cacheW,
              maxHeight: cacheH,
            ),
            context,
          );
        }
      });
    }

    final bool isSubscribed = _interactionsCubit?.state.isSubscribed ?? false;

    final bool shouldBlurImages;
    if (!widget.fromInteractions) {
      shouldBlurImages = user?.imageBlur ?? false;
    } else if (!isSubscribed) {
      shouldBlurImages = true;
    } else {
      shouldBlurImages = cubit.interactionUser?.isImageBlurred ?? false;
    }

    final timelineEvents = answers?.yourGoals != null
        ? _buildTimelineEventsFromAnswers(answers!.yourGoals!)
        : <Map<String, dynamic>>[];

    final bool isViewingSharedProfile = widget.personId != null;
    final bool isSameGender;

    if (selectedGender == Gender.male) {
      final hasHijab =
          answers?.aboutMe?.wearHijab != null &&
          answers!.aboutMe!.wearHijab!.isNotEmpty;
      isSameGender = !hasHijab;
    } else {
      final hasHijab =
          answers?.aboutMe?.wearHijab != null &&
          answers!.aboutMe!.wearHijab!.isNotEmpty;
      isSameGender = hasHijab;
    }

    final bool canInteract;
    if (_isConsultantViewingProfile) {
      canInteract = false;
    } else if (isSameGender && !isViewingSharedProfile) {
      canInteract = false;
    } else {
      canInteract = widget.fromInteractions
          ? true
          : (profile.allowInteractions ?? true);
    }

    final faithItems = _buildFaithItems(answers);

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
                    key: ValueKey(user?.id ?? profileIndex),
                    city: user?.city,
                    distanceKm: user?.distanceKm,
                    isVerified: isVerifiedUser,
                    nextIsVerified: hasNext
                        ? (nextUser?.isVerified ?? false)
                        : null,
                    reportId: user?.id,
                    images: displayImages,
                    name: user?.name ?? '',
                    age: "🎂 ${_tr(answers?.aboutMe?.age)}",
                    location: _tr(user?.country ?? answers?.aboutMe?.country),
                    tagsjob: "💼 ${_tr(user?.about?.job ?? '')}",
                    educationLevel: "🎓 ${_tr(user?.about?.educationLevel)}",
                    religiousCommitment:
                        "🕌 ${_tr(user?.about?.religiousCommitment)}",
                    nationality:
                        "${CountryFlagUtils.getFlag(_tr(user?.about?.nationality))} ${_tr(user?.about?.nationality)}",
                    height: "📏 ${user?.about?.height ?? ''}",
                    toggleWidget: null,
                    showTitleBar: false,
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
                        ? "💼 ${_tr(nextUser?.about?.job ?? '')}"
                        : null,
                    nextEducationLevel: hasNext
                        ? "🎓 ${_tr(nextUser?.about?.educationLevel)}"
                        : null,
                    nextReligiousCommitment: hasNext
                        ? "🕌 ${_tr(nextUser?.about?.religiousCommitment)}"
                        : null,
                    nextNationality: hasNext
                        ? "${CountryFlagUtils.getFlag(_tr(nextUser?.about?.nationality))} ${_tr(nextUser?.about?.nationality)}"
                        : null,
                    nextHeight: hasNext
                        ? "📏 ${nextUser?.about?.height ?? ''}"
                        : null,
                    isFavorited: state.favoritedIds.contains(user?.id ?? ''),
                    subscriptionType: user?.subscriptionType,
                    nextSubscriptionType: hasNext
                        ? nextUser?.subscriptionType
                        : null,
                    recentlyJoined: user?.recentlyJoined ?? false,
                    activeToday: user?.activeToday ?? false,
                    onFavoriteTap: canInteract
                        ? () => _runAction(() async {
                            if (state.requiresSubscription) {
                              showViewLimitPurchaseSheet(context);
                              return;
                            }
                            await _showSwipePopup(
                              context,
                              SwipeActionType.favorite,
                            );
                            await cubit.toggleLocalFavorite(
                              user?.id ?? '',
                              removeFromList:
                                  widget.personId == null &&
                                  !widget.fromInteractions,
                              countView:
                                  widget.personId == null &&
                                  !widget.fromInteractions,
                            );
                            // ✅ لو الـ API فشل بسبب requiresSubscription، اعرض الـ sheet
                            if (mounted && cubit.state.requiresSubscription) {
                              showViewLimitPurchaseSheet(context);
                              return;
                            }
                            await _syncNotificationAfterInteraction();
                            if (widget.fromInteractions && mounted) {
                              context.pop();
                            }
                          })
                        : null,
                  ),

                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Builder(
                        builder: (context) {
                          final subType =
                              (_interactionsCubit ?? getIt<InteractionsCubit>())
                                  .state
                                  .subscriptionType;
                          final isFree = subType == 'free' || subType.isEmpty;
                          return CompatibilitySection(
                            title: context.tr('compatibility_profile'),
                            subtitle: user?.similarity != null
                                ? '${user!.similarity}%'
                                : '',
                            tags: _buildCompatibilityTags(user?.matchingTags),
                            isBlurred: isFree,
                          );
                        },
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
                          if (answers?.aboutMe?.weight != null)
                            {
                              'label':
                                  "⚖️ \u200e${answers?.aboutMe?.weight} ${context.tr('kg')}",
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
                              Directionality.of(context) == TextDirection.rtl
                              ? '${context.tr('goals')} ${user?.name ?? ''}'
                              : '${user?.name ?? ''} ${context.tr('goals')}',
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
                          if (answers?.aboutMe?.smoker != null)
                            {
                              'label':
                                  "🚬 ${_translateYesNo(answers!.aboutMe!.smoker!, yesKey: 'smoking_yes', noKey: 'smoking_no')}",
                            },
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
                            MarriageConstants.parseKeysFromRaw(answers?.hobbies)
                                .where((key) => key.startsWith('interest_'))
                                .map((h) {
                                  final emoji = MarriageConstants.getEmoji(h);
                                  final translated = _tr(h);
                                  return {'label': '$emoji $translated'};
                                })
                                .toList(),
                      ),
                    ),
                  ),

                  if (faithItems.isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: InterestsSection(
                          title: 'choose_faith',
                          interests: faithItems,
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
                      vertical: 20.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: BottomActionsSection(
                        onShare: () {
                          DeepLinkService.shareProfile(
                            context: context,
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

                              if (widget.fromInteractions) {
                                context.pop();
                              } else if (widget.personId == null) {
                                _resetScrollTracking();
                                scrollToTop();
                              }
                            },
                            showCancelButton: true,
                            cancelText: context.tr(AppStrings.no),
                            onCancel: () {},
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
                    sliver: SliverToBoxAdapter(
                      child: _buildVerifiedCard(
                        user?.subscriptionType,
                        isVerifiedUser,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: 150.h)),
                ],
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildToggleAppBar(context),
            ),

            if (!_isConsultantViewingProfile)
              _isInLayout
                  ? BlocBuilder<LayoutCubit, LayoutState>(
                      buildWhen: (p, c) => p.isNavVisible != c.isNavVisible,
                      builder: (context, layoutState) {
                        return _buildButtonsRow(
                          context: context,
                          state: state,
                          cubit: cubit,
                          users: users,
                          profile: profile,
                          canInteract: canInteract,
                          bottom: layoutState.isNavVisible ? 130.h : 30.h,
                        );
                      },
                    )
                  : _buildButtonsRow(
                      context: context,
                      state: state,
                      cubit: cubit,
                      users: users,
                      profile: profile,
                      canInteract: canInteract,
                      bottom: 30.h,
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionsContent({Key? key, required MarriageState state}) {
    final cubit = context.read<MarriageCubit>();
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double topBarHeight = 72.h + statusBarHeight;

    return Directionality(
      key: key,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: CustomBackground(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: topBarHeight,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: statusBarHeight,
                    left: 16.w,
                    right: 16.w,
                  ),
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
                              child: _buildHistoryButton(forMarriageTab: false),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            Positioned(
              top: topBarHeight,
              left: 0,
              right: 0,
              bottom: 0,
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
                cubit.resetNotificationForFilter(filterKey);
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

  Widget _buildButtonsRow({
    required BuildContext context,
    required MarriageState state,
    required MarriageCubit cubit,
    required List<UserItem> users,
    required UserItem profile,
    required bool canInteract,
    required double bottom,
  }) {
    final user = profile.user;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      bottom: bottom,
      left: 0,
      right: 0,
      // ✅ ارتفاع محدد = حجم الـ button بس عشان ميغطيش على الـ content اللي تحته
      height: (28.r * 2) + 16.h,
      child: canInteract
          ? IgnorePointer(
              ignoring: state.isAnimating,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ✅ Like button
                  buildCircleButton(
                    onTap: () => _runAction(() async {
                      if (state.requiresSubscription) {
                        showViewLimitPurchaseSheet(context);
                        return;
                      }
                      if (state.likesLeft == 0) {
                        showGoldPurchaseSheet(context);
                        return;
                      }
                      await _showSwipePopup(context, SwipeActionType.like);
                      if (widget.fromInteractions) {
                        await cubit.userInteraction(
                          personId: user?.id ?? '',
                          interactionType: 'like',
                        );
                        await _syncNotificationAfterInteraction();
                        if (mounted) context.pop();
                      } else {
                        await cubit.swipeLike(
                          personId: user?.id ?? '',
                          usersLength: users.length,
                          hasSinglePerson: widget.personId != null,
                        );
                        if (widget.personId == null && mounted) {
                          _resetScrollTracking();
                          scrollToTop();
                        }
                        await _syncNotificationAfterInteraction();
                      }
                    }),
                    Icons.check,
                    AppColors.kprimaryTextColor,
                    HexColor('f8d3da'),
                  ),
                  // ✅ Regard button
                  buildCircleButton(
                    onTap: () => _runAction(() async {
                      if (state.requiresSubscription) {
                        showViewLimitPurchaseSheet(context);
                        return;
                      }
                      if (state.regardsLeft == 0) {
                        showRegardsPurchaseSheet(context);
                        return;
                      }
                      _showRegardInputSheet(
                        context,
                        cubit: cubit,
                        personId: user?.id ?? '',
                        personName: user?.name ?? '',
                        countView:
                            widget.personId == null && !widget.fromInteractions,
                      );
                      await _syncNotificationAfterInteraction();
                    }),
                    Icons.star,
                    Colors.white,
                    HexColor('cccab3'),
                  ),
                  // ✅ Dislike button
                  buildCircleButton(
                    onTap: () => _runAction(() async {
                      if (state.requiresSubscription) {
                        showViewLimitPurchaseSheet(context);
                        return;
                      }
                      await _showSwipePopup(context, SwipeActionType.dislike);
                      if (widget.fromInteractions) {
                        await cubit.userInteraction(
                          personId: user?.id ?? '',
                          interactionType: 'dislike',
                        );
                        await _syncNotificationAfterInteraction();
                        if (mounted) context.pop();
                      } else {
                        await cubit.swipeDislike(
                          personId: user?.id ?? '',
                          usersLength: users.length,
                          hasSinglePerson: widget.personId != null,
                        );
                        if (widget.personId == null && mounted) {
                          _resetScrollTracking();
                          scrollToTop();
                        }
                      }
                    }),
                    Icons.close,
                    Colors.white,
                    HexColor('e44e6c'),
                  ),
                  // ✅ Back button (only if history exists)
                  if (state.userHistory.isNotEmpty)
                    buildCircleButton(
                      onTap: () => _runAction(() async {
                        final isSubscribed =
                            _interactionsCubit?.state.isSubscribed ?? false;
                        if (!isSubscribed) {
                          showGoldPurchaseSheet(context);
                          return;
                        }
                        await _showSwipePopup(context, SwipeActionType.back);
                        cubit.goBackToPreviousUser();
                        _resetScrollTracking();
                        scrollToTop();
                      }),
                      isArabic
                          ? Icons.subdirectory_arrow_left_outlined
                          : Icons.subdirectory_arrow_right_outlined,
                      Colors.white,
                      flipVertical: true,
                      AppColors.primary200,
                    ),
                ],
              ),
            )
          : IgnorePointer(child: const SizedBox.shrink()),
    );
  }

  Widget buildCircleButton(
    IconData icon,
    Color iconColor,
    Color bgColor, {
    VoidCallback? onTap,
    bool flipVertical = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28.r,
        backgroundColor: bgColor,
        child: Transform(
          alignment: Alignment.center,
          transform: flipVertical
              ? (Matrix4.identity()..scale(1.0, -1.0))
              : Matrix4.identity(),
          child: Icon(icon, color: iconColor, size: 30),
        ),
      ),
    );
  }

  Widget _buildLoadingBackground() {
    // ✅ GIF كـ widget عادي scoped جوه الـ marriage tab بس
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AssetsData.userBGImage, fit: BoxFit.cover),
          Container(color: Colors.white.withOpacity(0.55)),
          Center(
            child: Image.asset(
              AssetsData.kGifOverlayLoading,
              width: 400.w,
              height: 400.w,
            ),
          ),
        ],
      ),
    );
  }

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
