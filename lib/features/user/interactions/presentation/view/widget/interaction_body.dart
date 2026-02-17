import 'package:tayseer/core/widgets/custom_content_switcher.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
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
  final GlobalKey<HistorypageState> _historyKey = GlobalKey<HistorypageState>();

  final ScrollController _mainScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  void handleTabReselect() {
    if (_currentIndex == 0 && selectedTab == context.tr("exploration")) {
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
      child: SafeArea(
        child: Column(
          children: [
            // _buildFixedHeader(),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [_buildExplorationContent(), _buildHistoryContent()],
              ),
            ),
            SizedBox(height: 90.h),
          ],
        ),
      ),
    );
  }

  // ✅ Header with conditional app bar display
  Widget _buildFixedHeader() {
    return Column(
      children: [
        // ✅ AppBar (only show in Exploration view)
        if (_currentIndex == 0) ...[
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: DefaultAppBar(
              trailingWidget: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = 1;
                    selectedTab = "history";
                  });

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _historyKey.currentState?.scrollToTop();
                  });
                },
                child: AppImage(
                  AssetsData.archiveIcon,
                  width: 50.w,
                  height: 50.h,
                ),
              ),
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
          // ✅ العنوان للـ Exploration
          Text(
            context.tr("exploration"),
            style: Styles.textStyle24SemiBold.copyWith(
              color: AppColors.secondary800,
            ),
          ),
        ] else ...[
          // ✅ SimpleAppBar for History view
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: SimpleAppBar(
              title: context.tr("history"),
              isLargeTitle: true,
              onBack: () {
                setState(() {
                  _currentIndex = 0;
                  selectedTab = "exploration";
                });
              },
            ),
          ),
        ],

        SizedBox(height: 10.h),

        // ✅ Filter Chips (بس في History)
        if (_currentIndex == 1)
          FilterChips(
            onFilterChanged: (filterKey) {
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
      ],
    );
  }

  Widget _buildExplorationContent() {
    return BlocBuilder<InteractionsCubit, InteractionsState>(
      builder: (context, state) {
        final bool shouldShowOverlay = _shouldShowSubscriptionOverlay(state);

        return Stack(
          children: [
            Exploration(
              key: _explorationKey,
              mainScrollController: _mainScrollController,
            ),
            if (shouldShowOverlay) const SubscriptionPromptOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildHistoryContent() {
    return Historypage(key: _historyKey, selectedFilter: selectedFilter);
  }

  bool _shouldShowSubscriptionOverlay(InteractionsState state) {
    if (state.isSubscribed) return false;
    if (!state.answerCompleted) return false;
    if (state.explorationState == CubitStates.loading &&
        state.explorationData.isEmpty) {
      return false;
    }
    if (state.explorationState == CubitStates.failure &&
        state.explorationData.isEmpty) {
      return false;
    }
    final hasData = state.explorationData.values.any((list) => list.isNotEmpty);
    if (!hasData) return false;
    return true;
  }
}
