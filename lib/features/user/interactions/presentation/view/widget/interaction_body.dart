import 'package:tayseer/core/widgets/custom_content_switcher.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_state.dart';
import 'package:tayseer/features/user/interactions/presentation/view/subscription_prompt_overlay.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/default_appbar.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/exploration_page.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/history_page.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_FilterChips.dart';
import 'package:tayseer/my_import.dart';

class InteractionBody extends StatefulWidget {
  const InteractionBody({super.key});

  @override
  State<InteractionBody> createState() => InteractionBodyState();
}

class InteractionBodyState extends State<InteractionBody> {
  int _currentIndex = 0;
  String selectedTab = "";
  String selectedFilter = "";

  final GlobalKey<ExplorationState> _explorationKey =
      GlobalKey<ExplorationState>();
  final GlobalKey<HistorypageState> _historyKey =
      GlobalKey<HistorypageState>(); // ✅ Key للـ History

  // ✅ ScrollController للصفحة بالكامل
  final ScrollController _mainScrollController = ScrollController();
 @override
  void initState() {
    super.initState();
    // ✅ Initialize with empty strings, will be set in first build
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Set initial values when context is available
    if (selectedTab.isEmpty) {
      selectedTab = context.tr("exploration");
    }
    if (selectedFilter.isEmpty) {
      selectedFilter = context.tr("liked_you");
    }
  }
  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  // ✅ دالة للتعامل مع إعادة الضغط على التاب
  void handleTabReselect() {
    if (_currentIndex == 0 && selectedTab == context.tr("exploration")) {
      // Scroll to top الصفحة كلها
      if (_mainScrollController.hasClients) {
        _mainScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InteractionsCubit, InteractionsState>(
      listener: (context, state) {
        if (state.actionState == CubitStates.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.actionMessage ?? context.tr("follow_success"),
              isSuccess: true,
            ),
          );
          context.read<InteractionsCubit>().resetActionState();
        } else if (state.actionState == CubitStates.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.actionMessage ?? context.tr("error_occurred"),
              isSuccess: false,
            ),
          );
          context.read<InteractionsCubit>().resetActionState();
        }
      },
      child: CustomBackground(
        assetsData: AssetsData.userBGImage,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildExplorationWithHeader(),
                    _buildHistoryWithHeader(),
                  ],
                ),
              ),
              SizedBox(height: 90.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplorationWithHeader() {
    return BlocBuilder<InteractionsCubit, InteractionsState>(
      builder: (context, state) {
        // ✅ Check if we should show the overlay
        final bool shouldShowOverlay = _shouldShowSubscriptionOverlay(state);

        return Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: DefaultAppBar(
                    title: context.tr("interactions"),
                    leadingWidget: GestureDetector(
                      onTap: () {
                        context.pushNamed(AppRouter.kMarriageFilterView);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        color: Colors.transparent,
                        child: SvgPicture.asset(
                          AssetsData.kfilterIcon,
                          width: 22.w,
                          height: 22.h,
                          color: AppColors.secondary600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                ContentSwitcher(
                 selectedOption: context.tr(selectedTab),
                  options: [
                    context.tr("exploration"), // ✅ "استكشاف" or "Exploration"
                    context.tr("history"),
                  ],
                  onOptionSelected: (String selectedOption) {
                    setState(() {
                      if (selectedOption.trim() == context.tr("exploration")) {
                        selectedTab = "exploration";
                        _currentIndex = 0;
                      } else {
                        selectedTab = "history";
                        _currentIndex = 1;
                      }
                    
                    });
                  },
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: Exploration(
                    key: _explorationKey,
                    mainScrollController: _mainScrollController,
                  ),
                ),
              ],
            ),

            // ✅ Only show overlay when conditions are met
            if (shouldShowOverlay) const SubscriptionPromptOverlay(),
          ],
        );
      },
    );
  }

  // ✅ Helper method to determine if overlay should be shown
  bool _shouldShowSubscriptionOverlay(InteractionsState state) {
    // Don't show if user is subscribed
    if (state.isSubscribed) return false;

    // Don't show if profile is incomplete (answerCompleted = false)
    if (!state.answerCompleted) return false;

    // Don't show if loading
    if (state.explorationState == CubitStates.loading &&
        state.explorationData.isEmpty) {
      return false;
    }

    // Don't show if there's an error
    if (state.explorationState == CubitStates.failure &&
        state.explorationData.isEmpty) {
      return false;
    }

    // Don't show if there's no data
    final hasData = state.explorationData.values.any((list) => list.isNotEmpty);
    if (!hasData) return false;

    // Show overlay: user is not subscribed AND has valid data to display
    return true;
  }
Widget _buildHistoryWithHeader() {
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.only(right: 10.w),
        child: DefaultAppBar(
          title: context.tr("interactions"),
          leadingWidget: GestureDetector(
            onTap: () {
              context.pushNamed(AppRouter.kMarriageFilterView);
            },
            child: Container(
              padding: EdgeInsets.all(10.w),
              color: Colors.transparent,
              child: SvgPicture.asset(
                AssetsData.kfilterIcon,
                width: 22.w,
                height: 22.h,
                color: AppColors.secondary600,
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: 10.h),

      // ✅ FIX: Use translated strings here too!
      ContentSwitcher(
       selectedOption: context.tr(selectedTab),
        options: [
          context.tr("exploration"),  // ✅ NOT "استكشاف  "
          context.tr("history"),       // ✅ NOT " السجل "
        ],
        onOptionSelected: (String selectedOption) {
          setState(() {
            // ✅ تحويل الترجمة إلى مفتاح
              if (selectedOption.trim() == context.tr("exploration")) {
                selectedTab = "exploration";
                _currentIndex = 0;
              } else {
                selectedTab = "history";
                _currentIndex = 1;
              }
          });

          if (selectedTab == context.tr("exploration")) {  // ✅ Use translated
            WidgetsBinding.instance.addPostFrameCallback((_) {
              handleTabReselect();
            });
          }
        },
      ),

     FilterChips(
          onFilterChanged: (filterKey) { // ✅ استقبال المفتاح
            setState(() {
              selectedFilter = filterKey;
            });


          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 100), () {
              _historyKey.currentState?.scrollToTop();
            });
          });
        },
      ),

      Expanded(
        child: Historypage(
          key: _historyKey,
          selectedFilter: selectedFilter,
        ),
      ),
    ],
  );
}
}
